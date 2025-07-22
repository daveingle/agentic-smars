//
//  Role.swift
//  Host
//
//  Created by David Ingle on 2025-07-21.
//


import Foundation
import FoundationModels

@Generable(description: "Role directive that scopes SMARS specification perspective to a specific actor type")
public struct Role: Sendable, Hashable, CustomStringConvertible  {
  @Guide(description: "Role identifier string - typically 'platform', 'developer', 'user', 'agent', but can be any actor perspective")
  public let title: String

  public init(_ title: String) {
    self.title = title
  }
  
  public var description: String {
    "@role(\(title))"
  }
}
