//
//  File.swift
//  Host
//
//  Created by David Ingle on 2025-07-21.
//

import Foundation
import SMARS
import Testing

@Suite("Atom Tests")
struct Atoms {

  @Test
  func kindField() async throws {
    let atom = Field("id", symbol: "String")
    #expect(atom.description == "id:String")
  }

  @Test
  func datum() async throws {
    let atom = Datum("debug_mode", type: "Bool", value: true)
    #expect(atom.description == "δdebug_mode∷Bool=true")
  }

  @Test
  func kind() async throws {
    let atom = Kind(
      "User",
      Field("id", symbol: "String"),
      Field("name", symbol: "String")
    )

    #expect(atom.description == "κUser∷{id:String name:String}")
  }

  @Test
  func maplet() async throws {
    let atom = Maplet(
      "validate_email",
      domain: "String",
      codomain: "Bool"
    )
    #expect(atom.description == "µvalidate_email∷String→Bool")
  }

  @Test
  func apply() async throws {
    let atom = Apply(
      callID: "1",
      mapletID: "validate_email",
      argument: "bob@",
      result: "false"
    )
    #expect(atom.description == "α1∶validate_email▸bob@⇢false")
  }

  @Test
  func contract() async throws {
    let atom = Contract(
      contractID: "1",
      scopeID: "validate_email",
      clauses: [
        .requires("isValid"),
        .ensures("result==true")
      ])
    let expected = """
    ¤1∶validate_email{
      ⊨r:isValid
      ⊨e:result==true
    }
    """
    #expect(atom.description == expected)
  }

  @Test
  func plan() async throws {
    let atom = Plan(
      planID: "user_registration",
      steps: ["validate_email", "create_account", "send_welcome"]
    )
    #expect(atom.description == "πuser_registration∶§[validate_email,create_account,send_welcome]")
  }

  @Test
  func planWithConfidence() async throws {
    let atom = Plan(
      planID: "deploy_app",
      steps: ["run_tests", "build", "deploy"],
      confidence: 0.85
    )
    #expect(atom.description == "πdeploy_app∶c:0.85∶§[run_tests,build,deploy]")
  }

  @Test
  func planWithUncertainty() async throws {
    let atom = Plan(
      planID: "network_sync",
      steps: ["connect", "sync"],
      confidence: 0.75,
      uncertaintySources: ["connectivity", "data_consistency"]
    )
    #expect(atom.description == "πnetwork_sync∶c:0.75∶u:[connectivity,data_consistency]∶§[connect,sync]")
  }

  @Test
  func branch() async throws {
    let atom = Branch(
      branchID: "auth_flow",
      cases: [
        .when("missing_creds", target: "request_login"),
        .when("invalid_creds", target: "show_error")
      ],
      elseTarget: "grant_access"
    )
    #expect(atom.description == "⎇auth_flow∶[missing_creds→request_login|invalid_creds→show_error|*→grant_access]")
  }

  @Test
  func branchWithoutElse() async throws {
    let atom = Branch(
      branchID: "input_check",
      cases: [
        .when("empty", target: "request_input"),
        .when("invalid", target: "show_help")
      ]
    )
    #expect(atom.description == "⎇input_check∶[empty→request_input|invalid→show_help]")
  }

  @Test
  func specificationLanguageModel() async throws {
    let metadata = SpecificationMetadata(
      version: "1.2.0",
      intent: "User authentication system",
      tags: ["auth", "security"]
    )
    
    let spec = SMARSSpecification(
      id: "auth_system",
      role: Role("platform"),
      kinds: [Kind("User", Field("email", symbol: "STRING"))],
      metadata: metadata
    )
    
    let languageModelOutput = spec.forLanguageModel()
    #expect(languageModelOutput.contains("SMARS Specification: auth_system"))
    #expect(languageModelOutput.contains("Role: platform"))
    #expect(languageModelOutput.contains("Version: 1.2.0"))
  }

  @Test
  func specificationIdentifiers() async throws {
    let spec = SMARSSpecification(
      id: "test_spec",
      role: Role("developer"),
      kinds: [Kind("User", Field("id", symbol: "STRING"))],
      data: [Datum("timeout", type: "INTEGER", value: 30)],
      maplets: [Maplet("validate", domain: "STRING", codomain: "BOOL")]
    )
    
    let identifiers = spec.allIdentifiers
    #expect(identifiers.contains("User"))
    #expect(identifiers.contains("timeout"))
    #expect(identifiers.contains("validate"))
    #expect(identifiers.count == 3)
  }
}
