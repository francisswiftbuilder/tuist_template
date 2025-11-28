import Foundation

let targetsFile = "Tuist/ProjectDescriptionHelpers/Targets.swift"
let outDir = "Tuist/ProjectDescriptionHelpers/.generated/Schemes"
let fm = FileManager.default
let aggregatorPath = "Tuist/ProjectDescriptionHelpers/Schemes.swift"

let buildActionsFile = "Tuist/ProjectDescriptionHelpers/BuildActions.swift"
let testActionsFile = "Tuist/ProjectDescriptionHelpers/TestActions.swift"
let runActionsFile = "Tuist/ProjectDescriptionHelpers/RunActions.swift"
let archiveActionsFile = "Tuist/ProjectDescriptionHelpers/ArchiveActions.swift"

// MARK: - Parsing targets list
func readTargetsList(from path: String) -> [String] {
	guard let s = try? String(contentsOfFile: path, encoding: .utf8) else { return [] }
	guard let rangeTargets = s.range(of: "targets") else { return [] }
	guard let eqIndex = s[rangeTargets.upperBound...].firstIndex(of: "=") else { return [] }
	guard let arrStart = s[eqIndex...].firstIndex(of: "[") else { return [] }
	var depth = 0
	var endIndex: String.Index?
	var idx = arrStart
	while idx < s.endIndex {
		let ch = s[idx]
		if ch == "[" {
			depth += 1
		} else if ch == "]" {
			depth -= 1
			if depth == 0 {
				endIndex = idx
				break
			}
		}
		idx = s.index(after: idx)
	}
	guard let arrEnd = endIndex else { return [] }
	let inside = String(s[s.index(after: arrStart)..<arrEnd])
	let pattern = "(?m)^[ \\t]*\\.([A-Za-z][_A-Za-z0-9]*)"
	let regex = (try? NSRegularExpression(pattern: pattern, options: [])) ?? .init()
	let nsInside = inside as NSString
	let matches = regex.matches(
		in: inside, options: [], range: NSRange(location: 0, length: nsInside.length))
	let blacklist: Set<String> = ["adding", "testTarget"]
	var ids: [String] = []
	for m in matches {
		if m.numberOfRanges < 2 { continue }
		let token = nsInside.substring(with: m.range(at: 1)).trimmingCharacters(
			in: .whitespacesAndNewlines)
		if token.isEmpty { continue }
		if blacklist.contains(token) { continue }
		ids.append(token)
	}
	var seen = Set<String>()
	return ids.filter { seen.insert($0).inserted }
}

// MARK: - Utils
func ensureDir(_ path: String) throws {
	var isDir: ObjCBool = false
	if !fm.fileExists(atPath: path, isDirectory: &isDir) || !isDir.boolValue {
		try fm.createDirectory(atPath: path, withIntermediateDirectories: true)
	}
}
func writeFile(_ path: String, content: String) throws {
	let dir = (path as NSString).deletingLastPathComponent
	if !fm.fileExists(atPath: dir) {
		try fm.createDirectory(atPath: dir, withIntermediateDirectories: true)
	}
	try content.write(toFile: path, atomically: true, encoding: .utf8)
}
func writeIfNotExists(_ path: String, content: String) {
	if !fm.fileExists(atPath: path) {
		try? writeFile(path, content: content)
	}
}
func capitalizedFirst(_ s: String) -> String {
	guard !s.isEmpty else { return s }
	return s.prefix(1).uppercased() + s.dropFirst()
}
func lowercasedFirst(_ s: String) -> String {
	guard !s.isEmpty else { return s }
	return s.prefix(1).lowercased() + s.dropFirst()
}

// MARK: - Scheme emission (now referencing action vars)
func emitAppScheme(hasAppTests: Bool) -> String {
	var l: [String] = []
	l.append("// AUTO-GENERATED. DO NOT EDIT.")
	l.append("// App scheme")
	l.append("import ProjectDescription")
	l.append("")
	l.append("extension Scheme {")
	l.append("\tpublic static var appScheme: Scheme {")
	l.append("\t\t.scheme(")
	l.append("\t\t\tname: \"App\",")
	l.append("\t\t\tshared: true,")
	l.append("\t\t\tbuildAction: .appBuildAction,")
	if hasAppTests {
		l.append("\t\t\ttestAction: .appTestAction,")
	}
	l.append("\t\t\trunAction: .appRunAction,")
	l.append("\t\t\tarchiveAction: .appArchiveAction")
	l.append("\t\t)")
	l.append("\t}")
	l.append("}")
	return l.joined(separator: "\n") + "\n"
}

func emitExampleScheme(targetName: String, testsName: String?, schemeName: String, varName: String)
	-> String
{
	var l: [String] = []
	l.append("// AUTO-GENERATED. DO NOT EDIT.")
	l.append("// Example scheme for \(targetName)")
	l.append("import ProjectDescription")
	l.append("")
	l.append("extension Scheme {")
	l.append("\tpublic static var \(varName)Scheme: Scheme {")
	l.append("\t\t.scheme(")
	l.append("\t\t\tname: \"\(schemeName)\",")
	l.append("\t\t\tshared: true,")
	l.append("\t\t\tbuildAction: .\(varName)BuildAction,")
	if testsName != nil {
		l.append("\t\t\ttestAction: .\(varName)TestAction,")
	}
	l.append("\t\t\trunAction: .\(varName)RunAction,")
	l.append("\t\t\tarchiveAction: .\(varName)ArchiveAction")
	l.append("\t\t)")
	l.append("\t}")
	l.append("}")
	return l.joined(separator: "\n") + "\n"
}

func emitTestsScheme(testsTarget: String, schemeName: String, varName: String) -> String {
	var l: [String] = []
	l.append("// AUTO-GENERATED. DO NOT EDIT.")
	l.append("// Test scheme for \(testsTarget)")
	l.append("import ProjectDescription")
	l.append("")
	l.append("extension Scheme {")
	l.append("\tpublic static var \(varName)Scheme: Scheme {")
	l.append("\t\t.scheme(")
	l.append("\t\t\tname: \"\(schemeName)\",")
	l.append("\t\t\tshared: true,")
	l.append("\t\t\tbuildAction: .\(varName)BuildAction,")
	l.append("\t\t\ttestAction: .\(varName)TestAction")
	l.append("\t\t)")
	l.append("\t}")
	l.append("}")
	return l.joined(separator: "\n") + "\n"
}

// MARK: - Action metadata
struct BuildActionDef {
	let name: String
	let targetsExpr: String
}
struct TestActionDef {
	let name: String
	let testTarget: String
}
struct RunActionDef {
	let name: String
	let executable: String
}
struct ArchiveActionDef { let name: String }

func emitAggregator(
	schemes: [String],
	buildDefs: [BuildActionDef],
	testDefs: [TestActionDef],
	runDefs: [RunActionDef],
	archiveDefs: [ArchiveActionDef]
) -> String {
	var out: [String] = []
	out.append("// AUTO-GENERATED. DO NOT EDIT.")
	out.append("import ProjectDescription")
	out.append("")
	out.append("public let schemes: [Scheme] = [")
	for (i, s) in schemes.enumerated() {
		let suff = i == schemes.count - 1 ? "" : ","
		out.append("\t.\(s)\(suff)")
	}
	out.append("]")
	out.append("")
	// Build
	if !buildDefs.isEmpty {
		out.append("public protocol BuildActionsSet {")
		for d in buildDefs { out.append("\tstatic var \(d.name): BuildAction { get }") }
		out.append("}")
		out.append("")
		out.append("public extension BuildActionsSet {")
		for d in buildDefs {
			out.append("\tstatic var \(d.name): BuildAction { .buildAction(targets: \(d.targetsExpr)) }")
		}
		out.append("}")
		out.append("")
		out.append("extension BuildAction: BuildActionsSet {}")
		out.append("")
	}
	// Test
	if !testDefs.isEmpty {
		out.append("public protocol TestActionsSet {")
		for d in testDefs { out.append("\tstatic var \(d.name): TestAction { get }") }
		out.append("}")
		out.append("")
		out.append("public extension TestActionsSet {")
		for d in testDefs {
			out.append("\tstatic var \(d.name): TestAction {")
			out.append(
				"\t\t.targets([ .testableTarget(target: .\(d.testTarget)) ], configuration: .debug, options: .options(coverage: true))"
			)
			out.append("\t}")
		}
		out.append("}")
		out.append("")
		out.append("extension TestAction: TestActionsSet {}")
		out.append("")
	}
	// Run
	if !runDefs.isEmpty {
		out.append("public protocol RunActionsSet {")
		for d in runDefs { out.append("\tstatic var \(d.name): RunAction { get }") }
		out.append("}")
		out.append("")
		out.append("public extension RunActionsSet {")
		for d in runDefs {
			out.append("\tstatic var \(d.name): RunAction {")
			out.append(
				"\t\t.runAction(configuration: .debug, executable: .\(d.executable), options: .options())")
			out.append("\t}")
		}
		out.append("}")
		out.append("")
		out.append("extension RunAction: RunActionsSet {}")
		out.append("")
	}
	// Archive
	if !archiveDefs.isEmpty {
		out.append("public protocol ArchiveActionsSet {")
		for d in archiveDefs { out.append("\tstatic var \(d.name): ArchiveAction { get }") }
		out.append("}")
		out.append("")
		out.append("public extension ArchiveActionsSet {")
		for d in archiveDefs {
			out.append(
				"\tstatic var \(d.name): ArchiveAction { .archiveAction(configuration: .release) }")
		}
		out.append("}")
		out.append("")
		out.append("extension ArchiveAction: ArchiveActionsSet {}")
		out.append("")
	}
	return out.joined(separator: "\n")
}

// MARK: - Files
func emitbuildActionsFile(buildDefs: [BuildActionDef]) -> String {
	var l: [String] = []
	l.append("// AUTO-GENERATED File (first generation). You may edit.")
	l.append("// Override any BuildAction static var to customize targets or scripts.")
	l.append("import ProjectDescription")
	l.append("")
	l.append("extension BuildAction {")
	if buildDefs.isEmpty {
		l.append("\t// No build actions detected.")
	} else {
		l.append("\t// Example:")
		if let first = buildDefs.first {
			l.append("\t// public static var \(first.name): BuildAction {")
			l.append(
				"\t//   .buildAction(targets: \(first.targetsExpr), preActions: [], postActions: [])")
			l.append("\t// }")
		}
	}
	l.append("}")
	return l.joined(separator: "\n") + "\n"
}

func emittestActionsFile(testDefs: [TestActionDef]) -> String {
	var l: [String] = []
	l.append("// AUTO-GENERATED File (first generation). You may edit.")
	l.append("// Override to change coverage, configuration, or add diagnostics.")
	l.append("import ProjectDescription")
	l.append("")
	l.append("extension TestAction {")
	if testDefs.isEmpty {
		l.append("\t// No test actions detected.")
	} else {
		l.append("\t// public static var \(testDefs[0].name): TestAction {")
		l.append("\t//   .targets([ .testableTarget(target: .\(testDefs[0].testTarget)) ],")
		l.append("\t//            configuration: .debug,")
		l.append("\t//            options: .options(coverage: true, randomExecutionOrdering: true))")
		l.append("\t// }")
	}
	l.append("}")
	return l.joined(separator: "\n") + "\n"
}

func emitRunActionsFile(runDefs: [RunActionDef]) -> String {
	var l: [String] = []
	l.append("// AUTO-GENERATED File (first generation). You may edit.")
	l.append("// Override to add arguments / environment variables.")
	l.append("import ProjectDescription")
	l.append("")
	l.append("extension RunAction {")
	if runDefs.isEmpty {
		l.append("\t// No run actions detected.")
	} else {
		l.append("\t// public static var \(runDefs[0].name): RunAction {")
		l.append("\t//   .runAction(")
		l.append("\t//     configuration: .debug,")
		l.append("\t//     executable: .\(runDefs[0].executable),")
		l.append("\t//     arguments: [\"--uitest\"],")
		l.append("\t//     environment: [\"API_BASE_URL\": \"https://dev.example.com\"],")
		l.append("\t//     options: .options()")
		l.append("\t//   )")
		l.append("\t// }")
	}
	l.append("}")
	return l.joined(separator: "\n") + "\n"
}

func emitArchiveActionsFile(archiveDefs: [ArchiveActionDef]) -> String {
	var l: [String] = []
	l.append("// AUTO-GENERATED File (first generation). You may edit.")
	l.append("// Override to change configuration or customArchiveName.")
	l.append("import ProjectDescription")
	l.append("")
	l.append("extension ArchiveAction {")
	if archiveDefs.isEmpty {
		l.append("\t// No archive actions detected.")
	} else {
		l.append("\t// public static var \(archiveDefs[0].name): ArchiveAction {")
		l.append(
			"\t//   .archiveAction(configuration: .release, customArchiveName: \"Custom\", revealArchiveInOrganizer: true)"
		)
		l.append("\t// }")
	}
	l.append("}")
	return l.joined(separator: "\n") + "\n"
}

// MARK: - Cleanup
func cleanSchemesDir() throws {
	guard outDir.contains(".generated/Schemes") else {
		fputs("⚠️ Skipping cleanup: unexpected directory.\n", stderr)
		return
	}
	if fm.fileExists(atPath: outDir) {
		let items = try fm.contentsOfDirectory(atPath: outDir)
		for i in items {
			let p = (outDir as NSString).appendingPathComponent(i)
			try? fm.removeItem(atPath: p)
		}
	} else {
		try fm.createDirectory(atPath: outDir, withIntermediateDirectories: true)
	}
}

// MARK: - Run
func run() {
	let targets = readTargetsList(from: targetsFile)
	if targets.isEmpty {
		fputs("ℹ️ No targets found.\n", stderr)
		return
	}

	try? cleanSchemesDir()
	try? ensureDir(outDir)

	var schemeVars: [String] = []
	var buildDefs: [BuildActionDef] = []
	var testDefs: [TestActionDef] = []
	var runDefs: [RunActionDef] = []
	var archiveDefs: [ArchiveActionDef] = []

	var createdFiles: [String] = []

	// app
	if targets.contains("app") {
		let hasTests = targets.contains("appTests")
		let schemeContent = emitAppScheme(hasAppTests: hasTests)
		let path = (outDir as NSString).appendingPathComponent("Schemes+App.swift")
		try? writeFile(path, content: schemeContent)
		createdFiles.append(path)
		schemeVars.append("appScheme")
		buildDefs.append(.init(name: "appBuildAction", targetsExpr: "[ .app ]"))
		runDefs.append(.init(name: "appRunAction", executable: "app"))
		archiveDefs.append(.init(name: "appArchiveAction"))
		if hasTests {
			testDefs.append(.init(name: "appTestAction", testTarget: "appTests"))
		}
	}

	// examples
	let exampleTargets = targets.filter { $0.hasSuffix("Example") }
	for t in exampleTargets {
		let suffix = "Example"
		guard t.count > suffix.count else { continue }
		let base = String(t.prefix(t.count - suffix.count))
		let moduleName = String(base.drop(while: { $0.isLowercase }))
		let schemeName = "Example" + moduleName
		let schemeVarBase = lowercasedFirst("example" + moduleName)
		let testsName = base + "Tests"
		let hasTests = targets.contains(testsName)

		let schemeContent = emitExampleScheme(
			targetName: t,
			testsName: hasTests ? testsName : nil,
			schemeName: schemeName,
			varName: schemeVarBase
		)
		let fname = "Schemes+\(capitalizedFirst(schemeVarBase)).swift"
		let path = (outDir as NSString).appendingPathComponent(fname)
		try? writeFile(path, content: schemeContent)
		createdFiles.append(path)
		schemeVars.append("\(schemeVarBase)Scheme")

		buildDefs.append(.init(name: "\(schemeVarBase)BuildAction", targetsExpr: "[ .\(t) ]"))
		runDefs.append(.init(name: "\(schemeVarBase)RunAction", executable: t))
		archiveDefs.append(.init(name: "\(schemeVarBase)ArchiveAction"))
		if hasTests {
			testDefs.append(.init(name: "\(schemeVarBase)TestAction", testTarget: testsName))
		}
	}

	// tests
	let testsTargets = targets.filter { $0.hasSuffix("Tests") && $0 != "appTests" }
	for t in testsTargets {
		let schemeName = capitalizedFirst(t)
		let schemeContent = emitTestsScheme(
			testsTarget: t,
			schemeName: schemeName,
			varName: t
		)
		let fname = "Schemes+\(capitalizedFirst(t)).swift"
		let path = (outDir as NSString).appendingPathComponent(fname)
		try? writeFile(path, content: schemeContent)
		createdFiles.append(path)
		schemeVars.append("\(t)Scheme")

		buildDefs.append(.init(name: "\(t)BuildAction", targetsExpr: "[ .\(t) ]"))
		testDefs.append(.init(name: "\(t)TestAction", testTarget: t))
	}

	// aggregator
	let aggregatorContent = emitAggregator(
		schemes: schemeVars,
		buildDefs: buildDefs,
		testDefs: testDefs,
		runDefs: runDefs,
		archiveDefs: archiveDefs
	)
	try? writeFile(aggregatorPath, content: aggregatorContent)
	createdFiles.append(aggregatorPath)

	// Files (only if absent)
	writeIfNotExists(buildActionsFile, content: emitbuildActionsFile(buildDefs: buildDefs))
	writeIfNotExists(testActionsFile, content: emittestActionsFile(testDefs: testDefs))
	writeIfNotExists(runActionsFile, content: emitRunActionsFile(runDefs: runDefs))
	writeIfNotExists(archiveActionsFile, content: emitArchiveActionsFile(archiveDefs: archiveDefs))

	fputs("✅ Created/updated scheme files:\n", stderr)
	for f in createdFiles { fputs("  - \(f)\n", stderr) }
	fputs("ℹ️ Files preserved/created (first generation only).\n", stderr)
}

run()
