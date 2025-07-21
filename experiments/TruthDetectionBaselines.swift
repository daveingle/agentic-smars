#!/usr/bin/env swift

import Foundation
import FoundationModels

/// Baseline Comparison Systems for Truth Detection Evaluation
@available(macOS 15, iOS 18, *)
class TruthDetectionBaselines {
    
    private var session1: LanguageModelSession
    private var session2: LanguageModelSession
    
    init() {
        self.session1 = LanguageModelSession()
        self.session2 = LanguageModelSession()
    }
    
    // MARK: - Baseline Methods
    
    /// Baseline 1: Single Source Individual Assessment
    func singleSourceTruthAssessment(claim: GroundTruthDataset.LabeledClaim) async -> TruthAssessment {
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
            let reasoning = extractReasoning(from: response.content)
            
            return TruthAssessment(
                method: "single_source",
                predicted: truthful,
                confidence: confidence,
                reasoning: reasoning
            )
            
        } catch {
            return TruthAssessment(
                method: "single_source",
                predicted: false,
                confidence: 0.0,
                reasoning: "Error: \(error.localizedDescription)"
            )
        }
    }
    
    /// Baseline 2: Naive Majority Vote
    func naiveMajorityVote(claim: GroundTruthDataset.LabeledClaim) async -> TruthAssessment {
        let prompt = """
        Evaluate the truthfulness of this claim:
        "\(claim.content)"
        
        Respond with:
        [TRUTHFUL]: true/false
        [CONFIDENCE]: 0.0-1.0
        """
        
        var votes: [Bool] = []
        var confidences: [Double] = []
        
        // Get assessments from both sources
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
        
        // Simple majority vote
        let trueVotes = votes.filter { $0 }.count
        let majorityPrediction = trueVotes > votes.count / 2
        let avgConfidence = confidences.reduce(0, +) / Double(confidences.count)
        
        return TruthAssessment(
            method: "naive_majority",
            predicted: majorityPrediction,
            confidence: avgConfidence,
            reasoning: "Majority vote: \(trueVotes)/\(votes.count) voted true"
        )
    }
    
    /// Baseline 3: Reliability-Weighted Average
    func reliabilityWeightedAverage(claim: GroundTruthDataset.LabeledClaim) async -> TruthAssessment {
        // Simple reliability weights (in practice, these would be learned)
        let source1Reliability = 0.85
        let source2Reliability = 0.82
        
        let prompt = """
        Evaluate the truthfulness of this claim:
        "\(claim.content)"
        
        Respond with:
        [TRUTHFUL]: true/false
        [CONFIDENCE]: 0.0-1.0
        """
        
        var assessments: [(truthful: Bool, confidence: Double, reliability: Double)] = []
        
        for (session, reliability) in [(session1, source1Reliability), (session2, source2Reliability)] {
            do {
                let response = try await session.respond(to: prompt)
                let truthful = extractTruthfulness(from: response.content)
                let confidence = extractConfidence(from: response.content)
                
                assessments.append((truthful, confidence, reliability))
                
            } catch {
                assessments.append((false, 0.0, reliability))
            }
        }
        
        // Reliability-weighted scoring
        var weightedTruthScore = 0.0
        var totalWeight = 0.0
        var avgConfidence = 0.0
        var totalConfidenceWeight = 0.0
        
        for assessment in assessments {
            let weight = assessment.reliability
            weightedTruthScore += (assessment.truthful ? 1.0 : 0.0) * weight
            totalWeight += weight
            
            avgConfidence += assessment.confidence * weight
            totalConfidenceWeight += weight
        }
        
        let finalTruthScore = weightedTruthScore / totalWeight
        let finalConfidence = avgConfidence / totalConfidenceWeight
        let prediction = finalTruthScore > 0.5
        
        return TruthAssessment(
            method: "reliability_weighted",
            predicted: prediction,
            confidence: finalConfidence,
            reasoning: "Weighted truth score: \(String(format: "%.2f", finalTruthScore))"
        )
    }
    
    /// Our Method: Collaborative Truth Detection with Domain Awareness
    func collaborativeTruthDetection(claim: GroundTruthDataset.LabeledClaim) async -> TruthAssessment {
        // Domain strength mapping (simplified version)
        let domainStrengths: [String: [Double]] = [
            "mathematics": [0.9, 0.85],
            "physics": [0.3, 0.25],
            "recent_events": [0.2, 0.15],
            "specialized_science": [0.3, 0.25]
        ]
        
        let prompt = """
        Evaluate this claim in the domain of \(claim.domain):
        "\(claim.content)"
        
        Provide a detailed assessment:
        [TRUTHFUL]: true/false
        [CONFIDENCE]: 0.0-1.0
        [REASONING]: Detailed explanation
        """
        
        var sourceAssessments: [(truthful: Bool, confidence: Double, domainStrength: Double)] = []
        
        for (index, session) in [session1, session2].enumerated() {
            do {
                let response = try await session.respond(to: prompt)
                let truthful = extractTruthfulness(from: response.content)
                let confidence = extractConfidence(from: response.content)
                let domainStrength = domainStrengths[claim.domain]?[index] ?? 0.1
                
                sourceAssessments.append((truthful, confidence, domainStrength))
                
            } catch {
                let domainStrength = domainStrengths[claim.domain]?[index] ?? 0.1
                sourceAssessments.append((false, 0.0, domainStrength))
            }
        }
        
        // Apply collaborative truth detection algorithm
        let convergent = sourceAssessments[0].truthful == sourceAssessments[1].truthful
        let avgReliability = 0.835  // Average of 0.85 and 0.82
        let avgDomainStrength = sourceAssessments.map { $0.domainStrength }.reduce(0, +) / Double(sourceAssessments.count)
        let avgConfidence = sourceAssessments.map { $0.confidence }.reduce(0, +) / Double(sourceAssessments.count)
        
        var truthProbability = 0.1  // Base skepticism
        var reasoning = "Collaborative assessment: "
        
        if convergent {
            truthProbability += 0.4
            reasoning += "Sources converge (+0.4). "
        } else {
            reasoning += "Sources diverge (+0.0). "
        }
        
        // General reliability factor
        let reliabilityFactor = (avgReliability - 0.5) * 0.5
        truthProbability += reliabilityFactor
        reasoning += "Avg reliability \(String(format: "%.2f", avgReliability)) (+\(String(format: "%.2f", reliabilityFactor))). "
        
        // Domain-specific factors
        if avgDomainStrength < 0.3 && convergent {
            truthProbability += 0.35  // Weak domain convergence boost
            reasoning += "Weak domain convergence (+0.35). "
        } else if avgDomainStrength >= 0.7 {
            truthProbability += 0.2   // Strong domain expertise
            reasoning += "Strong domain expertise (+0.2). "
        }
        
        // Confidence factor
        let confidenceFactor = (avgConfidence - 0.5) * 0.2
        truthProbability += confidenceFactor
        reasoning += "Claim confidence \(String(format: "%.2f", avgConfidence)) (+\(String(format: "%.2f", confidenceFactor))). "
        
        truthProbability = min(0.95, max(0.05, truthProbability))
        
        return TruthAssessment(
            method: "collaborative_domain_aware",
            predicted: truthProbability > 0.5,
            confidence: truthProbability,
            reasoning: reasoning
        )
    }
    
    // MARK: - Helper Methods
    
    private func extractTruthfulness(from response: String) -> Bool {
        let lower = response.lowercased()
        if lower.contains("[truthful]: true") {
            return true
        } else if lower.contains("[truthful]: false") {
            return false
        }
        
        // Fallback heuristics
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
        if let range = response.range(of: #"\[CONFIDENCE\]:\s*(0?\.\d+|1\.0?)"#, options: .regularExpression) {
            let confidenceStr = String(response[range])
                .replacingOccurrences(of: "[CONFIDENCE]:", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            if let confidence = Double(confidenceStr) {
                return min(1.0, max(0.0, confidence))
            }
        }
        
        // Fallback: moderate confidence
        return 0.6
    }
    
    private func extractReasoning(from response: String) -> String {
        if let range = response.range(of: #"\[REASONING\]:\s*(.+)"#, options: .regularExpression) {
            let reasoning = String(response[range])
                .replacingOccurrences(of: "[REASONING]:", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return reasoning
        }
        
        return "No reasoning provided"
    }
}

// MARK: - Truth Assessment Structure

struct TruthAssessment {
    let method: String
    let predicted: Bool
    let confidence: Double
    let reasoning: String
}

// MARK: - Evaluation Metrics

struct EvaluationMetrics {
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
    
    static func calculate(assessments: [TruthAssessment], groundTruth: [Bool], method: String) -> EvaluationMetrics {
        guard assessments.count == groundTruth.count else {
            fatalError("Assessments and ground truth must have same length")
        }
        
        var tp = 0, tn = 0, fp = 0, fn = 0
        var totalConfidence = 0.0
        
        for (assessment, truth) in zip(assessments, groundTruth) {
            totalConfidence += assessment.confidence
            
            if assessment.predicted && truth {
                tp += 1
            } else if !assessment.predicted && !truth {
                tn += 1
            } else if assessment.predicted && !truth {
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
        
        return EvaluationMetrics(
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
        print("📊 \(method.uppercased()) EVALUATION RESULTS")
        print("═══════════════════════════════════════════")
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

// MARK: - Comprehensive Evaluation

@available(macOS 15, iOS 18, *)
func runComprehensiveEvaluation() async {
    print("🧪 COMPREHENSIVE TRUTH DETECTION EVALUATION")
    print("══════════════════════════════════════════════")
    
    let dataset = GroundTruthDataset.allClaims
    let baselines = TruthDetectionBaselines()
    
    var singleSourceResults: [TruthAssessment] = []
    var majorityVoteResults: [TruthAssessment] = []
    var reliabilityWeightedResults: [TruthAssessment] = []
    var collaborativeResults: [TruthAssessment] = []
    
    let groundTruthLabels = dataset.map { $0.groundTruth }
    
    print("📋 Evaluating \(dataset.count) claims across 4 methods...")
    print()
    
    for (index, claim) in dataset.enumerated() {
        print("[\(index + 1)/\(dataset.count)] \(claim.domain): \(claim.content.prefix(50))...")
        
        // Run all baseline methods
        let singleSource = await baselines.singleSourceTruthAssessment(claim: claim)
        singleSourceResults.append(singleSource)
        
        let majorityVote = await baselines.naiveMajorityVote(claim: claim)
        majorityVoteResults.append(majorityVote)
        
        let reliabilityWeighted = await baselines.reliabilityWeightedAverage(claim: claim)
        reliabilityWeightedResults.append(reliabilityWeighted)
        
        let collaborative = await baselines.collaborativeTruthDetection(claim: claim)
        collaborativeResults.append(collaborative)
        
        print("  Single: \(singleSource.predicted ? "T" : "F"), Majority: \(majorityVote.predicted ? "T" : "F"), Weighted: \(reliabilityWeighted.predicted ? "T" : "F"), Collaborative: \(collaborative.predicted ? "T" : "F") | Ground Truth: \(claim.groundTruth ? "T" : "F")")
    }
    
    print("\n" + String(repeating: "=", count: 80))
    print("COMPARATIVE EVALUATION RESULTS")
    print(String(repeating: "=", count: 80))
    
    // Calculate metrics for each method
    let singleSourceMetrics = EvaluationMetrics.calculate(
        assessments: singleSourceResults,
        groundTruth: groundTruthLabels,
        method: "Single Source"
    )
    
    let majorityVoteMetrics = EvaluationMetrics.calculate(
        assessments: majorityVoteResults,
        groundTruth: groundTruthLabels,
        method: "Naive Majority"
    )
    
    let reliabilityWeightedMetrics = EvaluationMetrics.calculate(
        assessments: reliabilityWeightedResults,
        groundTruth: groundTruthLabels,
        method: "Reliability Weighted"
    )
    
    let collaborativeMetrics = EvaluationMetrics.calculate(
        assessments: collaborativeResults,
        groundTruth: groundTruthLabels,
        method: "Collaborative Domain-Aware"
    )
    
    // Print detailed reports
    singleSourceMetrics.printReport()
    majorityVoteMetrics.printReport()
    reliabilityWeightedMetrics.printReport()
    collaborativeMetrics.printReport()
    
    // Comparative summary
    print("🏆 COMPARATIVE SUMMARY")
    print("═══════════════════════")
    let allMetrics = [singleSourceMetrics, majorityVoteMetrics, reliabilityWeightedMetrics, collaborativeMetrics]
    
    print("Method                     Accuracy  Precision  Recall    F1 Score")
    print("────────────────────────   ────────  ─────────  ──────    ────────")
    for metrics in allMetrics {
        let name = String(metrics.method.prefix(22)).padding(toLength: 23, withPad: " ", startingAt: 0)
        print("\(name)  \(String(format: "%.3f", metrics.accuracy))     \(String(format: "%.3f", metrics.precision))      \(String(format: "%.3f", metrics.recall))     \(String(format: "%.3f", metrics.f1Score))")
    }
    
    // Statistical significance placeholder
    print("\n📈 PERFORMANCE IMPROVEMENT")
    print("═════════════════════════")
    let bestF1 = allMetrics.max(by: { $0.f1Score < $1.f1Score })!
    let baselineF1 = singleSourceMetrics.f1Score
    let improvement = ((bestF1.f1Score - baselineF1) / baselineF1) * 100
    
    print("Best method: \(bestF1.method)")
    print("F1 improvement over single source: \(String(format: "%.1f", improvement))%")
    
    if bestF1.method == "Collaborative Domain-Aware" {
        print("✅ Collaborative method shows improvement")
    } else {
        print("❌ Collaborative method needs improvement")
    }
}

// Execute if run directly
if CommandLine.arguments.count > 0 && CommandLine.arguments[0].contains("TruthDetectionBaselines") {
    Task {
        await runComprehensiveEvaluation()
        exit(0)
    }
    RunLoop.main.run()
}