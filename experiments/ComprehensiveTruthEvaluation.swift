#!/usr/bin/env swift

import Foundation
import FoundationModels

// MARK: - Ground Truth Dataset (Embedded)

struct GroundTruthDataset {
    
    struct LabeledClaim {
        let content: String
        let domain: String
        let groundTruth: Bool  // true = factual, false = hallucination
        let difficulty: Difficulty
        let verificationSource: String
        let notes: String
        
        enum Difficulty: String, CaseIterable {
            case easy = "easy"
            case medium = "medium" 
            case hard = "hard"
        }
    }
    
    static let allClaims: [LabeledClaim] = [
        // Mathematics (high confidence domain)
        LabeledClaim(content: "The sum of interior angles in any triangle equals 180 degrees", domain: "mathematics", groundTruth: true, difficulty: .easy, verificationSource: "Euclidean geometry theorem", notes: "Fundamental geometric fact"),
        LabeledClaim(content: "The sum of interior angles in any triangle equals 360 degrees", domain: "mathematics", groundTruth: false, difficulty: .easy, verificationSource: "Contradicts Euclidean geometry", notes: "Confusing triangles with quadrilaterals"),
        LabeledClaim(content: "The square root of 2 is approximately 1.414", domain: "mathematics", groundTruth: true, difficulty: .easy, verificationSource: "Mathematical calculation", notes: "Precise to 3 decimal places"),
        LabeledClaim(content: "The mathematical constant π equals exactly 22/7", domain: "mathematics", groundTruth: false, difficulty: .medium, verificationSource: "π is irrational, 22/7 is approximation", notes: "Common misconception about π"),
        
        // Physics (medium confidence domain)
        LabeledClaim(content: "Light travels at approximately 299,792,458 meters per second in vacuum", domain: "physics", groundTruth: true, difficulty: .easy, verificationSource: "NIST physical constants", notes: "Defined constant in SI units"),
        LabeledClaim(content: "Objects fall faster in a vacuum than in air", domain: "physics", groundTruth: false, difficulty: .easy, verificationSource: "Galileo's experiments", notes: "Common misconception about gravity"),
        LabeledClaim(content: "Quantum tunneling allows particles to pass through energy barriers", domain: "physics", groundTruth: true, difficulty: .medium, verificationSource: "Quantum mechanics textbooks", notes: "Well-established quantum phenomenon"),
        LabeledClaim(content: "Room-temperature superconductors are commercially available", domain: "physics", groundTruth: false, difficulty: .hard, verificationSource: "Current materials science literature", notes: "Active research area, not yet achieved"),
        
        // Recent Events (low confidence domain for LLMs)
        LabeledClaim(content: "The COVID-19 pandemic was declared by WHO in March 2020", domain: "recent_events", groundTruth: true, difficulty: .easy, verificationSource: "WHO official declaration March 11, 2020", notes: "Major global event, well documented"),
        LabeledClaim(content: "ChatGPT was released by Google in late 2022", domain: "recent_events", groundTruth: false, difficulty: .easy, verificationSource: "ChatGPT released by OpenAI, not Google", notes: "Incorrect attribution"),
        LabeledClaim(content: "Apple introduced the M1 chip in November 2020", domain: "recent_events", groundTruth: true, difficulty: .medium, verificationSource: "Apple press release November 10, 2020", notes: "Technology industry milestone"),
        LabeledClaim(content: "A room-temperature superconductor was commercially released in 2023", domain: "recent_events", groundTruth: false, difficulty: .hard, verificationSource: "No credible scientific reports", notes: "Would be major scientific breakthrough if true"),
        
        // Specialized Science (low confidence domain for general LLMs)
        LabeledClaim(content: "CRISPR-Cas9 uses guide RNA to target specific DNA sequences", domain: "specialized_science", groundTruth: true, difficulty: .medium, verificationSource: "Molecular biology literature", notes: "Established gene editing mechanism"),
        LabeledClaim(content: "Quantum entanglement enables faster-than-light communication", domain: "specialized_science", groundTruth: false, difficulty: .hard, verificationSource: "No-communication theorem in quantum mechanics", notes: "Common quantum mechanics misconception"),
        LabeledClaim(content: "Telomeres shorten with cellular division in most somatic cells", domain: "specialized_science", groundTruth: true, difficulty: .hard, verificationSource: "Cell biology research", notes: "Key aging mechanism"),
        LabeledClaim(content: "Human DNA contains exactly 50,000 protein-coding genes", domain: "specialized_science", groundTruth: false, difficulty: .medium, verificationSource: "Human genome project: ~20,000-25,000 genes", notes: "Overestimate of gene count")
    ]
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

// MARK: - Truth Detection Baselines

@available(macOS 15, iOS 18, *)
class TruthDetectionBaselines {
    
    private var session1: LanguageModelSession
    private var session2: LanguageModelSession
    
    init() {
        self.session1 = LanguageModelSession()
        self.session2 = LanguageModelSession()
    }
    
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
    
    /// Our Method: Collaborative Truth Detection with Domain Awareness
    func collaborativeTruthDetection(claim: GroundTruthDataset.LabeledClaim) async -> TruthAssessment {
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
        let avgReliability = 0.835
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
    
    private func extractReasoning(from response: String) -> String {
        if let range = response.range(of: #"\\[REASONING\\]:\\s*(.+)"#, options: .regularExpression) {
            let reasoning = String(response[range])
                .replacingOccurrences(of: "[REASONING]:", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return reasoning
        }
        
        return "No reasoning provided"
    }
}

// MARK: - Statistical Significance Testing

struct StatisticalTests {
    
    /// McNemar's test for comparing two classifiers
    static func mcNemarTest(baseline: [Bool], improved: [Bool], groundTruth: [Bool]) -> (statistic: Double, pValue: Double) {
        guard baseline.count == improved.count && baseline.count == groundTruth.count else {
            return (0.0, 1.0)
        }
        
        var a = 0, b = 0, c = 0, d = 0
        
        for i in 0..<baseline.count {
            let baselineCorrect = baseline[i] == groundTruth[i]
            let improvedCorrect = improved[i] == groundTruth[i]
            
            if baselineCorrect && improvedCorrect {
                a += 1
            } else if baselineCorrect && !improvedCorrect {
                b += 1
            } else if !baselineCorrect && improvedCorrect {
                c += 1
            } else {
                d += 1
            }
        }
        
        // McNemar's statistic: (|b - c| - 1)^2 / (b + c)
        let numerator = pow(Double(abs(b - c)) - 1.0, 2)
        let denominator = Double(b + c)
        
        let statistic = denominator > 0 ? numerator / denominator : 0.0
        
        // Approximate p-value (chi-square with 1 df)
        let pValue = 1.0 - chiSquareCDF(x: statistic, df: 1)
        
        return (statistic, pValue)
    }
    
    // Simplified chi-square CDF approximation
    private static func chiSquareCDF(x: Double, df: Int) -> Double {
        if x <= 0 { return 0.0 }
        if df == 1 {
            return 2 * (1.0 / (1.0 + exp(-sqrt(2 * x))))  // Rough approximation
        }
        return 0.5  // Placeholder
    }
}

// MARK: - Main Evaluation Function

@available(macOS 15, iOS 18, *)
func runComprehensiveEvaluation() async {
    print("🧪 COMPREHENSIVE TRUTH DETECTION EVALUATION")
    print("══════════════════════════════════════════════")
    
    let dataset = GroundTruthDataset.allClaims
    let baselines = TruthDetectionBaselines()
    
    var singleSourceResults: [TruthAssessment] = []
    var majorityVoteResults: [TruthAssessment] = []
    var collaborativeResults: [TruthAssessment] = []
    
    let groundTruthLabels = dataset.map { $0.groundTruth }
    
    print("📋 Evaluating \(dataset.count) claims across 3 methods...")
    print()
    
    for (index, claim) in dataset.enumerated() {
        print("[\(index + 1)/\(dataset.count)] \(claim.domain): \(claim.content.prefix(50))...")
        
        let singleSource = await baselines.singleSourceTruthAssessment(claim: claim)
        singleSourceResults.append(singleSource)
        
        let majorityVote = await baselines.naiveMajorityVote(claim: claim)
        majorityVoteResults.append(majorityVote)
        
        let collaborative = await baselines.collaborativeTruthDetection(claim: claim)
        collaborativeResults.append(collaborative)
        
        print("  Single: \(singleSource.predicted ? "T" : "F"), Majority: \(majorityVote.predicted ? "T" : "F"), Collaborative: \(collaborative.predicted ? "T" : "F") | Ground Truth: \(claim.groundTruth ? "T" : "F")")
    }
    
    print("\n" + String(repeating: "=", count: 80))
    print("COMPARATIVE EVALUATION RESULTS")
    print(String(repeating: "=", count: 80))
    
    // Calculate metrics
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
    
    let collaborativeMetrics = EvaluationMetrics.calculate(
        assessments: collaborativeResults,
        groundTruth: groundTruthLabels,
        method: "Collaborative Domain-Aware"
    )
    
    // Print reports
    singleSourceMetrics.printReport()
    majorityVoteMetrics.printReport()
    collaborativeMetrics.printReport()
    
    // Comparative summary
    print("🏆 COMPARATIVE SUMMARY")
    print("═══════════════════════")
    let allMetrics = [singleSourceMetrics, majorityVoteMetrics, collaborativeMetrics]
    
    print("Method                     Accuracy  Precision  Recall    F1 Score")
    print("────────────────────────   ────────  ─────────  ──────    ────────")
    for metrics in allMetrics {
        let name = String(metrics.method.prefix(22)).padding(toLength: 23, withPad: " ", startingAt: 0)
        print("\(name)  \(String(format: "%.3f", metrics.accuracy))     \(String(format: "%.3f", metrics.precision))      \(String(format: "%.3f", metrics.recall))     \(String(format: "%.3f", metrics.f1Score))")
    }
    
    // Statistical significance
    print("\n📈 STATISTICAL SIGNIFICANCE")
    print("════════════════════════════")
    
    let singlePreds = singleSourceResults.map { $0.predicted }
    let collaborativePreds = collaborativeResults.map { $0.predicted }
    
    let (statistic, pValue) = StatisticalTests.mcNemarTest(
        baseline: singlePreds,
        improved: collaborativePreds,
        groundTruth: groundTruthLabels
    )
    
    print("McNemar's test (Collaborative vs Single Source):")
    print("  Test statistic: \(String(format: "%.3f", statistic))")
    print("  P-value: \(String(format: "%.3f", pValue))")
    print("  Significant (p < 0.05): \(pValue < 0.05 ? "YES" : "NO")")
    
    // Final assessment
    print("\n🎯 FINAL ASSESSMENT")
    print("══════════════════")
    
    let bestMethod = allMetrics.max(by: { $0.f1Score < $1.f1Score })!
    print("Best performing method: \(bestMethod.method)")
    print("F1 Score: \(String(format: "%.3f", bestMethod.f1Score))")
    
    if bestMethod.method == "Collaborative Domain-Aware" && pValue < 0.05 {
        print("✅ Collaborative truth detection shows statistically significant improvement")
    } else if bestMethod.method == "Collaborative Domain-Aware" {
        print("⚠️ Collaborative method performs best but improvement not statistically significant")
    } else {
        print("❌ Collaborative method does not outperform baselines")
    }
}

// Execute if run directly
if CommandLine.arguments.count > 0 && CommandLine.arguments[0].contains("ComprehensiveTruthEvaluation") {
    Task {
        await runComprehensiveEvaluation()
        exit(0)
    }
    RunLoop.main.run()
}