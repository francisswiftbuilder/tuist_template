import Foundation
import ProjectDescription
import TargetPlugin

public enum Module: String, ModuleAppType {
  case App
  public var name: String { rawValue }
}

public extension Module {
  enum Feature: String, CaseIterable, ModuleFeatureType {
    case Some
    public var name: String { rawValue }
  }
}

extension ModuleAppType where Self == Module {
  public static var app: Module { Module.App }
}

extension ModuleFeatureType where Self == Module.Feature {
  public static var some: Module.Feature { Module.Feature.Some }
}
