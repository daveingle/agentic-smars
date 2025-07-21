#!/usr/bin/env swift

import Foundation
import FoundationModels

/// Collaborative Truth Detection with Uncertain Sources
@available(macOS 15, iOS 18, *)
class CollaborativeTruthDetection {
    
    // MARK: - Core Types
    
    struct UncertainSource {
        let sourceId: String
        let generalReliability: Double  // 0.0 - 1.0
        let domainStrengths: [String: Double]  // domain -> strength mapping
        let historicalAccuracy: Double
        
        func getDomainStrength(for domain: String) -> Double {
            return domainStrengths[domain] ?? 0.1  // Default to weak if unknown
        }
    }
    
    struct Claim {
        let content: String
        let domain: String
        let sourceId: String
        let confidence: Double
        let timestamp: Date
        let context: String
        
        var claimHash: String {
            return content.lowercased().replacingOccurrences(of: " ", with: "_")
        }
    }
    
    struct CollaborativeEvidence {
        let convergentClaims: [Claim]
        let truthProbability: Double
        let confidenceFactors: [String: Double]
        let verificationNeeded: Bool
        let reasoning: String
    }
    
    struct VerificationResult {
        let verificationSource: String
        let verificationMethod: String
        let result: Bool
        let confidence: Double
        let evidence: String
    }
    
    // MARK: - Properties
    
    private var sources: [String: UncertainSource] = [:]
    private var claims: [Claim] = []
    private var collaborativeEvidence: [CollaborativeEvidence] = []
    private var session1: LanguageModelSession
    private var session2: LanguageModelSession
    
    init() {
        self.session1 = LanguageModelSession()
        self.session2 = LanguageModelSession()
        
        // Initialize with example sources (two Foundation Model instances with different strengths)
        sources["fm1"] = UncertainSource(
            sourceId: "fm1",
            generalReliability: 0.85,
            domainStrengths: [
                "general_knowledge": 0.8,
                "mathematics": 0.9,
                "specialized_science": 0.3,
                "recent_events": 0.2,
                "technical_specifications": 0.4
            ],
            historicalAccuracy: 0.83
        )
        
        sources["fm2"] = UncertainSource(
            sourceId: "fm2", 
            generalReliability: 0.82,
            domainStrengths: [
                "general_knowledge": 0.7,
                "mathematics": 0.85,
                "specialized_science": 0.25,
                "recent_events": 0.15,
                "technical_specifications": 0.35
            ],
            historicalAccuracy: 0.80
        )
        
        print("🔍 Collaborative Truth Detection initialized with 2 uncertain sources")
    }
    
    // MARK: - Claim Generation
    
    func generateClaim(from sourceId: String, about topic: String, in domain: String) async -> Claim {
        let session = sourceId == "fm1" ? session1 : session2
        
        let prompt = """
        You are being asked about: \(topic)
        Domain: \(domain)
        
        Please provide a factual claim about this topic. Be specific and definitive.
        Format: [CLAIM]: Your specific claim here
        [CONFIDENCE]: Your confidence level (0.0-1.0)
        """
        
        do {
            let response = try await session.respond(to: prompt)
            
            // Extract claim and confidence
            let claimContent = extractClaim(from: response.content)
            let confidence = extractConfidence(from: response.content)
            
            let claim = Claim(
                content: claimContent,
                domain: domain,
                sourceId: sourceId,
                confidence: confidence,
                timestamp: Date(),
                context: topic
            )
            
            claims.append(claim)
            print("📝 \(sourceId): \(claimContent) (confidence: \(String(format: "%.2f", confidence)))")
            
            return claim
            
        } catch {
            print("❌ Error generating claim from \(sourceId): \(error)")
            
            let fallbackClaim = Claim(
                content: "Unable to generate claim due to error",
                domain: domain,
                sourceId: sourceId,
                confidence: 0.0,
                timestamp: Date(),
                context: topic
            )
            
            claims.append(fallbackClaim)
            return fallbackClaim
        }
    }
    
    private func extractClaim(from response: String) -> String {
        if let claimRange = response.range(of: #"\[CLAIM\]:\s*(.+)"#, options: .regularExpression) {
            let claim = String(response[claimRange])
                .replacingOccurrences(of: "[CLAIM]:", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return claim
        }
        
        // Fallback: use first substantial sentence
        let sentences = response.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        return sentences.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? response.prefix(100).description
    }
    
    private func extractConfidence(from response: String) -> Double {
        if let confidenceRange = response.range(of: #"\[CONFIDENCE\]:\s*(0?\.\d+|1\.0?)"#, options: .regularExpression) {
            let confidenceStr = String(response[confidenceRange])
                .replacingOccurrences(of: "[CONFIDENCE]:", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            if let confidence = Double(confidenceStr) {
                return min(1.0, max(0.0, confidence))
            }
        }
        
        // Fallback heuristic
        let uncertainWords = ["maybe", "possibly", "might", "could", "uncertain"]
        let confidentWords = ["definitely", "certainly", "clearly", "obviously"]
        
        let words = response.lowercased().components(separatedBy: .whitespacesAndNewlines)
        let uncertainCount = uncertainWords.reduce(0) { count, word in count + (words.contains(word) ? 1 : 0) }
        let confidentCount = confidentWords.reduce(0) { count, word in count + (words.contains(word) ? 1 : 0) }
        
        let baseConfidence = 0.6
        let adjustment = (Double(confidentCount) * 0.15) - (Double(uncertainCount) * 0.2)
        
        return min(1.0, max(0.0, baseConfidence + adjustment))
    }
    
    // MARK: - Collaborative Truth Detection
    
    func detectCollaborativeTruth(for topic: String, in domain: String) async -> CollaborativeEvidence {
        print("\n🎯 Detecting collaborative truth for: \(topic) (domain: \(domain))")
        
        // Generate claims from both sources
        let claim1 = await generateClaim(from: "fm1", about: topic, in: domain)
        let claim2 = await generateClaim(from: "fm2", about: topic, in: domain)
        
        // Check for convergence
        let convergent = areClaimsConvergent(claim1, claim2)
        print("🔄 Claims convergent: \(convergent)")
        
        // Analyze source reliability and domain strength
        let source1 = sources["fm1"]!
        let source2 = sources["fm2"]!
        
        let domain1Strength = source1.getDomainStrength(for: domain)
        let domain2Strength = source2.getDomainStrength(for: domain)
        
        print("📊 Domain strengths - FM1: \(String(format: "%.2f", domain1Strength)), FM2: \(String(format: "%.2f", domain2Strength))")
        
        // Calculate collaborative truth probability
        let evidence = calculateCollaborativeTruth(
            claims: [claim1, claim2],
            sources: [source1, source2],
            domainStrengths: [domain1Strength, domain2Strength],
            convergent: convergent
        )
        
        collaborativeEvidence.append(evidence)
        
        print("🏆 Truth probability: \(String(format: "%.2f", evidence.truthProbability))")
        print("📋 Reasoning: \(evidence.reasoning)")
        
        return evidence
    }
    
    private func areClaimsConvergent(_ claim1: Claim, _ claim2: Claim) -> Bool {
        // Simple convergence check - look for similar key concepts
        let words1 = Set(claim1.content.lowercased().components(separatedBy: .whitespacesAndNewlines))
        let words2 = Set(claim2.content.lowercased().components(separatedBy: .whitespacesAndNewlines))
        
        let commonWords = words1.intersection(words2)
        let totalWords = words1.union(words2)
        
        let similarity = Double(commonWords.count) / Double(totalWords.count)
        
        // Also check for semantic similarity patterns
        let claim1Lower = claim1.content.lowercased()
        let claim2Lower = claim2.content.lowercased()
        
        // Look for agreement patterns
        let agreementPatterns = ["yes", "true", "correct", "is", "has", "will", "can"]
        let disagreementPatterns = ["no", "false", "incorrect", "not", "cannot", "won't"]
        
        let claim1Positive = agreementPatterns.contains { claim1Lower.contains($0) }
        let claim2Positive = agreementPatterns.contains { claim2Lower.contains($0) }
        
        let claim1Negative = disagreementPatterns.contains { claim1Lower.contains($0) }
        let claim2Negative = disagreementPatterns.contains { claim2Lower.contains($0) }
        
        let polarityMatch = (claim1Positive && claim2Positive) || (claim1Negative && claim2Negative)
        
        return similarity > 0.3 || polarityMatch
    }
    
    private func calculateCollaborativeTruth(
        claims: [Claim],
        sources: [UncertainSource], 
        domainStrengths: [Double],
        convergent: Bool
    ) -> CollaborativeEvidence {
        
        let avgReliability = sources.map { $0.generalReliability }.reduce(0, +) / Double(sources.count)
        let avgDomainStrength = domainStrengths.reduce(0, +) / Double(domainStrengths.count)
        let avgClaimConfidence = claims.map { $0.confidence }.reduce(0, +) / Double(claims.count)
        
        var truthProbability = 0.1  // Base skepticism
        var factors: [String: Double] = [:]
        var reasoning = "Truth assessment: "
        
        // Factor 1: Convergence
        if convergent {
            let convergenceBoost = 0.4
            truthProbability += convergenceBoost
            factors["convergence"] = convergenceBoost
            reasoning += "Claims converge (+0.4). "
        } else {
            reasoning += "Claims diverge (+0.0). "
        }
        
        // Factor 2: General reliability
        let reliabilityFactor = (avgReliability - 0.5) * 0.5  // Scale 0.5-1.0 to 0.0-0.25
        truthProbability += reliabilityFactor
        factors["reliability"] = reliabilityFactor
        reasoning += "Avg reliability \(String(format: "%.2f", avgReliability)) (+\(String(format: "%.2f", reliabilityFactor))). "
        
        // Factor 3: Weak domain convergence boost
        let weakDomainThreshold = 0.3
        if avgDomainStrength < weakDomainThreshold && convergent {
            let weakDomainBoost = 0.35  // Significant boost for weak domain convergence
            truthProbability += weakDomainBoost
            factors["weak_domain_convergence"] = weakDomainBoost
            reasoning += "Weak domain convergence detected (+\(weakDomainBoost)). "
        } else if avgDomainStrength >= 0.7 {
            let strongDomainBoost = 0.2
            truthProbability += strongDomainBoost
            factors["strong_domain"] = strongDomainBoost
            reasoning += "Strong domain expertise (+\(strongDomainBoost)). "
        }
        
        // Factor 4: Claim confidence
        let confidenceFactor = (avgClaimConfidence - 0.5) * 0.2
        truthProbability += confidenceFactor
        factors["claim_confidence"] = confidenceFactor
        reasoning += "Claim confidence \(String(format: "%.2f", avgClaimConfidence)) (+\(String(format: "%.2f", confidenceFactor))). "
        
        // Cap at reasonable maximum
        truthProbability = min(0.95, max(0.05, truthProbability))
        
        // Determine if external verification is needed
        let verificationNeeded = avgDomainStrength < weakDomainThreshold && convergent && truthProbability > 0.6
        
        if verificationNeeded {
            reasoning += "External verification recommended due to weak domain convergence."
        }
        
        return CollaborativeEvidence(
            convergentClaims: convergent ? claims : [],
            truthProbability: truthProbability,
            confidenceFactors: factors,
            verificationNeeded: verificationNeeded,
            reasoning: reasoning
        )
    }
    
    // MARK: - External Verification Simulation
    
    func performExternalVerification(for evidence: CollaborativeEvidence) async -> VerificationResult {
        guard evidence.verificationNeeded else {
            return VerificationResult(
                verificationSource: "none",
                verificationMethod: "not_required",
                result: false,
                confidence: 0.0,
                evidence: "Verification not required for this claim"
            )
        }
        
        print("🔍 Performing external verification...")
        
        // Simulate external verification (in practice, this would query authoritative sources)
        let verificationPrompt = """
        Acting as an external verification system, please verify this claim:
        
        Claims to verify:
        \(evidence.convergentClaims.map { "- \($0.content)" }.joined(separator: "\n"))
        
        Provide verification result:
        [VERIFIED]: true/false
        [CONFIDENCE]: 0.0-1.0
        [EVIDENCE]: Supporting evidence or reasoning
        """
        
        do {
            let response = try await session1.respond(to: verificationPrompt)
            
            let verified = response.content.lowercased().contains("[verified]: true")
            let confidence = extractConfidence(from: response.content)
            
            // Extract evidence
            let evidenceText = extractVerificationEvidence(from: response.content)
            
            let result = VerificationResult(
                verificationSource: "external_foundation_model",
                verificationMethod: "authoritative_query",
                result: verified,
                confidence: confidence,
                evidence: evidenceText
            )
            
            print("✅ External verification: \(verified ? "CONFIRMED" : "DENIED") (confidence: \(String(format: "%.2f", confidence)))")
            
            return result
            
        } catch {
            print("❌ External verification failed: \(error)")
            return VerificationResult(
                verificationSource: "external_foundation_model",
                verificationMethod: "error",
                result: false,
                confidence: 0.0,
                evidence: "Verification failed: \(error.localizedDescription)"
            )
        }
    }
    
    private func extractVerificationEvidence(from response: String) -> String {
        if let evidenceRange = response.range(of: #"\[EVIDENCE\]:\s*(.+)"#, options: .regularExpression) {
            let evidence = String(response[evidenceRange])
                .replacingOccurrences(of: "[EVIDENCE]:", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return evidence
        }
        
        return response.components(separatedBy: .newlines)
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .last?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "No evidence provided"
    }
    
    // MARK: - Test Scenarios
    
    func runCollaborativeTruthTests() async {
        print("🧪 Running Collaborative Truth Detection Tests\n")
        
        // Test 1: Weak domain convergence (should boost truth probability)
        let evidence1 = await detectCollaborativeTruth(
            for: "The quantum tunneling effect in semiconductor junctions operates at room temperature",
            in: "specialized_science"
        )
        
        if evidence1.verificationNeeded {
            let verification1 = await performExternalVerification(for: evidence1)
            print("📋 Verification result: \(verification1.evidence)")
        }
        
        print("\n" + String(repeating: "-", count: 60) + "\n")
        
        // Test 2: Strong domain convergence (should have high confidence)
        let evidence2 = await detectCollaborativeTruth(
            for: "The sum of angles in a triangle equals 180 degrees",
            in: "mathematics"
        )
        
        if evidence2.verificationNeeded {
            let verification2 = await performExternalVerification(for: evidence2)
            print("📋 Verification result: \(verification2.evidence)")
        }
        
        print("\n" + String(repeating: "-", count: 60) + "\n")
        
        // Test 3: Recent events (weak domain for both)
        let evidence3 = await detectCollaborativeTruth(
            for: "A major breakthrough in room-temperature superconductors was announced last month",
            in: "recent_events"
        )
        
        if evidence3.verificationNeeded {
            let verification3 = await performExternalVerification(for: evidence3)
            print("📋 Verification result: \(verification3.evidence)")
        }
        
        // Generate final report
        generateCollaborativeTruthReport()
    }
    
    func generateCollaborativeTruthReport() {
        print("\n" + String(repeating: "=", count: 60))
        print("COLLABORATIVE TRUTH DETECTION RESULTS")
        print(String(repeating: "=", count: 60))
        
        print("📊 Total evidence assessments: \(collaborativeEvidence.count)")
        print("🔍 Verification requests: \(collaborativeEvidence.filter { $0.verificationNeeded }.count)")
        
        let avgTruthProbability = collaborativeEvidence.map { $0.truthProbability }.reduce(0, +) / Double(max(1, collaborativeEvidence.count))
        print("🎯 Average truth probability: \(String(format: "%.2f", avgTruthProbability))")
        
        let weakDomainCases = collaborativeEvidence.filter { $0.confidenceFactors["weak_domain_convergence"] != nil }.count
        print("🔬 Weak domain convergence cases: \(weakDomainCases)")
        
        print("\n📋 Evidence Summary:")
        for (index, evidence) in collaborativeEvidence.enumerated() {
            print("  \(index + 1). Truth probability: \(String(format: "%.2f", evidence.truthProbability))")
            print("     Factors: \(evidence.confidenceFactors.map { "\($0.key): \(String(format: "%.2f", $0.value))" }.joined(separator: ", "))")
            print("     Verification needed: \(evidence.verificationNeeded)")
        }
    }
}

// MARK: - Test Execution

@available(macOS 15, iOS 18, *)
func runCollaborativeTruthTest() async {
    guard #available(macOS 15, iOS 18, *) else {
        print("❌ Foundation Models requires macOS 15 or iOS 18")
        exit(1)
    }
    
    print("🤝 COLLABORATIVE TRUTH DETECTION TEST")
    print("Testing convergent hallucination detection with uncertain sources\n")
    
    let detector = CollaborativeTruthDetection()
    await detector.runCollaborativeTruthTests()
    
    print("\n🏁 Collaborative truth detection test completed")
}

// Execute if run directly
if CommandLine.arguments.count > 0 && CommandLine.arguments[0].contains("CollaborativeTruthDetection") {
    Task {
        await runCollaborativeTruthTest()
        exit(0)
    }
    RunLoop.main.run()
}