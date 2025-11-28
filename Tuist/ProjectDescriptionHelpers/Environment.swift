import EnvironmentPlugin

public nonisolated(unsafe) let environment = ProjectEnvironment(
	name: "App",
	organizationName: "com.example.app",
	destinations: [.iPhone, .iPad],
	deploymentTargets: .iOS("15.0"),
	baseSetting: baseSettings
)
