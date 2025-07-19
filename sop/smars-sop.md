# SMARS Standard Operating Procedure

This document defines the structured process for creating, interpreting, and iterating on symbolic specifications written in SMARS — the Symbolic Multi-Agent Reasoning System.

It is intended for use by agents (human or AI) that reason over plans, contracts, data structures, and tests in a deterministic, verifiable, and context-free way.

This SOP does not assume any specific programming framework or runtime.

---

## 1. Feature Specification Structure

### 1.1 Canonical Feature Directory Layout

Each feature or domain must follow this standardized structure in `spec/`:

```
spec/feature-name/
├── declaration.smars.md    # Single SMARS specification
├── implementation.md       # How to fulfill the spec
├── review.md              # Validation and feedback
└── summary.md             # Overview and status
```

### 1.2 Create `declaration.smars.md`

This is the single source of truth for the feature's symbolic specification. It must include:

- `@role(...)` — defines context (e.g. `developer`, `agent`)
- `kind` — data types with named fields
- `datum` — symbolic constants
- `maplet` — typed function declarations
- `contract` — behavioral requirements and guarantees
- `plan` — ordered symbolic procedures
- Optionally:
  - `branch` — conditional dispatch
  - `test` — behavioral expectations

Each block must be valid SMARS syntax, following the grammar defined in `grammar/smars.ebnf.md`.

---

## 2. Implementation Phase

### 2.1 Create `implementation.md` in the feature directory

This file describes how an interpreter (agent, developer, runtime) can fulfill the symbolic spec.

It must include:

- Concrete representations of each `kind`
- Functional scaffolds for each `maplet`
- Notes or logic that enforce each `contract` pre/postcondition
- An interpretation of each `plan` as sequential or reactive behavior
- Handling logic for each `branch`
- Binding or test implementation matching each `test` expectation

The implementation must remain logically consistent with its specification.

---

## 3. Validation Phase

### 3.1 Create `review.md` in the feature directory

Document validation results and feedback:

- Validate all `contract` requirements and postconditions in code or test logic
- Implement or simulate all `test` cases
- Confirm `plan` flows execute deterministically from the symbolic spec
- Check that `branch` conditions resolve to correct paths
- **Cross-feature symbol validation**: Detect duplicate `datum` and `kind` declarations across features
- **Agentic conflict resolution**: Generate `SpecDelta` proposals for symbol consolidation
- Record validation outcomes, issues found, and resolutions

Validation may be done manually, via interpreters, or through external runtime agents.

### 3.2 Agentic Symbol Conflict Resolution

When validation detects duplicate or inconsistent symbols across features:

1. **Detection**: Agent identifies duplicate `datum` or `kind` declarations
2. **Analysis**: Agent determines authoritative source and consolidation strategy
3. **Proposal**: Agent generates `SpecDelta` for moving shared symbols to `spec/shared/`
4. **Resolution**: Agent applies consolidation and updates dependent features
5. **Validation**: Agent re-validates to ensure consistency

This reactive approach allows natural symbol evolution while maintaining system consistency.

### 3.3 Symbolic Evolution as Refinement

When agents detect symbolic evolution, they should distinguish between:

- **Symbolic refinement**: Enhanced understanding that preserves core intent (e.g., `User` gains `mfa_enabled` field)
- **Intent preservation**: Changes that maintain essential contracts and behavioral meaning
- **Implementation details**: Surface-level changes that don't affect planning structure

Agents should treat most evolution as **refinement** rather than breaking changes, maintaining symbolic stability while allowing natural learning and adaptation.

### 3.4 Create `summary.md` in the feature directory

Provide high-level overview:

- Current implementation status
- Key decisions and trade-offs
- Next steps and dependencies
- Links to related features

---

## 4. Cue Declaration Phase

### 4.1 Use `cue` entries to capture non-binding symbolic guidance

Create `.cues.md` files in the `cues/` directory. Each `cue` must follow the symbolic form:

```smars
(cue cue_identifier
  ⊨ suggests: explanation or possible structure)
```

Cues are:
- Advisory, not mandatory
- Symbolically inspectable
- Used to mark future directions, unresolved tensions, or soft hypotheses

Cues should never affect execution directly. They may later be promoted to plan, contract, or test.

### 4.2 Cue Handling Policy

#### 4.2.1 Systematic Cue Evaluation Process

All cues must be systematically evaluated using the following repeatable process:

```smars
@role(architect)

(kind CueEvaluation ∷ {
  cue_id: STRING,
  technical_feasibility: FLOAT,
  system_alignment: FLOAT,
  implementation_complexity: FLOAT,
  value_proposition: FLOAT,
  combined_score: FLOAT,
  promotion_recommended: BOOL,
  rejection_reason: STRING,
  evaluator: STRING,
  evaluation_date: STRING
})

(kind CueReport ∷ {
  evaluation_cycle: STRING,
  total_cues_evaluated: INTEGER,
  promoted_count: INTEGER,
  rejected_count: INTEGER,
  deferred_count: INTEGER,
  evaluation_summary: [STRING],
  promoted_cues: [STRING],
  rejected_cues: [STRING]
})

(plan cueHandlingProcess § steps:
  - scanCueDirectory
  - evaluateCueQuality
  - assessPromotionCriteria
  - makePromotionDecision
  - generateCueReport
  - updateCueStatus
  - promoteApprovedCues)

(contract cueEvaluation
  ⊨ requires: cue_format_valid = true ∧ evaluation_criteria_applied = true
  ⊨ ensures: promotion_decision_documented = true ∧ rationale_provided = true)
```

#### 4.2.2 Evaluation Criteria

Each cue must be evaluated against four criteria (0.0-1.0 scale):

**Technical Feasibility (0.0-1.0)**
- 0.0-0.3: Technically infeasible or requires major system changes
- 0.4-0.6: Feasible with moderate implementation effort
- 0.7-1.0: Easily implementable with existing system capabilities

**System Alignment (0.0-1.0)**
- 0.0-0.3: Conflicts with core system principles or objectives
- 0.4-0.6: Neutral or tangentially related to system goals
- 0.7-1.0: Strongly aligned with system evolution and objectives

**Implementation Complexity (0.0-1.0)**
- 0.0-0.3: Highly complex, requires significant development effort
- 0.4-0.6: Moderate complexity, manageable implementation
- 0.7-1.0: Low complexity, straightforward implementation

**Value Proposition (0.0-1.0)**
- 0.0-0.3: Limited or unclear value to system capabilities
- 0.4-0.6: Moderate value, incremental improvement
- 0.7-1.0: High value, significant enhancement to system

#### 4.2.3 Decision Matrix

**Promotion Criteria:**
- Combined score ≥ 0.7 AND no individual criterion < 0.4
- Technical feasibility ≥ 0.6 (minimum viability threshold)
- System alignment ≥ 0.6 (consistency requirement)

**Rejection Criteria:**
- Technical feasibility < 0.4 (infeasible)
- System alignment < 0.4 (conflicts with system principles)
- Combined score < 0.5 (insufficient overall value)

**Deferral Criteria:**
- Combined score 0.5-0.69 (needs further analysis)
- Missing information prevents proper evaluation
- Dependencies on other system components not yet available

#### 4.2.4 Reporting Requirements

Each evaluation cycle must produce:

**Individual Cue Evaluation Reports:**
- Detailed scoring for each criterion
- Promotion/rejection rationale
- Implementation recommendations (if promoted)
- Alternative approaches (if rejected)

**Aggregate Cue Report:**
- Summary statistics for evaluation cycle
- Trends in cue quality and themes
- Promoted cues with implementation timelines
- Rejected cues with improvement suggestions

#### 4.2.5 Cue Status Management

**Promoted Cues:**
- Move to appropriate `spec/` directory as formal specifications
- Maintain traceability link to original cue
- Archive original cue with promotion notation

**Rejected Cues:**
- Archive with detailed rejection rationale
- Maintain in `archive/cues/` for future reference
- Include suggestions for improvement if applicable

**Deferred Cues:**
- Remain in `cues/` directory with deferral notation
- Schedule for re-evaluation in next cycle
- Document dependencies preventing current evaluation

#### 4.2.6 Evaluation Cycle

**Frequency:** Monthly or triggered by significant cue accumulation (>10 new cues)

**Process:**
1. Scan all `.cues.md` files in `cues/` directory
2. Evaluate each cue against criteria framework
3. Apply decision matrix for promotion/rejection/deferral
4. Generate individual and aggregate reports
5. Update cue status and move files as appropriate
6. Schedule follow-up actions for promoted cues

---

## 5. Artifact Output File Location Review

### 5.1 Systematic Location Assessment

Before committing any artifacts, conduct a systematic review of file locations to ensure proper organization:

```smars
@role(architect)

(kind LocationReview ∷ {
  artifact_name: STRING,
  current_location: STRING,
  recommended_location: STRING,
  artifact_type: STRING,
  rationale: STRING,
  move_required: BOOL
})

(plan artifactLocationReview § steps:
  - scanAllArtifacts
  - classifyArtifactTypes
  - assessCurrentLocations
  - applyLocationCriteria
  - generateMoveRecommendations
  - executeReorganization)

(contract locationReview
  ⊨ requires: all_artifacts_scanned = true ∧ criteria_applied = true
  ⊨ ensures: logical_organization = true ∧ accessibility_maintained = true)
```

### 5.2 File Location Criteria

**spec/**: Formal SMARS specifications
- `*.smars.md` files with formal symbolic declarations
- Must include at least one plan, kind, and contract
- Implementation-independent symbolic logic

**notes/**: Analysis, validation, and implementation documentation
- Validation reports and assessment documents
- Task execution logs and learning documentation
- Implementation guidance and architectural notes
- Process documentation and meta-analysis

**journal/**: Chronological development insights
- Numbered entries documenting system evolution
- Symbolic explorations and hypothesis testing
- Discovery narratives and design insights

**examples/**: Concrete implementation demonstrations
- Working code examples and prototypes
- Specific use case implementations
- Demonstration of symbolic specs in practice

**experiments/**: Active development and testing
- Ongoing experimental implementations
- Temporary development artifacts
- Work-in-progress prototypes

### 5.3 Location Review Process

1. **Artifact Classification**
   - Determine primary purpose (specification, analysis, implementation, exploration)
   - Assess formality level (formal symbolic, structured analysis, informal notes)
   - Identify target audience (system architects, implementers, researchers)

2. **Location Assessment**
   - Compare current location against intended purpose
   - Verify accessibility for target audience
   - Check for logical grouping with related artifacts

3. **Move Recommendations**
   - Generate specific move recommendations with rationale
   - Prioritize moves that improve system organization
   - Consider impact on existing references and links

4. **Reorganization Execution**
   - Execute file moves using git mv to preserve history
   - Update any internal references or links
   - Commit reorganization with clear rationale

### 5.4 Common Location Patterns

**Root Directory**: Only essential project files
- `README.md`, `LICENSE`, `CLAUDE.md`, `AGENT_PRIMER.md`
- Active evaluation cycles (until completed)

**Misplaced Artifacts**: Common location issues
- Validation reports in root → should be in `notes/`
- Implementation docs in root → should be in `notes/`
- Task execution logs in root → should be in `notes/`
- Process documentation in root → should be in `notes/`

## 6. Journal and Notes

Use:
- `journal/` to explore ideas and structure symbolically
- `notes/` to reflect on modeling, theory, edge cases, or meta-level questions

Neither folder is part of the active runtime model but provides context and continuity.

---

## 7. Archival

Retire deprecated, unstable, or exploratory designs to the `archive/` directory. Do not delete symbolic artifacts unless they are invalid; archive instead.

---

## Symbolic Artifact Expectations

| Type                  | Location                    | Must Include                               |
|-----------------------|-----------------------------|--------------------------------------------|
| `declaration.smars.md`| `spec/feature-name/`       | At least one plan, kind, and contract      |
| `implementation.md`   | `spec/feature-name/`       | Interpretation of all declared symbols     |
| `review.md`           | `spec/feature-name/`       | Validation results and cross-feature conflicts |
| `summary.md`          | `spec/feature-name/`       | Status overview and next steps             |
| `*.smars.md`          | `spec/shared/`             | Common symbols used across features        |
| `*.cues.md`           | `cues/`                    | Well-formed advisory cues only             |
| `*.md`                | `notes/`                   | Freeform, unstructured reflection          |
| `*.smars.md`          | `journal/`                 | Unstable symbolic explorations             |

---

## Operating Principles

- A valid SMARS spec is structurally complete, even without implementation.
- Implementation must defer to symbolic declarations.
- Cues exist as soft guidance, not as requirements.
- Tests validate behavior symbolically, not through language-specific tools.
- Archives preserve history of symbolic evolution, not just code.

### Symbolic Stability and Intent Preservation

SMARS operates at the **symbolic planning level**, where specifications evolve through **refinement**, not breaking changes:

- **Symbolic refinement**: New understanding refines existing symbols rather than invalidating them
- **Intent preservation**: Core symbolic meaning (authentication, user identity, data flow) remains constant across evolution
- **Implementation abstraction**: Details like `password` vs `password_hash` are implementation concerns, not planning concerns
- **Agent consensus**: Multiple agents can work with different levels of symbolic detail simultaneously
- **Evolutionary stability**: Essential contracts and plans remain valid as implementation details evolve

When agents detect symbolic evolution, they should treat it as **learning** rather than **breaking changes**. The fundamental planning structure maintains stability while allowing natural refinement of understanding.

---

## License and Structure Use

This SOP is shared to support the development of agentic, symbolic systems. It may be reused, adapted, or forked under the license in this repository.

---
