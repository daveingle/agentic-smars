//
//  Plan.swift
//  Host
//
//  Created by David Ingle on 2025-07-21.
//

import Foundation
import FoundationModels

@Generable(description: "Ordered procedural plan with steps, confidence metrics, and uncertainty tracking")
public struct Plan: Sendable, Hashable, CustomStringConvertible {
  @Guide(description: "Unique plan identifier - typically descriptive name in snake_case")
  public let planID: String
  @Guide(description: "Ordered list of step identifiers - each should reference a Maplet or Apply")
  public let steps: [String]
  @Guide(description: "Confidence level between 0.0 and 1.0 representing expected success probability")
  public let confidence: Double?
  @Guide(description: "List of uncertainty sources that could affect execution - helps with risk assessment")
  public let uncertaintySources: [String]
  
  public init(planID: String, 
              steps: [String], 
              confidence: Double? = nil,
              uncertaintySources: [String] = []) {
    self.planID = planID
    self.steps = steps
    self.confidence = confidence
    self.uncertaintySources = uncertaintySources
  }
  
  // MARK: - CustomStringConvertible (symbolic serialisation)
  
  public var description: String {
    var components = ["π\(planID)"]
    
    if let confidence = confidence {
      components.append("c:\(confidence)")
    }
    
    if !uncertaintySources.isEmpty {
      let sources = uncertaintySources.joined(separator: ",")
      components.append("u:[\(sources)]")
    }
    
    let stepsList = steps.joined(separator: ",")
    components.append("§[\(stepsList)]")
    
    return components.joined(separator: "∶")
  }
}

public extension Plan {
  /// Convenience initializer with confidence
  init(_ planID: String, 
       confidence: Double,
       steps: String...) {
    self.init(planID: planID, 
              steps: steps, 
              confidence: confidence)
  }
  
  /// Convenience initializer without confidence
  init(_ planID: String, 
       steps: String...) {
    self.init(planID: planID, 
              steps: steps)
  }
  
  /// Convenience initializer with uncertainty sources
  init(_ planID: String,
       confidence: Double,
       uncertaintySources: [String],
       steps: String...) {
    self.init(planID: planID,
              steps: steps,
              confidence: confidence, 
              uncertaintySources: uncertaintySources)
  }
}
