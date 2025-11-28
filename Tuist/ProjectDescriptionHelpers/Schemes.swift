import ProjectDescription

public let schemes: [Scheme] = [
  .appScheme,
  .exampleSomeScheme
]

public protocol BuildActionsSet {
  static var appBuildAction: BuildAction { get }
  static var exampleSomeBuildAction: BuildAction { get }
}

public extension BuildActionsSet {
  static var appBuildAction: BuildAction { .buildAction(targets: [ .app ]) }
  static var exampleSomeBuildAction: BuildAction { .buildAction(targets: [ .featureSomeExample ]) }
}

extension BuildAction: BuildActionsSet {}

public protocol TestActionsSet {
  static var exampleSomeTestAction: TestAction { get }
}

public extension TestActionsSet {
  static var exampleSomeTestAction: TestAction {
    .targets([ .testableTarget(target: .featureSomeTests) ], configuration: .debug, options: .options(coverage: true))
  }
}

extension TestAction: TestActionsSet {}

public protocol RunActionsSet {
  static var appRunAction: RunAction { get }
  static var exampleSomeRunAction: RunAction { get }
}

public extension RunActionsSet {
  static var appRunAction: RunAction {
    .runAction(configuration: .debug, executable: .app, options: .options())
  }
  static var exampleSomeRunAction: RunAction {
    .runAction(configuration: .debug, executable: .featureSomeExample, options: .options())
  }
}

extension RunAction: RunActionsSet {}

public protocol ArchiveActionsSet {
  static var appArchiveAction: ArchiveAction { get }
  static var exampleSomeArchiveAction: ArchiveAction { get }
}

public extension ArchiveActionsSet {
  static var appArchiveAction: ArchiveAction { .archiveAction(configuration: .release) }
  static var exampleSomeArchiveAction: ArchiveAction { .archiveAction(configuration: .release) }
}

extension ArchiveAction: ArchiveActionsSet {}
