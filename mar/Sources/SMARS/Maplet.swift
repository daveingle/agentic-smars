//
//  File.swift
//  Host
//
//  Created by David Ingle on 2025-07-21.
//

import Foundation
import FoundationModels

@Generable
public struct Maplet: Sendable, Hashable, CustomStringConvertible {
  @Guide(description: "The function name identifier")
  public let name: String
  @Guide(description: "The input type(s) - domain of the function (e.g., STRING, (STRING, INTEGER) for multiple parameters)")
  public let domain: String
  @Guide(description: "The output type - codomain of the function (e.g., BOOL, AuthResult)")
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
