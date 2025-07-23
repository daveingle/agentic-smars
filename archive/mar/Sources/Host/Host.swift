
import Foundation
import FoundationModels
import SMARS


public struct SMARSConcierge {
  private let session = LanguageModelSession(instructions: """
    You are working with a SMARS (Symbolic Multi-Agent Reasoning System) specification.

    Available Atoms:
    - Kind: Data structure definitions
    - Datum: Symbolic constants  
    - Maplet: Function declarations
    - Apply: Function calls
    - Contract: Behavioral requirements
    - Plan: Procedural workflows
    - Branch: Conditional logic
    
    When working with specifications:
    1. Respect the role context
    2. Maintain consistency with existing atoms
    3. Follow symbolic conventions
    4. Provide concrete, reality-grounded outputs
    5. Use confidence metrics for uncertain operations
    """)

  public init() {

  }

  /// Request a comprehensive SMARS specification from the Foundation Model.
  /// - Parameter goal: A short description of the desired agentic workflow.
  /// - Returns: The raw specification text returned by the model.
  public func generateSpecification(for goal: String) async throws -> SMARSSpecification {
      let prompt = "Please generate a SMARS specification to accomplish this goal:\(goal)"
    let response = try await session.respond(
      to: prompt,
      generating: SMARSSpecification.self
    )
    return response.content
  }
}

import SwiftUI
import Playgrounds

#Playground {
  let concierge = SMARSConcierge()
  do {
    let spec = try await concierge.generateSpecification(for: "I want to make a peanut butter and jam sandwich")
    print(spec)
  } catch {
    print(error)
  }
}
