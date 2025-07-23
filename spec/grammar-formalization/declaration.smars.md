# SMARS Grammar Formalization Project

@role(language_architect)

**Comprehensive Enhancement of SMARS DSL Grammar and Parsing Infrastructure**

// Grammar Enhancement Types
(kind LexicalLayer ∷ {
  whitespace_rules: STRING,
  comment_syntax: STRING,
  escape_sequences: [STRING],
  unicode_support: BOOL,
  numeric_formats: [STRING]
})

(kind GrammarDeclaration ∷ {
  declaration_type: STRING,
  cardinality_rules: STRING,
  ordering_constraints: STRING,
  validation_rules: [STRING]
})

(kind RoleSection ∷ {
  role_directive: STRING,
  scope_boundaries: STRING,
  nested_declarations: [STRING],
  deterministic_parsing: BOOL
})

(kind TestCorpus ∷ {
  declaration_type: STRING,
  valid_samples: [STRING],
  invalid_samples: [STRING],
  test_coverage: FLOAT
})

(kind ParserImplementation ∷ {
  grammar_type: STRING,
  parser_generator: STRING,
  existing_specs_parsed: [STRING],
  drift_detection: BOOL
})

(kind TypePrelude ∷ {
  primitive_kinds: [STRING],
  parametric_types: [STRING],
  type_system_rules: [STRING]
})

// Project Constants
(datum ⟦target_declaration_types⟧ ∷ [STRING] = [
  "kind_decl", "datum_decl", "maplet_decl", "apply_decl", 
  "contract_decl", "plan_decl", "branch_decl", "default_decl",
  "test_decl", "agent_decl", "memory_decl", "confidence_decl",
  "validation_decl", "cue_decl"
])

(datum ⟦test_corpus_size⟧ ∷ INTEGER = 20)
(datum ⟦valid_samples_per_type⟧ ∷ INTEGER = 10)
(datum ⟦invalid_samples_per_type⟧ ∷ INTEGER = 10)

// Grammar Enhancement Operations
(maplet finalizeLexicalLayer ∷ LexicalLayer → STRING)
(maplet tightenDeclarationRules ∷ GrammarDeclaration → STRING)
(maplet addRoleSectionWrapper ∷ RoleSection → STRING)
(maplet generateTestCorpus ∷ STRING → TestCorpus)
(maplet implementParser ∷ STRING → ParserImplementation)
(maplet publishTypePrelude ∷ TypePrelude → STRING)

// Grammar Enhancement Contracts
(contract lexical_completeness ⊨
  requires: whitespace_defined = true ∧ comments_defined = true ∧ unicode_supported = true
  ensures: all_lexical_elements_specified = true)

(contract declaration_determinism ⊨
  requires: cardinalities_specified = true ∧ ordering_constraints_defined = true
  ensures: parsing_is_unambiguous = true)

(contract role_scope_isolation ⊨
  requires: role_section_wrapper_present = true
  ensures: scope_boundaries_deterministic = true)

(contract test_coverage_completeness ⊨
  requires: test_corpus_size >= 20 ∧ all_declaration_types_covered = true
  ensures: grammar_validation_comprehensive = true)

(contract parser_drift_prevention ⊨
  requires: existing_specs_parsed_successfully = true
  ensures: zero_drift_between_grammar_and_specs = true)

(contract type_system_formalization ⊨
  requires: primitive_types_defined = true ∧ parametric_types_defined = true
  ensures: semantic_rules_complete = true)

// Grammar Enhancement Plan
(plan formalizeGrammar § steps:
  - finalizeLexicalLayer
  - tightenDeclarationRules
  - addRoleSectionWrapper
  - generateTestCorpus
  - implementParser
  - validateExistingSpecs
  - publishTypePrelude
  - publishSemanticRules)

// Phase 1: Lexical Layer Finalization
(plan finalizeLexicalLayer § steps:
  - defineWhitespaceRules
  - specifyCommentSyntax
  - addEscapeSequences
  - enableUnicodeSupport
  - formalizeNumericFormats)

// Phase 2: Declaration Rule Tightening
(plan tightenDeclarationRules § steps:
  - specifyContractCardinalities
  - definePlanStepOrdering
  - clarifyBranchStructure
  - addValidationConstraints)

// Phase 3: Role Section Enhancement
(plan addRoleSectionWrapper § steps:
  - defineRoleSectionSyntax
  - establishScopeBoundaries
  - enableNestedDeclarations
  - ensureDeterministicParsing)

// Phase 4: Test Corpus Generation
(plan generateTestCorpus § steps:
  - createValidSamples
  - createInvalidSamples
  - validateTestCoverage
  - exportJSONFormat)

// Phase 5: Parser Implementation
(plan implementParser § steps:
  - choosePEGOrANTLR
  - implementGrammar
  - parseExistingSpecs
  - validateZeroDrift)

// Phase 6: Type System Documentation
(plan publishTypePrelude § steps:
  - documentPrimitiveKinds
  - specifyParametricTypes
  - defineSemanticRules
  - publishValidationMessages)

// Grammar Enhancement Tests
(test lexical_layer_complete ∷
  whitespace_rules_defined ∧
  comment_syntax_specified ∧
  escape_sequences_supported ∧
  unicode_handling_correct ∧
  numeric_formats_validated)

(test declaration_rules_tight ∷
  contract_cardinalities_enforced ∧
  plan_ordering_validated ∧
  branch_structure_deterministic ∧
  validation_constraints_applied)

(test role_sections_deterministic ∷
  scope_boundaries_clear ∧
  nested_declarations_supported ∧
  parsing_unambiguous)

(test corpus_coverage_complete ∷
  all_declaration_types_tested ∧
  valid_samples_sufficient ∧
  invalid_samples_comprehensive ∧
  json_format_valid)

(test parser_implementation_valid ∷
  existing_specs_parsed ∧
  zero_drift_confirmed ∧
  error_messages_helpful)

(test type_system_formalized ∷
  primitive_types_documented ∧
  parametric_types_specified ∧
  semantic_rules_complete ∧
  validation_messages_clear)

// Enhancement Cues
(cue grammar_versioning ⊨ suggests: implement semantic versioning for grammar changes)
(cue ide_integration ⊨ suggests: create language server protocol support for SMARS)
(cue error_recovery ⊨ suggests: implement robust error recovery in parser)
(cue performance_optimization ⊨ suggests: optimize parser for large SMARS specifications)
(cue documentation_generation ⊨ suggests: auto-generate documentation from grammar)

## Project Scope

This specification defines a comprehensive enhancement of the SMARS DSL grammar and parsing infrastructure. The project addresses six critical areas:

### 1. Lexical Layer Finalization
Complete specification of low-level language elements including whitespace handling, comment syntax, escape sequences, Unicode support, and numeric formats.

### 2. Declaration Rule Tightening  
Precise cardinalities and ordering constraints for complex declarations like contracts, plans, and branches to eliminate parsing ambiguities.

### 3. Role Section Wrapper
Deterministic scope boundaries through role-section wrappers that clearly define declaration contexts and enable proper nesting.

### 4. Comprehensive Test Corpus
JSON-formatted test suite with 10 valid and 10 invalid samples for each of the 14 declaration types, ensuring thorough grammar validation.

### 5. Parser Implementation
Production-ready PEG or ANTLR grammar with validation against existing `.smars.md` specifications to guarantee zero drift.

### 6. Type System Documentation
Formal type prelude with primitive kinds, parametric types, and semantic rules documentation including validation message specifications.

## Success Criteria

The project succeeds when:
- All existing SMARS specifications parse without errors
- Test corpus achieves 100% coverage of declaration types
- Grammar eliminates all parsing ambiguities
- Type system provides clear semantic foundation
- Zero drift confirmed between grammar and existing specs

This formalization project will establish SMARS as a robust, formally specified DSL with production-ready parsing infrastructure.