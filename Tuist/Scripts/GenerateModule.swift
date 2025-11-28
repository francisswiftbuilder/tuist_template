import Foundation

enum LayerType: String, CaseIterable {
	case feature = "Feature"
	case domain = "Domain"
	case data = "Data"
	case core = "Core"
	case shared = "Shared"

	init?(number: Int) {
		switch number {
		case 1: self = .feature
		case 2: self = .domain
		case 3: self = .data
		case 4: self = .core
		case 5: self = .shared
		default: return nil
		}
	}
}

enum MicroTargetType: String {
	case interface = "Interface"
	case sources = "Sources"
	case testing = "Testing"
	case tests = "Tests"
	case example = "Example"
}

enum ExtensionType: String {
	case widget = "Widget"
	case notificationService = "NotificationService"
	case intents = "Intents"

	init?(number: Int) {
		switch number {
		case 1: self = .widget
		case 2: self = .notificationService
		case 3: self = .intents
		default: return nil
		}
	}
}

let fileManager = FileManager.default
let currentPath = fileManager.currentDirectoryPath + "/"
let bash = Bash()

// MARK: - IO
@discardableResult
func ask(_ prompt: String) -> String {
	print(prompt, terminator: " : ")
	return (readLine() ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
}

// MARK: - Scaffold
func makeDirectory(path: String) {
	try? fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
}

func makeProjectDirectory(layer: LayerType, module: String) {
	makeDirectory(path: currentPath + "Projects/\(layer.rawValue)/\(module)")
}

func makeScaffold(target: MicroTargetType, layer: LayerType, module: String) {
	_ = try? bash.run(
		commandName: "tuist",
		arguments: ["scaffold", target.rawValue, "--name", module, "--layer", layer.rawValue]
	)
}

func makeExtensionScaffold(type: ExtensionType, module: String) {
	switch type {
	case .widget, .intents:
		_ = try? bash.run(
			commandName: "tuist",
			arguments: ["scaffold", type.rawValue, "--name", module]
		)
	case .notificationService:
		_ = try? bash.run(
			commandName: "tuist",
			arguments: ["scaffold", type.rawValue]
		)
	}
}

func listBody(_ items: [String]) -> String {
	let lastSuffix = items.count > 1 ? "," : ""
	return items.enumerated()
		.map { "\t\t\($0.element)\($0.offset == items.count - 1 ? lastSuffix : ",")" }
		.joined(separator: "\n")
}

func makeProjectFile(layer: LayerType, module: String, hasTests: Bool, hasExample: Bool) {
	let projectFilePath = currentPath + "Projects/\(layer.rawValue)/\(module)/Project.swift"
	guard !fileManager.fileExists(atPath: projectFilePath) else {
		print("ℹ️ Project.swift already exists. Skipping file generation.")
		return
	}

	let projectName = "\(layer.rawValue)\(module)"
	let targetPrefix = layer.rawValue.lowercased()
	var targets = [".\(targetPrefix)\(module)", ".\(targetPrefix)\(module)Interface"]
	if hasTests {
		targets.append(contentsOf: [
			".\(targetPrefix)\(module)Tests",
			".\(targetPrefix)\(module)Testing",
		])
	}
	if layer == .feature && hasExample {
		targets.append(".\(targetPrefix)\(module)Example")
	}

	let targetsBlock = listBody(targets)

	var schemeVars: [String] = []
	if layer == .feature && hasExample {
		schemeVars.append(".example\(module)Scheme")
	}
	if hasTests {
		schemeVars.append(".\(targetPrefix)\(module)TestsScheme")
	}

	let schemesBlock: String = {
		guard !schemeVars.isEmpty else { return "\tschemes: []" }
		return "\tschemes: [\n" + listBody(schemeVars) + "\n\t]"
	}()

	let fileContents = """
		import ProjectDescription
		import ProjectDescriptionHelpers

		let project = Project(
		\tname: \"\(projectName)\",
		\toptions: .options(
		\t\tautomaticSchemesOptions: .disabled,
		\t\ttextSettings: .textSettings(
		\t\t\tusesTabs: true,
		\t\t\tindentWidth: 2,
		\t\t\ttabWidth: 2
		\t\t)
		\t),
		\tsettings: .settings(
		\t\tbase: baseSettings,
		\t\tconfigurations: configurations
		\t),
		\ttargets: [
		\(targetsBlock)
		\t],
		\(schemesBlock)
		)
		"""

	do {
		try (fileContents + "\n").write(toFile: projectFilePath, atomically: true, encoding: .utf8)
		print("🆕 Created Project.swift at Projects/\(layer.rawValue)/\(module)")
	} catch {
		print("⚠️ Failed to write Project.swift: \(error)")
	}
}

func registerExtension() {
	let typeInput = ask("\n1.Widget \n2.NotificationService \n3.Intents\nEnter extension number ")
	guard
		let typeInt = Int(typeInput),
		let type = ExtensionType(number: typeInt)
	else {
		print("Invalid extension type")
		exit(1)
	}

	let module: String
	switch type {
	case .widget:
		module = ask("Enter widget name")
		guard !module.isEmpty else {
			print("Empty widget name")
			exit(1)
		}
	case .intents:
		module = ask("Enter intents extension name")
		guard !module.isEmpty else {
			print("Empty intents extension name")
			exit(1)
		}
	case .notificationService:
		module = type.rawValue
	}

	makeExtensionScaffold(type: type, module: module)

	print("------------------------------------------------------------------")
	print("Extension: \(type.rawValue)")
	print("Module: \(module)")
	print("✅ Extension scaffold completed.")
	print("ℹ️ Targets land in the App project via `appProjectTargets`.")
	print("ℹ️ Embed it by adding `.appExtension(implements:)` to `appDependencies`.")
	print("------------------------------------------------------------------")
}

func registerModule() {
	let layerInput: String = ask(
		"\n1.Feature \n2.Domain \n3.Data \n4.Core \n5.Shared \n6.AppExtension\nEnter layer number ")
	if layerInput == "6" {
		registerExtension()
		return
	}
	guard
		let layerInt = Int(layerInput),
		let layer = LayerType(number: layerInt)
	else {
		print("Invalid layer")
		exit(1)
	}
	let module = ask("Enter module name")
	guard !module.isEmpty else {
		print("Empty module")
		exit(1)
	}
	let hasTests = ask("Has Tests? (y/n, default n)").lowercased() == "y"
	let hasExample = (layer == .feature) && ask("Has Example? (y/n, default n)").lowercased() == "y"

	makeProjectDirectory(layer: layer, module: module)
	makeScaffold(target: .interface, layer: layer, module: module)
	makeScaffold(target: .sources, layer: layer, module: module)
	if hasTests {
		makeScaffold(target: .testing, layer: layer, module: module)
		makeScaffold(target: .tests, layer: layer, module: module)
	}
	if hasExample {
		makeScaffold(target: .example, layer: layer, module: module)
	}

	makeProjectFile(layer: layer, module: module, hasTests: hasTests, hasExample: hasExample)

	print("------------------------------------------------------------------")
	print("Layer: \(layer.rawValue)")
	print("Module: \(module)")
	print("Tests: \(hasTests), Example: \(hasExample)")
	print("✅ Module scaffold completed.")
	print("------------------------------------------------------------------")
}

registerModule()

// MARK: - Bash
protocol CommandExecuting {
	func run(commandName: String, arguments: [String]) throws -> String
}
enum BashError: Error { case commandNotFound(name: String) }
struct Bash: CommandExecuting {
	func run(commandName: String, arguments: [String] = []) throws -> String {
		try run(resolve(commandName), with: arguments)
	}
	private func resolve(_ command: String) throws -> String {
		guard let which = try? run("/bin/bash", with: ["-l", "-c", "which \(command)"]) else {
			throw BashError.commandNotFound(name: command)
		}
		return which.trimmingCharacters(in: .whitespacesAndNewlines)
	}
	private func run(_ command: String, with arguments: [String]) throws -> String {
		let p = Process()
		p.launchPath = command
		p.arguments = arguments
		let pipe = Pipe()
		p.standardOutput = pipe
		p.launch()
		let data = pipe.fileHandleForReading.readDataToEndOfFile()
		return String(decoding: data, as: UTF8.self)
	}
}
