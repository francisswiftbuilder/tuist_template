import Foundation
import ProjectDescription
import TargetPlugin

extension Target {
  public static var featureSome: Target {
    .feature(
      implements: .some,
      factory: .init(
        destinations: .featureSomeDestinations,
        bundlePrefix: .featureSomeBundlePrefix,
        deploymentTargets: .featureSomeDeploymentTargets,
        infoPlist: .featureSomeInfoPlist,
        scripts: .featureSomeTargetScripts,
        dependencies: .featureSomeDependencies,
        settings: .featureSomeSettings,
        coreDataModels: .featureSomeCoreDataModels
      )
    )
  }

  public static var featureSomeInterface: Target {
    .feature(
      interface: .some,
      factory: .init(
        destinations: .featureSomeInterfaceDestinations,
        bundlePrefix: .featureSomeInterfaceBundlePrefix,
        deploymentTargets: .featureSomeInterfaceDeploymentTargets,
        infoPlist: .featureSomeInterfaceInfoPlist,
        scripts: .featureSomeInterfaceTargetScripts,
        dependencies: .featureSomeInterfaceDependencies,
        settings: .featureSomeInterfaceSettings,
        coreDataModels: .featureSomeInterfaceCoreDataModels
      )
    )
  }

  public static var featureSomeTests: Target {
    .feature(
      tests: .some,
      factory: .init(
        destinations: .featureSomeTestsDestinations,
        bundlePrefix: .featureSomeTestsBundlePrefix,
        deploymentTargets: .featureSomeTestsDeploymentTargets,
        infoPlist: .featureSomeTestsInfoPlist,
        scripts: .featureSomeTestsTargetScripts,
        dependencies: .featureSomeTestsDependencies,
        settings: .featureSomeTestsSettings,
        coreDataModels: .featureSomeTestsCoreDataModels
      )
    )
  }

  public static var featureSomeTesting: Target {
    .feature(
      testing: .some,
      factory: .init(
        destinations: .featureSomeTestingDestinations,
        bundlePrefix: .featureSomeTestingBundlePrefix,
        deploymentTargets: .featureSomeTestingDeploymentTargets,
        infoPlist: .featureSomeTestingInfoPlist,
        scripts: .featureSomeTestingTargetScripts,
        dependencies: .featureSomeTestingDependencies,
        settings: .featureSomeTestingSettings,
        coreDataModels: .featureSomeTestingCoreDataModels
      )
    )
  }

  public static var featureSomeExample: Target {
    .feature(
      example: .some,
      factory: .init(
        destinations: .featureSomeExampleDestinations,
        bundlePrefix: .featureSomeExampleBundlePrefix,
        deploymentTargets: .featureSomeExampleDeploymentTargets,
        infoPlist: .featureSomeExampleInfoPlist,
        scripts: .featureSomeExampleTargetScripts,
        dependencies: .featureSomeExampleDependencies,
        settings: .featureSomeExampleSettings,
        coreDataModels: .featureSomeExampleCoreDataModels
      )
    )
  }
}

extension TargetReference {
  public static var featureSome: TargetReference {
    .feature(
      implements: .some
    )
  }

  public static var featureSomeInterface: TargetReference {
    .feature(
      interface: .some
    )
  }

  public static var featureSomeTests: TargetReference {
    .feature(
      tests: .some
    )
  }

  public static var featureSomeTesting: TargetReference {
    .feature(
      testing: .some
    )
  }

  public static var featureSomeExample: TargetReference {
    .feature(
      example: .some
    )
  }
}
