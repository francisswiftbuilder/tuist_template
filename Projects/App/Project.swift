import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
	name: environment.name,
	options: .options(
		automaticSchemesOptions: .disabled,
		textSettings: .textSettings(
			usesTabs: true,
			indentWidth: 2,
			tabWidth: 2
		)
	),
	settings: .settings(
		base: baseSettings,
		configurations: configurations
	),
	targets: appProjectTargets,
	schemes: [
		.appScheme
	]
)
