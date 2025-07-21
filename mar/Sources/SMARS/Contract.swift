//
//  Contract.swift
//  Host
//
//  Created by David Ingle on 2025-07-21.
//

import Foundation
import FoundationModels

@Generable
public struct Contract: Codable, Sendable, CustomStringConvertible, Hashable {
  @Generable
  public enum Clause: Codable, Sendable, CustomStringConvertible, Hashable {
    /// Precondition that must be true before execution
    case requires(String)
    /// Postcondition guaranteed to be true after successful execution
    case ensures(String)

    public var description: String {
      switch self {
      case .requires(let expression): "⊨r:\(expression)"
      case .ensures(let expression): "⊨e:\(expression)"
      }
    }
  }

  @Guide(description: "Unique identifier for this behavioral contract")
  public let contractID: String
  @Guide(description: "The scope this contract applies to - typically a maplet or apply call identifier")
  public let scopeID: String
  @Guide(description: "Array of requires and ensures clauses that define the contract")
  public let clauses: [Clause]

  public var description: String {
    let body = clauses
      .map(\.description)
      .joined(separator: "\n  ")
    return """
    ¤\(contractID)∶\(scopeID){
      \(body)
    }
    """
  }

  public init(contractID: String, scopeID: String, clauses: [Clause]) {
    self.contractID = contractID
    self.scopeID = scopeID
    self.clauses = clauses
  }
}

