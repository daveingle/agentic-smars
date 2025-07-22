#!/usr/bin/env swift

import Foundation
#if canImport(FoundationModels)
import FoundationModels
#endif

struct LLMRequest: Codable {
    let taskType: String
    let mapletName: String
    let args: [AnyCodable]
    let context: LLMContext
    
    private enum CodingKeys: String, CodingKey {
        case taskType = "task_type"
        case mapletName = "maplet_name"
        case args, context
    }
}

struct LLMContext: Codable {
    let executionId: String
    let variables: [String: AnyCodable]
    let trace: [String]
    
    private enum CodingKeys: String, CodingKey {
        case executionId = "execution_id"
        case variables, trace
    }
}

struct LLMResponse: Codable {
    let success: Bool
    let result: AnyCodable?
    let error: String?
    let reasoning: String?
}

// Helper for encoding/decoding Any values
struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let string = try? container.decode(String.self) {
            value = string
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dict = try? container.decode([String: AnyCodable].self) {
            value = dict.mapValues { $0.value }
        } else {
            value = NSNull()
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let string as String:
            try container.encode(string)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let bool as Bool:
            try container.encode(bool)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dict as [String: Any]:
            try container.encode(dict.mapValues { AnyCodable($0) })
        default:
            try container.encodeNil()
        }
    }
}

class FoundationModelsAgent {
    
    func processRequest(_ request: LLMRequest) async -> LLMResponse {
        switch request.taskType {
        case "test":
            return LLMResponse(
                success: true,
                result: AnyCodable("FoundationModels agent is working"),
                error: nil,
                reasoning: "Test successful"
            )
            
        case "execute_maplet":
            return await executeMaplet(request)
            
        case "validate_contract":
            return await validateContract(request)
            
        case "complete_cue":
            return await completeCue(request)
            
        default:
            return LLMResponse(
                success: false,
                result: nil,
                error: "Unknown task type: \\(request.taskType)",
                reasoning: nil
            )
        }
    }
    
    private func executeMaplet(_ request: LLMRequest) async -> LLMResponse {
        #if canImport(FoundationModels)
        // Use FoundationModels for LLM-based maplet execution
        let prompt = buildMapletPrompt(request)
        
        do {
            let response = try await callFoundationModel(prompt: prompt)
            return LLMResponse(
                success: true,
                result: AnyCodable(response),
                error: nil,
                reasoning: "Executed via FoundationModels"
            )
        } catch {
            return LLMResponse(
                success: false,
                result: nil,
                error: error.localizedDescription,
                reasoning: nil
            )
        }
        #else
        // Fallback implementation without FoundationModels
        return await executeMapletFallback(request)
        #endif
    }
    
    private func validateContract(_ request: LLMRequest) async -> LLMResponse {
        #if canImport(FoundationModels)
        let prompt = buildContractValidationPrompt(request)
        
        do {
            let response = try await callFoundationModel(prompt: prompt)
            let isValid = response.lowercased().contains("true") || response.lowercased().contains("valid")
            
            return LLMResponse(
                success: true,
                result: AnyCodable(isValid),
                error: nil,
                reasoning: response
            )
        } catch {
            return LLMResponse(
                success: false,
                result: AnyCodable(false),
                error: error.localizedDescription,
                reasoning: nil
            )
        }
        #else
        // Fallback: assume contracts are valid
        return LLMResponse(
            success: true,
            result: AnyCodable(true),
            error: nil,
            reasoning: "Fallback validation (no FoundationModels)"
        )
        #endif
    }
    
    private func completeCue(_ request: LLMRequest) async -> LLMResponse {
        #if canImport(FoundationModels)
        let prompt = buildCueCompletionPrompt(request)
        
        do {
            let completion = try await callFoundationModel(prompt: prompt)
            return LLMResponse(
                success: true,
                result: AnyCodable(completion),
                error: nil,
                reasoning: "Completed via FoundationModels"
            )
        } catch {
            return LLMResponse(
                success: false,
                result: nil,
                error: error.localizedDescription,
                reasoning: nil
            )
        }
        #else
        return await completeCueFallback(request)
        #endif
    }
    
    #if canImport(FoundationModels)
    private func callFoundationModel(prompt: String) async throws -> String {
        // Initialize the model client
        let client = LanguageModelClient()
        
        // Create the request
        let systemPrompt = """
        You are a SMARS (Symbolic Multi-Agent Reasoning System) interpreter. 
        You help execute symbolic plans, validate contracts, and complete cues.
        Always provide precise, actionable responses.
        """
        
        let request = LanguageModelRequest(
            messages: [
                .system(content: systemPrompt),
                .user(content: prompt)
            ],
            parameters: LanguageModelRequestParameters()
        )
        
        // Execute the request
        let response = try await client.send(request)
        
        return response.content ?? "No response generated"
    }
    #endif
    
    // Fallback implementations for when FoundationModels is not available
    
    private func executeMapletFallback(_ request: LLMRequest) async -> LLMResponse {
        let mapletName = request.mapletName
        
        switch mapletName {
        case "complete_cue":
            return LLMResponse(
                success: true,
                result: AnyCodable("Cue completed (fallback implementation)"),
                error: nil,
                reasoning: "Fallback cue completion"
            )
            
        case "generate_plan":
            return LLMResponse(
                success: true,
                result: AnyCodable([
                    "step_1": "analyze_requirements",
                    "step_2": "generate_solution",
                    "step_3": "validate_output"
                ]),
                error: nil,
                reasoning: "Fallback plan generation"
            )
            
        case "analyze_pattern":
            return LLMResponse(
                success: true,
                result: AnyCodable([
                    "pattern": "sequential_processing",
                    "confidence": 0.8,
                    "recommendations": ["optimize_parallelism"]
                ]),
                error: nil,
                reasoning: "Fallback pattern analysis"
            )
            
        default:
            return LLMResponse(
                success: true,
                result: AnyCodable("Maplet \\(mapletName) executed (fallback)"),
                error: nil,
                reasoning: "Generic fallback execution"
            )
        }
    }
    
    private func completeCueFallback(_ request: LLMRequest) async -> LLMResponse {
        return LLMResponse(
            success: true,
            result: AnyCodable("Cue completion: Consider implementing error handling and validation patterns for improved system resilience."),
            error: nil,
            reasoning: "Fallback cue completion with generic improvement suggestion"
        )
    }
    
    // Prompt building helpers
    
    private func buildMapletPrompt(_ request: LLMRequest) -> String {
        let context = request.context
        let args = request.args.map { "\\($0.value)" }.joined(separator: ", ")
        
        return """
        Execute SMARS maplet: \\(request.mapletName)
        
        Arguments: [\\(args)]
        
        Execution Context:
        - Execution ID: \\(context.executionId)
        - Variables: \\(context.variables.keys.joined(separator: ", "))
        - Previous Steps: \\(context.trace.joined(separator: " → "))
        
        Provide a specific, actionable result for this maplet execution.
        """
    }
    
    private func buildContractValidationPrompt(_ request: LLMRequest) -> String {
        guard let contractData = request.args.first?.value as? [String: Any] else {
            return "Invalid contract data"
        }
        
        let requires = (contractData["requires"] as? [String]) ?? []
        let ensures = (contractData["ensures"] as? [String]) ?? []
        
        return """
        Validate SMARS contract: \\(request.mapletName)
        
        Requirements:
        \\(requires.map { "- \\($0)" }.joined(separator: "\\n"))
        
        Ensures:
        \\(ensures.map { "- \\($0)" }.joined(separator: "\\n"))
        
        Current execution context: \\(request.context.trace.joined(separator: " → "))
        
        Determine if this contract is satisfied. Respond with "true" if valid, "false" if invalid, and explain your reasoning.
        """
    }
    
    private func buildCueCompletionPrompt(_ request: LLMRequest) -> String {
        let cueContext = request.args.first?.value ?? "No context provided"
        let missingParts = (request.args.count > 1 ? request.args[1].value as? [String] : nil) ?? []
        
        return """
        Complete the following SMARS cue:
        
        Context: \\(cueContext)
        Missing parts: \\(missingParts.joined(separator: ", "))
        
        Execution history: \\(request.context.trace.joined(separator: " → "))
        
        Provide a specific, actionable completion that addresses the missing parts and fits the context.
        """
    }
}

// Main execution logic

@main
struct Main {
    static func main() async {
        let agent = FoundationModelsAgent()
        
        let arguments = CommandLine.arguments
        
        // Check for --json-input flag
        guard arguments.contains("--json-input") else {
            print("Usage: swift-foundationmodels-agent --json-input")
            print("Reads JSON input from stdin and processes SMARS requests")
            return
        }
        
        // Read JSON from stdin
        let inputData = FileHandle.standardInput.readDataToEndOfFile()
        
        guard let jsonString = String(data: inputData, encoding: .utf8) else {
            let errorResponse = LLMResponse(
                success: false,
                result: nil,
                error: "Failed to read input as UTF-8",
                reasoning: nil
            )
            printResponse(errorResponse)
            return
        }
        
        // Parse JSON request
        guard let requestData = jsonString.data(using: .utf8),
              let request = try? JSONDecoder().decode(LLMRequest.self, from: requestData) else {
            let errorResponse = LLMResponse(
                success: false,
                result: nil,
                error: "Failed to parse JSON request",
                reasoning: nil
            )
            printResponse(errorResponse)
            return
        }
        
        // Process request
        let response = await agent.processRequest(request)
        printResponse(response)
    }
    
    static func printResponse(_ response: LLMResponse) {
        do {
            let jsonData = try JSONEncoder().encode(response)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
        } catch {
            print("{\"success\": false, \"error\": \"Failed to encode response\"}")
        }
    }
}