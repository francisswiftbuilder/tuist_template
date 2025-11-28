import Foundation

// MARK: - Constants

private let modulesSwiftPath = "Tuist/ProjectDescriptionHelpers/Modules.swift"
private let generationDir = "Tuist/ProjectDescriptionHelpers/.generated/Targets"
private let targetsAggregateFile = "Tuist/ProjectDescriptionHelpers/Targets.swift"

private let bundlePrefixesFile = "Tuist/ProjectDescriptionHelpers/BundlePrefixes.swift"
private let dependenciesFile = "Tuist/ProjectDescriptionHelpers/Dependencies.swift"
private let infoPlistsFile = "Tuist/ProjectDescriptionHelpers/InfoPlists.swift"
private let settingsFile = "Tuist/ProjectDescriptionHelpers/Settings.swift"
private let scriptsFile = "Tuist/ProjectDescriptionHelpers/Scripts.swift"
private let coreDataModelsFile = "Tuist/ProjectDescriptionHelpers/CoreDataModels.swift"
private let environmentFile = "Tuist/ProjectDescriptionHelpers/Environment.swift"
private let permissionsFile = "Tuist/ProjectDescriptionHelpers/Permissions.swift"

private let fm = FileManager.default

// MARK: - Layer

private enum Layer: String {
	case app = "App"
	case appExtension = "AppExtension"
	case feature = "Feature"
	case domain = "Domain"
	case data = "Data"
	case core = "Core"
	case shared = "Shared"

	var enumName: String { rawValue }
	var dirName: String {
		switch self {
		case .app: return "Projects"
		default: return "Projects/\(rawValue)"
		}
	}
}

private let layers: [Layer] = [.app, .appExtension, .feature, .domain, .data, .core, .shared]

// MARK: - Utilities

private func lowercasedFirst(_ s: String) -> String {
	guard let f = s.first else { return s }
	return f.lowercased() + s.dropFirst()
}

private struct ModuleRef {
	let layer: Layer
	let caseIdent: String
	let caseRaw: String
	let group: String?
}

// MARK: - Parse Modules.swift

private func parseModulesSwift(at path: String) -> [ModuleRef] {
	guard let text = try? String(contentsOfFile: path, encoding: .utf8) else { return [] }
	var results: [ModuleRef] = []
	var currentLayer: Layer?
	var groupStack: [String] = []
	let lines = text.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
	let enumRegex = try! NSRegularExpression(pattern: #"\benum\s+([A-Za-z0-9_]+)\b"#)

	for line in lines {
		let trimmed = line.trimmingCharacters(in: .whitespaces)
		if let m = enumRegex.firstMatch(
			in: trimmed, range: NSRange(location: 0, length: trimmed.utf16.count))
		{
			let nameRange = Range(m.range(at: 1), in: trimmed)!
			let name = String(trimmed[nameRange])
			if name == "Module", trimmed.contains("ModuleAppType") {
				currentLayer = .app
				groupStack.removeAll()
				continue
			}
			if let layer = layers.first(where: { $0.enumName == name }) {
				currentLayer = layer
				groupStack.removeAll()
				continue
			}
			if currentLayer == .appExtension {
				groupStack.append(name)
				continue
			}
			currentLayer = nil
			groupStack.removeAll()
			continue
		}

		if currentLayer != nil {
			if trimmed.hasPrefix("case ") {
				let afterCase = trimmed.dropFirst(5).trimmingCharacters(in: .whitespaces)
				let comps = afterCase.split(separator: "=", maxSplits: 1).map {
					$0.trimmingCharacters(in: .whitespaces)
						.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
				}
				let ident = String(comps[0])
				let raw = comps.count > 1 ? String(comps[1]) : ident
				let group = groupStack.last
				results.append(.init(layer: currentLayer!, caseIdent: ident, caseRaw: raw, group: group))
			}
			if trimmed == "}" {
				if !groupStack.isEmpty {
					groupStack.removeLast()
				} else {
					currentLayer = nil
				}
			}
		}
	}
	return results
}

// MARK: - Kinds

private enum TargetKind { case implementation, interface, example, tests, testing }

private func existingKinds(for layer: Layer, module: ModuleRef) -> [TargetKind] {
	let base: String
	if layer == .appExtension, let g = module.group {
		base = "Projects/AppExtension/\(g)/\(module.caseRaw)"
	} else {
		base = "\(layer.dirName)/\(module.caseRaw)"
	}
	var kinds: [TargetKind] = []
	if fm.fileExists(atPath: base + "/Sources") { kinds.append(.implementation) }
	if fm.fileExists(atPath: base + "/Interface") { kinds.append(.interface) }
	if fm.fileExists(atPath: base + "/Example") { kinds.append(.example) }
	if fm.fileExists(atPath: base + "/Tests") { kinds.append(.tests) }
	if fm.fileExists(atPath: base + "/Testing") { kinds.append(.testing) }
	return kinds
}

// MARK: - Naming

private func targetVarName(layerLower: String, moduleIdent: String, group: String?) -> String {
	if layerLower == "app", moduleIdent.lowercased() == "app" { return layerLower }
	if let g = group { return layerLower + g + moduleIdent }
	return layerLower + moduleIdent
}

private func moduleEnumAccess(_ layer: Layer, moduleIdent: String) -> String {
	".\(lowercasedFirst(moduleIdent))"
}

// MARK: - Roles

private enum TargetRole {
	case implementation, interface, tests, testing, example

	var invocationLabel: String {
		switch self {
		case .implementation: return "implements"
		case .interface: return "interface"
		case .tests: return "tests"
		case .testing: return "testing"
		case .example: return "example"
		}
	}
	var varSuffix: String {
		switch self {
		case .implementation: return ""
		case .interface: return "Interface"
		case .tests: return "Tests"
		case .testing: return "Testing"
		case .example: return "Example"
		}
	}
}

private func roles(from kinds: [TargetKind]) -> [TargetRole] {
	var r: [TargetRole] = []
	if kinds.contains(.implementation) { r.append(.implementation) }
	if kinds.contains(.interface) { r.append(.interface) }
	if kinds.contains(.tests) { r.append(.tests) }
	if kinds.contains(.testing) { r.append(.testing) }
	if kinds.contains(.example) { r.append(.example) }
	return r
}

// MARK: - Factory fragment

private func makeFactoryLines(varName: String) -> [String] {
	[
		"factory: .init(",
		"\tdestinations: .\(varName)Destinations,",
		"\tbundlePrefix: .\(varName)BundlePrefix,",
		"\tdeploymentTargets: .\(varName)DeploymentTargets,",
		"\tinfoPlist: .\(varName)InfoPlist,",
		"\tscripts: .\(varName)TargetScripts,",
		"\tdependencies: .\(varName)Dependencies,",
		"\tsettings: .\(varName)Settings,",
		"\tcoreDataModels: .\(varName)CoreDataModels",
		")",
	]
}

private func indent(_ lines: [String], by levels: Int) -> [String] {
	let pad = String(repeating: "\t", count: levels)
	return lines.map { pad + $0 }
}

// MARK: - Block assembly

private struct TargetBlocks {
	let targetDecl: String
	let referenceDecl: String?
}

private func buildBlocks(
	role: TargetRole,
	baseVarName: String,
	targetFuncName: String,
	depFuncName: String,
	moduleAccessExpr: String
) -> TargetBlocks {
	let varName = baseVarName + role.varSuffix
	let label = role.invocationLabel

	var t: [String] = []
	t.append("\tpublic static var \(varName): Target {")
	t.append("\t\t.\(targetFuncName)(")
	t.append("\t\t\t\(label): \(moduleAccessExpr),")
	t.append(contentsOf: indent(makeFactoryLines(varName: varName), by: 3))
	t.append("\t\t)")
	t.append("\t}")

	let ref = [
		"\tpublic static var \(varName): TargetReference {",
		"\t\t.\(depFuncName)(",
		"\t\t\t\(label): \(moduleAccessExpr)",
		"\t\t)",
		"\t}",
	].joined(separator: "\n")

	return .init(
		targetDecl: t.joined(separator: "\n"),
		referenceDecl: ref)
}

// MARK: - Per-module emission

private func emitCombinedFile(layer: Layer, module: ModuleRef, kinds: [TargetKind]) -> String {
	let moduleIdent = module.caseIdent
	let targetFuncName: String = {
		if layer == .appExtension {
			return module.group.map(lowercasedFirst) ?? lowercasedFirst(module.caseIdent)
		}
		return lowercasedFirst(layer.enumName)
	}()
	let depFuncName = lowercasedFirst(layer.enumName)
	let baseVarName = targetVarName(
		layerLower: lowercasedFirst(layer.enumName),
		moduleIdent: moduleIdent,
		group: module.group
	)
	let moduleAccessExpr = moduleEnumAccess(layer, moduleIdent: moduleIdent)
	let rs = roles(from: kinds)

	var targetParts: [String] = []
	var refParts: [String] = []

	for r in rs {
		let b = buildBlocks(
			role: r,
			baseVarName: baseVarName,
			targetFuncName: targetFuncName,
			depFuncName: depFuncName,
			moduleAccessExpr: moduleAccessExpr
		)
		targetParts.append(b.targetDecl)
		if let rf = b.referenceDecl { refParts.append(rf) }
	}

	if targetParts.isEmpty { return "" }

	var out: [String] = []
	out.append("// AUTO-GENERATED. DO NOT EDIT.")
	out.append("// Generated by SyncTargets.swift")
	out.append("import Foundation")
	out.append("import ProjectDescription")
	out.append("import TargetPlugin")
	out.append("")
	out.append("extension Target {")
	out.append(targetParts.joined(separator: "\n\n"))
	out.append("}")
	out.append("")
	out.append("extension TargetReference {")
	out.append(refParts.joined(separator: "\n\n"))
	out.append("}")
	out.append("")
	return out.joined(separator: "\n")
}

// MARK: - Headers

private func commonHeader(_ name: String) -> [String] {
	[
		"// AUTO-GENERATED. DO NOT EDIT.",
		"// \(name) generated by SyncTargets.swift",
	]
}

// MARK: - Aggregate

private func emitTargetsAggregate(targetNames: [String], appProjectTargetNames: [String]) -> String
{
	var l: [String] = []
	l.append(contentsOf: commonHeader("Targets Aggregate"))
	l.append("import Foundation")
	l.append("import ProjectDescription")
	l.append("import TargetPlugin")
	l.append("")
	l.append("public let targets: [Target] = [")
	for (i, n) in targetNames.enumerated() {
		let c = i == targetNames.count - 1 ? "" : ","
		l.append("\t.\(n)\(c)")
	}
	l.append("]")
	l.append("")
	l.append("public let appProjectTargets: [Target] = [")
	for (i, n) in appProjectTargetNames.enumerated() {
		let c = i == appProjectTargetNames.count - 1 ? "" : ","
		l.append("\t.\(n)\(c)")
	}
	l.append("]")
	l.append("")
	l.append("public extension Destinations {")
	for n in targetNames {
		l.append("\tstatic var \(n)Destinations: Destinations { environment.destinations }")
	}
	l.append("}")
	l.append("")
	l.append("public extension DeploymentTargets {")
	for n in targetNames {
		l.append(
			"\tstatic var \(n)DeploymentTargets: DeploymentTargets { environment.deploymentTargets }")
	}
	l.append("}")
	l.append("")
	l.append("public protocol TargetDependencies {")
	for n in targetNames { l.append("\tstatic var \(n)Dependencies: [TargetDependency] { get }") }
	l.append("}")
	l.append("")
	l.append("public extension TargetDependencies {")
	for n in targetNames { l.append("\tstatic var \(n)Dependencies: [TargetDependency] { [] }") }
	l.append("}")
	l.append("")
	l.append("public protocol InfoPlists {")
	for n in targetNames { l.append("\tstatic var \(n)InfoPlist: InfoPlist { get }") }
	l.append("}")
	l.append("")
	l.append("public extension InfoPlists {")
	for n in targetNames {
		l.append("\tstatic var \(n)InfoPlist: InfoPlist { .extendingDefault(with: [:]) }")
	}
	l.append("}")
	l.append("")
	l.append("public protocol BundlePrefixes {")
	for n in targetNames { l.append("\tstatic var \(n)BundlePrefix: String { get }") }
	l.append("}")
	l.append("")
	l.append("public extension BundlePrefixes {")
	for n in targetNames {
		l.append("\tstatic var \(n)BundlePrefix: String { environment.organizationName }")
	}
	l.append("}")
	l.append("")
	l.append("public protocol TargetSettings {")
	for n in targetNames { l.append("\tstatic var \(n)Settings: Settings? { get }") }
	l.append("}")
	l.append("")
	l.append("public extension TargetSettings {")
	for n in targetNames { l.append("\tstatic var \(n)Settings: Settings? { nil }") }
	l.append("}")
	l.append("")
	l.append("public protocol TargetScripts {")
	for n in targetNames { l.append("\tstatic var \(n)TargetScripts: [TargetScript] { get }") }
	l.append("}")
	l.append("")
	l.append("public extension TargetScripts {")
	for n in targetNames { l.append("\tstatic var \(n)TargetScripts: [TargetScript] { [] }") }
	l.append("}")
	l.append("")
	l.append("public protocol CoreDataModels {")
	for n in targetNames { l.append("\tstatic var \(n)CoreDataModels: [CoreDataModel] { get }") }
	l.append("}")
	l.append("")
	l.append("public extension CoreDataModels {")
	for n in targetNames { l.append("\tstatic var \(n)CoreDataModels: [CoreDataModel] { [] }") }
	l.append("}")
	l.append("")
	return l.joined(separator: "\n")
}

// MARK: - Editable support file emitters (first generation)

private func emitDependenciesFile() -> String {
	[
		"// AUTO-GENERATED File (first generation). You may edit.",
		"// Customize target dependency arrays per target variable name.",
		"import ProjectDescription",
		"",
		"extension Array: TargetDependencies where Element == TargetDependency {",
		"\t// Override static vars like `appDependencies` in another file if desired.",
		"}",
		"",
	].joined(separator: "\n")
}

private func emitInfoPlistsFile() -> String {
	[
		"// AUTO-GENERATED File (first generation). You may edit.",
		"// Provide custom InfoPlist definitions per target.",
		"import ProjectDescription",
		"",
		"extension InfoPlist: InfoPlists {",
		"\t// Example override:",
		"\t// public static var appInfoPlist: InfoPlist {",
		"\t//   .extendingDefault(with: [\"UILaunchStoryboardName\": .string(\"LaunchScreen\")])",
		"\t// }",
		"}",
		"",
	].joined(separator: "\n")
}

private func emitBundlePrefixesFile() -> String {
	[
		"// AUTO-GENERATED File (first generation). You may edit.",
		"// Set bundle prefixes per target. Uses `environment.organizationName` by default.",
		"import Foundation",
		"",
		"extension String: BundlePrefixes {",
		"\t// public static var appBundlePrefix: String { \"com.example.app\" }",
		"}",
		"",
	].joined(separator: "\n")
}

private func emitSettingsFile() -> String {
	[
		"// AUTO-GENERATED File (first generation). You may edit.",
		"// Provide Settings overrides (e.g. compiler flags) per target.",
		"import ProjectDescription",
		"import ConfigurationPlugin",
		"",
		"public let baseSettings: SettingsDictionary = [",
		"\t\"CODE_SIGN_STYLE\": \"Automatic\",",
		"\t\"DEVELOPMENT_TEAM\": {DEV_TEAM},",
		"\t\"CLANG_ENABLE_MODULES\": \"YES\",",
		"\t\"CLANG_ENABLE_MODULE_VERIFIER\": \"YES\",",
		"\t\"CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES\": \"YES\",",
		"\t\"ENABLE_USER_SCRIPT_SANDBOXING\": \"YES\",",
		"\t\"ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS\": \"YES\"",
		"]",
		"",
		"extension Settings: TargetSettings {",
		"\t// public static var appSettings: Settings? {",
		"\t//   .settings(base: [\"SWIFT_OPTIMIZATION_LEVEL\": \"-Onone\"], configurations: [])",
		"\t// }",
		"}",
		"",
	].joined(separator: "\n")
}

private func emitScriptsFile() -> String {
	[
		"// AUTO-GENERATED File (first generation). You may edit.",
		"// Add build / post scripts per target.",
		"import ProjectDescription",
		"",
		"extension Array: TargetScripts where Element == TargetScript {",
		"\t// public static var appTargetScripts: [TargetScript] {",
		"\t//   [ .pre(script: \"echo PreBuild\", name: \"PreBuild\") ]",
		"\t// }",
		"}",
		"",
	].joined(separator: "\n")
}

private func emitCoreDataModelsFile() -> String {
	[
		"// AUTO-GENERATED File (first generation). You may edit.",
		"// Register CoreDataModel entries if needed.",
		"import ProjectDescription",
		"",
		"extension Array: CoreDataModels where Element == CoreDataModel {",
		"\t// public static var appCoreDataModels: [CoreDataModel] {",
		"\t//   [ .coreDataModel(path: \"Projects/App/Resources/Model.xcdatamodeld\") ]",
		"\t// }",
		"}",
		"",
	].joined(separator: "\n")
}

private func emitEnvironmentFile() -> String {
	[
		"// AUTO-GENERATED File (first generation). You may edit.",
		"// Defines shared environment values used by generation scripts & build settings.",
		"import EnvironmentPlugin",
		"",
		"nonisolated(unsafe) public let environment = ProjectEnvironment(",
		"\tname: {NAME},",
		"\torganizationName: {ORG_NAME},",
		"\tdestinations: [.iPhone, .iPad],",
		"\tdeploymentTargets: .iOS(\"15.0\"),",
		"\tbaseSetting: baseSettings",
		")",
	].joined(separator: "\n")
}

private func emitPermissionsFile() -> String {
	[
		"// AUTO-GENERATED File (first generation). You may edit.",
		"// Centralize TargetPermissionConfiguration definitions per target.",
		"import ProjectDescription",
		"import TargetPlugin",
		"",
		"public enum Permissions {",
		"\t// public static let app = TargetPermissionConfiguration(",
		"\t//   required: [.camera],",
		"\t//   optional: []",
		"\t// )",
		"}",
		"",
	].joined(separator: "\n")
}

// MARK: - IO

private func writeFile(_ path: String, content: String) throws {
	let dir = (path as NSString).deletingLastPathComponent
	if !fm.fileExists(atPath: dir) {
		try fm.createDirectory(atPath: dir, withIntermediateDirectories: true)
	}
	try content.write(toFile: path, atomically: true, encoding: .utf8)
}

private func writeIfNotExists(path: String, content: String) throws {
	if !fm.fileExists(atPath: path) {
		try writeFile(path, content: content)
	}
}

// MARK: - Cleanup

private func cleanGenerationDir() {
	guard generationDir.contains(".generated/Targets") else {
		fputs("⚠️ Skip cleanup (safety check failed)\n", stderr)
		return
	}
	if fm.fileExists(atPath: generationDir) {
		for item in (try? fm.contentsOfDirectory(atPath: generationDir)) ?? [] {
			let p = (generationDir as NSString).appendingPathComponent(item)
			try? fm.removeItem(atPath: p)
		}
	} else {
		try? fm.createDirectory(atPath: generationDir, withIntermediateDirectories: true)
	}
}

// MARK: - Run

private func run() {
	let modules = parseModulesSwift(at: modulesSwiftPath)
	if modules.isEmpty {
		fputs("ℹ️ No modules.\n", stderr)
		return
	}

	cleanGenerationDir()

	var allTargetNames: [String] = []
	var appProjectTargetNames: [String] = []
	for m in modules {
		let kinds = existingKinds(for: m.layer, module: m)
		if kinds.isEmpty { continue }

		let fileBase: String = {
			if m.layer == .app {
				return "\(generationDir)/Target+\(m.layer.rawValue).swift"
			} else if m.layer == .appExtension, let g = m.group {
				return "\(generationDir)/Target+\(m.layer.rawValue)\(g)\(m.caseIdent).swift"
			} else {
				return "\(generationDir)/Target+\(m.layer.rawValue)\(m.caseIdent).swift"
			}
		}()

		let content = emitCombinedFile(layer: m.layer, module: m, kinds: kinds)
		if content.isEmpty { continue }
		try? writeFile(fileBase, content: content)

		let base = targetVarName(
			layerLower: lowercasedFirst(m.layer.enumName),
			moduleIdent: m.caseIdent,
			group: m.group
		)
		var names: [String] = []
		if kinds.contains(.implementation) { names.append(base) }
		if kinds.contains(.interface) { names.append(base + "Interface") }
		if kinds.contains(.tests) { names.append(base + "Tests") }
		if kinds.contains(.testing) { names.append(base + "Testing") }
		if kinds.contains(.example) { names.append(base + "Example") }
		allTargetNames.append(contentsOf: names)
		if m.layer == .app || m.layer == .appExtension {
			appProjectTargetNames.append(contentsOf: names)
		}
	}

	try? writeFile(
		targetsAggregateFile,
		content: emitTargetsAggregate(
			targetNames: allTargetNames,
			appProjectTargetNames: appProjectTargetNames
		)
	)

	// Editable stubs (only first generation)
	try? writeIfNotExists(path: dependenciesFile, content: emitDependenciesFile())
	try? writeIfNotExists(path: infoPlistsFile, content: emitInfoPlistsFile())
	try? writeIfNotExists(path: bundlePrefixesFile, content: emitBundlePrefixesFile())
	try? writeIfNotExists(path: settingsFile, content: emitSettingsFile())
	try? writeIfNotExists(path: scriptsFile, content: emitScriptsFile())
	try? writeIfNotExists(path: coreDataModelsFile, content: emitCoreDataModelsFile())
	try? writeIfNotExists(path: environmentFile, content: emitEnvironmentFile())
	try? writeIfNotExists(path: permissionsFile, content: emitPermissionsFile())
}

run()
