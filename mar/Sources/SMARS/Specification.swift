//
//  Specification.swift
//  Host
//
//  Created by David Ingle on 2025-07-21.
//

import Foundation
import FoundationModels

@Generable
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

@Generable
public struct SMARSSpecification: Sendable, Hashable, CustomStringConvertible {
  @Guide(description: "Unique identifier for this specification")
  public let id: String
  
  @Guide(description: "The role context for this specification (e.g., platform, developer, user)")
  public let role: Role
  
  @Guide(description: "Data structure type definitions")
  public let kinds: [Kind]
  
  @Guide(description: "Symbolic constants with values")
  public let data: [Datum]
  
  @Guide(description: "Function type declarations")
  public let maplets: [Maplet]
  
  @Guide(description: "Function application instances")
  public let applications: [Apply]
  
  @Guide(description: "Behavioral contracts with preconditions and postconditions")
  public let contracts: [Contract]
  
  @Guide(description: "Ordered procedural plans with confidence metrics")
  public let plans: [Plan]
  
  @Guide(description: "Conditional branching logic")
  public let branches: [Branch]
  
  @Guide(description: "Metadata about this specification")
  public let metadata: SpecificationMetadata
  
  public init(id: String,
              role: Role,
              kinds: [Kind] = [],
              data: [Datum] = [],
              maplets: [Maplet] = [],
              applications: [Apply] = [],
              contracts: [Contract] = [],
              plans: [Plan] = [],
              branches: [Branch] = [],
              metadata: SpecificationMetadata = SpecificationMetadata()) {
    self.id = id
    self.role = role
    self.kinds = kinds
    self.data = data
    self.maplets = maplets
    self.applications = applications
    self.contracts = contracts
    self.plans = plans
    self.branches = branches
    self.metadata = metadata
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

@Generable
public struct SpecificationMetadata: Sendable, Hashable, CustomStringConvertible {
  @Guide(description: "When this specification was created")
  public let created: GenerableDate
  
  @Guide(description: "When this specification was last modified")
  public let modified: GenerableDate
  
  @Guide(description: "Version identifier for this specification")
  public let version: String
  
  @Guide(description: "Intent of what this specification defines")
  public let intent: String

  @Guide(description: "Optional array of tags for categorizing this specification")
  public let tags: [String]
  
  public init(created: GenerableDate = GenerableDate(),
              modified: GenerableDate = GenerableDate(),
              version: String = "1.0.0",
              intent: String = "",
              tags: [String] = []) {
    self.created = created
    self.modified = modified
    self.version = version
    self.intent = intent
    self.tags = tags
  }
  
  public var description: String {
    var components = ["v\(version)", "created:\(created)", "modified:\(modified)"]
    components.append("intent:\(intent)")
    
    if !tags.isEmpty {
      components.append("tags:[\(tags.joined(separator: ","))]")
    }
    
    return components.joined(separator: " ")
  }
}

// MARK: - Language Model Integration Extensions

public extension SMARSSpecification {
  /// Create a specification optimized for language model consumption
  func forLanguageModel() -> String {
    """
    SMARS Specification: \(id)
    Role: \(role.title)
    Version: \(metadata.version)
    
    \(description)
    
    Metadata: \(metadata.description)")
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

