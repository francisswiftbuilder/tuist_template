import ProjectDescription

extension Scheme {
  public static var exampleSomeScheme: Scheme {
    .scheme(
      name: "ExampleSome",
      shared: true,
      buildAction: .exampleSomeBuildAction,
      testAction: .exampleSomeTestAction,
      runAction: .exampleSomeRunAction,
      archiveAction: .exampleSomeArchiveAction
    )
  }
}