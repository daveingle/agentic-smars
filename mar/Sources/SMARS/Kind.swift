//
//  Kind.swift
//  Host
//
//  Created by David Ingle on 2025‑07‑21.
//

import Foundation
import FoundationModels

@Generable(description: "Data structure definition with named typed fields - equivalent to struct or record types")
public struct Kind: Sendable, Hashable, CustomStringConvertible {
  @Guide(description: "Unique type name identifier - should be CamelCase and descriptive")
  public let name: String
  @Guide(description: "List of typed fields defining the structure schema - each field has name and type symbol")
  public let fields: [Field]

  public init(_ name: String, _ fields: Field...) {
    self.name = name
    self.fields = fields
  }

  // MARK: ‑ CustomStringConvertible (symbolic serialisation)

  public var description: String {
    let body = fields
      .map(\.description)
      .joined(separator: " ")
    return "κ\(name)∷{\(body)}"
  }
}

// MARK: ‑ Field

@Generable(description: "Typed field within a Kind structure - defines name and type for a single data element")
public struct Field: Sendable, Hashable, CustomStringConvertible {
  @Guide(description: "Field name - should be camelCase identifier")
  public let name: String
  @Guide(description: "Type symbol - primitive types (STRING, INTEGER, FLOAT, BOOL) or custom Kind names")
  public let symbol: String

  public init(_ name: String, symbol: String) {
    self.name = name
    self.symbol = symbol
  }

  public var description: String { "\(name):\(symbol)" }
}
