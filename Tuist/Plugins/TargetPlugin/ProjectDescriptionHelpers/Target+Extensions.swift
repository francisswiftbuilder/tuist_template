import ProjectDescription

public extension Target {
  func addingDependency(_ dependency: TargetDependency) -> Target {
    var copy = self
    copy.dependencies.append(dependency)
    return copy
  }

  func addingDependencies(_ dependencies: [TargetDependency]) -> Target {
    var copy = self
    copy.dependencies.append(contentsOf: dependencies)
    return copy
  }
  
  func addingInfoPlist(_ infoPlist: InfoPlist) -> Target {
    var copy = self
    var merged: [String: Plist.Value] = [:]
    switch copy.infoPlist {
    case let .dictionary(orig):
      merged = orig
    case let .extendingDefault(orig):
      merged = orig
    default:
      merged = [:]
    }
    switch infoPlist {
    case let .dictionary(new):
      new.forEach { merged[$0.key] = $0.value }
    case let .extendingDefault(new):
      new.forEach { merged[$0.key] = $0.value }
    default:
      break
    }
    copy.infoPlist = .extendingDefault(with: merged)
    return copy
  }
  
  func addingDeploymentTargets(_ deploymentTargets: DeploymentTargets) -> Target {
    var copy = self
    copy.deploymentTargets = deploymentTargets
    return copy
  }
  
  func addingEntitlements(_ entitlements: Entitlements) -> Target {
    var copy = self
    copy.entitlements = entitlements
    return copy
  }
}
