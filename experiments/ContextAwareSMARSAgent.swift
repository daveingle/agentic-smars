#!/usr/bin/env swift

import Foundation
import FoundationModels

/// Context-Aware SMARS Agent with Paradox Detection and Artifact-Based Reconstruction
@available(macOS 15, iOS 18, *)
class ContextAwareSMARSAgent {
    
    // MARK: - Core Types
    
    struct ExecutionArtifact {
        let artifactId: String
        let artifactType: ArtifactType
        let stepId: String
        let stepName: String
        let content: [String: Any]
        let timestamp: Date
        let deterministicHash: String
        
        var deterministicDescription: String {
            """
            ARTIFACT[\(artifactId)]: \(artifactType.rawValue)
            Step: \(stepName)
            Content: \(formatContent())
            Hash: \(deterministicHash)
            """
        }
        
        private func formatContent() -> String {
            return content.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        }
    }
    
    enum ArtifactType: String {
        case shellExecution = "shell_execution"
        case foundationModelResponse = "foundation_model_response"
        case validationResult = "validation_result"
        case contractEvaluation = "contract_evaluation"
        case systemState = "system_state"
    }
    
    struct UndefinedAssumption {
        let paradoxId: String
        let paradoxType: ParadoxType
        let conflictingElements: [String]
        let exclusionRationale: String
        let detectedAt: Date
        
        var description: String {
            """
            PARADOX[\(paradoxId)]: \(paradoxType.rawValue)
            Conflicting: \(conflictingElements.joined(separator: " → "))
            Rationale: \(exclusionRationale)
            """
        }
    }
    
    enum ParadoxType: String {
        case actionUndoCycle = "action_undo_cycle"
        case validationConflict = "validation_conflict"
        case foundationModelContradiction = "foundation_model_contradiction"
    }
    
    struct ContextSeed {
        let artifacts: [ExecutionArtifact]
        let excludedParadoxes: [UndefinedAssumption]
        let systemState: SystemState
        let reconstructionPrompt: String
    }
    
    struct SystemState {
        let currentStep: Int
        let completedPlans: [String]
        let validatedContracts: [String: Bool]
        let confidenceTrajectory: [Double]
        let overallProgress: Double
        
        var description: String {
            """
            Current Step: \(currentStep)
            Completed Plans: \(completedPlans.joined(separator: ", "))
            Contract Status: \(validatedContracts.map { "\($0.key): \($0.value)" }.joined(separator: ", "))
            Average Confidence: \(String(format: "%.2f", confidenceTrajectory.reduce(0, +) / Double(max(1, confidenceTrajectory.count))))
            Progress: \(String(format: "%.1f%%", overallProgress * 100))
            """
        }
    }
    
    struct ExecutionStep {
        let stepId: String
        let stepName: String
        let actionType: String
        var foundationModelPrompt: String?
        var foundationModelResponse: String?
        var shellCommand: String?
        var shellOutput: String?
        var validationResult: Bool?
        var confidenceScore: Double?
        let timestamp: Date
        var error: String?
        var executionTimeMs: Int?
        var artifacts: [ExecutionArtifact] = []
        
        init(stepId: String, stepName: String, actionType: String) {
            self.stepId = stepId
            self.stepName = stepName
            self.actionType = actionType
            self.timestamp = Date()
        }
    }
    
    // MARK: - Properties
    
    private var session: LanguageModelSession
    private var executionTrace: [ExecutionStep] = []
    private var artifacts: [ExecutionArtifact] = []
    private var paradoxes: [UndefinedAssumption] = []
    private let contextLimit = 3500 // Leave buffer before 4096 limit
    private var sessionCount = 1
    
    init() {
        self.session = LanguageModelSession()
        print("🧠 Context-Aware SMARS Agent initialized (Session \(sessionCount))")
    }
    
    // MARK: - Context Management
    
    private func isContextNearLimit() -> Bool {
        // Heuristic: assume ~10 tokens per character for estimation
        let estimatedTokens = executionTrace.count * 200 // Rough estimate per step
        return estimatedTokens > contextLimit
    }
    
    private func detectContextOverflow(from error: Error) -> Bool {
        let errorDescription = String(describing: error)
        return errorDescription.localizedCaseInsensitiveContains("context length") ||
               errorDescription.localizedCaseInsensitiveContains("max context")
    }
    
    private func createContextSeed() -> ContextSeed {
        print("🔄 Creating context seed from \(artifacts.count) artifacts")
        
        let systemState = SystemState(
            currentStep: executionTrace.count,
            completedPlans: Array(Set(executionTrace.compactMap { $0.validationResult == true ? $0.stepName : nil })),
            validatedContracts: [:], // Would extract from contract evaluations
            confidenceTrajectory: executionTrace.compactMap { $0.confidenceScore },
            overallProgress: Double(executionTrace.filter { $0.validationResult == true }.count) / Double(max(1, executionTrace.count))
        )
        
        let reconstructionPrompt = """
        You are continuing a SMARS (Symbolic Multi-Agent Reasoning System) execution.
        Context was reset due to length limits. Resume from this validated state:
        
        SYSTEM STATE:
        \(systemState.description)
        
        EXECUTION ARTIFACTS:
        \(artifacts.suffix(20).map { $0.deterministicDescription }.joined(separator: "\n\n"))
        
        EXCLUDED PARADOXES (do not repeat):
        \(paradoxes.map { $0.description }.joined(separator: "\n"))
        
        Continue SMARS execution maintaining consistency with these artifacts.
        Do not repeat paradoxical patterns. Focus on deterministic progress.
        """
        
        return ContextSeed(
            artifacts: artifacts,
            excludedParadoxes: paradoxes,
            systemState: systemState,
            reconstructionPrompt: reconstructionPrompt
        )
    }
    
    private func reconstructSession(with seed: ContextSeed) async {
        print("🔄 Reconstructing session from context seed...")
        sessionCount += 1
        
        // Create new session
        session = LanguageModelSession()
        
        do {
            // Prime with reconstruction context
            let _ = try await session.respond(to: seed.reconstructionPrompt)
            print("✅ Session \(sessionCount) reconstructed with \(seed.artifacts.count) artifacts")
        } catch {
            print("⚠️ Session reconstruction failed: \(error)")
        }
    }
    
    // MARK: - Paradox Detection
    
    private func detectParadoxes() -> [UndefinedAssumption] {
        var detectedParadoxes: [UndefinedAssumption] = []
        
        // Detect action-undo cycles in recent execution
        let recentSteps = executionTrace.suffix(8)
        for i in 0..<(recentSteps.count - 3) {
            let window = Array(recentSteps[i..<(i+4)])
            if let paradox = detectActionUndoCycle(in: window) {
                detectedParadoxes.append(paradox)
            }
        }
        
        // Detect validation conflicts
        let validationResults = executionTrace.filter { $0.validationResult != nil }
        if validationResults.count >= 4 {
            let recent = validationResults.suffix(4)
            if let paradox = detectValidationOscillation(in: Array(recent)) {
                detectedParadoxes.append(paradox)
            }
        }
        
        // Detect Foundation Model contradictions
        if let paradox = detectFoundationModelContradictions() {
            detectedParadoxes.append(paradox)
        }
        
        return detectedParadoxes
    }
    
    private func detectActionUndoCycle(in steps: [ExecutionStep]) -> UndefinedAssumption? {
        guard steps.count == 4 else { return nil }
        
        // Look for A → ¬A → A → ¬A pattern in validation results
        let results = steps.compactMap { $0.validationResult }
        if results.count == 4 && results == [true, false, true, false] {
            return UndefinedAssumption(
                paradoxId: "paradox_\(UUID().uuidString.prefix(8))",
                paradoxType: .actionUndoCycle,
                conflictingElements: steps.map { "\($0.stepName): \($0.validationResult ?? false)" },
                exclusionRationale: "Detected oscillating validation results indicating contradictory assumptions",
                detectedAt: Date()
            )
        }
        
        return nil
    }
    
    private func detectValidationOscillation(in steps: [ExecutionStep]) -> UndefinedAssumption? {
        let validationPattern = steps.map { $0.validationResult ?? false }
        
        // Check for alternating pattern
        if validationPattern.count >= 4 {
            let alternating = zip(validationPattern, validationPattern.dropFirst()).allSatisfy { $0 != $1 }
            if alternating {
                return UndefinedAssumption(
                    paradoxId: "validation_\(UUID().uuidString.prefix(8))",
                    paradoxType: .validationConflict,
                    conflictingElements: steps.map { "\($0.stepName): \($0.validationResult ?? false)" },
                    exclusionRationale: "Validation results oscillate, indicating conflicting contracts or requirements",
                    detectedAt: Date()
                )
            }
        }
        
        return nil
    }
    
    private func detectFoundationModelContradictions() -> UndefinedAssumption? {
        let responses = executionTrace.compactMap { $0.foundationModelResponse }.suffix(3)
        
        // Simple contradiction detection: look for "SUCCESS: yes" followed by "SUCCESS: no" patterns
        if responses.count >= 3 {
            let successPattern = responses.map { response in
                response.lowercased().contains("success: yes")
            }
            
            // If we see success, failure, success pattern, it might be a contradiction
            if successPattern.count == 3 && successPattern == [true, false, true] {
                return UndefinedAssumption(
                    paradoxId: "contradiction_\(UUID().uuidString.prefix(8))",
                    paradoxType: .foundationModelContradiction,
                    conflictingElements: Array(responses),
                    exclusionRationale: "Foundation Model provided contradictory assessments for similar operations",
                    detectedAt: Date()
                )
            }
        }
        
        return nil
    }
    
    private func saveParadoxArtifact(_ paradox: UndefinedAssumption) {
        let timestamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let filename = "artifacts/undefined-assumptions/\(paradox.paradoxId)-\(timestamp).md"
        
        let artifactContent = """
        # Undefined Assumption Artifact: \(paradox.paradoxId.uppercased())
        
        ## Paradox Type: \(paradox.paradoxType.rawValue)
        
        ## Detection Time: \(ISO8601DateFormatter().string(from: paradox.detectedAt))
        
        ## Conflicting Elements:
        \(paradox.conflictingElements.enumerated().map { "  \($0.offset + 1). \($0.element)" }.joined(separator: "\n"))
        
        ## Root Cause Analysis:
        \(paradox.exclusionRationale)
        
        ## Resolution:
        This paradox has been excluded from future context reconstruction to prevent 
        infinite loops and maintain deterministic execution progress.
        
        ## Context Impact:
        Future sessions will not include the conflicting elements in their context
        reconstruction, allowing the system to progress without repeating this paradox.
        """
        
        // Create directory if needed
        try? FileManager.default.createDirectory(atPath: "artifacts/undefined-assumptions", withIntermediateDirectories: true)
        
        // Save artifact
        try? artifactContent.write(toFile: filename, atomically: true, encoding: .utf8)
        print("💾 Saved paradox artifact: \(filename)")
    }
    
    // MARK: - Enhanced Foundation Models Integration
    
    private func callFoundationModelWithContextManagement(prompt: String, role: String = "assistant") async -> (response: String, confidence: Double) {
        // Check if we're near context limit before making call
        if isContextNearLimit() {
            print("⚠️ Near context limit, proactively reconstructing session")
            await proactiveContextReconstruction()
        }
        
        do {
            let response = try await session.respond(to: prompt)
            let confidence = extractConfidence(from: response.content)
            
            print("🤖 Foundation Model (\(role)) responded successfully")
            return (response.content, confidence)
            
        } catch {
            if detectContextOverflow(from: error) {
                print("🔄 Context overflow detected, reconstructing session")
                await handleContextOverflow()
                
                // Retry with new session
                do {
                    let response = try await session.respond(to: prompt)
                    let confidence = extractConfidence(from: response.content)
                    return (response.content, confidence)
                } catch let retryError {
                    print("❌ Foundation Model failed after context reconstruction: \(retryError)")
                    return ("Error after reconstruction: \(retryError.localizedDescription)", 0.0)
                }
            } else {
                print("❌ Foundation Model error: \(error)")
                return ("Error: \(error.localizedDescription)", 0.0)
            }
        }
    }
    
    private func proactiveContextReconstruction() async {
        let detectedParadoxes = detectParadoxes()
        if !detectedParadoxes.isEmpty {
            print("🔍 Detected \(detectedParadoxes.count) paradoxes, excluding from context")
            paradoxes.append(contentsOf: detectedParadoxes)
            
            // Save paradox artifacts
            for paradox in detectedParadoxes {
                saveParadoxArtifact(paradox)
            }
        }
        
        let seed = createContextSeed()
        await reconstructSession(with: seed)
    }
    
    private func handleContextOverflow() async {
        await proactiveContextReconstruction()
    }
    
    private func extractConfidence(from text: String) -> Double {
        // Look for explicit confidence patterns
        if let match = text.range(of: #"confidence[:\s]+(0\.\d+|\d+\.?\d*)"#, options: .regularExpression) {
            let confidenceStr = String(text[match]).components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            if let conf = Double(confidenceStr), conf <= 1.0 {
                return conf
            }
        }
        
        // Heuristic based on response quality indicators
        let uncertainWords = ["maybe", "possibly", "might", "could", "uncertain", "not sure", "unclear"]
        let confidenceWords = ["definitely", "certainly", "sure", "confident", "clearly", "successfully"]
        
        let words = text.lowercased().components(separatedBy: .whitespacesAndNewlines)
        let uncertainCount = uncertainWords.reduce(0) { count, word in count + (words.contains(word) ? 1 : 0) }
        let confidentCount = confidenceWords.reduce(0) { count, word in count + (words.contains(word) ? 1 : 0) }
        
        let baseConfidence = 0.7
        let adjustment = (Double(confidentCount) * 0.1) - (Double(uncertainCount) * 0.15)
        return max(0.1, min(1.0, baseConfidence + adjustment))
    }
    
    // MARK: - Artifact Generation
    
    private func createArtifact(for step: ExecutionStep, type: ArtifactType, content: [String: Any]) -> ExecutionArtifact {
        let artifactId = "artifact_\(UUID().uuidString.prefix(8))"
        let contentData = try! JSONSerialization.data(withJSONObject: content)
        let hash = contentData.base64EncodedString().prefix(16)
        
        let artifact = ExecutionArtifact(
            artifactId: artifactId,
            artifactType: type,
            stepId: step.stepId,
            stepName: step.stepName,
            content: content,
            timestamp: step.timestamp,
            deterministicHash: String(hash)
        )
        
        artifacts.append(artifact)
        return artifact
    }
    
    // MARK: - Enhanced Execution
    
    func executeStepWithContextAwareness(stepName: String, stepId: String) async -> ExecutionStep {
        var step = ExecutionStep(stepId: stepId, stepName: stepName, actionType: "context_aware_execution")
        
        // Foundation Model planning with context management
        let planPrompt = "Suggest a concrete action for SMARS step: \(stepName). Respond with just the shell command."
        let (planResponse, planConfidence) = await callFoundationModelWithContextManagement(prompt: planPrompt, role: "planner")
        
        step.foundationModelPrompt = planPrompt
        let command = planResponse.trimmingCharacters(in: .whitespacesAndNewlines)
        step.shellCommand = command
        
        // Create planning artifact
        _ = createArtifact(for: step, type: .foundationModelResponse, content: [
            "role": "planner",
            "prompt": planPrompt,
            "response": planResponse,
            "confidence": planConfidence
        ])
        
        // Execute shell command
        let (output, success, executionTime) = executeShellCommand(command)
        step.shellOutput = output
        step.executionTimeMs = executionTime
        
        // Create execution artifact
        _ = createArtifact(for: step, type: .shellExecution, content: [
            "command": command,
            "output": output,
            "success": success,
            "execution_time_ms": executionTime
        ])
        
        // Foundation Model validation with context management
        let validationPrompt = """
        SMARS Step: \(stepName)
        Command: \(command)
        Output: \(output)
        
        Was this successful? Respond: SUCCESS: [yes/no], CONFIDENCE: [0.0-1.0], REASON: [brief explanation]
        """
        
        let (validationResponse, validationConfidence) = await callFoundationModelWithContextManagement(prompt: validationPrompt, role: "validator")
        step.foundationModelResponse = validationResponse
        
        // Parse validation
        let isSuccessful = validationResponse.lowercased().contains("success: yes") && success
        step.validationResult = isSuccessful
        step.confidenceScore = validationConfidence
        
        // Create validation artifact
        _ = createArtifact(for: step, type: .validationResult, content: [
            "validation_prompt": validationPrompt,
            "validation_response": validationResponse,
            "final_result": isSuccessful,
            "confidence": validationConfidence
        ])
        
        executionTrace.append(step)
        
        print("📊 Step: \(stepName) - \(isSuccessful ? "✅ SUCCESS" : "❌ FAILED") (Session \(sessionCount))")
        
        return step
    }
    
    private func executeShellCommand(_ command: String) -> (output: String, success: Bool, executionTimeMs: Int) {
        let startTime = Date()
        
        let process = Process()
        process.launchPath = "/bin/bash"
        process.arguments = ["-c", command]
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            
            let stdout = String(data: outputData, encoding: .utf8) ?? ""
            let stderr = String(data: errorData, encoding: .utf8) ?? ""
            
            let executionTime = Int(Date().timeIntervalSince(startTime) * 1000)
            let success = process.terminationStatus == 0
            
            let output = stdout.isEmpty ? stderr : stdout
            return (output.trimmingCharacters(in: .whitespacesAndNewlines), success, executionTime)
            
        } catch {
            let executionTime = Int(Date().timeIntervalSince(startTime) * 1000)
            return ("Error: \(error.localizedDescription)", false, executionTime)
        }
    }
    
    // MARK: - Test Execution
    
    func runContextAwarenessTest() async {
        print("🎯 Running Context-Aware SMARS Test")
        
        // Simulate a larger workflow that would exceed context
        let testSteps = [
            "parse_smars_specification",
            "validate_grammar_compliance", 
            "create_execution_plan",
            "initialize_foundation_models",
            "setup_tool_interfaces",
            "configure_validation_framework",
            "test_basic_functionality",
            "run_integration_tests",
            "validate_contract_compliance",
            "generate_execution_report",
            "save_session_artifacts",
            "perform_final_validation",
            "cleanup_temporary_files",
            "archive_execution_data",
            "generate_summary_report"
        ]
        
        for (index, stepName) in testSteps.enumerated() {
            let _ = await executeStepWithContextAwareness(stepName: stepName, stepId: "test_step_\(index)")
            
            // Add small delay to simulate real workflow
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }
        
        // Generate final report
        let successCount = executionTrace.filter { $0.validationResult == true }.count
        let averageConfidence = executionTrace.compactMap { $0.confidenceScore }.reduce(0, +) / Double(max(1, executionTrace.count))
        
        print("\n" + String(repeating: "=", count: 60))
        print("CONTEXT-AWARE SMARS TEST RESULTS")
        print(String(repeating: "=", count: 60))
        print("📊 Total steps: \(executionTrace.count)")
        print("✅ Successful steps: \(successCount)")
        print("📈 Success rate: \(String(format: "%.1f%%", Double(successCount) / Double(executionTrace.count) * 100))")
        print("🎯 Average confidence: \(String(format: "%.2f", averageConfidence))")
        print("🔄 Session reconstructions: \(sessionCount - 1)")
        print("💾 Artifacts generated: \(artifacts.count)")
        print("🔍 Paradoxes detected: \(paradoxes.count)")
        print("🏆 Context management: \(sessionCount > 1 ? "SUCCESSFUL" : "NOT NEEDED")")
        
        // Save final execution report
        try? saveExecutionReport()
    }
    
    private func saveExecutionReport() throws {
        let timestamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let reportPath = "impl/context-aware-execution-\(timestamp).json"
        
        let report: [String: Any] = [
            "execution_summary": [
                "total_steps": executionTrace.count,
                "successful_steps": executionTrace.filter { $0.validationResult == true }.count,
                "session_count": sessionCount,
                "artifacts_generated": artifacts.count,
                "paradoxes_detected": paradoxes.count,
                "context_management_active": sessionCount > 1
            ],
            "artifacts": artifacts.map { artifact in
                [
                    "artifact_id": artifact.artifactId,
                    "type": artifact.artifactType.rawValue,
                    "step_name": artifact.stepName,
                    "hash": artifact.deterministicHash
                ]
            },
            "paradoxes": paradoxes.map { paradox in
                [
                    "paradox_id": paradox.paradoxId,
                    "type": paradox.paradoxType.rawValue,
                    "elements": paradox.conflictingElements,
                    "rationale": paradox.exclusionRationale
                ]
            }
        ]
        
        let reportData = try JSONSerialization.data(withJSONObject: report, options: .prettyPrinted)
        try reportData.write(to: URL(fileURLWithPath: reportPath))
        
        print("💾 Context-aware execution report saved: \(reportPath)")
    }
}

// MARK: - Test Execution

@available(macOS 15, iOS 18, *)
func runContextAwarenessTest() async {
    guard #available(macOS 15, iOS 18, *) else {
        print("❌ Foundation Models requires macOS 15 or iOS 18")
        exit(1)
    }
    
    print("🏭 CONTEXT-AWARE SMARS AGENT TEST")
    print("Testing artifact-based context management with paradox detection\n")
    
    let agent = ContextAwareSMARSAgent()
    await agent.runContextAwarenessTest()
    
    print("\n🏁 Context awareness test completed")
}

// Execute if run directly
if CommandLine.arguments.count > 0 && CommandLine.arguments[0].contains("ContextAwareSMARSAgent") {
    Task {
        await runContextAwarenessTest()
        exit(0)
    }
    RunLoop.main.run()
}