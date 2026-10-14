import { execFileSync } from "node:child_process";
import { setTimeout as sleep } from "node:timers/promises";

const forkRepository = "pattobrien/tinycast";
const releaseTagPattern = /^v(\d+)\.(\d+)\.(\d+)(?:-beta\.(\d+))?$/;
const workflow = "release-fork.yml";
const stableOutranksEveryBeta = Number.MAX_SAFE_INTEGER;
const workflowRunPollAttempts = 12;

type ReleaseTag = { name: string; commit: string; precedence: number[] };

function run(command: string, args: string[]): string {
  return execFileSync(command, args, { encoding: "utf8" }).trim();
}

function fail(message: string): never {
  console.error(`fork-release: ${message}`);
  process.exit(1);
}

function parseArguments(argv: string[]): { dryRun: boolean } {
  const unknown = argv.filter((argument) => argument !== "--dry-run");
  if (unknown.length > 0) fail(`unknown argument ${unknown.join(" ")}; only --dry-run is accepted`);
  return { dryRun: argv.includes("--dry-run") };
}

function remoteTagCommits(remote: string, pattern: string): Map<string, string> {
  const commits = new Map<string, string>();
  const lines = run("git", ["ls-remote", "--tags", remote, pattern]).split("\n").filter(Boolean);
  for (const line of lines) {
    const [commit, ref] = line.split("\t");
    const name = ref.replace("refs/tags/", "");
    if (name.endsWith("^{}")) commits.set(name.slice(0, -3), commit);
    else if (!commits.has(name)) commits.set(name, commit);
  }
  return commits;
}

function precedenceOf(match: RegExpMatchArray): number[] {
  const [, major, minor, patch, beta] = match;
  return [Number(major), Number(minor), Number(patch), beta ? Number(beta) : stableOutranksEveryBeta];
}

function comparePrecedence(left: number[], right: number[]): number {
  const differing = left.findIndex((part, index) => part !== right[index]);
  return differing === -1 ? 0 : left[differing] - right[differing];
}

function newestUpstreamTag(head: string): ReleaseTag {
  const history = new Set(run("git", ["rev-list", head]).split("\n"));
  const candidates: ReleaseTag[] = [];
  for (const [name, commit] of remoteTagCommits("upstream", "refs/tags/v*")) {
    const match = name.match(releaseTagPattern);
    if (match && history.has(commit)) candidates.push({ name, commit, precedence: precedenceOf(match) });
  }
  candidates.sort((left, right) => comparePrecedence(right.precedence, left.precedence));
  return candidates[0] ?? fail("no upstream release tag is reachable from HEAD");
}

function nextForkNumber(upstreamTag: string): number {
  const forkTagPattern = new RegExp(`^${upstreamTag.replaceAll(".", "\\.")}-fork\\.(\\d+)$`);
  const taken = [...remoteTagCommits("origin", `refs/tags/${upstreamTag}-fork.*`).keys()]
    .map((name) => name.match(forkTagPattern)?.[1])
    .filter((number) => number !== undefined)
    .map(Number);
  return Math.max(0, ...taken) + 1;
}

function assertReleasableCheckout(): string {
  const branch = run("git", ["rev-parse", "--abbrev-ref", "HEAD"]);
  if (branch !== "main") fail(`on branch ${branch}; cut a fork release from main`);
  const dirty = run("git", ["status", "--porcelain"]);
  if (dirty) fail(`the working tree is not clean:\n${dirty}`);
  const head = run("git", ["rev-parse", "HEAD"]);
  const remoteMain = run("git", ["ls-remote", "origin", "refs/heads/main"]).split("\t")[0];
  if (head !== remoteMain) fail(`HEAD ${head} is not origin/main ${remoteMain}; pull or push first`);
  return head;
}

async function workflowRunURL(tag: string): Promise<string> {
  for (let attempt = 0; attempt < workflowRunPollAttempts; attempt++) {
    const runs: { url: string }[] = JSON.parse(
      run("gh", [
        "run", "list", "-R", forkRepository, "--workflow", workflow, "--branch", tag,
        "--limit", "1", "--json", "url",
      ]),
    );
    if (runs[0]) return runs[0].url;
    await sleep(5_000);
  }
  return fail(`${tag} was pushed but no ${workflow} run started for it within a minute`);
}

const { dryRun } = parseArguments(process.argv.slice(2));
const head = assertReleasableCheckout();
const upstream = newestUpstreamTag(head);
const tag = `${upstream.name}-fork.${nextForkNumber(upstream.name)}`;
console.log(`upstream base: ${upstream.name} (${upstream.commit.slice(0, 8)})`);

if (dryRun) {
  console.log(`would tag ${head.slice(0, 8)} as ${tag} and push it to origin`);
  console.log(tag);
  process.exit(0);
}

run("git", ["tag", "--annotate", tag, "--message", `Tinycast ${tag.slice(1)}`, head]);
run("git", ["push", "origin", `refs/tags/${tag}`]);
console.log(tag);

console.log(await workflowRunURL(tag));
