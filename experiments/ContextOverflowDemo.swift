#!/usr/bin/env swift

import Foundation
import FoundationModels

/// Demonstration of Context Paradox Detection and Artifact-Based Reconstruction
@available(macOS 15, iOS 18, *)
class ContextOverflowDemo {
    
    private var session: LanguageModelSession
    private var sessionCount = 1
    private var artifacts: [String] = []
    private var paradoxes: [String] = []
    
    init() {
        self.session = LanguageModelSession()
        print("🧠 Context Overflow Demo initialized (Session \(sessionCount))")
    }
    
    // MARK: - Force Context Overflow
    
    func demonstrateContextOverflow() async {
        print("🎯 Demonstrating Context Overflow and Recovery")
        
        // Build up context until overflow
        var stepCount = 0
        var overflowDetected = false
        
        while !overflowDetected && stepCount < 50 {
            stepCount += 1
            
            // Create increasingly large prompts to force overflow
            let largePrompt = """
            This is SMARS execution step \(stepCount). Please analyze this complex symbolic reasoning task:
            
            CONTEXT EXPANSION \(stepCount):
            \(String(repeating: "Complex symbolic reasoning requires detailed analysis of multi-agent coordination patterns with foundation model integration, validation frameworks, contract enforcement, artifact generation, and reality-grounding mechanisms. ", count: stepCount * 2))
            
            TASK: Analyze this step and respond with detailed reasoning about:
            1. Symbolic expressiveness requirements
            2. Foundation model integration patterns  
            3. Validation framework considerations
            4. Artifact generation strategies
            5. Multi-agent coordination protocols
            
            Provide comprehensive analysis with specific recommendations.
            """
            
            print("📊 Step \(stepCount): Sending large prompt (\(largePrompt.count) chars)")
            
            do {
                let response = try await session.respond(to: largePrompt)
                
                // Store artifact
                let artifact = "STEP_\(stepCount): \(response.content.prefix(100))..."
                artifacts.append(artifact)
                
                print("✅ Step \(stepCount) completed, response: \(response.content.prefix(50))...")
                
                // Check for potential context issues by response quality degradation
                if response.content.count < 50 {
                    print("⚠️ Response quality degrading, may be near context limit")
                }
                
            } catch {
                print("❌ Context overflow detected at step \(stepCount): \(error)")
                overflowDetected = true
                
                if String(describing: error).localizedCaseInsensitiveContains("context") {
                    await handleContextOverflow(currentStep: stepCount)
                }
            }
        }
        
        if !overflowDetected {
            print("⚠️ Context overflow not reached in \(stepCount) steps")
            await demonstrateParadoxDetection()
        }
    }
    
    // MARK: - Context Reconstruction
    
    func handleContextOverflow(currentStep: Int) async {
        print("🔄 CONTEXT OVERFLOW DETECTED - Beginning Recovery Process")
        
        // Detect any paradoxes in execution pattern  
        detectParadoxes()
        
        // Create context seed from artifacts
        let contextSeed = createContextSeed(currentStep: currentStep)
        
        // Reconstruct session
        await reconstructSession(with: contextSeed)
        
        // Continue execution to prove recovery
        await continueAfterReconstruction(fromStep: currentStep)
    }
    
    func detectParadoxes() {
        print("🔍 Detecting paradoxes in execution pattern...")
        
        // Simple paradox detection: look for repeated patterns
        let recentArtifacts = artifacts.suffix(10)
        
        for i in 0..<(recentArtifacts.count - 2) {
            let pattern = Array(recentArtifacts[i..<(i+3)])
            
            // Check for repetitive or contradictory patterns
            if pattern.count == 3 {
                let responses = pattern.map { $0.contains("SUCCESS") || $0.contains("successful") }
                
                // Look for oscillating success/failure pattern
                if responses == [true, false, true] || responses == [false, true, false] {
                    let paradox = "PARADOX_\(UUID().uuidString.prefix(8)): Oscillating validation pattern detected"
                    paradoxes.append(paradox)
                    saveParadoxArtifact(paradox)
                    print("🚨 Paradox detected: Oscillating validation pattern")
                }
            }
        }
        
        if paradoxes.isEmpty {
            print("✅ No paradoxes detected in execution pattern")
        }
    }
    
    func saveParadoxArtifact(_ paradox: String) {
        let timestamp = DateFormatter().string(from: Date()).replacingOccurrences(of: " ", with: "_")
        let filename = "artifacts/undefined-assumptions/paradox-\(timestamp).md"
        
        let content = """
        # Undefined Assumption Artifact
        
        ## Paradox Detected: \(paradox)
        
        ## Detection Context:
        - Session: \(sessionCount)
        - Total artifacts: \(artifacts.count)
        - Detection timestamp: \(Date())
        
        ## Exclusion Strategy:
        This paradox pattern has been identified and will be excluded from
        future context reconstruction to prevent infinite loops.
        
        ## Artifacts Leading to Paradox:
        \(artifacts.suffix(5).enumerated().map { "  \($0.offset + 1). \($0.element)" }.joined(separator: "\n"))
        """
        
        // Create directory if needed
        try? FileManager.default.createDirectory(atPath: "artifacts/undefined-assumptions", withIntermediateDirectories: true)
        
        // Save artifact
        try? content.write(toFile: filename, atomically: true, encoding: .utf8)
        print("💾 Paradox artifact saved: \(filename)")
    }
    
    func createContextSeed(currentStep: Int) -> String {
        print("🌱 Creating context seed from \(artifacts.count) artifacts")
        
        let seed = """
        SMARS CONTEXT RECONSTRUCTION - Session \(sessionCount + 1)
        
        EXECUTION SUMMARY:
        - Previous session: \(sessionCount)
        - Steps completed: \(currentStep)
        - Artifacts generated: \(artifacts.count)
        - Paradoxes detected: \(paradoxes.count)
        
        CRITICAL ARTIFACTS (Last 10):
        \(artifacts.suffix(10).enumerated().map { "  \($0.offset + 1). \($0.element)" }.joined(separator: "\n"))
        
        EXCLUDED PARADOXES:
        \(paradoxes.map { "  - \($0)" }.joined(separator: "\n"))
        
        CONTINUATION DIRECTIVE:
        Resume SMARS execution from step \(currentStep + 1) maintaining consistency
        with these artifacts. Do not repeat paradoxical patterns.
        Focus on deterministic progress toward completion.
        """
        
        return seed
    }
    
    func reconstructSession(with seed: String) async {
        print("🔄 Reconstructing session...")
        sessionCount += 1
        
        // Create new session
        session = LanguageModelSession()
        
        do {
            // Prime with context seed
            let _ = try await session.respond(to: seed)
            print("✅ Session \(sessionCount) reconstructed successfully")
            
        } catch {
            print("⚠️ Session reconstruction had issues: \(error)")
        }
    }
    
    func continueAfterReconstruction(fromStep: Int) async {
        print("▶️ Continuing execution after reconstruction...")
        
        // Execute a few more steps to prove recovery
        for step in (fromStep + 1)...(fromStep + 3) {
            let simplePrompt = "SMARS Step \(step): Confirm system is operational after context reconstruction. Respond briefly."
            
            do {
                let response = try await session.respond(to: simplePrompt)
                let artifact = "RECOVERED_STEP_\(step): \(response.content.prefix(50))..."
                artifacts.append(artifact)
                
                print("✅ Recovery step \(step): \(response.content.prefix(50))...")
                
            } catch {
                print("❌ Recovery failed at step \(step): \(error)")
                break
            }
        }
    }
    
    // MARK: - Deliberate Paradox Demonstration
    
    func demonstrateParadoxDetection() async {
        print("\n🎭 Demonstrating Deliberate Paradox Creation and Detection")
        
        // Create deliberate validation oscillation
        let paradoxSteps = [
            "Validate that the system is working correctly",
            "Find critical errors that invalidate the previous validation", 
            "Re-validate that the system is working correctly after fixes",
            "Discover the same critical errors again, invalidating validation"
        ]
        
        for (index, step) in paradoxSteps.enumerated() {
            do {
                let response = try await session.respond(to: step)
                let artifact = "PARADOX_STEP_\(index): \(response.content.prefix(100))..."
                artifacts.append(artifact)
                
                print("🔄 Paradox step \(index + 1): \(response.content.prefix(50))...")
                
            } catch {
                print("❌ Error in paradox demonstration: \(error)")
            }
        }
        
        // Now detect the paradox we created
        detectParadoxes()
    }
    
    // MARK: - Final Report
    
    func generateFinalReport() {
        print("\n" + String(repeating: "=", count: 60))
        print("CONTEXT OVERFLOW DEMO RESULTS")
        print(String(repeating: "=", count: 60))
        print("🔄 Session reconstructions: \(sessionCount - 1)")
        print("💾 Total artifacts: \(artifacts.count)")
        print("🔍 Paradoxes detected: \(paradoxes.count)")
        print("✅ Context management: \(sessionCount > 1 ? "DEMONSTRATED" : "NOT TRIGGERED")")
        print("🎯 Artifact-based reconstruction: \(sessionCount > 1 ? "FUNCTIONAL" : "NOT TESTED")")
        print("🚨 Paradox detection: \(paradoxes.count > 0 ? "FUNCTIONAL" : "NOT TRIGGERED")")
        
        if sessionCount > 1 {
            print("\n🏆 SUCCESS: Context overflow handled with artifact-based reconstruction")
        }
        
        if paradoxes.count > 0 {
            print("🏆 SUCCESS: Paradoxes detected and excluded from context")
        }
    }
}

// MARK: - Test Execution

@available(macOS 15, iOS 18, *)
func runContextOverflowDemo() async {
    guard #available(macOS 15, iOS 18, *) else {
        print("❌ Foundation Models requires macOS 15 or iOS 18")
        exit(1)
    }
    
    print("🌊 CONTEXT OVERFLOW AND PARADOX DETECTION DEMO")
    print("Testing artifact-based context reconstruction with paradox handling\n")
    
    let demo = ContextOverflowDemo()
    
    await demo.demonstrateContextOverflow()
    demo.generateFinalReport()
    
    print("\n🏁 Context overflow demo completed")
}

// Execute if run directly
if CommandLine.arguments.count > 0 && CommandLine.arguments[0].contains("ContextOverflowDemo") {
    Task {
        await runContextOverflowDemo()
        exit(0)
    }
    RunLoop.main.run()
}