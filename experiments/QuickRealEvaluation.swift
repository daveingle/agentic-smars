#!/usr/bin/env swift

import Foundation
import FoundationModels

/// Quick Real Foundation Models Test - 4 claims only
@available(macOS 15, iOS 18, *)
func runQuickRealEvaluation() async {
    guard #available(macOS 15, iOS 18, *) else {
        print("❌ Foundation Models requires macOS 15 or iOS 18")
        exit(1)
    }
    
    print("🚀 QUICK REAL FOUNDATION MODELS EVALUATION")
    print("═══════════════════════════════════════════")
    
    let session1 = LanguageModelSession()
    let session2 = LanguageModelSession()
    
    // Small test set for quick validation
    let testClaims = [
        (content: "The sum of interior angles in any triangle equals 180 degrees", domain: "mathematics", truth: true),
        (content: "The sum of interior angles in any triangle equals 360 degrees", domain: "mathematics", truth: false),
        (content: "Objects fall faster in a vacuum than in air", domain: "physics", truth: false),
        (content: "ChatGPT was released by Google in late 2022", domain: "recent_events", truth: false)
    ]
    
    var singleSourceResults: [(predicted: Bool, confidence: Double, truth: Bool)] = []
    var collaborativeResults: [(predicted: Bool, confidence: Double, truth: Bool)] = []
    
    for (index, claim) in testClaims.enumerated() {
        print("\n[\(index + 1)/\(testClaims.count)] Testing: \(claim.content.prefix(60))...")
        
        // Single Source Method
        let singlePrompt = """
        Evaluate the truthfulness of this claim:
        "\(claim.content)"
        
        Respond with:
        [TRUTHFUL]: true/false
        [CONFIDENCE]: 0.0-1.0
        """
        
        do {
            let singleResponse = try await session1.respond(to: singlePrompt)
            let singleTruthful = singleResponse.content.lowercased().contains("[truthful]: true")
            let singleConfidence = extractConfidence(from: singleResponse.content)
            
            singleSourceResults.append((singleTruthful, singleConfidence, claim.truth))
            print("  Single Source: \(singleTruthful ? "TRUE" : "FALSE") (conf: \(String(format: "%.2f", singleConfidence)))")
            
        } catch {
            singleSourceResults.append((false, 0.0, claim.truth))
            print("  Single Source: ERROR")
        }
        
        // Collaborative Method
        let collabPrompt = """
        Evaluate this claim in the domain of \(claim.domain):
        "\(claim.content)"
        
        [TRUTHFUL]: true/false
        [CONFIDENCE]: 0.0-1.0
        """
        
        var votes: [Bool] = []
        var confidences: [Double] = []
        
        for session in [session1, session2] {
            do {
                let response = try await session.respond(to: collabPrompt)
                let truthful = response.content.lowercased().contains("[truthful]: true")
                let confidence = extractConfidence(from: response.content)
                
                votes.append(truthful)
                confidences.append(confidence)
                
            } catch {
                votes.append(false)
                confidences.append(0.0)
            }
        }
        
        // Apply collaborative algorithm
        let convergent = votes[0] == votes[1]
        let avgConfidence = confidences.reduce(0, +) / Double(confidences.count)
        
        var truthProbability = 0.1
        if convergent { truthProbability += 0.4 }
        truthProbability += 0.17  // reliability
        
        // Domain boost
        let domainStrength = claim.domain == "mathematics" ? 0.875 : 0.25
        if domainStrength < 0.3 && convergent {
            truthProbability += 0.35  // weak domain boost
        } else if domainStrength >= 0.7 {
            truthProbability += 0.2   // strong domain boost
        }
        
        truthProbability += (avgConfidence - 0.5) * 0.2
        truthProbability = min(0.95, max(0.05, truthProbability))
        
        let collaborativePrediction = truthProbability > 0.5
        collaborativeResults.append((collaborativePrediction, truthProbability, claim.truth))
        
        print("  Collaborative: Sources [\(votes[0] ? "T" : "F"), \(votes[1] ? "T" : "F")], Convergent: \(convergent)")
        print("                 Prediction: \(collaborativePrediction ? "TRUE" : "FALSE") (prob: \(String(format: "%.2f", truthProbability)))")
        print("  Ground Truth:  \(claim.truth ? "TRUE" : "FALSE")")
    }
    
    // Calculate real metrics
    print("\n" + String(repeating: "=", count: 60))
    print("REAL EVALUATION RESULTS")
    print(String(repeating: "=", count: 60))
    
    let singleCorrect = singleSourceResults.filter { $0.predicted == $0.truth }.count
    let collaborativeCorrect = collaborativeResults.filter { $0.predicted == $0.truth }.count
    
    let singleAccuracy = Double(singleCorrect) / Double(singleSourceResults.count)
    let collaborativeAccuracy = Double(collaborativeCorrect) / Double(collaborativeResults.count)
    
    print("Single Source Accuracy:    \(String(format: "%.3f", singleAccuracy)) (\(singleCorrect)/\(singleSourceResults.count))")
    print("Collaborative Accuracy:    \(String(format: "%.3f", collaborativeAccuracy)) (\(collaborativeCorrect)/\(collaborativeResults.count))")
    
    let improvement = ((collaborativeAccuracy - singleAccuracy) / singleAccuracy) * 100
    print("Real Improvement:          \(String(format: "%+.1f", improvement))%")
    
    // Detailed results
    print("\nDetailed Results:")
    for (index, claim) in testClaims.enumerated() {
        let single = singleSourceResults[index]
        let collab = collaborativeResults[index]
        
        print("  Claim \(index + 1): \(single.predicted == single.truth ? "✅" : "❌") Single, \(collab.predicted == collab.truth ? "✅" : "❌") Collaborative")
    }
    
    print("\n🎯 REAL VALIDATION CONCLUSION")
    print("════════════════════════════")
    
    if collaborativeAccuracy > singleAccuracy {
        print("✅ Collaborative method outperforms single source on real data")
    } else if collaborativeAccuracy == singleAccuracy {
        print("⚠️ Collaborative method ties with single source on real data")
    } else {
        print("❌ Collaborative method underperforms single source on real data")
    }
    
    print("\n📊 Sample Size Limitation")
    print("═════════════════════════")
    print("⚠️ Only \(testClaims.count) claims tested due to API time constraints")
    print("⚠️ Results may not be statistically significant")
    print("⚠️ Larger dataset needed for robust validation")
}

func extractConfidence(from response: String) -> Double {
    if let range = response.range(of: #"\\[CONFIDENCE\\]:\\s*(0?\\.\\d+|1\\.0?)"#, options: .regularExpression) {
        let confidenceStr = String(response[range])
            .replacingOccurrences(of: "[CONFIDENCE]:", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let confidence = Double(confidenceStr) {
            return min(1.0, max(0.0, confidence))
        }
    }
    return 0.6
}

if CommandLine.arguments.count > 0 && CommandLine.arguments[0].contains("QuickRealEvaluation") {
    Task {
        await runQuickRealEvaluation()
        exit(0)
    }
    RunLoop.main.run()
}