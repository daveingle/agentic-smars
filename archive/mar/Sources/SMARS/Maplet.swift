//
//  File.swift
//  Host
//
//  Created by David Ingle on 2025-07-21.
//

import Foundation
import FoundationModels

@Generable(description: "Function type declaration specifying domain and codomain - defines function signature without implementation")
public struct Maplet: Sendable, Hashable, CustomStringConvertible {
  @Guide(description: "Function name identifier - should be descriptive and typically snake_case")
  public let name: String
  @Guide(description: "Input type domain - single type or tuple like (Type1, Type2) for multiple parameters")
  public let domain: String
  @Guide(description: "Output type codomain - return type of the function")
  public let codomain: String

  public init(_ name: String, domain: String, codomain: String) {
    self.name = name
    self.domain = domain
    self.codomain = codomain
  }

  public var description: String {
    "µ\(name)∷\(domain)→\(codomain)"
  }
}
