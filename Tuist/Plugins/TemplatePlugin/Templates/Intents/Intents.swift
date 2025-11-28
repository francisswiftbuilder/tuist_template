import ProjectDescription

private let nameAttribute = Template.Attribute.required("name")

private let template = Template(
	description: "A template for a new Intents app extension",
	attributes: [
		nameAttribute
	],
	items: [
		.file(
			path: "Projects/AppExtension/Intents/\(nameAttribute)/Sources/IntentHandler.swift",
			templatePath: "Intents.stencil"
		),
		.file(
			path:
				"Projects/AppExtension/Intents/\(nameAttribute)/SupportFiles/Intents.entitlements",
			templatePath: "IntentsEntitlements.stencil"
		),
		.string(
			path: "Projects/AppExtension/Intents/\(nameAttribute)/Resources/.gitkeep",
			contents: ""
		),
	]
)
