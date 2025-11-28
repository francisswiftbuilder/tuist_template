import Foundation
import ProjectDescription

public protocol ModuleType {
  var name: String { get }
}

public protocol ModuleAppType: ModuleType {}

public protocol ModuleAppExtensionType: ModuleType {}

public protocol ModuleFeatureType: ModuleType {}

public protocol ModuleDomainType: ModuleType {}

public protocol ModuleDataType: ModuleType {}

public protocol ModuleCoreType: ModuleType {}

public protocol ModuleSharedType: ModuleType {}


public enum ModulePath {
	case app
	case appExtension(ModuleType?)
	case feature(ModuleType?)
	case domain(ModuleType?)
	case data(ModuleType?)
	case core(ModuleType?)
	case shared(ModuleType?)

  private var prefix: String {
    switch self {
    case .app: return "App"
		case .appExtension: return "AppExtension"
    case .feature: return "Feature"
    case .domain: return "Domain"
    case .data: return "Data"
    case .core: return "Core"
    case .shared: return "Shared"
    }
  }
  
  private var module: ModuleType? {
    switch self {
    case .app: return nil
		case .appExtension(let module): return module
    case .feature(let module): return module
    case .domain(let module): return module
    case .data(let module): return module
    case .core(let module): return module
    case .shared(let module): return module
    }
  }
  
  var path: String {
		switch self {
		case .app, .appExtension:
			return "Projects/\(prefix)"
			
		case .feature(let module), .domain(let module), .data(let module), .core(let module), .shared(let module):
			guard let moduleName = module?.name else {
				return "Projects/\(prefix)"
			}
			return "Projects/\(prefix)/\(moduleName)"
		}
	}
  
  public var name: String {
    guard let moduleName = module?.name else { return prefix }
    return "\(prefix)\(moduleName)"
  }
  
  public var interface: String {
    guard let moduleName = module?.name else { return prefix }
    return "\(prefix)\(moduleName)" + "Interface"
  }
  
  public var testing: String {
    guard let moduleName = module?.name else { return prefix }
    return "\(prefix)\(moduleName)" + "Testing"
  }

  public var tests: String {
    guard let moduleName = module?.name else { return prefix }
    return "\(prefix)\(moduleName)" + "Tests"
  }
  
  public var example: String {
    guard let moduleName = module?.name else { return prefix }
    return "\(prefix)\(moduleName)" + "Example"
  }
}

// MARK: ProjectDescription.Path + App

public extension ProjectDescription.Path {
	static var app: Self {
		return .relativeToRoot(ModulePath.app.path)
	}
}

// MARK: ProjectDescription.Path + Extension

public extension ProjectDescription.Path {
	static var widget: Self {
		return .relativeToRoot("Projects/AppExtension/Widget")
	}
	
	static func widget(implementation module: ModuleType) -> Self {
		return .relativeToRoot("Projects/AppExtension/Widget/\(ModulePath.appExtension(module).path)")
	}
	
	static func intents(implementation module: ModuleType) -> Self {
		return .relativeToRoot("Projects/AppExtension/Intents/\(ModulePath.appExtension(module).path)")
	}
	
	static func notificationService(implementation module: ModuleType) -> Self {
		return .relativeToRoot("Projects/AppExtension/NotificationService")
	}
}

// MARK: ProjectDescription.Path + Feature

public extension ProjectDescription.Path {
	static var feature: Self {
		return .relativeToRoot(ModulePath.feature(nil).path)
	}
	
	static func feature(implementation module: ModuleType) -> Self {
		return .relativeToRoot(ModulePath.feature(module).path)
	}
	
	static func feature(interface module: ModuleType) -> Self {
		return .relativeToRoot(ModulePath.feature(module).path + "/Interface")
	}
	
	static func feature(tests module: ModuleType) -> Self {
		return .relativeToRoot(ModulePath.feature(module).path + "/Tests")
	}
	
	static func feature(testing module: ModuleType) -> Self {
		return .relativeToRoot(ModulePath.feature(module).path + "/Testing")
	}
	
	static func feature(example module: ModuleType) -> Self {
		return .relativeToRoot(ModulePath.feature(module).path + "/Example")
	}
}

// MARK: ProjectDescription.Path + Domain

public extension ProjectDescription.Path {
	static var domain: Self {
		return .relativeToRoot(ModulePath.domain(nil).path)
	}
	
	static func domain(implementation module: ModuleType) -> Self {
		return .relativeToRoot(ModulePath.domain(module).path)
	}
	
	static func domain(interface module: ModuleType) -> Self {
		return .relativeToRoot(ModulePath.domain(module).path + "/Interface")
	}
	
	static func domain(tests module: ModuleType) -> Self {
		return .relativeToRoot(ModulePath.domain(module).path + "/Tests")
	}
	
	static func domain(testing module: ModuleType) -> Self {
		return .relativeToRoot(ModulePath.domain(module).path + "/Testing")
	}
}

// MARK: ProjectDescription.Path + Data

public extension ProjectDescription.Path {
	static var data: Self {
		return .relativeToRoot(ModulePath.data(nil).path)
	}
	
	static func data(implementation module: ModuleType) -> Self {
		return .relativeToRoot(ModulePath.data(module).path)
	}
	
	static func data(interface module: ModuleType) -> Self {
		return .relativeToRoot(ModulePath.data(module).path + "/Interface")
	}
	
	static func data(tests module: ModuleType) -> Self {
		return .relativeToRoot(ModulePath.data(module).path + "/Tests")
	}
	
	static func data(testing module: ModuleType) -> Self {
		return .relativeToRoot(ModulePath.data(module).path + "/Testing")
	}
}


// MARK: ProjectDescription.Path + Core

public extension ProjectDescription.Path {
	static var core: Self {
		return .relativeToRoot(ModulePath.core(nil).path)
	}
	
	static func core(implementation module: ModuleType) -> Self {
		return .relativeToRoot(ModulePath.core(module).path)
	}
	
	static func core(interface module: ModuleType) -> Self {
		return .relativeToRoot(ModulePath.core(module).path + "/Interface")
	}
	
	static func core(tests module: ModuleType) -> Self {
		return .relativeToRoot(ModulePath.core(module).path + "/Tests")
	}
	
	static func core(testing module: ModuleType) -> Self {
		return .relativeToRoot(ModulePath.core(module).path + "/Testing")
	}
}

// MARK: ProjectDescription.Path + Shared

public extension ProjectDescription.Path {
	static var shared: Self {
		return .relativeToRoot(ModulePath.shared(nil).path)
	}
	
	static func shared(implementation module: ModuleType) -> Self {
		return .relativeToRoot(ModulePath.shared(module).path)
	}
	
	static func shared(interface module: ModuleType) -> Self {
		return .relativeToRoot(ModulePath.shared(module).path + "/Interface")
	}
	
	static func shared(tests module: ModuleType) -> Self {
		return .relativeToRoot(ModulePath.shared(module).path + "/Tests")
	}
	
	static func shared(testing module: ModuleType) -> Self {
		return .relativeToRoot(ModulePath.shared(module).path + "/Testing")
	}

}
