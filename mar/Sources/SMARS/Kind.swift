//
//  Kind.swift
//  Host
//
//  Created by David Ingle on 2025‑07‑21.
//

import Foundation
import FoundationModels

@Generable
public struct Kind: Sendable, Hashable, CustomStringConvertible {
  @Guide(description: "The type name identifier for this data structure")
  public let name: String
  @Guide(description: "Array of typed fields that define the structure's schema")
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

@Generable
public struct Field: Sendable, Hashable, CustomStringConvertible {
  @Guide(description: "The field name identifier")
  public let name: String
  @Guide(description: "The type symbol for this field (e.g., STRING, INTEGER, BOOL, or custom type names)")
  public let symbol: String

  public init(_ name: String, symbol: String) {
    self.name = name
    self.symbol = symbol
  }

  public var description: String { "\(name):\(symbol)" }
}
