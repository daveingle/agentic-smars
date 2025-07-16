# Kind Promotion Implementation

This implementation scaffold describes how to interpret and execute the kind promotion workflow defined in `spec/automation/kind-promotion.smars.md`.

## Overview

The kind promotion system automatically detects new `kind` declarations and places them in canonical locations within the project structure, maintaining a registry of all kinds and handling duplications appropriately.

## Symbol Interpretations

### Types (kind)

- **KindDeclaration**: Parsed kind with name, definition, domain, and source location
- **KindLocation**: Target location with path, domain classification, and canonical flag
- **KindDuplication**: Analysis result showing existing vs proposed kinds and conflict status
- **KindPlacement**: Completed placement with kind, location, and status
- **KindRegistry**: Master registry tracking all kinds and their locations

### Constants (datum)

- **canonical_kinds_path**: Primary location for core/shared kinds (`spec/types/`)
- **domain_kinds_path**: Template for domain-specific kinds (`spec/{{domain}}/types/`)
- **kind_registry_path**: Master registry file location
- **deduplication_policy**: Strategy for handling duplicate kinds

### Functions (maplet)

#### extractKind
- **Input**: Raw string containing kind declaration
- **Output**: Structured KindDeclaration
- **Implementation**: Parse SMARS syntax to extract kind name and definition, validate against grammar, determine source context

#### analyzeKindDomain
- **Input**: KindDeclaration
- **Output**: Domain string
- **Implementation**: Analyze kind name patterns, field types, and usage context to classify domain (core, automation, patterns, etc.)

#### checkKindDuplication
- **Input**: Kind and existing registry
- **Output**: Duplication analysis
- **Implementation**: Compare kind name and definition against existing registry, detect conflicts based on name collision or incompatible definitions

#### determineKindLocation
- **Input**: Kind and domain
- **Output**: Target location
- **Implementation**: Apply domain classification rules to determine canonical vs domain-specific placement, generate appropriate file paths

#### placeKind
- **Input**: Kind and target location
- **Output**: Placement result
- **Implementation**: Write kind declaration to target file, ensure proper SMARS formatting, handle file creation if needed

#### updateKindRegistry
- **Input**: Registry and placement result
- **Output**: Updated registry
- **Implementation**: Add new kind to registry, maintain sorted order, preserve uniqueness constraints

## Plan Execution

### promoteKindToCanonical

The workflow executes in sequence:

1. **extractKind**: Parse raw kind declaration into structured form
2. **analyzeKindDomain**: Classify kind by domain to determine placement strategy
3. **checkKindDuplication**: Verify no conflicts with existing kinds
4. **determineKindLocation**: Calculate canonical location based on domain
5. **placeKind**: Write kind to target location with proper formatting
6. **updateKindRegistry**: Update master registry with new kind

### Branch Logic

#### domainClassification
- **core domain**: Place in canonical `spec/types/` location
- **automation/patterns domains**: Place in domain-specific `spec/{{domain}}/types/`
- **unknown domains**: Default to domain-specific placement

#### duplicationHandling
- **No conflict**: Proceed with placement
- **Conflict + merge_compatible**: Merge compatible definitions
- **Conflict + reject_duplicate**: Reject and report conflict
- **Other conflicts**: Flag for manual review

## Contract Enforcement

### extractKind Contract
- Verify input contains required SMARS `kind` syntax
- Ensure extracted name and definition are non-empty
- Validate against SMARS grammar rules

### analyzeKindDomain Contract
- Require valid kind name
- Ensure domain matches known patterns
- Return appropriate domain classification

### checkKindDuplication Contract
- Require populated kind name and registry
- Accurately detect conflicts
- Provide existing kind details when conflicts found

### determineKindLocation Contract
- Require valid kind name and domain
- Generate non-empty file paths
- Set canonical flag appropriately for core domain

### placeKind Contract
- Require valid kind and location
- Return appropriate status (placed/duplicate/conflict)
- Preserve kind integrity during placement

### updateKindRegistry Contract
- Only update registry for successfully placed kinds
- Maintain registry uniqueness
- Preserve existing registry structure

## File Structure

### Canonical Locations
- `spec/types/` - Core/shared kinds used across domains
- `spec/automation/types/` - Automation-specific kinds
- `spec/patterns/types/` - Pattern-specific kinds
- `spec/types/registry.smars.md` - Master registry file

### Registry Format
```smars
@role(architect)

// Registry of all canonical kinds
(kind KindRegistryEntry ∷ { name: STRING, location: STRING, domain: STRING })

(datum ⟦kind_registry⟧ ∷ [KindRegistryEntry] = [
  { name: "Artifact", location: "spec/types/core.smars.md", domain: "core" },
  { name: "Cue", location: "spec/automation/types/promotion.smars.md", domain: "automation" }
])
```

## Integration Points

### With Existing Promotion System
- Kind promotion extends the general cue promotion workflow
- Kinds can be promoted from cues using the existing promotion infrastructure
- Registry updates feed back into the promotion system

### With DEU Generation
- Generated DEUs may contain new kinds that need promotion
- Kind promotion can run automatically after DEU generation
- Registry provides type information for subsequent DEU generation

### With Artifact Lifecycle
- Kind promotion follows the same declare → implement → review pattern
- Registry serves as implementation of the canonical kind system
- Review phase validates kind placement and registry consistency

## Default Behavior

- `automatic_domain_detection: true` - Automatically classify domains without manual input
- `preserve_existing_kinds: true` - Avoid overwriting existing kind definitions

## Error Handling

Common failure modes and handling:
- **Invalid SMARS syntax**: Reject with grammar error details
- **Domain classification failures**: Default to domain-specific placement
- **File system errors**: Retry with alternative locations
- **Registry corruption**: Rebuild from canonical locations
- **Circular dependencies**: Flag for manual resolution

## Testing Strategy

- **extract_valid_kind**: Verify parsing of well-formed kind declarations
- **detect_core_domain**: Ensure core kinds are properly classified
- **handle_duplicate_kind**: Test conflict detection and resolution
- **place_in_canonical_location**: Verify proper file placement
- **update_registry_successfully**: Confirm registry maintenance

## Future Enhancements

The cues suggest several potential improvements:
- Semantic clustering of related kinds
- Version tracking for kind evolution
- Cross-domain reuse analysis
- Automated grammar validation
- Dependency analysis for placement optimization