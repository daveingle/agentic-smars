# SMARS Validation Refinements

A symbolic exploration of validation gaps discovered in the Tryink design system specs and proposed refinements to strengthen SMARS consistency checking.

---

## Problem Analysis

Review of a sample design system specification revealed several validation gaps that current SMARS flow did not catch:

1. **Brand color inconsistency**: `#FEBA00` vs `#FEB000` across files
2. **Grammar violations**: Incorrect `datum` syntax in definition.smars.md  
3. **Role authority conflicts**: `@role(platform)` vs `@role(developer)` for same system
4. **Contract validation gaps**: Undefined symbol references in assertions

These issues should have been caught by the SMARS validation flow itself.

---

```smars
@role(architect)

// Enhanced Validation Types
(kind ValidationResult ∷ { 
  status: STRING, 
  violations: [ValidationViolation], 
  cross_references: [SymbolReference] 
})

(kind ValidationViolation ∷ { 
  file: STRING, 
  line: INT, 
  type: STRING, 
  message: STRING, 
  severity: STRING 
})

(kind SymbolReference ∷ { 
  symbol: STRING, 
  declared_in: STRING, 
  referenced_in: [STRING], 
  consistent: BOOL 
})

(kind SpecificationSet ∷ { 
  files: [STRING], 
  symbols: [SymbolReference], 
  roles: [STRING], 
  validation_status: ValidationResult 
})

// Cross-File Validation Constants
(datum ⟦validation_phases⟧ ∷ [STRING] = [
  "grammar_check", 
  "symbol_resolution", 
  "cross_reference_validation", 
  "contract_verification", 
  "role_consistency_check"
])

(datum ⟦severity_levels⟧ ∷ [STRING] = ["error", "warning", "info"])

// Enhanced Validation Maplets
(maplet parseSpecificationSet ∷ [STRING] → SpecificationSet)
(maplet validateGrammar ∷ SpecificationSet → ValidationResult)
(maplet buildSymbolTable ∷ SpecificationSet → SpecificationSet)
(maplet validateCrossReferences ∷ SpecificationSet → ValidationResult)
(maplet validateContractAssertions ∷ SpecificationSet → ValidationResult)
(maplet validateRoleConsistency ∷ SpecificationSet → ValidationResult)
(maplet generateValidationReport ∷ ValidationResult → STRING)

// Refined Validation Contracts
(contract parseSpecificationSet
  ⊨ requires: files.length > 0
  ⊨ ensures: all_files_parsed)

(contract validateGrammar
  ⊨ requires: files_parsed
  ⊨ ensures: grammar_violations_identified)

(contract buildSymbolTable
  ⊨ requires: grammar_valid
  ⊨ ensures: symbol_table_complete)

(contract validateCrossReferences
  ⊨ requires: symbol_table_complete
  ⊨ ensures: undefined_references_caught)

(contract validateContractAssertions
  ⊨ requires: cross_references_valid
  ⊨ ensures: contract_violations_identified)

(contract validateRoleConsistency
  ⊨ requires: symbol_table_complete
  ⊨ ensures: role_conflicts_detected)

// Enhanced Validation Plan
(plan validateSpecificationIntegrity § steps:
  - parseSpecificationSet
  - validateGrammar
  - buildSymbolTable
  - validateCrossReferences
  - validateContractAssertions
  - validateRoleConsistency
  - validateSymbolicStability
  - maintainSymbolicConsistency
  - generateValidationReport)

// Specific Validation Branches
(branch grammar_validation_outcome
  ⎇ when syntax_errors_found:
      → halt_validation_with_errors
    when warnings_only:
      → continue_with_warnings
    else:
      → proceed_to_symbol_resolution)

(branch cross_reference_validation_outcome
  ⎇ when undefined_symbols_found:
      → generate_symbol_error_report
    when inconsistent_values_found:
      → generate_consistency_error_report
    else:
      → proceed_to_contract_validation)

// Enhanced Test Coverage
(test grammar_violation_detection 
  expects: datum_syntax_errors_caught)

(test symbol_consistency_validation 
  expects: brand_color_mismatch_detected)

(test role_authority_validation 
  expects: conflicting_roles_flagged)

(test contract_assertion_validation 
  expects: undefined_symbol_references_caught)

(test multi_file_validation 
  expects: cross_file_inconsistencies_detected)

(test symbolic_stability_validation 
  expects: intent_preservation_verified)

(test refinement_classification 
  expects: refinement_type_correctly_identified)

(test agent_consensus_validation 
  expects: consensus_level_meets_threshold)

// Implementation Cues
(cue implement_grammar_parser
  ⊨ suggests: create EBNF validator that parses all .smars.md files before proceeding)

(cue implement_symbol_table_builder
  ⊨ suggests: build comprehensive symbol registry across specification set)

(cue implement_contract_validator
  ⊨ suggests: validate all contract assertions against resolved symbols)

(cue implement_role_authority_checker
  ⊨ suggests: ensure consistent role declarations across related specifications)

(cue integrate_validation_into_agentic_loop
  ⊨ suggests: make validation mandatory step in agenticDevelopmentLoop)

// Meta-Validation Plan
(plan refineValidationCapabilities § steps:
  - implement_grammar_parser
  - implement_symbol_table_builder
  - implement_contract_validator
  - implement_role_authority_checker
  - integrate_validation_into_agentic_loop)
```

---

## Validation Refinement Summary

The proposed refinements address the identified gaps through:

1. **Multi-file awareness**: `SpecificationSet` kind captures relationships across files
2. **Grammar enforcement**: Mandatory syntax validation before symbol resolution
3. **Symbol consistency**: Cross-reference validation catches value mismatches
4. **Role authority checking**: Validates consistent role declarations
5. **Contract verification**: Ensures all assertions reference defined symbols

These refinements would have caught all four issues in the Tryink design system specs.

---

## Integration with Agentic Patterns

The validation refinements integrate with the agentic patterns through:

- **SpecDelta**: Changes validated before application
- **ReviewOutcome**: Structured validation results feed back into review
- **AgenticCycle**: Self-referential validation ensures specs remain consistent

This creates a closed-loop validation system where specifications continuously validate themselves.

---

## Next Steps

1. Implement grammar parser following EBNF specification
2. Build symbol table construction for cross-file analysis
3. Create contract assertion validator
4. Integrate validation into existing agentic development loop
5. Test against known problematic specifications

The validation refinements maintain SMARS' symbolic nature while adding necessary consistency checks.