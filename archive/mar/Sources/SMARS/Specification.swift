//
//  Specification.swift
//  Host
//
//  Created by David Ingle on 2025-07-21.
//

import Foundation
import FoundationModels

@Generable(description: "A serializable, uniquely stringified ISO 8601 date for deterministic code generation and traceability.")
public struct GenerableDate: Sendable, Hashable, CustomStringConvertible {
  public let dateString: String

  public init() {
    self.dateString = ISO8601DateFormatter().string(from: Date())
  }

  public init(_ date: Date) {
    self.dateString = ISO8601DateFormatter().string(from: date)
  }

  public var description: String {
    dateString
  }

  public var date: Date {
    ISO8601DateFormatter().date(from: dateString)!
  }
}

@Generable(description: "A complete, role-anchored system specification: defines all atoms (types, constants, signatures, requirements, plans, and branches) for multi-agent reasoning with contextual boundaries.")
public struct SMARSSpecification: Sendable, Hashable, CustomStringConvertible {
  @Guide(description: "Globally unique, human-readable identifier for this specification (e.g., system or project name)")
  public let id: String
  
  @Guide(description: "Root actor or perspective—controls interpretation and authority across the specification")
  public let role: Role
  
  @Guide(description: "Schema definitions: custom structured types with named, typed fields")
  public let kinds: [Kind]
  
  @Guide(description: "Immutable symbolic constants—configuration or reference values shared across the system")
  public let data: [Datum]
  
  @Guide(description: "Function signatures/interfaces: input-output type declarations without implementations")
  public let maplets: [Maplet]
  
  @Guide(description: "Specific function/maplet invocations: actual arguments and results for each call")
  public let applications: [Apply]
  
  @Guide(description: "Interface requirements: preconditions, postconditions, and guarantees for behavioral correctness")
  public let contracts: [Contract]
  
  @Guide(description: "Procedural workflows—ordered steps, often for multi-step tasks or goals, with confidence tracking")
  public let plans: [Plan]
  
  @Guide(description: "Conditional logic: decision points and execution paths based on runtime criteria")
  public let branches: [Branch]
  
  public init(id: String,
              role: Role,
              kinds: [Kind] = [],
              data: [Datum] = [],
              maplets: [Maplet] = [],
              applications: [Apply] = [],
              contracts: [Contract] = [],
              plans: [Plan] = [],
              branches: [Branch] = []) {
    self.id = id
    self.role = role
    self.kinds = kinds
    self.data = data
    self.maplets = maplets
    self.applications = applications
    self.contracts = contracts
    self.plans = plans
    self.branches = branches
  }
  
  // MARK: - CustomStringConvertible (symbolic serialisation)
  
  public var description: String {
    var components: [String] = []
    
    // Role declaration
    components.append(role.description)
    
    // Add each atom type if present
    if !kinds.isEmpty {
      let kindsList = kinds.map(\.description).joined(separator: "\n")
      components.append("// Kinds\n\(kindsList)")
    }
    
    if !data.isEmpty {
      let dataList = data.map(\.description).joined(separator: "\n")
      components.append("// Data\n\(dataList)")
    }
    
    if !maplets.isEmpty {
      let mapletsList = maplets.map(\.description).joined(separator: "\n")
      components.append("// Maplets\n\(mapletsList)")
    }
    
    if !applications.isEmpty {
      let applicationsList = applications.map(\.description).joined(separator: "\n")
      components.append("// Applications\n\(applicationsList)")
    }
    
    if !contracts.isEmpty {
      let contractsList = contracts.map(\.description).joined(separator: "\n")
      components.append("// Contracts\n\(contractsList)")
    }
    
    if !plans.isEmpty {
      let plansList = plans.map(\.description).joined(separator: "\n")
      components.append("// Plans\n\(plansList)")
    }
    
    if !branches.isEmpty {
      let branchesList = branches.map(\.description).joined(separator: "\n")
      components.append("// Branches\n\(branchesList)")
    }
    
    return components.joined(separator: "\n\n")
  }
}


// MARK: - Language Model Integration Extensions

public extension SMARSSpecification {
  /// Create a specification optimized for language model consumption
  func forLanguageModel() -> String {
    """
    SMARS Specification: \(id)
    Role: \(role.title)
    
    \(description)
    """
  }
  
  /// Create a compact representation for context-constrained scenarios
  func compact() -> String {
    let totalAtoms = kinds.count + data.count + maplets.count + applications.count + 
                    contracts.count + plans.count + branches.count
    
    return "SMARS[\(id)]@\(role.title):{\(totalAtoms)atoms}"
  }
  
  /// Validate the specification for completeness
  var isValid: Bool {
    // Basic validation: must have at least one atom and valid role
    let hasAtoms = kinds.count + data.count + maplets.count + applications.count + 
                   contracts.count + plans.count + branches.count > 0
    let hasValidRole = !role.title.isEmpty
    
    return hasAtoms && hasValidRole
  }
  
  /// Get all atom identifiers for reference checking
  var allIdentifiers: Set<String> {
    var identifiers = Set<String>()
    
    identifiers.formUnion(kinds.map(\.name))
    identifiers.formUnion(data.map(\.name))
    identifiers.formUnion(maplets.map(\.name))
    identifiers.formUnion(applications.map(\.callID))
    identifiers.formUnion(contracts.map(\.contractID))
    identifiers.formUnion(plans.map(\.planID))
    identifiers.formUnion(branches.map(\.branchID))
    
    return identifiers
  }
}

