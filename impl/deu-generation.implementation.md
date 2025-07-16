# DEU Generation Implementation

This implementation scaffold describes how to interpret and execute the DEU generation workflow defined in `spec/automation/deu-generation.smars.md`.

## Overview

The DEU (Declarative Execution Unit) generation system transforms natural language prompts into structured SMARS specifications, corresponding implementations, and validation test suites.

## Symbol Interpretations

### Types (kind)

- **Prompt**: Input containing natural language text and target domain
- **Spec**: Generated SMARS specification with module name, file path, and domain
- **Implementation**: Executable interpretation of the specification
- **Review**: Validation result with status and diagnostic notes
- **TestSet**: Collection of test cases targeting the generated module
- **ValidationResult**: Structured validation outcome with success flag and error details
- **DEUArtifact**: Complete artifact bundle containing spec, implementation, and tests

### Constants (datum)

- **spec_template**: File path template for SMARS specifications following project conventions
- **impl_template**: File path template for implementation files
- **validation_policy**: Enforcement level for validation ("strict" requires all contracts to pass)

### Functions (maplet)

#### interpretPrompt
- **Input**: Prompt with text and domain
- **Output**: Spec with generated module name and file path
- **Implementation**: Parse natural language to extract symbolic requirements, generate appropriate SMARS declarations (kind, maplet, contract, plan), determine module name and file location

#### generateImplementation
- **Input**: Spec with module and path information
- **Output**: Implementation with content and file path
- **Implementation**: Read the SMARS specification, create corresponding implementation scaffolds for each declared symbol, generate concrete representations of abstract types and functions

#### generateTests
- **Input**: Spec with module information
- **Output**: TestSet with test cases
- **Implementation**: Analyze declared test blocks in the specification, generate test scaffolds that verify contract preconditions and postconditions, create edge case tests for each maplet

#### validateImplementation
- **Input**: Spec and Implementation pair
- **Output**: Review with validation status
- **Implementation**: Cross-reference implementation against specification contracts, verify all declared symbols have corresponding implementations, check that contract requirements are enforced

#### assembleArtifact
- **Input**: Spec, Implementation, and TestSet
- **Output**: Complete DEUArtifact
- **Implementation**: Bundle all components into a cohesive artifact, ensure referential consistency across components, generate summary documentation

## Plan Execution

### generateDeclarativeExecutionUnit

The main workflow executes in sequence:

1. **interpretPrompt**: Parse natural language input into structured symbolic requirements
2. **generateImplementation**: Create executable interpretation of the symbolic spec
3. **generateTests**: Generate validation test cases
4. **validateImplementation**: Verify implementation consistency with specification
5. **assembleArtifact**: Bundle components into complete DEU artifact

### Validation Branching

The `validationOutcome` branch handles different validation results:

- **status = "pass"**: Proceed to artifact assembly
- **status = "fail"**: Return to implementation generation for correction
- **else**: Re-run validation with additional diagnostics

## Contract Enforcement

### interpretPrompt Contract
- Verify non-empty text and domain inputs
- Ensure generated spec has valid path and module name
- Validate path follows project conventions

### generateImplementation Contract
- Require valid spec path and module name
- Ensure non-empty implementation content
- Verify file path contains ".implementation.md" extension

### generateTests Contract
- Require valid module name
- Ensure at least one test case is generated
- Verify all test cases reference declared module symbols

### validateImplementation Contract
- Require matching module names between spec and implementation
- Enforce validation policy settings
- Ensure validation produces either "pass" or "fail" status with explanatory notes

### assembleArtifact Contract
- Require consistent module names across all components
- Ensure artifact contains all required components

## Integration Points

### With Artifact Lifecycle Pattern
- DEU generation can be instantiated as a specific domain in the artifact lifecycle
- Generated specs follow the same declaration → implementation → review flow

### With Cue Promotion System
- Failed validations can generate cues for improvement
- Cues can be promoted to new plan steps or contract refinements
- Validation notes can inform cue generation

### With Agentic Development Loop
- DEU generation serves as a concrete implementation of the meta-level development cycle
- Each generated DEU can itself be subject to the agentic loop for refinement

## Default Behavior

With `automated_validation: true`, the system automatically validates implementations against specifications without manual intervention.

## Test Execution

- **full_deu_generation**: End-to-end test verifying complete workflow produces "pass" status
- **validation_retry_on_fail**: Test that failed validation triggers implementation regeneration
- **empty_prompt_handling**: Test that empty prompts raise appropriate errors

## Error Handling

The system should handle common failure modes:
- Invalid or empty prompts
- Specification parsing errors
- Implementation generation failures
- Validation timeouts or errors
- File system access issues

## Future Enhancements

The cues in the specification suggest several potential improvements:
- Symbol resolution tracking
- Automated test scaffold generation
- Validation matrix reporting
- Cross-role pathway testing
- Integration with cue promotion workflows