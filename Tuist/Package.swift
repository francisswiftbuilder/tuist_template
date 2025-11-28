// swift-tools-version: 6.0
import Foundation
import PackageDescription

#if TUIST
import struct ProjectDescription.PackageSettings
import ConfigurationPlugin

let packageSettings = PackageSettings(
	baseSettings: .settings(
		configurations: ConfigurationType.configurations()
	)
)
#endif

let package = Package(
	name: "App",
	platforms: [.iOS(.v15)],
	products: [],
	dependencies: [],
	targets: []
)
