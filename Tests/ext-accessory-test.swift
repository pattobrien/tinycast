import Foundation

/// Only `RenderNode.arguments(from:)` reaches for the runtime, and this harness never runs JS.
enum ExtensionRuntime {
    static func jsonArray(from json: String) -> [Any] { [] }
}

enum ExtensionCatalog {
    static func safeName(_ name: String) -> String { name }
}

enum ExtensionPreferenceValue: Equatable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case application(String)
}

struct ExtensionPreferenceSchema {
    let name: String
    let required: Bool
    let effectiveDefault: ExtensionPreferenceValue

    var displayTitle: String { name }

    func runtimeValue(_ stored: ExtensionPreferenceValue?) -> ExtensionPreferenceValue? {
        stored ?? effectiveDefault
    }
}

@main
@MainActor
struct ExtensionSearchAccessoryTests {
    static var failures = 0
    static var passes = 0

    static func main() {
        parsing()
        seeding()
        searchContract()
        pickerChosen()
        searchBarAccessories()
        storageIsolation()
        print(failures == 0 ? "\nALL PASSED" : "\n\(failures) FAILED")
        print("\(passes) passed, \(failures) failed")
        exit(failures == 0 ? 0 : 1)
    }

    static func node(_ json: String) -> RenderNode {
        let wrapped = """
            {"children":[{"id":1,"type":"__screen","props":{"active":true},"children":[\(json)]}]}
            """
        guard let tree = RenderTree(json: wrapped), let root = tree.activeRoot else {
            fatalError("test tree did not decode")
        }
        return root
    }

    /// The shape the Visual Studio Code extension ships: items inside an untitled section.
    static let listJSON = """
        {"id":2,"type":"List","props":{
            "searchBarAccessory":{"id":9,"type":"List.Dropdown","props":{
                "tooltip":"Filter project types","defaultValue":"All Types","storeValue":true,
                "onChange":{"$fn":"9:onChange"}},"children":[
                {"id":10,"type":"List.Dropdown.Item","props":{
                    "title":"All Types","value":"All Types"},"children":[]},
                {"id":11,"type":"List.Dropdown.Section","props":{},"children":[
                    {"id":12,"type":"List.Dropdown.Item","props":{
                        "title":"Folders","value":"Folders",
                        "icon":{"source":"folder-16"}},"children":[]},
                    {"id":13,"type":"List.Dropdown.Item","props":{
                        "title":"Workspaces","value":"Workspaces"},"children":[]}]}]}},
            "children":[]}
        """

    /// Same dropdown with no props at all: nothing to seed it from but its own first choice.
    static let bareJSON = """
        {"id":2,"type":"List","props":{
            "searchBarAccessory":{"id":9,"type":"List.Dropdown","props":{},"children":[
                {"id":10,"type":"List.Dropdown.Item","props":{
                    "title":"One","value":"one"},"children":[]},
                {"id":11,"type":"List.Dropdown.Item","props":{
                    "title":"Two","value":"two"},"children":[]}]}},
            "children":[]}
        """

    static func parse(_ json: String) -> ExtensionSearchAccessory? {
        ExtensionSearchAccessory(node: node(json).node("searchBarAccessory"))
    }

    static func formJSON(_ linkProps: String) -> String {
        """
        {"id":2,"type":"Form","props":{
            "searchBarAccessory":{"id":5,"type":"Form.LinkAccessory","props":{\(linkProps)},
                "children":[]}},
            "children":[]}
        """
    }

    static func searchBarAccessories() {
        func accessory(_ json: String) -> ExtensionSearchBarAccessory? {
            ExtensionSearchBarAccessory(node: node(json).node("searchBarAccessory"))
        }
        let link = formJSON(
            #""target":"https://linear.app/settings/api","text":"Get API key","#
                + #""onTinycastOpen":{"$fn":"5:onTinycastOpen"}"#)
        guard case .link(let parsed) = accessory(link) else {
            check("a Form.LinkAccessory parses as a link", false)
            return
        }
        check("a Form.LinkAccessory parses as a link", true)
        check("the link keeps its target", parsed.target == "https://linear.app/settings/api")
        check("the link keeps its text", parsed.text == "Get API key")
        check("the link opens through the runtime", parsed.onOpen == "5:onTinycastOpen")

        let untitled = formJSON(
            #""target":"raycast://extensions/raycast/raycast/search","#
                + #""onTinycastOpen":{"$fn":"5:onTinycastOpen"}"#)
        guard case .link(let bare) = accessory(untitled) else {
            check("a link without text still parses", false)
            return
        }
        check(
            "a link without text reads as its target",
            bare.text == "raycast://extensions/raycast/raycast/search", bare.text)

        let targetless = formJSON(
            #""text":"Get API key","onTinycastOpen":{"$fn":"5:onTinycastOpen"}"#)
        check("a link with no target is no accessory", accessory(targetless) == nil)
        let empty = formJSON(
            #""target":"","text":"Get API key","onTinycastOpen":{"$fn":"5:onTinycastOpen"}"#)
        check("a link with an empty target is no accessory", accessory(empty) == nil)
        let inert = formJSON(#""target":"https://linear.app","text":"Linear""#)
        check("a link the runtime cannot open is no accessory", accessory(inert) == nil)

        guard case .dropdown(let dropdown) = accessory(listJSON) else {
            check("a List.Dropdown parses as a dropdown", false)
            return
        }
        check("a List.Dropdown parses as a dropdown", dropdown.nodeID == 9)
        check(
            "a List root is no accessory", ExtensionSearchBarAccessory(node: node(listJSON)) == nil)
        check("no node is no accessory", ExtensionSearchBarAccessory(node: nil) == nil)
    }

    static func parsing() {
        guard let accessory = parse(listJSON) else {
            check("a dropdown parses", false)
            return
        }
        check("a dropdown parses", true)
        check("node id kept", accessory.nodeID == 9)
        check("onChange handle kept", accessory.onChange == "9:onChange")
        check("defaultValue kept", accessory.defaultValue == "All Types")
        check(
            "storeValue names a storage key", accessory.storageKey == "searchBarAccessory",
            accessory.storageKey ?? "nil")
        check(
            "items flatten in order, section carried",
            accessory.items.map { "\($0.value)|\($0.section ?? "-")" }
                == ["All Types|-", "Folders|-", "Workspaces|-"],
            accessory.items.map(\.value).joined(separator: ","))
        check("an item's icon survives", accessory.item(for: "Folders")?.iconValue != nil)
        check("a title resolves from a value", accessory.title(for: "Folders") == "Folders")
        check("a value no item claims still reads as itself", accessory.title(for: "x") == "x")
        check("the held choice is the row the list opens on", accessory.index(of: "Workspaces") == 2)
        check("an unheld choice opens on the first row", accessory.index(of: "Gone") == 0)

        check("a List root is not a dropdown", ExtensionSearchAccessory(node: node(listJSON)) == nil)
        let grid = listJSON.replacingOccurrences(of: "List.Dropdown", with: "Grid.Dropdown")
            .replacingOccurrences(of: "\"type\":\"List\"", with: "\"type\":\"Grid\"")
        check("a Grid dropdown parses too", parse(grid)?.items.count == 3)

        guard let bare = parse(bareJSON) else {
            check("a bare dropdown parses", false)
            return
        }
        check("a bare dropdown parses", true)
        check("without storeValue nothing is persisted", bare.storageKey == nil)
        check("without a value the extension controls nothing", bare.controlledValue == nil)

        let controlled = bareJSON.replacingOccurrences(
            of: "\"props\":{}", with: "\"props\":{\"value\":\"two\"}")
        check("a value prop is the extension's own", parse(controlled)?.controlledValue == "two")
    }

    /// Which choice a dropdown lands on before anyone has touched it.
    static func seeding() {
        guard let accessory = parse(listJSON), let bare = parse(bareJSON) else {
            check("the seeding fixtures parse", false)
            return
        }
        check("defaultValue seeds it", accessory.initialValue(stored: nil) == "All Types")
        check(
            "a stored pick wins while it still names an item",
            accessory.initialValue(stored: "Folders") == "Folders")
        check(
            "a stale stored pick falls back to defaultValue",
            accessory.initialValue(stored: "Gone") == "All Types")
        check(
            "with nothing to go on it starts on the first choice",
            bare.initialValue(stored: nil) == "one", bare.initialValue(stored: nil) ?? "nil")
        check(
            "an empty dropdown seeds nothing",
            ExtensionSearchAccessory(
                node: node(
                    """
                    {"id":2,"type":"List","props":{"searchBarAccessory":{
                        "id":9,"type":"List.Dropdown","props":{},"children":[]}},"children":[]}
                    """
                ).node("searchBarAccessory"))?.initialValue(stored: nil) == nil)
    }

    static func contract(_ props: String) -> ExtensionSearchContract {
        ExtensionSearchContract(
            node: node(#"{"id":7,"type":"Form.Dropdown","props":{\#(props)},"children":[]}"#))
    }

    static func admitted(_ contract: ExtensionSearchContract, _ query: String) -> [String] {
        let filter = contract.filter(for: query)
        return ["Apple", "Banana", "Cherry"].filter { filter.admits([$0]) }
    }

    /// Raycast's `SearchBarInterface` defaults, the same for a dropdown as for a List.
    static func searchContract() {
        let handler = #""onSearchTextChange":{"$fn":"7:onSearchTextChange"}"#
        let bare = contract("")
        check("no handler filters locally", bare.filtersLocally == true)
        check("no handler names none", bare.textHandler == nil)
        check("isLoading defaults to false", bare.isLoading == false)

        let searched = contract(handler)
        check("a handler turns local filtering off", searched.filtersLocally == false)
        check(
            "the handler is kept", searched.textHandler == "7:onSearchTextChange",
            searched.textHandler ?? "nil")
        check(
            "filtering: true filters beside a handler",
            contract(handler + #","filtering":true"#).filtersLocally == true)
        check(
            "the object form counts as filtering",
            contract(handler + #","filtering":{"keepSectionOrder":false}"#).filtersLocally == true)
        check(
            "filtering: false holds without a handler",
            contract(#""filtering":false"#).filtersLocally == false)
        check("isLoading is read", contract(#""isLoading":true"#).isLoading == true)
        check(
            "the inert contract filters nothing",
            ExtensionSearchContract.inert.filtersLocally == false)

        check(
            "a local query narrows", admitted(bare, " ban ") == ["Banana"],
            "\(admitted(bare, " ban "))")
        check(
            "a blank query admits every choice",
            admitted(bare, "   ") == ["Apple", "Banana", "Cherry"])
        check(
            "an extension-owned query admits every choice",
            admitted(searched, "ban") == ["Apple", "Banana", "Cherry"])
        check("a query nothing matches admits none", admitted(bare, "zzz") == [])
    }

    /// What a closed picker reads once a search has replaced the choices under its value.
    static func pickerChosen() {
        let alice = ExtensionPickerItem(value: "alice", title: "Alice")
        let bob = ExtensionPickerItem(value: "bob", title: "Bob")
        func titles(_ values: [String], remembered: [ExtensionPickerItem]) -> [String] {
            ExtensionPickerItem.chosen(values, in: [alice], remembered: remembered).map(\.title)
        }
        check("a live choice resolves", titles(["alice"], remembered: []) == ["Alice"])
        check(
            "a choice the search dropped keeps its title",
            titles(["bob"], remembered: [bob]) == ["Bob"])
        check(
            "the live choice wins over a remembered one",
            titles(["alice"], remembered: [ExtensionPickerItem(value: "alice", title: "Old")])
                == ["Alice"])
        check("an unknown value reads as itself", titles(["zed"], remembered: []) == ["zed"])
        check(
            "several values keep their order",
            titles(["bob", "alice"], remembered: [bob]) == ["Bob", "Alice"])
        check("nothing chosen resolves to nothing", titles([], remembered: [bob]) == [])
    }

    static func storageIsolation() {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("tinycast-ext-accessory-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: directory) }
        let storage = ExtensionStorage(directory: directory)
        storage.setLocalStorage(extension: "sample", key: "filter", value: .string("extension-data"))
        storage.setAccessoryValue(extension: "sample", key: "filter", value: "selected")
        storage.setPreference(
            extension: "sample", key: "editor", value: .application("/Applications/Editor.app"))
        check(
            "a pick never lands in the namespace JavaScript reads",
            storage.localStorageValue(extension: "sample", key: "filter") == .string("extension-data"))
        check(
            "a pick reads back on its own",
            storage.accessoryValue(extension: "sample", key: "filter") == "selected")
        storage.flush()

        let reloaded = ExtensionStorage(directory: directory)
        check(
            "a pick survives a reload",
            reloaded.accessoryValue(extension: "sample", key: "filter") == "selected")
        check(
            "an app picker persists as its path",
            reloaded.preference(extension: "sample", key: "editor")
                == .string("/Applications/Editor.app"))

        // A store written before dropdowns held anything: the missing key must cost nothing.
        storage.setLocalStorage(extension: "older", key: "kept", value: .string("value"))
        storage.setPreference(extension: "older", key: "token", value: .string("secret"))
        storage.flush()
        let file = directory.appendingPathComponent("older.json")
        if var older = (try? Data(contentsOf: file))
            .flatMap({ try? JSONSerialization.jsonObject(with: $0) as? [String: Any] })
        {
            older.removeValue(forKey: "accessoryValues")
            if let data = try? JSONSerialization.data(withJSONObject: older) {
                try? data.write(to: file)
            }
        }
        let older = ExtensionStorage(directory: directory)
        check(
            "a store with no accessory section keeps its localStorage",
            older.localStorageValue(extension: "older", key: "kept") == .string("value"))
        check(
            "a store with no accessory section keeps its preferences",
            older.preference(extension: "older", key: "token") == .string("secret"))
    }

    static func check(_ label: String, _ condition: Bool, _ detail: String = "") {
        if condition {
            passes += 1
            print("ok    \(label)")
        } else {
            failures += 1
            print("FAIL  \(label)\(detail.isEmpty ? "" : " — \(detail)")")
        }
    }
}
