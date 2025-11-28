import Foundation
import ProjectDescription

// MARK: TargetDependency + App

public extension TargetDependency {
  static func app(implements module: ModuleAppType? = nil) -> Self {
    return .project(target: ModulePath.app.name, path: .app)
  }
}

// MARK: TargetDependency + Extension

public extension TargetDependency {
	static func appExtension(implements module: ModuleAppExtensionType? = nil) -> Self {
    return .target(name: ModulePath.appExtension(module).name)
	}
}


// MARK: TargetDependency + Feature

public extension TargetDependency {
  static func feature(implements module: ModuleFeatureType? = nil) -> Self {
    return .target(name: ModulePath.feature(module).name)
  }
  
  static func feature(interface module: ModuleFeatureType) -> Self {
    return .target(name: ModulePath.feature(module).interface)
  }
  
  static func feature(tests module: ModuleFeatureType) -> Self {
    return .target(name: ModulePath.feature(module).tests)
  }
  
  static func feature(testing module: ModuleFeatureType) -> Self {
    return .target(name: ModulePath.feature(module).testing)
  }
  
  static func feature(example module: ModuleFeatureType) -> Self {
    return .target(name: ModulePath.feature(module).example)
  }
}

// MARK: TargetDependency + Domain

public extension TargetDependency {
  static func domain(implements module: ModuleDomainType? = nil) -> Self {
    return .target(name: ModulePath.domain(module).name)
  }
  
  static func domain(interface module: ModuleDomainType) -> Self {
    return .target(name: ModulePath.domain(module).interface)
  }
  
  static func domain(tests module: ModuleDomainType) -> Self {
    return .target(name: ModulePath.domain(module).tests)
  }
  
  static func domain(testing module: ModuleDomainType) -> Self {
    return .target(name: ModulePath.domain(module).testing)
  }
}

// MARK: TargetDependency + Data

public extension TargetDependency {
  static func data(implements module: ModuleDataType? = nil) -> Self {
    return .target(name: ModulePath.data(module).name)
  }
  
  static func data(interface module: ModuleDataType) -> Self {
    return .target(name: ModulePath.data(module).interface)
  }
  
  static func data(tests module: ModuleDataType) -> Self {
    return .target(name: ModulePath.data(module).tests)
  }
  
  static func data(testing module: ModuleDataType) -> Self {
    return .target(name: ModulePath.data(module).testing)
  }
}

// MARK: TargetDependency + Core

public extension TargetDependency {
  static func core(implements module: ModuleCoreType? = nil) -> Self {
    return .target(name: ModulePath.core(module).name)
  }
  
  static func core(interface module: ModuleCoreType) -> Self {
    return .target(name: ModulePath.core(module).interface)
  }
  
  static func core(tests module: ModuleCoreType) -> Self {
    return .target(name: ModulePath.core(module).tests)
  }
  
  static func core(testing module: ModuleCoreType) -> Self {
    return .target(name: ModulePath.core(module).testing)
  }
}

// MARK: TargetDependency + Shared

public extension TargetDependency {
  static func shared(implements module: ModuleSharedType? = nil) -> Self {
    return .target(name: ModulePath.shared(module).name)
  }
  
  static func shared(interface module: ModuleSharedType) -> Self {
    return .target(name: ModulePath.shared(module).interface)
  }
}

public extension TargetDependency {
  static func module<Module>(feature module: Module) -> TargetDependency where Module: ModuleFeatureType {
    .project(target: "Feature\(module.name)", path: .feature(implementation: module))
  }
  
  static func module<Module>(domain module: Module) -> TargetDependency where Module: ModuleDomainType {
    .project(target: "Domain\(module.name)", path: .domain(implementation: module))
  }
  
  static func module<Module>(data module: Module) -> TargetDependency where Module: ModuleDataType {
    .project(target: "Data\(module.name)", path: .data(implementation: module))
  }
  
  static func module<Module>(core module: Module) -> TargetDependency where Module: ModuleCoreType {
    .project(target: "Core\(module.name)", path: .core(implementation: module))
  }
  
  static func module<Module>(shared module: Module) -> TargetDependency where Module: ModuleSharedType {
    .project(target: "Shared\(module.name)", path: .shared(implementation: module))
  }
}
