import Foundation
import ProjectDescription
import TargetPlugin

public let allTargets: [Target] = [
  .app,
  .featureSome,
  .featureSomeInterface,
  .featureSomeTests,
  .featureSomeTesting,
  .featureSomeExample
]

public extension Destinations {
  static var appDestinations: Destinations { environment.destinations }
  static var featureSomeDestinations: Destinations { environment.destinations }
  static var featureSomeInterfaceDestinations: Destinations { environment.destinations }
  static var featureSomeTestsDestinations: Destinations { environment.destinations }
  static var featureSomeTestingDestinations: Destinations { environment.destinations }
  static var featureSomeExampleDestinations: Destinations { environment.destinations }
}

public extension DeploymentTargets {
  static var appDeploymentTargets: DeploymentTargets { environment.deploymentTargets }
  static var featureSomeDeploymentTargets: DeploymentTargets { environment.deploymentTargets }
  static var featureSomeInterfaceDeploymentTargets: DeploymentTargets { environment.deploymentTargets }
  static var featureSomeTestsDeploymentTargets: DeploymentTargets { environment.deploymentTargets }
  static var featureSomeTestingDeploymentTargets: DeploymentTargets { environment.deploymentTargets }
  static var featureSomeExampleDeploymentTargets: DeploymentTargets { environment.deploymentTargets }
}

public protocol TargetDependencies {
  static var appDependencies: [TargetDependency] { get }
  static var featureSomeDependencies: [TargetDependency] { get }
  static var featureSomeInterfaceDependencies: [TargetDependency] { get }
  static var featureSomeTestsDependencies: [TargetDependency] { get }
  static var featureSomeTestingDependencies: [TargetDependency] { get }
  static var featureSomeExampleDependencies: [TargetDependency] { get }
}

public extension TargetDependencies {
  static var appDependencies: [TargetDependency] { [] }
  static var featureSomeDependencies: [TargetDependency] { [] }
  static var featureSomeInterfaceDependencies: [TargetDependency] { [] }
  static var featureSomeTestsDependencies: [TargetDependency] { [] }
  static var featureSomeTestingDependencies: [TargetDependency] { [] }
  static var featureSomeExampleDependencies: [TargetDependency] { [] }
}

public protocol InfoPlists {
  static var appInfoPlist: InfoPlist { get }
  static var featureSomeInfoPlist: InfoPlist { get }
  static var featureSomeInterfaceInfoPlist: InfoPlist { get }
  static var featureSomeTestsInfoPlist: InfoPlist { get }
  static var featureSomeTestingInfoPlist: InfoPlist { get }
  static var featureSomeExampleInfoPlist: InfoPlist { get }
}

public extension InfoPlists {
  static var appInfoPlist: InfoPlist { .extendingDefault(with: [:]) }
  static var featureSomeInfoPlist: InfoPlist { .extendingDefault(with: [:]) }
  static var featureSomeInterfaceInfoPlist: InfoPlist { .extendingDefault(with: [:]) }
  static var featureSomeTestsInfoPlist: InfoPlist { .extendingDefault(with: [:]) }
  static var featureSomeTestingInfoPlist: InfoPlist { .extendingDefault(with: [:]) }
  static var featureSomeExampleInfoPlist: InfoPlist { .extendingDefault(with: [:]) }
}

public protocol BundlePrefixes {
  static var appBundlePrefix: String { get }
  static var featureSomeBundlePrefix: String { get }
  static var featureSomeInterfaceBundlePrefix: String { get }
  static var featureSomeTestsBundlePrefix: String { get }
  static var featureSomeTestingBundlePrefix: String { get }
  static var featureSomeExampleBundlePrefix: String { get }
}

public extension BundlePrefixes {
  static var appBundlePrefix: String { environment.organizationName }
  static var featureSomeBundlePrefix: String { environment.organizationName }
  static var featureSomeInterfaceBundlePrefix: String { environment.organizationName }
  static var featureSomeTestsBundlePrefix: String { environment.organizationName }
  static var featureSomeTestingBundlePrefix: String { environment.organizationName }
  static var featureSomeExampleBundlePrefix: String { environment.organizationName }
}

public protocol TargetSettings {
  static var appSettings: Settings? { get }
  static var featureSomeSettings: Settings? { get }
  static var featureSomeInterfaceSettings: Settings? { get }
  static var featureSomeTestsSettings: Settings? { get }
  static var featureSomeTestingSettings: Settings? { get }
  static var featureSomeExampleSettings: Settings? { get }
}

public extension TargetSettings {
  static var appSettings: Settings? { nil }
  static var featureSomeSettings: Settings? { nil }
  static var featureSomeInterfaceSettings: Settings? { nil }
  static var featureSomeTestsSettings: Settings? { nil }
  static var featureSomeTestingSettings: Settings? { nil }
  static var featureSomeExampleSettings: Settings? { nil }
}

public protocol TargetScripts {
  static var appTargetScripts: [TargetScript] { get }
  static var featureSomeTargetScripts: [TargetScript] { get }
  static var featureSomeInterfaceTargetScripts: [TargetScript] { get }
  static var featureSomeTestsTargetScripts: [TargetScript] { get }
  static var featureSomeTestingTargetScripts: [TargetScript] { get }
  static var featureSomeExampleTargetScripts: [TargetScript] { get }
}

public extension TargetScripts {
  static var appTargetScripts: [TargetScript] { [] }
  static var featureSomeTargetScripts: [TargetScript] { [] }
  static var featureSomeInterfaceTargetScripts: [TargetScript] { [] }
  static var featureSomeTestsTargetScripts: [TargetScript] { [] }
  static var featureSomeTestingTargetScripts: [TargetScript] { [] }
  static var featureSomeExampleTargetScripts: [TargetScript] { [] }
}

public protocol CoreDataModels {
  static var appCoreDataModels: [CoreDataModel] { get }
  static var featureSomeCoreDataModels: [CoreDataModel] { get }
  static var featureSomeInterfaceCoreDataModels: [CoreDataModel] { get }
  static var featureSomeTestsCoreDataModels: [CoreDataModel] { get }
  static var featureSomeTestingCoreDataModels: [CoreDataModel] { get }
  static var featureSomeExampleCoreDataModels: [CoreDataModel] { get }
}

public extension CoreDataModels {
  static var appCoreDataModels: [CoreDataModel] { [] }
  static var featureSomeCoreDataModels: [CoreDataModel] { [] }
  static var featureSomeInterfaceCoreDataModels: [CoreDataModel] { [] }
  static var featureSomeTestsCoreDataModels: [CoreDataModel] { [] }
  static var featureSomeTestingCoreDataModels: [CoreDataModel] { [] }
  static var featureSomeExampleCoreDataModels: [CoreDataModel] { [] }
}
