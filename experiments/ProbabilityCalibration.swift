#!/usr/bin/env swift

import Foundation

/// Probability Calibration Analysis for Truth Detection Systems
/// Evaluates how well confidence scores match actual accuracy

struct CalibrationResult {
    let method: String
    let calibrationError: Double  // Mean absolute difference between confidence and accuracy
    let brier: Double            // Brier score (lower is better)
    let overconfidence: Double   // Average confidence - accuracy (positive = overconfident)
    let bins: [(binStart: Double, binEnd: Double, avgConfidence: Double, accuracy: Double, count: Int)]
}

class ProbabilityCalibrationAnalyzer {
    
    /// Calculate calibration metrics for a set of predictions
    static func analyzeCalibration(
        predictions: [Bool],
        confidences: [Double],
        groundTruth: [Bool],
        method: String,
        binCount: Int = 10
    ) -> CalibrationResult {
        
        guard predictions.count == confidences.count && predictions.count == groundTruth.count else {
            fatalError("All arrays must have same length")
        }
        
        // Create calibration bins
        var bins: [(binStart: Double, binEnd: Double, avgConfidence: Double, accuracy: Double, count: Int)] = []
        
        for i in 0..<binCount {
            let binStart = Double(i) / Double(binCount)
            let binEnd = Double(i + 1) / Double(binCount)
            
            // Find predictions in this confidence bin
            let binPredictions = zip(zip(predictions, confidences), groundTruth).compactMap { predConfTruth in
                let ((pred, conf), truth) = predConfTruth
                if conf >= binStart && conf < binEnd {
                    return (pred, conf, truth)
                }
                return nil
            }
            
            if !binPredictions.isEmpty {
                let avgConfidence = binPredictions.map { $0.1 }.reduce(0, +) / Double(binPredictions.count)
                let correctPredictions = binPredictions.filter { $0.0 == $0.2 }.count
                let accuracy = Double(correctPredictions) / Double(binPredictions.count)
                
                bins.append((binStart, binEnd, avgConfidence, accuracy, binPredictions.count))
            }
        }
        
        // Calculate overall calibration metrics
        var totalCalibrationError = 0.0
        var totalBrier = 0.0
        var totalOverconfidence = 0.0
        var totalSamples = 0
        
        for bin in bins {
            let binWeight = Double(bin.count) / Double(predictions.count)
            totalCalibrationError += binWeight * abs(bin.avgConfidence - bin.accuracy)
            totalSamples += bin.count
        }
        
        // Brier score: average of (confidence - truth)^2
        for i in 0..<predictions.count {
            let truthValue = groundTruth[i] ? 1.0 : 0.0
            totalBrier += pow(confidences[i] - truthValue, 2)
        }
        totalBrier /= Double(predictions.count)
        
        // Overconfidence: average confidence - accuracy
        let avgConfidence = confidences.reduce(0, +) / Double(confidences.count)
        let overallAccuracy = Double(zip(predictions, groundTruth).filter { $0.0 == $0.1 }.count) / Double(predictions.count)
        totalOverconfidence = avgConfidence - overallAccuracy
        
        return CalibrationResult(
            method: method,
            calibrationError: totalCalibrationError,
            brier: totalBrier,
            overconfidence: totalOverconfidence,
            bins: bins
        )
    }
    
    /// Print detailed calibration report
    static func printCalibrationReport(_ result: CalibrationResult) {
        print("📈 \(result.method.uppercased()) CALIBRATION ANALYSIS")
        print("═══════════════════════════════════════════════════")
        print("Expected Calibration Error: \(String(format: "%.3f", result.calibrationError))")
        print("Brier Score:               \(String(format: "%.3f", result.brier))")
        print("Overconfidence:            \(String(format: "%+.3f", result.overconfidence))")
        print()
        
        print("Calibration Plot (Confidence vs Accuracy):")
        print("Bin Range      Avg Conf  Accuracy  Count  |Conf-Acc|")
        print("──────────────────────────────────────────────────────")
        for bin in result.bins {
            let range = String(format: "[%.1f, %.1f]", bin.binStart, bin.binEnd)
            let diff = abs(bin.avgConfidence - bin.accuracy)
            print("\(range.padding(toLength: 12, withPad: " ", startingAt: 0))   \(String(format: "%.3f", bin.avgConfidence))     \(String(format: "%.3f", bin.accuracy))     \(String(format: "%3d", bin.count))    \(String(format: "%.3f", diff))")
        }
        print()
        
        // Calibration quality assessment
        if result.calibrationError < 0.05 {
            print("✅ Excellent calibration (ECE < 0.05)")
        } else if result.calibrationError < 0.1 {
            print("🟡 Good calibration (ECE < 0.1)")
        } else if result.calibrationError < 0.2 {
            print("⚠️ Poor calibration (ECE < 0.2)")
        } else {
            print("❌ Very poor calibration (ECE ≥ 0.2)")
        }
        
        if abs(result.overconfidence) < 0.05 {
            print("✅ Well-calibrated confidence")
        } else if result.overconfidence > 0.05 {
            print("⚠️ Overconfident system")
        } else {
            print("⚠️ Underconfident system")
        }
        print()
    }
}

// Mock predictions with realistic confidence patterns
func generateMockPredictionsWithConfidence() -> [(predictions: [Bool], confidences: [Double], method: String)] {
    
    let groundTruthClaims = [
        // Mathematics (should have high confidence, high accuracy)
        (truth: true, domain: "mathematics"),
        (truth: true, domain: "mathematics"),
        (truth: true, domain: "mathematics"),
        (truth: false, domain: "mathematics"),
        (truth: false, domain: "mathematics"),
        
        // Physics (medium confidence, medium accuracy)
        (truth: true, domain: "physics"),
        (truth: true, domain: "physics"),
        (truth: false, domain: "physics"),
        (truth: false, domain: "physics"),
        
        // Recent Events (low confidence, variable accuracy)
        (truth: true, domain: "recent_events"),
        (truth: true, domain: "recent_events"),
        (truth: false, domain: "recent_events"),
        (truth: false, domain: "recent_events"),
        
        // Specialized Science (low confidence, variable accuracy)
        (truth: true, domain: "specialized_science"),
        (truth: true, domain: "specialized_science"),
        (truth: false, domain: "specialized_science"),
        (truth: false, domain: "specialized_science")
    ]
    
    var results: [(predictions: [Bool], confidences: [Double], method: String)] = []
    
    // Method 1: Overconfident Baseline (high confidence, mediocre accuracy)
    var overconfidentPreds: [Bool] = []
    var overconfidentConf: [Double] = []
    
    for claim in groundTruthClaims {
        // Always high confidence (0.8-0.95)
        let confidence = Double.random(in: 0.8...0.95)
        overconfidentConf.append(confidence)
        
        // Mediocre accuracy (70%)
        let correct = Double.random(in: 0...1) < 0.7
        overconfidentPreds.append(correct ? claim.truth : !claim.truth)
    }
    
    results.append((overconfidentPreds, overconfidentConf, "Overconfident Baseline"))
    
    // Method 2: Well-Calibrated Baseline
    var calibratedPreds: [Bool] = []
    var calibratedConf: [Double] = []
    
    for claim in groundTruthClaims {
        // Domain-appropriate confidence and accuracy
        let (confidence, accuracy) = switch claim.domain {
        case "mathematics":
            (Double.random(in: 0.85...0.95), 0.9)
        case "physics":
            (Double.random(in: 0.6...0.8), 0.7)
        case "recent_events", "specialized_science":
            (Double.random(in: 0.4...0.6), 0.55)
        default:
            (0.5, 0.5)
        }
        
        calibratedConf.append(confidence)
        let correct = Double.random(in: 0...1) < accuracy
        calibratedPreds.append(correct ? claim.truth : !claim.truth)
    }
    
    results.append((calibratedPreds, calibratedConf, "Well-Calibrated Baseline"))
    
    // Method 3: Our Collaborative Truth Detection (domain-aware confidence)
    var collaborativePreds: [Bool] = []
    var collaborativeConf: [Double] = []
    
    for claim in groundTruthClaims {
        let domainStrength = switch claim.domain {
        case "mathematics": 0.875
        case "physics": 0.275
        case "recent_events": 0.175
        case "specialized_science": 0.275
        default: 0.1
        }
        
        // Simulate collaborative truth detection algorithm
        var truthProbability = 0.1  // Base skepticism
        
        // Most sources converge (80% of time)
        let sourcesConverge = Double.random(in: 0...1) < 0.8
        
        if sourcesConverge {
            truthProbability += 0.4  // Convergence boost
            truthProbability += 0.17 // Reliability factor
            
            if domainStrength < 0.3 {
                truthProbability += 0.35  // Weak domain convergence boost
            } else if domainStrength >= 0.7 {
                truthProbability += 0.2   // Strong domain boost
            }
            
            truthProbability += 0.02  // Confidence factor
        }
        
        truthProbability = min(0.95, max(0.05, truthProbability))
        collaborativeConf.append(truthProbability)
        
        // Prediction accuracy correlates with confidence
        let accuracy = min(0.95, 0.5 + (truthProbability - 0.5) * 0.8)
        let correct = Double.random(in: 0...1) < accuracy
        collaborativePreds.append(correct ? claim.truth : !claim.truth)
    }
    
    results.append((collaborativePreds, collaborativeConf, "Collaborative Domain-Aware"))
    
    return results
}

func runCalibrationAnalysis() {
    print("📊 PROBABILITY CALIBRATION ANALYSIS")
    print("═══════════════════════════════════")
    print("Evaluating how well confidence scores match actual accuracy\n")
    
    let groundTruth = [true, true, true, false, false,  // mathematics
                      true, true, false, false,         // physics
                      true, true, false, false,         // recent_events
                      true, true, false, false]         // specialized_science
    
    let methodResults = generateMockPredictionsWithConfidence()
    var calibrationResults: [CalibrationResult] = []
    
    for (predictions, confidences, method) in methodResults {
        let result = ProbabilityCalibrationAnalyzer.analyzeCalibration(
            predictions: predictions,
            confidences: confidences,
            groundTruth: groundTruth,
            method: method
        )
        
        calibrationResults.append(result)
        ProbabilityCalibrationAnalyzer.printCalibrationReport(result)
    }
    
    // Comparative calibration summary
    print("🏆 CALIBRATION COMPARISON")
    print("═════════════════════════")
    print("Method                     ECE       Brier     Overconf")
    print("────────────────────────   ───────   ───────   ────────")
    
    for result in calibrationResults {
        let name = String(result.method.prefix(22)).padding(toLength: 23, withPad: " ", startingAt: 0)
        print("\(name)  \(String(format: "%.3f", result.calibrationError))     \(String(format: "%.3f", result.brier))     \(String(format: "%+.3f", result.overconfidence))")
    }
    
    // Find best calibrated method
    let bestCalibrated = calibrationResults.min(by: { $0.calibrationError < $1.calibrationError })!
    print("\n🎯 BEST CALIBRATED METHOD")
    print("═════════════════════════")
    print("Method: \(bestCalibrated.method)")
    print("Expected Calibration Error: \(String(format: "%.3f", bestCalibrated.calibrationError))")
    
    if bestCalibrated.method == "Collaborative Domain-Aware" {
        print("✅ Collaborative method is best calibrated")
    } else {
        print("⚠️ Collaborative method needs calibration improvement")
    }
    
    // Calibration improvement recommendations
    print("\n💡 CALIBRATION IMPROVEMENT RECOMMENDATIONS")
    print("═════════════════════════════════════════")
    
    let collaborativeResult = calibrationResults.first { $0.method == "Collaborative Domain-Aware" }!
    
    if collaborativeResult.overconfidence > 0.1 {
        print("• Reduce confidence scores by \(String(format: "%.1f", collaborativeResult.overconfidence * 100))%")
        print("• Implement confidence penalty for weak domain convergence")
    } else if collaborativeResult.overconfidence < -0.1 {
        print("• Increase confidence scores by \(String(format: "%.1f", abs(collaborativeResult.overconfidence) * 100))%")
        print("• Add confidence boost for strong domain expertise")
    } else {
        print("✅ Collaborative method confidence is well-calibrated")
    }
    
    if collaborativeResult.calibrationError > 0.1 {
        print("• Implement temperature scaling for confidence calibration")
        print("• Use domain-specific calibration parameters")
        print("• Collect more validation data for calibration tuning")
    } else {
        print("✅ Collaborative method shows good calibration")
    }
}

// Execute calibration analysis
runCalibrationAnalysis()