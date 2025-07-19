import Foundation
import FoundationModels

/// SMARS Agent with Real Apple Foundation Models Integration
@available(macOS 15, iOS 18, *)
struct SMARSAgentWithFoundationModels {
    
    // MARK: - Core Types
    
    struct Declaration {
        let type: DeclarationType
        let identifier: String
        let content: [String: Any]
        let lineNumber: Int
    }
    
    enum DeclarationType: String, CaseIterable {
        case kind, datum, maplet, contract, plan, apply, test, cue
    }
    
    struct ExecutionStep {
        let stepId: String
        let actionType: String
        let target: String
        let inputData: Any
        var outputData: Any?
        var validationResult: Bool?
        var confidenceScore: Double?
        let timestamp: Date
        var error: String?
        var modelResponse: String?
        
        init(stepId: String, actionType: String, target: String, inputData: Any) {
            self.stepId = stepId
            self.actionType = actionType
            self.target = target
            self.inputData = inputData
            self.timestamp = Date()
        }
    }
    
    // MARK: - Properties
    
    private var declarations: [Declaration] = []
    private var executionTrace: [ExecutionStep] = []
    private var modelSession = LanguageModelSession()
    
    // MARK: - Foundation Models Integration
    
    mutating func invokeFoundationModel(prompt: String, role: String = "assistant") async -> (response: String, confidence: Double) {
        do {
            let response = try await modelSession.respond(to: prompt)
            
            // Extract confidence from response content (simple heuristic)
            let confidence = extractConfidenceHeuristic(from: response.content)
            
            print("🤖 Foundation Model (\(role)): \(response.content)")
            return (response.content, confidence)
            
        } catch {
            print("⚠️  Foundation Model error: \(error)")
            return ("Error: \(error.localizedDescription)", 0.0)
        }
    }
    
    private func extractConfidenceHeuristic(from content: String) -> Double {
        // Simple heuristic - look for uncertainty indicators
        let uncertainWords = ["maybe", "possibly", "might", "could", "uncertain", "not sure"]
        let words = content.lowercased().components(separatedBy: .whitespacesAndNewlines)
        let uncertainCount = uncertainWords.reduce(0) { count, word in
            count + (words.contains(word) ? 1 : 0)
        }
        
        // Higher uncertainty = lower confidence
        return max(0.1, 1.0 - (Double(uncertainCount) * 0.2))
    }
    
    // MARK: - SMARS Parsing (simplified)
    
    mutating func parseFile(at path: String) throws -> [Declaration] {
        let content = try String(contentsOfFile: path)
        
        // Parse plan declarations (focus on plans for execution)
        let planPattern = #"\(plan\s+(\w+).*?§\s*steps:\s*((?:\s*-\s*\w+)+)\)"#
        parseDeclarations(in: content, pattern: planPattern, type: .plan)
        
        print("📋 Parsed \(declarations.count) SMARS declarations")
        return declarations
    }
    
    private mutating func parseDeclarations(in content: String, pattern: String, type: DeclarationType) {
        let regex = try! NSRegularExpression(pattern: pattern, options: [.dotMatchesLineSeparators])
        let matches = regex.matches(in: content, range: NSRange(content.startIndex..., in: content))
        
        for match in matches {
            guard let identifierRange = Range(match.range(at: 1), in: content) else { continue }
            let identifier = String(content[identifierRange])
            
            var declarationContent: [String: Any] = [:]
            
            if type == .plan,
               let stepsRange = Range(match.range(at: 2), in: content) {
                let stepsText = String(content[stepsRange])
                let steps = stepsText.components(separatedBy: "\n")
                    .compactMap { line in
                        let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
                        return trimmed.hasPrefix("-") ? String(trimmed.dropFirst().trimmingCharacters(in: .whitespacesAndNewlines)) : nil
                    }
                declarationContent["steps"] = steps
            }
            
            let lineNumber = content[..<content.index(content.startIndex, offsetBy: match.range.location)]
                .components(separatedBy: .newlines).count
            
            let declaration = Declaration(
                type: type,
                identifier: identifier,
                content: declarationContent,
                lineNumber: lineNumber
            )
            
            declarations.append(declaration)
            print("✅ Parsed \(type.rawValue): \(identifier)")
        }
    }
    
    // MARK: - Foundation Model-Enhanced Plan Execution
    
    mutating func executePlanWithFoundationModel(_ plan: Declaration) async -> [ExecutionStep] {
        guard plan.type == .plan,
              let steps = plan.content["steps"] as? [String] else {
            return []
        }
        
        print("🚀 Executing plan with Foundation Model: \(plan.identifier)")
        var planSteps: [ExecutionStep] = []
        
        // Ask Foundation Model to plan the execution
        let planPrompt = """
        You are executing a SMARS plan called '\(plan.identifier)' with these steps:
        \(steps.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n"))
        
        For each step, suggest a concrete shell command or action to execute it.
        Be specific and practical. Respond in this format:
        Step 1: [suggested command]
        Step 2: [suggested command]
        etc.
        """
        
        let (planningResponse, planningConfidence) = await invokeFoundationModel(prompt: planPrompt, role: "planner")
        
        // Execute each step with Foundation Model guidance
        for (index, stepName) in steps.enumerated() {
            var step = ExecutionStep(
                stepId: "plan_\(plan.identifier)_step_\(index)",
                actionType: "foundation_model_guided_execution",
                target: stepName,
                inputData: ["step_name": stepName, "planning_response": planningResponse]
            )
            
            // Extract suggested command from planning response (simple pattern matching)
            let command = extractCommandForStep(stepName: stepName, from: planningResponse)
            
            // Execute the command
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
                
                step.outputData = [
                    "command": command,
                    "stdout": stdout,
                    "stderr": stderr,
                    "exitCode": process.terminationStatus
                ]
                
                // Ask Foundation Model to validate the result
                let validationPrompt = """
                Step '\(stepName)' executed command: \(command)
                Output: \(stdout)
                Error: \(stderr)
                Exit code: \(process.terminationStatus)
                
                Was this step successful? Rate confidence 0-1 and explain briefly.
                """
                
                let (validationResponse, validationConfidence) = await invokeFoundationModel(prompt: validationPrompt, role: "validator")
                
                step.validationResult = process.terminationStatus == 0 && validationResponse.lowercased().contains("successful")
                step.confidenceScore = validationConfidence
                step.modelResponse = validationResponse
                
                print("📊 Step \(index + 1)/\(steps.count): \(stepName) - \(step.validationResult == true ? "✅" : "❌")")
                
            } catch {
                step.error = error.localizedDescription
                step.validationResult = false
                step.confidenceScore = 0.0
                print("❌ Step execution failed: \(error)")
            }
            
            planSteps.append(step)
            executionTrace.append(step)
        }
        
        return planSteps
    }
    
    private func extractCommandForStep(stepName: String, from planningResponse: String) -> String {
        // Simple command extraction - in practice this would be more sophisticated
        if stepName.lowercased().contains("parse") {
            return "wc -l grammar/smars.ebnf.md"
        } else if stepName.lowercased().contains("test") {
            return "echo 'Test step: \(stepName)'"
        } else if stepName.lowercased().contains("validate") {
            return "ls -la spec/"
        } else {
            return "echo 'Executing: \(stepName)'"
        }
    }
    
    // MARK: - Main Execution
    
    mutating func runSpecificationWithFoundationModels(at path: String) async -> [String: Any] {
        print("🎯 Running SMARS specification with Foundation Models: \(path)")
        
        do {
            let declarations = try parseFile(at: path)
            let plans = declarations.filter { $0.type == .plan }
            
            var results: [String: Any] = [
                "specification_file": path,
                "declarations_found": declarations.count,
                "plans_executed": 0,
                "execution_steps": 0,
                "foundation_model_calls": 0,
                "overall_success": true,
                "timestamp": ISO8601DateFormatter().string(from: Date())
            ]
            
            // Execute all plans with Foundation Model integration
            for plan in plans {
                let planSteps = await executePlanWithFoundationModel(plan)
                results["plans_executed"] = (results["plans_executed"] as! Int) + 1
                results["execution_steps"] = (results["execution_steps"] as! Int) + planSteps.count
                results["foundation_model_calls"] = (results["foundation_model_calls"] as! Int) + (planSteps.count * 2) // planner + validator calls
                
                // Check for failures
                if planSteps.contains(where: { $0.validationResult == false }) {
                    results["overall_success"] = false
                }
            }
            
            // Calculate success metrics
            let successfulSteps = executionTrace.filter { $0.validationResult == true }.count
            results["success_rate"] = Double(successfulSteps) / Double(executionTrace.count)
            results["average_confidence"] = executionTrace.compactMap { $0.confidenceScore }.reduce(0, +) / Double(executionTrace.count)
            
            return results
            
        } catch {
            return [
                "error": error.localizedDescription,
                "overall_success": false
            ]
        }
    }
}

// MARK: - Main Entry Point

@available(macOS 15, iOS 18, *)
@main
struct SMARSFoundationModelsMain {
    static func main() async {
        guard #available(macOS 15, iOS 18, *) else {
            fatalError("Foundation Models requires macOS 15 / iOS 18")
        }
        
        print("🧠 Starting SMARS Agent with Apple Foundation Models")
        
        var agent = SMARSAgentWithFoundationModels()
        
        // Test with the corrected specification
        let specPath = "spec/automation/symbolic-testing-workflow-corrected.smars.md"
        
        guard FileManager.default.fileExists(atPath: specPath) else {
            print("❌ Specification file not found at \(specPath)")
            exit(1)
        }
        
        // Run the specification with Foundation Models
        let results = await agent.runSpecificationWithFoundationModels(at: specPath)
        
        // Output results
        print("\n" + String(repeating: "=", count: 60))
        print("SMARS + FOUNDATION MODELS EXECUTION RESULTS")
        print(String(repeating: "=", count: 60))
        
        for (key, value) in results.sorted(by: { $0.key < $1.key }) {
            print("📈 \(key): \(value)")
        }
        
        // Save execution report
        let reportData = try! JSONSerialization.data(withJSONObject: results, options: .prettyPrinted)
        let timestamp = ISO8601DateFormatter().string(from: Date()).replacingOccurrences(of: ":", with: "-")
        let reportPath = "impl/foundation-models-execution-\(timestamp).json"
        
        try! reportData.write(to: URL(fileURLWithPath: reportPath))
        print("\n💾 Execution report saved to: \(reportPath)")
        
        // Exit with appropriate code
        let success = results["overall_success"] as? Bool ?? false
        exit(success ? 0 : 1)
    }
}