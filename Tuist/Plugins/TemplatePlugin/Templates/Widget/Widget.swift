import ProjectDescription

private let nameAttribute = Template.Attribute.required("name")

private let template = Template(
	description: "A template for a new WidgetKit app extension",
	attributes: [
		nameAttribute
	],
	items: [
		.file(
			path: "Projects/AppExtension/Widget/\(nameAttribute)/Sources/\(nameAttribute).swift",
			templatePath: "Widget.stencil"
		),
		.file(
			path:
				"Projects/AppExtension/Widget/\(nameAttribute)/SupportFiles/Widget.entitlements",
			templatePath: "WidgetEntitlements.stencil"
		),
		.string(
			path: "Projects/AppExtension/Widget/\(nameAttribute)/Resources/.gitkeep",
			contents: ""
		),
	]
)
