
⚙️ SMARS Implementation Review (Template)

(Copy → paste → fill in)

<analysis>
### 1. Snapshot

| Metric              | Count |
| ------------------- | ----: |
| Kinds (κ)           |   {#} |
| Datums (δ)          |   {#} |
| Maplets (µ)         |   {#} |
| Apply calls (α)     |   {#} |
| Contracts (§ or γ)  |   {#} |
| Plans / Branches    |   {#} |
| Unit tests          |   {#} |
| parser round-trip % | {xx}% |

> **Spec version**: {v}  **Runtime commit**: `{short-SHA}`

---

### 2. Core checklist  (✅ pass  ❌ fail  ⚠️ partial)

| Area                                                         | Status | Notes / Blocking issues |
| ------------------------------------------------------------ | ------ | ----------------------- |
| **Parser**: κ/δ/µ/α/§ lines round-trip (string ⇒ struct ⇒ string) |        |                         |
| **Executor**: `Maplet` identifier ⇒ closure mapping          |        |                         |
| **Apply re-run**: deterministic outputs reproduce            |        |                         |
| **Contract eval**: requires / ensures AST passes all sample specs |        |                         |
| **Literal type safety** (`LiteralValue` enum)                |        |                         |
| **Hash chain / tamper proofing** (optional)                  |        |                         |
| **CI green** (`swift test`)                                  |        |                         |

---

### 3. Code-quality drill-down

| Topic                                      | Finding | Recommended fix |
| ------------------------------------------ | ------- | --------------- |
| **Struct cohesion**                        |         |                 |
| **Error propagation** (`throws`, `Result`) |         |                 |
| **Sendable conformance**                   |         |                 |
| **Logging / tracing**                      |         |                 |
| **Dead code**                              |         |                 |

---

### 4. Reality-grounding verdict

*When I parse **demo.smars** and call `Executor.runAll()`…*

| Stage                            | Result |
| -------------------------------- | ------ |
| Parse spec                       | ✅ / ❌  |
| Execute all α                    | ✅ / ❌  |
| Validate all §                   | ✅ / ❌  |
| Re-run determinism (same inputs) | ✅ / ❌  |

> **Overall**: _(Green / Yellow / Red)_  
> *(If yellow/red, list top 3 root causes.)*

---

### 5. Minimal fix-plan (≤ 5 tasks)

1. **Parser gaps**: `{...}`  
2. **Bind maplets to code**: `{...}`  
3. **Contract expression evaluator**: `{...}`  
4. **Unit test scaffolding**: `{...}`  
5. **(Optional) remove Plans/Branches until core is solid**  

*(Each task should touch ≤ 20 files or <300 LOC.)*

---

### 6. Target MVP acceptance test

```bash
# Given the sample spec
smars run demo.smars \
  --bind validate_email ./lib/validate_email.swift \
  --bind slice         ./lib/slice.swift \
  --assert-all-contracts

Exit code 0 ⇒ MVP passes.


```

</analysis>

⸻

How to use
	1.	Fill the {placeholders} with real numbers and findings.
	2.	Run it every sprint; keep old versions for diffing progress.
	3.	Attach the "Minimal fix-plan" section to a ticket in your tracker—each bullet becomes an epic or story.

Customising
	•	Need performance metrics? Add a "Runtime perf" row under Core checklist (avg exec time, memory).
	•	Multiple runtimes (Rust/Swift)? Duplicate the table, one per language.
	•	Want spec vs runtime drift list? Add a script that diffs κ/δ/µ identifiers between spec file and generated Swift structs; report in Code-quality section.

⸻