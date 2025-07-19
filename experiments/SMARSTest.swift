#!/usr/bin/env swift

import Foundation
import FoundationModels

@available(macOS 15, iOS 18, *)
func testFoundationModelsIntegration() async {
    print("🧠 Testing Foundation Models Integration")
    print("📱 macOS version: \(ProcessInfo.processInfo.operatingSystemVersionString)")
    
    do {
        // Test basic session creation
        let session = LanguageModelSession()
        print("✅ LanguageModelSession created successfully")
        
        // Test basic prompt response
        let testPrompt = "What is 2 + 2? Respond with just the number."
        print("🔄 Sending test prompt: '\(testPrompt)'")
        
        let response = try await session.respond(to: testPrompt)
        print("✅ Response received: '\(response.content)'")
        
        // Test SMARS-related prompt
        let smarsPrompt = """
        You are helping execute a SMARS (Symbolic Multi-Agent Reasoning System) plan.
        Given this step: "validate_grammar_compliance"
        Suggest a concrete shell command to check if a file follows grammar rules.
        Respond with just the command, no explanation.
        """
        
        print("🔄 Sending SMARS prompt...")
        let smarsResponse = try await session.respond(to: smarsPrompt)
        print("✅ SMARS response: '\(smarsResponse.content)'")
        
        // Test confidence extraction
        let confidencePrompt = "Rate your confidence in the previous response from 0.0 to 1.0. Just return the number."
        let confidenceResponse = try await session.respond(to: confidencePrompt)
        print("✅ Confidence response: '\(confidenceResponse.content)'")
        
        print("\n🎉 Foundation Models integration test completed successfully!")
        
    } catch {
        print("❌ Foundation Models test failed: \(error)")
        print("Error details: \(error.localizedDescription)")
    }
}

@available(macOS 15, iOS 18, *)
func testSMARSParsing() {
    print("\n📋 Testing SMARS file parsing")
    
    let testSMARSContent = """
    @role(platform)
    
    (plan test_foundation_models
      confidence: 0.8
      § steps:
        - initialize_session
        - send_test_prompt
        - validate_response)
    """
    
    // Simple regex test for plan parsing
    let planPattern = #"\(plan\s+(\w+).*?§\s*steps:\s*((?:\s*-\s*\w+)+)\)"#
    let regex = try! NSRegularExpression(pattern: planPattern, options: [.dotMatchesLineSeparators])
    let matches = regex.matches(in: testSMARSContent, range: NSRange(testSMARSContent.startIndex..., in: testSMARSContent))
    
    if let match = matches.first,
       let identifierRange = Range(match.range(at: 1), in: testSMARSContent),
       let stepsRange = Range(match.range(at: 2), in: testSMARSContent) {
        let identifier = String(testSMARSContent[identifierRange])
        let stepsText = String(testSMARSContent[stepsRange])
        let steps = stepsText.components(separatedBy: "\n")
            .compactMap { line in
                let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmed.hasPrefix("-") ? String(trimmed.dropFirst().trimmingCharacters(in: .whitespacesAndNewlines)) : nil
            }
        
        print("✅ Parsed plan: \(identifier)")
        print("✅ Found \(steps.count) steps: \(steps)")
    } else {
        print("❌ Failed to parse SMARS plan")
    }
}

// Main execution
if #available(macOS 15, iOS 18, *) {
    testSMARSParsing()
    
    Task {
        await testFoundationModelsIntegration()
        exit(0)
    }
    
    RunLoop.main.run()
} else {
    print("❌ Foundation Models requires macOS 15 or iOS 18")
    exit(1)
}