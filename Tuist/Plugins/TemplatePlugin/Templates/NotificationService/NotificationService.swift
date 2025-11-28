import ProjectDescription

private let template = Template(
	description: "A template for the notification service app extension",
	attributes: [],
	items: [
		.file(
			path: "Projects/AppExtension/NotificationService/Sources/NotificationService.swift",
			templatePath: "NotificationService.stencil"
		),
		.string(
			path: "Projects/AppExtension/NotificationService/Resources/.gitkeep",
			contents: ""
		),
	]
)
