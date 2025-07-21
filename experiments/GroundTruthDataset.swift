#!/usr/bin/env swift

import Foundation

/// Ground Truth Dataset for Collaborative Truth Detection Validation
/// Provides labeled truth/hallucination cases across multiple domains
struct GroundTruthDataset {
    
    struct LabeledClaim {
        let content: String
        let domain: String
        let groundTruth: Bool  // true = factual, false = hallucination
        let difficulty: Difficulty
        let verificationSource: String
        let notes: String
        
        enum Difficulty: String, CaseIterable {
            case easy = "easy"           // Obvious facts/falsehoods
            case medium = "medium"       // Requires domain knowledge
            case hard = "hard"           // Subtle or contested claims
        }
    }
    
    // MARK: - Mathematics Domain (High Confidence Ground Truth)
    
    static let mathematicsClaims: [LabeledClaim] = [
        // TRUE claims
        LabeledClaim(
            content: "The sum of interior angles in any triangle equals 180 degrees",
            domain: "mathematics",
            groundTruth: true,
            difficulty: .easy,
            verificationSource: "Euclidean geometry theorem",
            notes: "Fundamental geometric fact"
        ),
        LabeledClaim(
            content: "The square root of 2 is approximately 1.414",
            domain: "mathematics", 
            groundTruth: true,
            difficulty: .easy,
            verificationSource: "Mathematical calculation",
            notes: "Precise to 3 decimal places"
        ),
        LabeledClaim(
            content: "Euler's identity states that e^(iπ) + 1 = 0",
            domain: "mathematics",
            groundTruth: true,
            difficulty: .medium,
            verificationSource: "Complex analysis theorem",
            notes: "Famous mathematical identity"
        ),
        
        // FALSE claims
        LabeledClaim(
            content: "The sum of interior angles in any triangle equals 360 degrees",
            domain: "mathematics",
            groundTruth: false,
            difficulty: .easy,
            verificationSource: "Contradicts Euclidean geometry",
            notes: "Confusing triangles with quadrilaterals"
        ),
        LabeledClaim(
            content: "The mathematical constant π equals exactly 22/7",
            domain: "mathematics",
            groundTruth: false,
            difficulty: .medium,
            verificationSource: "π is irrational, 22/7 is approximation",
            notes: "Common misconception about π"
        )
    ]
    
    // MARK: - Physics Domain (Medium Confidence Ground Truth)
    
    static let physicsClaims: [LabeledClaim] = [
        // TRUE claims
        LabeledClaim(
            content: "Light travels at approximately 299,792,458 meters per second in vacuum",
            domain: "physics",
            groundTruth: true,
            difficulty: .easy,
            verificationSource: "NIST physical constants",
            notes: "Defined constant in SI units"
        ),
        LabeledClaim(
            content: "Quantum tunneling allows particles to pass through energy barriers",
            domain: "physics",
            groundTruth: true,
            difficulty: .medium,
            verificationSource: "Quantum mechanics textbooks",
            notes: "Well-established quantum phenomenon"
        ),
        LabeledClaim(
            content: "Superconductivity occurs when electrical resistance drops to zero",
            domain: "physics",
            groundTruth: true,
            difficulty: .medium,
            verificationSource: "Solid state physics",
            notes: "Defining characteristic of superconductors"
        ),
        
        // FALSE claims
        LabeledClaim(
            content: "Objects fall faster in a vacuum than in air",
            domain: "physics",
            groundTruth: false,
            difficulty: .easy,
            verificationSource: "Galileo's experiments",
            notes: "Common misconception about gravity"
        ),
        LabeledClaim(
            content: "Room-temperature superconductors are commercially available",
            domain: "physics",
            groundTruth: false,
            difficulty: .hard,
            verificationSource: "Current materials science literature",
            notes: "Active research area, not yet achieved"
        )
    ]
    
    // MARK: - Recent Events Domain (Low Confidence for LLMs)
    
    static let recentEventsClaims: [LabeledClaim] = [
        // TRUE claims (verifiable historical events)
        LabeledClaim(
            content: "The COVID-19 pandemic was declared by WHO in March 2020",
            domain: "recent_events",
            groundTruth: true,
            difficulty: .easy,
            verificationSource: "WHO official declaration March 11, 2020",
            notes: "Major global event, well documented"
        ),
        LabeledClaim(
            content: "Apple introduced the M1 chip in November 2020",
            domain: "recent_events",
            groundTruth: true,
            difficulty: .medium,
            verificationSource: "Apple press release November 10, 2020",
            notes: "Technology industry milestone"
        ),
        
        // FALSE claims
        LabeledClaim(
            content: "A room-temperature superconductor was commercially released in 2023",
            domain: "recent_events",
            groundTruth: false,
            difficulty: .hard,
            verificationSource: "No credible scientific reports",
            notes: "Would be major scientific breakthrough if true"
        ),
        LabeledClaim(
            content: "ChatGPT was released by Google in late 2022",
            domain: "recent_events",
            groundTruth: false,
            difficulty: .easy,
            verificationSource: "ChatGPT released by OpenAI, not Google",
            notes: "Incorrect attribution"
        )
    ]
    
    // MARK: - Specialized Science Domain (Low Confidence for General LLMs)
    
    static let specializedScienceClaims: [LabeledClaim] = [
        // TRUE claims
        LabeledClaim(
            content: "CRISPR-Cas9 uses guide RNA to target specific DNA sequences",
            domain: "specialized_science",
            groundTruth: true,
            difficulty: .medium,
            verificationSource: "Molecular biology literature",
            notes: "Established gene editing mechanism"
        ),
        LabeledClaim(
            content: "Telomeres shorten with cellular division in most somatic cells",
            domain: "specialized_science",
            groundTruth: true,
            difficulty: .hard,
            verificationSource: "Cell biology research",
            notes: "Key aging mechanism"
        ),
        
        // FALSE claims
        LabeledClaim(
            content: "Quantum entanglement enables faster-than-light communication",
            domain: "specialized_science",
            groundTruth: false,
            difficulty: .hard,
            verificationSource: "No-communication theorem in quantum mechanics",
            notes: "Common quantum mechanics misconception"
        ),
        LabeledClaim(
            content: "Human DNA contains exactly 50,000 protein-coding genes",
            domain: "specialized_science",
            groundTruth: false,
            difficulty: .medium,
            verificationSource: "Human genome project: ~20,000-25,000 genes",
            notes: "Overestimate of gene count"
        )
    ]
    
    // MARK: - Dataset Access Methods
    
    static var allClaims: [LabeledClaim] {
        return mathematicsClaims + physicsClaims + recentEventsClaims + specializedScienceClaims
    }
    
    static func claimsForDomain(_ domain: String) -> [LabeledClaim] {
        return allClaims.filter { $0.domain == domain }
    }
    
    static func claimsForDifficulty(_ difficulty: LabeledClaim.Difficulty) -> [LabeledClaim] {
        return allClaims.filter { $0.difficulty == difficulty }
    }
    
    static func trueClaims() -> [LabeledClaim] {
        return allClaims.filter { $0.groundTruth == true }
    }
    
    static func falseClaims() -> [LabeledClaim] {
        return allClaims.filter { $0.groundTruth == false }
    }
    
    // MARK: - Dataset Statistics
    
    static func printDatasetStatistics() {
        let total = allClaims.count
        let trueCount = trueClaims().count
        let falseCount = falseClaims().count
        
        print("📊 GROUND TRUTH DATASET STATISTICS")
        print("═══════════════════════════════════")
        print("Total claims: \(total)")
        print("True claims: \(trueCount) (\(Int(Double(trueCount)/Double(total)*100))%)")
        print("False claims: \(falseCount) (\(Int(Double(falseCount)/Double(total)*100))%)")
        print()
        
        print("By Domain:")
        let domains = Set(allClaims.map { $0.domain })
        for domain in domains.sorted() {
            let domainClaims = claimsForDomain(domain)
            let domainTrue = domainClaims.filter { $0.groundTruth }.count
            print("  \(domain): \(domainClaims.count) claims (\(domainTrue) true, \(domainClaims.count - domainTrue) false)")
        }
        print()
        
        print("By Difficulty:")
        for difficulty in LabeledClaim.Difficulty.allCases {
            let difficultyClaims = claimsForDifficulty(difficulty)
            let difficultyTrue = difficultyClaims.filter { $0.groundTruth }.count
            print("  \(difficulty.rawValue): \(difficultyClaims.count) claims (\(difficultyTrue) true, \(difficultyClaims.count - difficultyTrue) false)")
        }
    }
    
    // MARK: - Cross-Validation Splits
    
    static func createTrainTestSplit(testRatio: Double = 0.3, seed: UInt32 = 42) -> (train: [LabeledClaim], test: [LabeledClaim]) {
        var rng = SeededRandomNumberGenerator(seed: seed)
        
        let shuffledClaims = allClaims.shuffled(using: &rng)
        let testSize = Int(Double(shuffledClaims.count) * testRatio)
        
        let testClaims = Array(shuffledClaims.prefix(testSize))
        let trainClaims = Array(shuffledClaims.dropFirst(testSize))
        
        return (train: trainClaims, test: testClaims)
    }
}

// MARK: - Seeded Random Number Generator for Reproducibility

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64
    
    init(seed: UInt32) {
        self.state = UInt64(seed)
    }
    
    mutating func next() -> UInt64 {
        state = state &* 1103515245 &+ 12345
        return state
    }
}

// MARK: - Test Dataset Creation

func createGroundTruthDataset() {
    print("🏗️ CREATING GROUND TRUTH DATASET")
    print("═══════════════════════════════════")
    
    GroundTruthDataset.printDatasetStatistics()
    
    let (train, test) = GroundTruthDataset.createTrainTestSplit()
    print("\nTrain/Test Split:")
    print("  Training set: \(train.count) claims")
    print("  Test set: \(test.count) claims")
    
    // Verify balanced representation
    let testDomains = Set(test.map { $0.domain })
    print("\nTest set domain coverage: \(testDomains.sorted().joined(separator: ", "))")
    
    let testTrueCount = test.filter { $0.groundTruth }.count
    print("Test set balance: \(testTrueCount) true, \(test.count - testTrueCount) false")
}

// Execute if run directly
if CommandLine.arguments.count > 0 && CommandLine.arguments[0].contains("GroundTruthDataset") {
    createGroundTruthDataset()
}