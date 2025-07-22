//
//  Contract.swift
//  Host
//
//  Created by David Ingle on 2025-07-21.
//

import Foundation
import FoundationModels

@Generable(description: "Behavioral contract with preconditions and postconditions that define function or system requirements")
public struct Contract: Codable, Sendable, CustomStringConvertible, Hashable {
  @Generable(description: "Contract clause specifying either a precondition or postcondition")
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

  @Guide(description: "Unique contract identifier - typically descriptive name ending in '_contract'")
  public let contractID: String
  @Guide(description: "Scope identifier this contract applies to - must reference existing Maplet or Apply callID")
  public let scopeID: String
  @Guide(description: "List of contract clauses - mix of requires (preconditions) and ensures (postconditions)")
  public let clauses: [Clause]

  public var description: String {
    let body = clauses
      .map(\.description)
      .joined(separator: "\n  ")
    return """
    §\(contractID)∶\(scopeID){
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

