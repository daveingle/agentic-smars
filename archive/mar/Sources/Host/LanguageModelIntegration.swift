//
//  LanguageModelIntegration.swift
//  Host
//
//  Created by David Ingle on 2025-07-21.
//

import Foundation
import FoundationModels
import SMARS

// MARK: - SMARS Language Session Integration

/// Protocol for SMARS-aware language model sessions
public protocol SMARSLanguageSession {
  /// Process a SMARS specification and generate response based on role context
  func process(specification: SMARSSpecification) async throws -> String
  
  /// Generate atoms from natural language description within a role context
  func generateAtoms(from description: String, role: Role) async throws -> SMARSSpecification
  
  /// Validate and suggest improvements for a SMARS specification
  func validate(specification: SMARSSpecification) async throws -> ValidationResult
  
  /// Execute a plan from a SMARS specification
  func execute(plan: Plan, from specification: SMARSSpecification) async throws -> ExecutionResult
}

@Generable
public struct ValidationResult: Sendable, Hashable, CustomStringConvertible {
  @Guide(description: "Whether the specification passed validation")
  public let isValid: Bool
  
  @Guide(description: "Array of validation issues found")
  public let issues: [ValidationIssue]
  
  @Guide(description: "Suggested improvements for the specification")
  public let suggestions: [String]
  
  @Guide(description: "Confidence level in the validation (0.0 to 1.0)")
  public let confidence: Double
  
  public var description: String {
    let status = isValid ? "VALID" : "INVALID"
    return "ValidationResult[\(status), \(issues.count)issues, confidence:\(confidence)]"
  }
}

@Generable
public struct ValidationIssue: Sendable, Hashable, CustomStringConvertible {
  @Guide(description: "Severity level of the issue")
  public let severity: Severity
  
  @Guide(description: "Human-readable description of the issue")
  public let message: String
  
  @Guide(description: "The atom identifier where the issue was found")
  public let atomID: String?
  
  @Guide(description: "Suggested fix for this issue")
  public let suggestedFix: String?
  
  @Generable
  public enum Severity: String, Sendable, CaseIterable {
    case error = "ERROR"
    case warning = "WARNING" 
    case info = "INFO"
  }
  
  public var description: String {
    var components = [severity.rawValue, message]
    if let atomID = atomID {
      components.append("@\(atomID)")
    }
    return components.joined(separator: ": ")
  }
}

@Generable
public struct ExecutionResult: Sendable, Hashable, CustomStringConvertible {
  @Guide(description: "Whether the plan executed successfully")
  public let success: Bool
  
  @Guide(description: "Array of step results from plan execution")
  public let stepResults: [StepResult]
  
  @Guide(description: "Final output or error message")
  public let output: String
  
  @Guide(description: "Execution duration in seconds")
  public let duration: TimeInterval
  
  @Guide(description: "Confidence in the execution result (0.0 to 1.0)")
  public let confidence: Double?
  
  public var description: String {
    let status = success ? "SUCCESS" : "FAILED"
    let steps = stepResults.count
    return "ExecutionResult[\(status), \(steps)steps, \(duration)s]"
  }
}

@Generable
public struct StepResult: Sendable, Hashable, CustomStringConvertible {
  @Guide(description: "The step identifier that was executed")
  public let stepID: String
  
  @Guide(description: "Whether this step completed successfully")
  public let success: Bool
  
  @Guide(description: "Output from this step execution")
  public let output: String?
  
  @Guide(description: "Error message if step failed")
  public let error: String?
  
  @Guide(description: "Execution duration for this step")
  public let duration: TimeInterval
  
  public var description: String {
    let status = success ? "✓" : "✗"
    return "\(status)\(stepID)(\(duration)s)"
  }
}

// MARK: - Language Model Prompt Generation

public extension SMARSSpecification {
  /// Generate a system prompt for language model sessions
  func systemPrompt() -> String {
    """
    You are working with a SMARS (Symbolic Multi-Agent Reasoning System) specification.
    
    Role Context: \(role.title)
    Specification ID: \(id)
    
    Available Atoms:
    - Kind: Data structure definitions
    - Datum: Symbolic constants  
    - Maplet: Function declarations
    - Apply: Function calls
    - Contract: Behavioral requirements
    - Plan: Procedural workflows
    - Branche: Conditional logic
    
    When working with specifications:
    1. Respect the role context
    2. Maintain consistency with existing atoms
    3. Follow symbolic conventions
    4. Provide concrete, reality-grounded outputs
    5. Use confidence metrics for uncertain operations
    
    Current specification:
    \(self.description)
    """
  }
  
  /// Generate a user prompt for specific tasks
  func userPrompt(task: String) -> String {
    """
    Task: \(task)
    
    Context: \(compact())
    
    Please work with the SMARS specification above to complete this task.
    Provide your response in the appropriate symbolic format when applicable.
    """
  }
  
  /// Generate a structured message for language model consumption
  func languageModelMessage(task: String? = nil) -> [String: Any] {
    var message: [String: Any] = [
      "specification_id": id,
      "role": role.title,
      "atom_counts": [
        "kinds": kinds.count,
        "data": data.count,
        "maplets": maplets.count,
        "applications": applications.count,
        "contracts": contracts.count,
        "plans": plans.count,
        "branches": branches.count
      ],
      "symbolic_representation": description
    ]
    
    if let task = task {
      message["task"] = task
    }
    
    return message
  }
}

// MARK: - Parsing and Generation Utilities

public extension SMARSSpecification {
  /// Parse a SMARS specification from symbolic text representation
  static func parse(from text: String) throws -> SMARSSpecification {
    // This would integrate with the SMARS parser from grammar/smars_parser.py
    // For now, return a basic implementation
    throw SMARSError.notImplemented("Parsing from text not yet implemented")
  }
  
  /// Generate executable code from this specification for a given target
  func generateCode(target: CodeGenTarget) throws -> String {
    switch target {
    case .swift:
      return generateSwiftCode()
    case .python:
      return generatePythonCode()
    case .typescript:
      return generateTypeScriptCode()
    }
  }
  
  private func generateSwiftCode() -> String {
    var code = "// Generated Swift code from SMARS specification: \(id)\n\n"
    
    // Generate structs from kinds
    for kind in kinds {
      code += "struct \(kind.name) {\n"
      for field in kind.fields {
        let swiftType = mapSMARSTypeToSwift(field.symbol)
        code += "  let \(field.name): \(swiftType)\n"
      }
      code += "}\n\n"
    }
    
    // Generate constants from data
    for datum in data {
      let swiftType = mapSMARSTypeToSwift(datum.type)
      code += "let \(datum.name): \(swiftType) = \(datum.value)\n"
    }
    
    return code
  }
  
  private func generatePythonCode() -> String {
    // Python code generation implementation
    return "# Generated Python code from SMARS specification: \(id)\n"
  }
  
  private func generateTypeScriptCode() -> String {
    // TypeScript code generation implementation
    return "// Generated TypeScript code from SMARS specification: \(id)\n"
  }
  
  private func mapSMARSTypeToSwift(_ smarsType: String) -> String {
    switch smarsType.uppercased() {
    case "STRING": return "String"
    case "INTEGER": return "Int"
    case "FLOAT": return "Double"
    case "BOOL", "BOOLEAN": return "Bool"
    default: return smarsType // Assume it's a custom type
    }
  }
}

@Generable
public enum CodeGenTarget: String, Sendable, CaseIterable {
  case swift = "swift"
  case python = "python"
  case typescript = "typescript"
}

@Generable
public enum SMARSError: Error, Sendable {
  case notImplemented(String)
  case parsingError(String)
  case validationError(String)
  case executionError(String)
}
