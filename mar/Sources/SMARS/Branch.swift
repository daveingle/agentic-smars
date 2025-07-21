//
//  Branch.swift
//  Host
//
//  Created by David Ingle on 2025-07-21.
//

import Foundation
import FoundationModels

@Generable
public struct Branch: Sendable, Hashable, CustomStringConvertible {
  @Generable
  public struct Case: Sendable, Hashable, CustomStringConvertible {
    @Guide(description: "The conditional expression to evaluate")
    public let condition: String
    @Guide(description: "The target identifier to execute when condition is true")
    public let target: String
    
    public init(condition: String, target: String) {
      self.condition = condition
      self.target = target
    }
    
    public var description: String {
      "\(condition)→\(target)"
    }
  }
  
  @Guide(description: "Unique identifier for this conditional branch")
  public let branchID: String
  @Guide(description: "Array of condition-target pairs for branching logic")
  public let cases: [Case]
  @Guide(description: "Optional default target when no conditions match")
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
