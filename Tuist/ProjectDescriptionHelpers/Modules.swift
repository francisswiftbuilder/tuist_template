// AUTO-GENERATED. DO NOT EDIT.
// Source of truth: directory structure under Projects/<Layer>/<Module>/Sources
// Tuist 4.55.6

import Foundation
import ProjectDescription
import TargetPlugin

// MARK: AppModule
public enum Module: String, ModuleAppType {
	case App
	public var name: String { rawValue }
}

extension ModuleAppType where Self == Module {
	public static var app: Module { Module.App }
}
