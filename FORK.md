# pattobrien/tinycast

This repository is a fork of [abue-ammar/tinycast](https://github.com/abue-ammar/tinycast). It builds
its own signed app with GitHub Actions and publishes it as GitHub Releases, so the fork can be
installed over the upstream app without building it locally.

Current upstream base: `v0.11.21-beta.120`.

## What this fork carries

- A Micro interface size sized like the VS Code command palette,
  [#1](https://github.com/pattobrien/tinycast/pull/1). No upstream PR.
- Appearance overrides that tune any palette design token from `settings.json`,
  [#2](https://github.com/pattobrien/tinycast/pull/2). No upstream PR.
- Palette placement over the frame a deeplink names,
  [#3](https://github.com/pattobrien/tinycast/pull/3). No upstream PR.
- Room windows resolved by command, and rooms entered from their `tinycast://window-room` link,
  [#4](https://github.com/pattobrien/tinycast/pull/4). No upstream PR.
- Extension form fields with Raycast's search, link and alert contracts,
  [#5](https://github.com/pattobrien/tinycast/pull/5). No upstream PR.
- `AppVersion` parses a `-fork.N` suffix and orders a fork build just above the upstream version it
  was cut from. Required for every fork version; without it the app cannot read its own version and
  never checks for updates. No upstream PR.
- The fork release workflow `.github/workflows/release-fork.yml`, the preview workflow
  `.github/workflows/build.yml`, the shared build action `.github/actions/build-app`,
  `Scripts/fork-release.ts`, and this file.

Remove an item from this list once upstream ships an equivalent and a sync brings it in.

## Releases

A fork tag is `v<upstream>-fork.N`, where `<upstream>` is the newest upstream release tag reachable
from the tagged commit. For example, tag `v0.11.21-beta.120-fork.1` publishes the release
`Tinycast 0.11.21-beta.120 (fork build 1)` with the assets `Tinycast-0.11.21-beta.120-fork.1.dmg`
and `Tinycast-0.11.21-beta.120-fork.1.zip`. N counts up within one upstream base, starts again at 1
after a sync moves the base, and never reuses a number that has a tag.

Tinycast commits no version. The tag alone carries it: the workflow passes it to `xcodebuild` as
`MARKETING_VERSION`, with the run number as the build number. Every fork build is named `Tinycast`
with bundle id `com.tinycast.app` and signed with the `Tinycast Self-Signed` identity, the same as
upstream's stable channel, so it replaces an installed copy and keeps its data and permission grants.

The workflow fails unless the newest upstream tag reachable from the tagged commit equals the
`<upstream>` part of the tag. It publishes the release marked as latest, with generated notes since
the previous fork tag. Upstream's `release.yml` is dispatch-only, so a fork tag never starts it.

## Runners and the build cache

Both workflows run on the Namespace runner profile `mac`, a 6 CPU Apple silicon machine on the
`goldengate` image (macOS 27 with Xcode 26.6), and build through `.github/actions/build-app`. The
action mounts the Namespace cache volume tagged `tinycast-xcode` and turns on the Xcode 26
compilation cache, so a build after the first one compiles only what changed since the cache was
last written. The build log prints the hit and miss counts.

A cache tag keeps one newest generation, written by whichever machine with it mounted exits last,
so every tag has a single kind of writer. `tinycast-xcode` is written only by the Release builds in
CI. The `agent-cache` job of every preview run builds Debug on its own tag, `tinycast-xcode-agent`,
and that is the tag an agent machine attaches with
`nsc create --volume cache:tinycast-xcode-agent:/Volumes/cache:50GB`. An agent machine that is
destroyed writes its own generation back to that tag, and the next preview run refreshes it. A
machine created within about a minute of a commit to the tag can fork an empty volume while the
new generation is still spreading; its first build is then cold.

## Previews

Every pull request from this repository gets a `Build` run that produces the same signed app the
release would, versioned as the next fork build, and uploads `Tinycast-<version>.dmg` and `.zip` as
a run artifact. The run comments on the pull request with a link to the artifact. Install it the
same way as a release; it replaces the installed Tinycast and keeps its grants. Pull requests from
other forks skip the run, because they cannot read the signing secrets.

## Cutting a release

From the main checkout, on `main`, with a clean tree that matches `origin/main`:

```sh
node Scripts/fork-release.ts --dry-run
node Scripts/fork-release.ts
```

The script reads the upstream and fork tags from the remotes, creates the annotated tag
`v<upstream>-fork.N` on `HEAD`, pushes it to `origin`, and prints the tag and the URL of the workflow
run the push started. `--dry-run` prints the tag it would create and changes nothing.

To publish an existing fork tag again, run the workflow by hand with the `version` input:

```sh
gh workflow run release-fork.yml -R pattobrien/tinycast -f version=<upstream>-fork.N
```

It rebuilds the tagged commit and replaces the release's assets, title and notes.

## Installing

1. Download `Tinycast-<version>.zip` from the
   [latest release](https://github.com/pattobrien/tinycast/releases/latest).
2. Quit Tinycast, then replace the app:

   ```sh
   ditto -xk Tinycast-<version>.zip /tmp/tinycast-fork
   rm -rf /Applications/Tinycast.app
   mv /tmp/tinycast-fork/Tinycast.app /Applications/
   open /Applications/Tinycast.app
   ```

The signing identity is the same as the build it replaces, so Accessibility and other grants persist.

The in-app updater still reads releases from abue-ammar/tinycast, so it can offer an upstream stable
release newer than the fork's base. Accepting it replaces the fork build with upstream's.

## Syncing from upstream

The upstream remote is `https://github.com/abue-ammar/tinycast`.

1. Create a branch from `main`.
2. Merge upstream into the branch:

   ```sh
   git fetch upstream
   git merge --no-ff upstream/main
   ```

3. Open a PR into `main` and merge it with a merge commit.
4. Update the upstream base line at the top of this file in the same PR.

Never rebase or force-push `main` or any pushed branch.
