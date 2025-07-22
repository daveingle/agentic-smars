//
//  Branch.swift
//  Host
//
//  Created by David Ingle on 2025-07-21.
//

import Foundation
import FoundationModels

@Generable(description: "Conditional branching logic with multiple condition-target pairs and optional default case")
public struct Branch: Sendable, Hashable, CustomStringConvertible {
  @Generable(description: "Single condition-target pair within a branch - represents one possible execution path")
  public struct Case: Sendable, Hashable, CustomStringConvertible {
    @Guide(description: "Boolean condition expression - can be simple predicate or complex logical expression")
    public let condition: String
    @Guide(description: "Target identifier to execute when condition is true - references Plan or Apply")
    public let target: String
    
    public init(condition: String, target: String) {
      self.condition = condition
      self.target = target
    }
    
    public var description: String {
      "\(condition)→\(target)"
    }
  }
  
  @Guide(description: "Unique branch identifier - typically descriptive name ending in '_flow' or '_branch'")
  public let branchID: String
  @Guide(description: "List of condition-target cases - evaluated in order until first match")
  public let cases: [Case]
  @Guide(description: "Default target when no conditions match - should reference Plan or Apply identifier")
  public let elseTarget: String?
  
  public init(branchID: String, 
              cases: [Case],
              elseTarget: String? = nil) {
    self.branchID = branchID
    self.cases = cases
    self.elseTarget = elseTarget
  }
  
  // MARK: - CustomStringConvertible (symbolic serialisation)
  
  public var description: String {
    let caseDescriptions = cases.map(\.description).joined(separator: "|")
    var result = "⎇\(branchID)∶[\(caseDescriptions)"
    
    if let elseTarget = elseTarget {
      result += "|*→\(elseTarget)"
    }
    
    result += "]"
    return result
  }
}

public extension Branch {
  /// Convenience initializer for simple branches without else
  init(_ branchID: String, cases: Case...) {
    self.init(branchID: branchID, cases: cases)
  }
  
  /// Convenience initializer with else target
  init(_ branchID: String, elseTarget: String, cases: Case...) {
    self.init(branchID: branchID, cases: cases, elseTarget: elseTarget)
  }
}

public extension Branch.Case {
  /// Convenience factory method
  static func when(_ condition: String, target: String) -> Branch.Case {
    Branch.Case(condition: condition, target: target)
  }
}
