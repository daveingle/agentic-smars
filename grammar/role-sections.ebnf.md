# SMARS Role Section Specification (v1.0)

**Deterministic scope boundaries through role-section wrappers**

## Overview

This specification defines role-section wrappers that provide deterministic scope boundaries for SMARS declarations. Role sections ensure clear separation of concerns, prevent identifier conflicts, and enable hierarchical organization of specifications.

## Role Section Grammar (EBNF)

```ebnf
(* ========== TOP-LEVEL STRUCTURE ========== *)
smars_file     = { role_section | standalone_declaration | comment | whitespace } ;

role_section   = role_header "{" role_content "}" ;
role_header    = "@role" "(" role_type ")" [ role_metadata ] ;
role_content   = { declaration | nested_role_section | comment | whitespace } ;

standalone_declaration = declaration ;
nested_role_section   = role_section ;

(* ========== ROLE TYPES ========== *)
role_type      = primary_role | extended_role ;
primary_role   = "platform" | "developer" | "user" | "agent" | "system" ;
extended_role  = custom_role | qualified_role ;
custom_role    = IDENTIFIER ;
qualified_role = role_type "." IDENTIFIER ;

(* ========== ROLE METADATA ========== *)
role_metadata  = "[" metadata_properties "]" ;
metadata_properties = metadata_property { "," metadata_property } ;
metadata_property   = metadata_key ":" metadata_value ;
metadata_key   = "version" | "description" | "dependencies" | "capabilities" | "priority" ;
metadata_value = STRING | IDENTIFIER | literal ;

(* ========== SCOPE RULES ========== *)
declaration_scope = role_scope | global_scope ;
role_scope     = "within role section" ;
global_scope   = "outside any role section" ;

identifier_visibility = local_visibility | inherited_visibility | public_visibility ;
local_visibility      = "visible within same role section" ;
inherited_visibility  = "visible in nested role sections" ;
public_visibility     = "visible across all role sections" ;

(* ========== ROLE SECTION NESTING ========== *)
nesting_level  = INTEGER "// Maximum depth: 3" ;
parent_role    = role_type ;
child_role     = role_type ;

nested_scope_rules = "child inherits parent visibility" ;
override_rules     = "child can override parent declarations" ;
conflict_resolution = "explicit qualification required for conflicts" ;

(* ========== DECLARATION ORGANIZATION ========== *)
role_content   = imports_section
                 exports_section
                 declarations_section
                 nested_sections ;

imports_section = [ "imports" "{" import_list "}" ] ;
import_list     = import_declaration { import_declaration } ;
import_declaration = "import" qualified_identifier [ "as" IDENTIFIER ] ;
qualified_identifier = role_type "." IDENTIFIER ;

exports_section = [ "exports" "{" export_list "}" ] ;
export_list     = export_declaration { export_declaration } ;
export_declaration = "export" IDENTIFIER [ export_metadata ] ;
export_metadata = "[" "visibility:" visibility_level "]" ;
visibility_level = "public" | "protected" | "private" ;

declarations_section = { declaration } ;
nested_sections     = { nested_role_section } ;

(* ========== ENHANCED DECLARATION SYNTAX ========== *)
declaration    = visibility_modifier declaration_body ;
visibility_modifier = [ visibility_keyword ] ;
visibility_keyword  = "public" | "protected" | "private" | "internal" ;

declaration_body = kind_decl | datum_decl | maplet_decl | apply_decl |
                   contract_decl | plan_decl | branch_decl | default_decl |
                   test_decl | agent_decl | memory_decl | confidence_decl |
                   validation_decl | cue_decl ;

(* ========== SCOPE RESOLUTION ========== *)
scoped_identifier = simple_identifier | qualified_identifier | absolute_identifier ;
simple_identifier = IDENTIFIER ;
absolute_identifier = "::" qualified_identifier ;

scope_resolution_rules = {
  "1. Search current role section",
  "2. Search parent role sections (if nested)",
  "3. Search imported role sections", 
  "4. Search global scope",
  "5. Report unresolved identifier error"
} ;

(* ========== DEPENDENCY MANAGEMENT ========== *)
dependency_declaration = "depends_on" dependency_list ;
dependency_list = dependency { "," dependency } ;
dependency     = role_reference | external_reference ;
role_reference = role_type [ "." version_spec ] ;
external_reference = STRING "// External module reference" ;
version_spec   = "v" INT "." INT [ "." INT ] ;

(* ========== ROLE SECTION VALIDATION ========== *)
validation_rules = {
  circular_dependency_check,
  identifier_uniqueness_check,
  visibility_consistency_check,
  nesting_depth_check,
  export_validity_check
} ;

circular_dependency_check = "No circular dependencies between role sections" ;
identifier_uniqueness_check = "No duplicate identifiers within same scope" ;
visibility_consistency_check = "Visibility modifiers consistent with usage" ;
nesting_depth_check = "Maximum nesting depth of 3 levels" ;
export_validity_check = "All exported identifiers exist and are accessible" ;
```

## Role Section Examples

### 1. Basic Role Section
```smars
@role(platform) {
  // Platform-level declarations
  (kind SystemConfiguration ∷ {
    database_url: STRING,
    api_key: STRING,
    debug_mode: BOOL
  })
  
  public (datum ⟦default_timeout⟧ ∷ INTEGER = 30)
  
  private (contract system_initialized ⊨
    requires: database_connected = true
    ensures: system_ready = true)
}
```

### 2. Role Section with Metadata
```smars
@role(developer)[version: "1.2", description: "User management module"] {
  imports {
    import platform.SystemConfiguration
    import platform.default_timeout as timeout
  }
  
  exports {
    export User [visibility: public]
    export create_user [visibility: public]
    export UserValidation [visibility: protected]
  }
  
  (kind User ∷ {
    id: INTEGER,
    email: STRING,
    created_at: TIMESTAMP
  })
  
  (maplet create_user ∷ STRING → STRING → User)
  
  protected (contract UserValidation ⊨
    requires: valid_email(email) = true
    ensures: user_created = true)
}
```

### 3. Nested Role Sections
```smars
@role(user) {
  (kind UserRequest ∷ {
    user_id: INTEGER,
    action: STRING,
    timestamp: TIMESTAMP
  })
  
  @role(user.authentication) {
    (kind AuthToken ∷ {
      token: STRING,
      expires_at: TIMESTAMP,
      permissions: [STRING]
    })
    
    (contract token_validation ⊨
      requires: token_not_expired = true ∧ token_signature_valid = true
      ensures: user_authenticated = true)
  }
  
  @role(user.authorization) {
    depends_on user.authentication
    
    (contract permission_check ⊨
      requires: user_authenticated = true ∧ required_permission ∈ user_permissions
      ensures: action_authorized = true)
  }
}
```

### 4. Cross-Role Dependencies
```smars
@role(agent)[version: "2.0", dependencies: "platform.v1.0,developer.v1.2"] {
  imports {
    import platform.SystemConfiguration
    import developer.User
    import developer.create_user
  }
  
  (agent ⟦user_manager⟧ ∷ UserManagementAgent
    capabilities: "user_creation", "user_validation"
    memory: user_memory
    confidence_calibration: 0.85
  )
  
  (plan manage_user_request § steps:
    - validate_request
    - ::developer.create_user  // Absolute reference
    - update_user_memory
    - send_confirmation
  )
}
```

## Scope Resolution Rules

### 1. Identifier Lookup Order
1. **Current role section**: Search local declarations first
2. **Parent role sections**: Search parent scopes if nested
3. **Imported declarations**: Search explicitly imported identifiers
4. **Global scope**: Search standalone declarations
5. **Error**: Report unresolved identifier

### 2. Visibility Rules
| Modifier | Scope | Description |
|----------|-------|-------------|
| `public` | Cross-role | Visible to all role sections |
| `protected` | Role hierarchy | Visible to current and child roles |
| `private` | Local only | Visible only within current role section |
| `internal` | Module | Visible within same file/module |

### 3. Inheritance Rules
- **Child inherits parent**: Nested roles inherit parent declarations
- **Override allowed**: Child can override parent declarations
- **Explicit qualification**: Required for conflict resolution
- **Absolute references**: `::role.identifier` bypasses local scope

## Dependency Management

### 1. Dependency Declaration
```smars
@role(service)[dependencies: "platform.v1.0,shared.v2.1"] {
  depends_on platform.v1.0, shared.v2.1
  
  // Role content
}
```

### 2. Version Compatibility
- **Semantic versioning**: Major.minor.patch format
- **Compatibility rules**: Minor version backward compatible
- **Conflict resolution**: Explicit version specification required

### 3. Circular Dependency Detection
- **Static analysis**: Detect cycles at parse time
- **Error reporting**: Clear dependency chain in errors
- **Resolution suggestions**: Recommend dependency restructuring

## Import/Export System

### 1. Import Syntax
```smars
imports {
  import platform.Configuration        // Import with original name
  import developer.User as DeveloperUser // Import with alias
  import ::global.utility_functions    // Absolute import
}
```

### 2. Export Control
```smars
exports {
  export User [visibility: public]           // Public export
  export UserValidation [visibility: protected] // Protected export
  export internal_helper [visibility: private]  // Private export (contradiction - error)
}
```

### 3. Selective Imports
```smars
imports {
  import platform.{Configuration, Logger}  // Multiple imports
  import developer.* as dev                 // Wildcard import with namespace
}
```

## Validation and Error Handling

### 1. Scope Validation Errors
```
Error: Identifier 'User' not found in current scope
  Searched: role(agent) -> role(platform) -> global
  Suggestion: Import developer.User or use qualified name
  Location: line 15, column 10
```

### 2. Circular Dependency Errors
```
Error: Circular dependency detected
  Chain: platform -> developer -> agent -> platform
  Break: Remove dependency from agent to platform
  Location: role(agent), line 3
```

### 3. Visibility Violation Errors
```
Error: Cannot access private declaration 'internal_config'
  Declaration: role(platform).internal_config [private]
  Access attempt: role(developer), line 22
  Resolution: Use public interface or import explicitly
```

## Nesting Constraints

### 1. Depth Limits
- **Maximum depth**: 3 levels of nesting
- **Practical limit**: 2 levels recommended for clarity
- **Performance**: Shallow nesting improves lookup speed

### 2. Naming Conventions
- **Nested roles**: Use dotted notation (`parent.child`)
- **Flat organization**: Prefer flat over deep nesting
- **Clear separation**: Distinct responsibilities per role

## Benefits of Role Sections

### 1. Deterministic Parsing
- **Clear boundaries**: Unambiguous scope determination
- **No ambiguity**: Identifier resolution rules eliminate conflicts
- **Predictable behavior**: Consistent scoping across files

### 2. Modular Organization
- **Separation of concerns**: Each role handles specific domain
- **Dependency management**: Explicit import/export control
- **Version compatibility**: Support for evolving specifications

### 3. Tool Support
- **IDE integration**: Scope-aware autocomplete and navigation
- **Static analysis**: Comprehensive dependency checking
- **Refactoring**: Safe identifier renaming within scope

This role section specification provides robust scope management while maintaining SMARS's symbolic clarity and enabling complex multi-role specifications.