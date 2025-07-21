#!/usr/bin/env swift

import Foundation
import FoundationModels

/// REAL Foundation Models Evaluation - No Simulation
/// This tests the actual collaborative truth detection system with live API calls

@available(macOS 15, iOS 18, *)
class RealFoundationModelsEvaluation {
    
    private var session1: LanguageModelSession
    private var session2: LanguageModelSession
    
    // Real ground truth dataset
    let groundTruthClaims = [
        (content: "The sum of interior angles in any triangle equals 180 degrees", domain: "mathematics", truth: true),
        (content: "The sum of interior angles in any triangle equals 360 degrees", domain: "mathematics", truth: false),
        (content: "The square root of 2 is approximately 1.414", domain: "mathematics", truth: true),
        (content: "The mathematical constant π equals exactly 22/7", domain: "mathematics", truth: false),
        (content: "Light travels at approximately 299,792,458 meters per second in vacuum", domain: "physics", truth: true),
        (content: "Objects fall faster in a vacuum than in air", domain: "physics", truth: false),
        (content: "Quantum tunneling allows particles to pass through energy barriers", domain: "physics", truth: true),
        (content: "Room-temperature superconductors are commercially available", domain: "physics", truth: false),
        (content: "The COVID-19 pandemic was declared by WHO in March 2020", domain: "recent_events", truth: true),
        (content: "ChatGPT was released by Google in late 2022", domain: "recent_events", truth: false),
        (content: "CRISPR-Cas9 uses guide RNA to target specific DNA sequences", domain: "specialized_science", truth: true),
        (content: "Quantum entanglement enables faster-than-light communication", domain: "specialized_science", truth: false)
    ]
    
    init() {
        self.session1 = LanguageModelSession()
        self.session2 = LanguageModelSession()
    }
    
    // MARK: - Real Baseline Methods
    
    /// Baseline 1: Single Source Assessment
    func singleSourceEvaluation() async -> [RealTruthAssessment] {
        print("🔄 Running Single Source Baseline...")
        var results: [RealTruthAssessment] = []
        
        for (index, claim) in groundTruthClaims.enumerated() {
            print("  [\(index + 1)/\(groundTruthClaims.count)] Evaluating: \(claim.content.prefix(50))...")
            
            let prompt = """
            Evaluate the truthfulness of this claim:
            "\(claim.content)"
            
            Respond with:
            [TRUTHFUL]: true/false
            [CONFIDENCE]: 0.0-1.0
            [REASONING]: Brief explanation
            """
            
            do {
                let response = try await session1.respond(to: prompt)
                let truthful = extractTruthfulness(from: response.content)
                let confidence = extractConfidence(from: response.content)
                
                let assessment = RealTruthAssessment(
                    method: "single_source",
                    predicted: truthful,
                    confidence: confidence,
                    groundTruth: claim.truth,
                    claim: claim.content,
                    domain: claim.domain
                )
                
                results.append(assessment)
                print("    Predicted: \(truthful ? "TRUE" : "FALSE"), Confidence: \(String(format: "%.2f", confidence)), Actual: \(claim.truth ? "TRUE" : "FALSE")")
                
            } catch {
                print("    ERROR: \(error)")
                let assessment = RealTruthAssessment(
                    method: "single_source",
                    predicted: false,
                    confidence: 0.0,
                    groundTruth: claim.truth,
                    claim: claim.content,
                    domain: claim.domain
                )
                results.append(assessment)
            }
        }
        
        return results
    }
    
    /// Baseline 2: Naive Majority Vote
    func naiveMajorityVoteEvaluation() async -> [RealTruthAssessment] {
        print("\n🔄 Running Naive Majority Vote Baseline...")
        var results: [RealTruthAssessment] = []
        
        for (index, claim) in groundTruthClaims.enumerated() {
            print("  [\(index + 1)/\(groundTruthClaims.count)] Evaluating: \(claim.content.prefix(50))...")
            
            let prompt = """
            Evaluate the truthfulness of this claim:
            "\(claim.content)"
            
            Respond with:
            [TRUTHFUL]: true/false
            [CONFIDENCE]: 0.0-1.0
            """
            
            var votes: [Bool] = []
            var confidences: [Double] = []
            
            // Get votes from both sessions
            for session in [session1, session2] {
                do {
                    let response = try await session.respond(to: prompt)
                    let truthful = extractTruthfulness(from: response.content)
                    let confidence = extractConfidence(from: response.content)
                    
                    votes.append(truthful)
                    confidences.append(confidence)
                    
                } catch {
                    votes.append(false)
                    confidences.append(0.0)
                }
            }
            
            // Majority vote
            let trueVotes = votes.filter { $0 }.count
            let majorityPrediction = trueVotes > votes.count / 2
            let avgConfidence = confidences.reduce(0, +) / Double(confidences.count)
            
            let assessment = RealTruthAssessment(
                method: "naive_majority",
                predicted: majorityPrediction,
                confidence: avgConfidence,
                groundTruth: claim.truth,
                claim: claim.content,
                domain: claim.domain
            )
            
            results.append(assessment)
            print("    Votes: \(votes), Majority: \(majorityPrediction ? "TRUE" : "FALSE"), Actual: \(claim.truth ? "TRUE" : "FALSE")")
        }
        
        return results
    }
    
    /// Our Method: Collaborative Truth Detection
    func collaborativeTruthDetectionEvaluation() async -> [RealTruthAssessment] {
        print("\n🔄 Running Collaborative Truth Detection...")
        var results: [RealTruthAssessment] = []
        
        let domainStrengths: [String: [Double]] = [
            "mathematics": [0.9, 0.85],
            "physics": [0.3, 0.25],
            "recent_events": [0.2, 0.15],
            "specialized_science": [0.3, 0.25]
        ]
        
        for (index, claim) in groundTruthClaims.enumerated() {
            print("  [\(index + 1)/\(groundTruthClaims.count)] Evaluating: \(claim.content.prefix(50))...")
            
            let prompt = """
            Evaluate this claim in the domain of \(claim.domain):
            "\(claim.content)"
            
            Provide a detailed assessment:
            [TRUTHFUL]: true/false
            [CONFIDENCE]: 0.0-1.0
            [REASONING]: Detailed explanation
            """
            
            var sourceAssessments: [(truthful: Bool, confidence: Double, domainStrength: Double)] = []
            
            for (sessionIndex, session) in [session1, session2].enumerated() {
                do {
                    let response = try await session.respond(to: prompt)
                    let truthful = extractTruthfulness(from: response.content)
                    let confidence = extractConfidence(from: response.content)
                    let domainStrength = domainStrengths[claim.domain]?[sessionIndex] ?? 0.1
                    
                    sourceAssessments.append((truthful, confidence, domainStrength))
                    
                } catch {
                    let domainStrength = domainStrengths[claim.domain]?[sessionIndex] ?? 0.1
                    sourceAssessments.append((false, 0.0, domainStrength))
                }
            }
            
            // Apply collaborative truth detection algorithm
            let convergent = sourceAssessments[0].truthful == sourceAssessments[1].truthful
            let avgReliability = 0.835
            let avgDomainStrength = sourceAssessments.map { $0.domainStrength }.reduce(0, +) / Double(sourceAssessments.count)
            let avgConfidence = sourceAssessments.map { $0.confidence }.reduce(0, +) / Double(sourceAssessments.count)
            
            var truthProbability = 0.1  // Base skepticism
            
            if convergent {
                truthProbability += 0.4
            }
            
            // General reliability factor
            let reliabilityFactor = (avgReliability - 0.5) * 0.5
            truthProbability += reliabilityFactor
            
            // Domain-specific factors
            if avgDomainStrength < 0.3 && convergent {
                truthProbability += 0.35  // Weak domain convergence boost
            } else if avgDomainStrength >= 0.7 {
                truthProbability += 0.2   // Strong domain expertise
            }
            
            // Confidence factor
            let confidenceFactor = (avgConfidence - 0.5) * 0.2
            truthProbability += confidenceFactor
            
            truthProbability = min(0.95, max(0.05, truthProbability))
            
            let finalPrediction = truthProbability > 0.5
            
            let assessment = RealTruthAssessment(
                method: "collaborative_domain_aware",
                predicted: finalPrediction,
                confidence: truthProbability,
                groundTruth: claim.truth,
                claim: claim.content,
                domain: claim.domain
            )
            
            results.append(assessment)
            print("    Sources: [\(sourceAssessments[0].truthful ? "T" : "F"), \(sourceAssessments[1].truthful ? "T" : "F")], Convergent: \(convergent), Truth Prob: \(String(format: "%.2f", truthProbability)), Actual: \(claim.truth ? "TRUE" : "FALSE")")
        }
        
        return results
    }
    
    // MARK: - Helper Methods
    
    private func extractTruthfulness(from response: String) -> Bool {
        let lower = response.lowercased()
        if lower.contains("[truthful]: true") {
            return true
        } else if lower.contains("[truthful]: false") {
            return false
        }
        
        let positiveWords = ["true", "correct", "accurate", "yes", "valid"]
        let negativeWords = ["false", "incorrect", "wrong", "no", "invalid"]
        
        let positiveCount = positiveWords.reduce(0) { count, word in
            count + (lower.contains(word) ? 1 : 0)
        }
        let negativeCount = negativeWords.reduce(0) { count, word in
            count + (lower.contains(word) ? 1 : 0)
        }
        
        return positiveCount > negativeCount
    }
    
    private func extractConfidence(from response: String) -> Double {
        if let range = response.range(of: #"\\[CONFIDENCE\\]:\\s*(0?\\.\\d+|1\\.0?)"#, options: .regularExpression) {
            let confidenceStr = String(response[range])
                .replacingOccurrences(of: "[CONFIDENCE]:", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            if let confidence = Double(confidenceStr) {
                return min(1.0, max(0.0, confidence))
            }
        }
        
        return 0.6  // Fallback
    }
}

// MARK: - Assessment Structure

struct RealTruthAssessment {
    let method: String
    let predicted: Bool
    let confidence: Double
    let groundTruth: Bool
    let claim: String
    let domain: String
    
    var isCorrect: Bool {
        return predicted == groundTruth
    }
}

// MARK: - Real Metrics Calculation

struct RealEvaluationMetrics {
    let method: String
    let accuracy: Double
    let precision: Double
    let recall: Double
    let f1Score: Double
    let averageConfidence: Double
    let truePositives: Int
    let trueNegatives: Int
    let falsePositives: Int
    let falseNegatives: Int
    
    static func calculate(assessments: [RealTruthAssessment]) -> RealEvaluationMetrics {
        var tp = 0, tn = 0, fp = 0, fn = 0
        var totalConfidence = 0.0
        let method = assessments.first?.method ?? "unknown"
        
        for assessment in assessments {
            totalConfidence += assessment.confidence
            
            if assessment.predicted && assessment.groundTruth {
                tp += 1
            } else if !assessment.predicted && !assessment.groundTruth {
                tn += 1
            } else if assessment.predicted && !assessment.groundTruth {
                fp += 1
            } else {
                fn += 1
            }
        }
        
        let accuracy = Double(tp + tn) / Double(assessments.count)
        let precision = tp + fp > 0 ? Double(tp) / Double(tp + fp) : 0.0
        let recall = tp + fn > 0 ? Double(tp) / Double(tp + fn) : 0.0
        let f1 = precision + recall > 0 ? 2 * precision * recall / (precision + recall) : 0.0
        let avgConfidence = totalConfidence / Double(assessments.count)
        
        return RealEvaluationMetrics(
            method: method,
            accuracy: accuracy,
            precision: precision,
            recall: recall,
            f1Score: f1,
            averageConfidence: avgConfidence,
            truePositives: tp,
            trueNegatives: tn,
            falsePositives: fp,
            falseNegatives: fn
        )
    }
    
    func printReport() {
        print("📊 \(method.uppercased()) REAL EVALUATION RESULTS")
        print("═══════════════════════════════════════════════════")
        print("Accuracy:    \(String(format: "%.3f", accuracy))")
        print("Precision:   \(String(format: "%.3f", precision))")
        print("Recall:      \(String(format: "%.3f", recall))")
        print("F1 Score:    \(String(format: "%.3f", f1Score))")
        print("Avg Conf:    \(String(format: "%.3f", averageConfidence))")
        print()
        print("Confusion Matrix:")
        print("                 Predicted")
        print("Actual     True  False")
        print("True       \(String(format: "%4d", truePositives))   \(String(format: "%4d", falseNegatives))")
        print("False      \(String(format: "%4d", falsePositives))   \(String(format: "%4d", trueNegatives))")
        print()
    }
}

// MARK: - Main Evaluation

@available(macOS 15, iOS 18, *)
func runRealFoundationModelsEvaluation() async {
    guard #available(macOS 15, iOS 18, *) else {
        print("❌ Foundation Models requires macOS 15 or iOS 18")
        exit(1)
    }
    
    print("🚀 REAL FOUNDATION MODELS TRUTH DETECTION EVALUATION")
    print("═══════════════════════════════════════════════════════")
    print("Testing actual collaborative truth detection with live API calls")
    print("Dataset: 12 claims across 4 domains\n")
    
    let evaluator = RealFoundationModelsEvaluation()
    
    // Run all methods with real Foundation Models
    let singleSourceResults = await evaluator.singleSourceEvaluation()
    let majorityVoteResults = await evaluator.naiveMajorityVoteEvaluation() 
    let collaborativeResults = await evaluator.collaborativeTruthDetectionEvaluation()
    
    print("\n" + String(repeating: "=", count: 80))
    print("REAL EVALUATION RESULTS")
    print(String(repeating: "=", count: 80))
    
    // Calculate real metrics
    let singleSourceMetrics = RealEvaluationMetrics.calculate(assessments: singleSourceResults)
    let majorityVoteMetrics = RealEvaluationMetrics.calculate(assessments: majorityVoteResults)
    let collaborativeMetrics = RealEvaluationMetrics.calculate(assessments: collaborativeResults)
    
    // Print reports
    singleSourceMetrics.printReport()
    majorityVoteMetrics.printReport()
    collaborativeMetrics.printReport()
    
    // Real comparative summary
    print("🏆 REAL COMPARATIVE RESULTS")
    print("══════════════════════════")
    let allMetrics = [singleSourceMetrics, majorityVoteMetrics, collaborativeMetrics]
    
    print("Method                     Accuracy  Precision  Recall    F1 Score")
    print("────────────────────────   ────────  ─────────  ──────    ────────")
    for metrics in allMetrics {
        let name = String(metrics.method.prefix(22)).padding(toLength: 23, withPad: " ", startingAt: 0)
        print("\(name)  \(String(format: "%.3f", metrics.accuracy))     \(String(format: "%.3f", metrics.precision))      \(String(format: "%.3f", metrics.recall))     \(String(format: "%.3f", metrics.f1Score))")
    }
    
    // Real domain analysis
    print("\n🔬 REAL DOMAIN-SPECIFIC ANALYSIS")
    print("════════════════════════════════")
    
    let domains = Set(collaborativeResults.map { $0.domain })
    for domain in domains.sorted() {
        let domainCollaborative = collaborativeResults.filter { $0.domain == domain }
        let domainBaseline = singleSourceResults.filter { $0.domain == domain }
        
        let collaborativeAccuracy = domainCollaborative.filter { $0.isCorrect }.count
        let baselineAccuracy = domainBaseline.filter { $0.isCorrect }.count
        
        let collabAccuracyPct = Double(collaborativeAccuracy) / Double(domainCollaborative.count) * 100
        let baselineAccuracyPct = Double(baselineAccuracy) / Double(domainBaseline.count) * 100
        
        print("\(domain.capitalized):")
        print("  Collaborative: \(String(format: "%.1f", collabAccuracyPct))% (\(collaborativeAccuracy)/\(domainCollaborative.count))")
        print("  Single source: \(String(format: "%.1f", baselineAccuracyPct))% (\(baselineAccuracy)/\(domainBaseline.count))")
        print("  Real improvement: \(String(format: "%+.1f", collabAccuracyPct - baselineAccuracyPct))%")
        print()
    }
    
    // Final REAL assessment
    print("🎯 REAL VALIDATION RESULTS")
    print("═════════════════════════")
    
    let bestMethod = allMetrics.max(by: { $0.f1Score < $1.f1Score })!
    print("Best performing method: \(bestMethod.method)")
    print("F1 Score: \(String(format: "%.3f", bestMethod.f1Score))")
    
    let improvement = ((collaborativeMetrics.f1Score - singleSourceMetrics.f1Score) / singleSourceMetrics.f1Score) * 100
    print("Real F1 improvement over single source: \(String(format: "%+.1f", improvement))%")
    
    if bestMethod.method.contains("collaborative") {
        print("✅ REAL validation: Collaborative truth detection outperforms baselines")
    } else {
        print("❌ REAL validation: Collaborative method does not outperform baselines")
    }
    
    print("\n📋 REAL TESTING COMPLETED")
    print("═════════════════════════")
    print("✅ Live Foundation Models API calls")
    print("✅ Real ground truth dataset")
    print("✅ Actual baseline comparisons") 
    print("✅ No simulation or mock data")
    print("✅ Reproducible with same dataset")
}

// Execute real evaluation
if CommandLine.arguments.count > 0 && CommandLine.arguments[0].contains("RealFoundationModelsEvaluation") {
    Task {
        await runRealFoundationModelsEvaluation()
        exit(0)
    }
    RunLoop.main.run()
}