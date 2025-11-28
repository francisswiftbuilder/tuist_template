import Foundation
import ProjectDescription

// MARK: TargetReference + App

public extension TargetReference {
  static func app(implements module: ModuleAppType? = nil) -> Self {
    return .project(path: .app, target: ModulePath.app.name)
  }
}

// MARK: TargetReference + Extension

public extension TargetReference {
	static func appExtension(implements module: ModuleAppExtensionType? = nil) -> Self {
		return .target(ModulePath.appExtension(module).name)
	}
}

// MARK: TargetReference + Feature

public extension TargetReference {
  static func feature(implements module: ModuleFeatureType? = nil) -> Self {
    return .target(ModulePath.feature(module).name)
  }
  
  static func feature(interface module: ModuleFeatureType) -> Self {
    return .target(ModulePath.feature(module).interface)
  }
  
  static func feature(tests module: ModuleFeatureType) -> Self {
    return .target(ModulePath.feature(module).tests)
  }
  
  static func feature(testing module: ModuleFeatureType) -> Self {
    return .target(ModulePath.feature(module).testing)
  }
  
  static func feature(example module: ModuleFeatureType) -> Self {
    return .target(ModulePath.feature(module).example)
  }
}

// MARK: TargetReference + Domain

public extension TargetReference {
  static func domain(implements module: ModuleDomainType? = nil) -> Self {
    return .target(ModulePath.domain(module).name)
  }
  
  static func domain(interface module: ModuleDomainType) -> Self {
    return .target(ModulePath.domain(module).interface)
  }
  
  static func domain(tests module: ModuleDomainType) -> Self {
    return .target(ModulePath.domain(module).tests)
  }
  
  static func domain(testing module: ModuleDomainType) -> Self {
    return .target(ModulePath.domain(module).testing)
  }
}

// MARK: TargetReference + Data

public extension TargetReference {
  static func data(implements module: ModuleDataType? = nil) -> Self {
    return .target(ModulePath.data(module).name)
  }
  
  static func data(interface module: ModuleDataType) -> Self {
    return .target(ModulePath.data(module).interface)
  }
  
  static func data(tests module: ModuleDataType) -> Self {
    return .target(ModulePath.data(module).tests)
  }
  
  static func data(testing module: ModuleDataType) -> Self {
    return .target(ModulePath.data(module).testing)
  }
}

// MARK: TargetReference + Core

public extension TargetReference {
  static func core(implements module: ModuleCoreType? = nil) -> Self {
    return .target(ModulePath.core(module).name)
  }
  
  static func core(interface module: ModuleCoreType) -> Self {
    return .target(ModulePath.core(module).interface)
  }
  
  static func core(tests module: ModuleCoreType) -> Self {
    return .target(ModulePath.core(module).tests)
  }
  
  static func core(testing module: ModuleCoreType) -> Self {
    return .target(ModulePath.core(module).testing)
  }
}

// MARK: TargetReference + Shared

public extension TargetReference {
  static func shared(implements module: ModuleSharedType? = nil) -> Self {
    return .target(ModulePath.shared(module).name)
  }
  
  static func shared(interface module: ModuleSharedType) -> Self {
    return .target(ModulePath.shared(module).interface)
  }
}
