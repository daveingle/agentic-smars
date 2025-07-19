# File Reorganization Plan

## Current Issues
Several files are in the root directory that should be organized into appropriate subdirectories based on their content and purpose.

## Proposed Moves

### Validation and Assessment Files → notes/
These are analysis and assessment documents that belong in notes/:
- `agency-gap-validation.md` → `notes/agency-gap-validation.md`
- `existing-plans-validation.md` → `notes/existing-plans-validation.md`  
- `maturity-assessment-report.md` → `notes/maturity-assessment-report.md`
- `plan-validation-execution.md` → `notes/plan-validation-execution.md`
- `self-validation-using-implementation.md` → `notes/self-validation-using-implementation.md`
- `symbolic-agency-implementation-validation.md` → `notes/symbolic-agency-implementation-validation.md`
- `symbolic-agency-validation.md` → `notes/symbolic-agency-validation.md`
- `system-diagnostic-report.md` → `notes/system-diagnostic-report.md`

### Task Execution Documentation → notes/
These are execution logs and task documentation:
- `task-execution-collaboration-expansion.md` → `notes/task-execution-collaboration-expansion.md`
- `task-execution-with-symbolic-agency.md` → `notes/task-execution-with-symbolic-agency.md`
- `test-execution-log.md` → `notes/test-execution-log.md`
- `validation-test-cases.md` → `notes/validation-test-cases.md`

### Implementation Documentation → notes/
Foundation model mapping is implementation documentation:
- `foundation-model-collaboration-mapping.md` → `notes/foundation-model-collaboration-mapping.md`

### Process Documentation → notes/
- `commit-series-breakdown.md` → `notes/commit-series-breakdown.md`

## Rationale

### Why notes/ for these files?
- **Assessment and validation files**: These are analysis documents, not formal specifications
- **Task execution logs**: These are execution records and learning documentation
- **Implementation documentation**: Foundation model mapping is guidance, not formal spec
- **Process documentation**: Commit breakdown is meta-documentation about the development process

### What stays in root?
- `AGENT_PRIMER.md` - Top-level orientation document
- `CLAUDE.md` - Project instructions
- `LICENSE` - Legal requirement
- `README.md` - Project overview
- `evaluation_cycle_001.md` - Current evaluation cycle (could move to notes/ if completed)

### Directory Structure After Reorganization
```
/
├── notes/           # Analysis, validation, execution logs, implementation docs
├── journal/         # Chronological development insights
├── spec/           # Formal SMARS specifications
├── examples/       # Concrete implementation examples
├── experiments/    # Active development experiments
├── requests/       # Request management
├── cues/          # Advisory guidance
├── grammar/       # Language specification
├── sop/           # Standard operating procedures
└── archive/       # Deprecated materials
```

This creates a cleaner separation between:
- **Formal specifications** (spec/)
- **Development insights** (journal/)
- **Analysis and documentation** (notes/)
- **Active experiments** (experiments/)