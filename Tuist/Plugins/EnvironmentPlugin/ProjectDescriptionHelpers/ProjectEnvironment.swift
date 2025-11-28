import Foundation
import ProjectDescription

public struct ProjectEnvironment {
  public let name: String
  public let organizationName: String
  public let destinations: Destinations
  public let deploymentTargets: DeploymentTargets
  public let baseSetting: SettingsDictionary
  
  public init(
    name: String,
    organizationName: String,
    destinations: Destinations = [.iPhone, .iPad],
    deploymentTargets: DeploymentTargets = .iOS("15.0"),
    baseSetting: SettingsDictionary = [:]
  ) {
    self.name = name
    self.organizationName = organizationName
    self.destinations = destinations
    self.deploymentTargets = deploymentTargets
    self.baseSetting = baseSetting
  }
}
