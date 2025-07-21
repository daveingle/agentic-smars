//
//  Plan.swift
//  Host
//
//  Created by David Ingle on 2025-07-21.
//

import Foundation
import FoundationModels

@Generable
public struct Plan: Sendable, Hashable, CustomStringConvertible {
  @Guide(description: "Unique identifier for this procedural plan")
  public let planID: String
  @Guide(description: "Ordered sequence of step identifiers to be executed")
  public let steps: [String]
  @Guide(description: "Optional confidence level for plan success (0.0 to 1.0)")
  public let confidence: Double?
  @Guide(description: "Optional array of uncertainty sources that may affect plan execution")
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
