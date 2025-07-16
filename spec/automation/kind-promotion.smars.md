@role(architect)

// --- Types
(kind KindDeclaration ∷ { name: STRING, definition: STRING, domain: STRING, source: STRING })
(kind KindLocation ∷ { path: STRING, domain: STRING, canonical: BOOL })
(kind KindDuplication ∷ { existing: STRING, proposed: STRING, conflict: BOOL })
(kind KindPlacement ∷ { kind: KindDeclaration, location: KindLocation, status: STRING })
(kind KindRegistry ∷ { kinds: [KindDeclaration], locations: [KindLocation] })

// --- Datum Constants
(datum ⟦canonical_kinds_path⟧ ∷ STRING = "spec/types/")
(datum ⟦domain_kinds_path⟧ ∷ STRING = "spec/{{domain}}/types/")
(datum ⟦kind_registry_path⟧ ∷ STRING = "spec/types/registry.smars.md")
(datum ⟦deduplication_policy⟧ ∷ STRING = "merge_compatible")
(datum ⟦default_registry⟧ ∷ KindRegistry = { kinds: [], locations: [] })

// --- Core Maplets
(maplet extractKind ∷ STRING → KindDeclaration)
(maplet analyzeKindDomain ∷ KindDeclaration → STRING)
(maplet checkKindDuplication ∷ { kind: KindDeclaration, registry: KindRegistry } → KindDuplication)
(maplet determineKindLocation ∷ { kind: KindDeclaration, domain: STRING } → KindLocation)
(maplet placeKind ∷ { kind: KindDeclaration, location: KindLocation } → KindPlacement)
(maplet updateKindRegistry ∷ { registry: KindRegistry, placement: KindPlacement } → KindRegistry)

// --- Contracts
(contract extractKind
  ⊨ requires: input contains "kind"
  ⊨ requires: input contains "∷"
  ⊨ ensures: name ≠ ""
  ⊨ ensures: definition ≠ "")

(contract analyzeKindDomain
  ⊨ requires: name ≠ ""
  ⊨ ensures: domain ≠ ""
  ⊨ ensures: domain matches known domain patterns)

(contract checkKindDuplication
  ⊨ requires: kind.name ≠ ""
  ⊨ requires: registry.kinds ≠ []
  ⊨ ensures: conflict = true | conflict = false
  ⊨ ensures: existing ≠ "" when conflict = true)

(contract determineKindLocation
  ⊨ requires: kind.name ≠ ""
  ⊨ requires: domain ≠ ""
  ⊨ ensures: path ≠ ""
  ⊨ ensures: canonical = true when domain = "core")

(contract placeKind
  ⊨ requires: kind.name ≠ ""
  ⊨ requires: location.path ≠ ""
  ⊨ ensures: status = "placed" | status = "duplicate" | status = "conflict"
  ⊨ ensures: placement preserves kind integrity)

(contract updateKindRegistry
  ⊨ requires: placement.status = "placed"
  ⊨ ensures: registry contains new kind
  ⊨ ensures: registry maintains uniqueness)

// --- Kind Promotion Plan
(plan promoteKindToCanonical
  § steps:
    - extractKind
    - analyzeKindDomain
    - checkKindDuplication
    - duplicationHandling
    - determineKindLocation
    - placeKind
    - updateKindRegistry
)

// --- Domain Classification Branch
(branch domainClassification
  ⎇ when domain = "core":
      → canonical_kinds_path
    when domain = "automation":
      → domain_kinds_path
    when domain = "patterns":
      → domain_kinds_path
    else:
      → domain_kinds_path
)

// --- Duplication Handling Branch
(branch duplicationHandling
  ⎇ when conflict = false:
      → placeKind
    when conflict = true and deduplication_policy = "merge_compatible":
      → mergeCompatibleKinds
    when conflict = true and deduplication_policy = "reject_duplicate":
      → rejectDuplicateKind
    else:
      → flagConflictForReview
)

// --- Default Behavior
(default automatic_domain_detection: true)
(default preserve_existing_kinds: true)

// --- Tests
(test extract_valid_kind expects: { name: "populated", definition: "populated" })
(test detect_core_domain expects: { domain: "core", canonical: true })
(test handle_duplicate_kind expects: { conflict: true, existing: "populated" })
(test place_in_canonical_location expects: { status: "placed", location: "canonical" })
(test update_registry_successfully expects: { registry: "contains_new_kind", uniqueness: "maintained" })

// --- Cues
(cue optimize_kind_clustering
  ⊨ suggests: group related kinds by semantic similarity in canonical locations)

(cue version_kind_evolution
  ⊨ suggests: track kind definition changes over time for compatibility analysis)

(cue cross_domain_kind_reuse
  ⊨ suggests: identify kinds that could be promoted from domain-specific to core)

(cue automated_kind_validation
  ⊨ suggests: validate kind definitions against SMARS grammar before placement)

(cue kind_dependency_analysis
  ⊨ suggests: analyze field type dependencies when determining canonical placement)