//
//  Role.swift
//  Host
//
//  Created by David Ingle on 2025-07-21.
//


import Foundation
import FoundationModels

@Generable
public struct Role: Sendable, Hashable, CustomStringConvertible  {
  @Guide(description: "The role identifier - any string identifying the actor's perspective (e.g., platform, developer, user, agent, etc.)")
  public let title: String

  public init(_ title: String) {
    self.title = title
  }
  
  public var description: String {
    "@role(\(title))"
  }
}
