# Journal Entry Management System

**SMARS Specification for Journal Entry File Lineage and Format**

```smars
@role(developer)

// Journal Entry Core Types
(kind JournalEntry ∷ {
  filename: STRING,
  title: STRING,
  created_timestamp: STRING,
  entry_type: STRING,
  tags: [STRING],
  content: STRING
})

(kind JournalEntryFormat ∷ {
  iso8601_timestamp: STRING,
  monotonic_slug: STRING,
  yaml_frontmatter: BOOL,
  markdown_content: BOOL
})

(kind JournalEntryType ∷ {
  analysis: STRING,
  specification: STRING,
  milestone: STRING,
  reflection: STRING,
  external_research: STRING
})

// Journal Entry Constants
(datum ⟦filename_pattern⟧ ∷ STRING = "YYYY-MM-DDTHH-MM-SSZ--descriptive-slug.md")
(datum ⟦timestamp_format⟧ ∷ STRING = "ISO 8601 with Z suffix")
(datum ⟦journal_directory⟧ ∷ STRING = "journal/")
(datum ⟦yaml_frontmatter_required⟧ ∷ BOOL = true)
(datum ⟦markdown_content_required⟧ ∷ BOOL = true)

// Journal Entry Operations
(maplet generateTimestamp ∷ → STRING)
(maplet createSlug ∷ STRING → STRING)
(maplet formatFilename ∷ STRING → STRING → STRING)
(maplet validateJournalEntry ∷ JournalEntry → BOOL)
(maplet extractTitleFromContent ∷ STRING → STRING)
(maplet addYAMLFrontMatter ∷ JournalEntry → STRING)

// Journal Entry Contracts
(contract immutable_lineage ⊨
  requires: filename_has_timestamp = true
  ensures: never_renumber_after_publication = true)

(contract monotonic_ordering ⊨ 
  requires: iso8601_format = true
  ensures: lexicographic_equals_chronological = true)

(contract filename_authority ⊨
  requires: filename_contains_metadata = true
  ensures: filename_is_single_source_of_truth = true)

(contract yaml_frontmatter_consistency ⊨
  requires: yaml_frontmatter_present = true
  ensures: filename_matches_frontmatter_filename = true)

// Journal Entry Creation Process
(plan createJournalEntry § steps:
  - generateTimestamp
  - createDescriptiveSlug  
  - formatFilename
  - addYAMLFrontMatter
  - writeMarkdownContent
  - validateFormat
  - saveToJournalDirectory)

// Journal Entry Migration Process
(plan migrateExistingJournalEntries § steps:
  - scanJournalDirectory
  - extractModificationTimestamps
  - generateNewFilenames
  - addYAMLFrontMatter
  - renameFiles
  - validateMigration)

// Journal Entry Validation
(test journal_entry_format_valid ∷ 
  filename_matches_pattern ∧ 
  timestamp_is_iso8601 ∧
  yaml_frontmatter_present ∧
  markdown_content_valid)

(test filename_timestamp_consistency ∷
  filename_timestamp_matches_yaml_created_field)

(test monotonic_ordering_preserved ∷
  newer_entries_have_later_timestamps)

// Journal Entry Quality Assurance
(contract journal_entry_quality ⊨
  requires: content_is_meaningful = true ∧ title_is_descriptive = true
  ensures: journal_entry_adds_value = true)

// Cues for Future Enhancement
(cue journal_entry_search ⊨ suggests: implement search functionality across journal entries)
(cue journal_entry_tagging ⊨ suggests: enhance tagging system for better categorization)
(cue journal_entry_linking ⊨ suggests: add cross-references between related journal entries)
(cue journal_entry_templates ⊨ suggests: create templates for common journal entry types)
```

## Purpose

This specification defines the canonical format and lifecycle management for journal entries in the SMARS system. It establishes:

1. **Immutable File Lineage**: ISO 8601 timestamps prevent renumbering chaos
2. **Monotonic Ordering**: Lexicographic sorting matches chronological order
3. **Metadata Authority**: Filename contains definitive creation metadata
4. **Format Consistency**: YAML front-matter with markdown content
5. **Quality Assurance**: Contracts ensure meaningful content

## Key Principles

### Immutable Lineage
Once published, journal entries are never renumbered. The timestamp in the filename serves as the immutable identifier and ordering mechanism.

### Filename as Single Source of Truth
The filename contains all essential metadata:
- Creation timestamp (ISO 8601 format)
- Descriptive slug for human readability
- File extension indicating format

### YAML Front-Matter Integration
Each journal entry includes structured metadata in YAML front-matter while maintaining the filename as the authoritative source.

### Validation and Quality
Contracts ensure journal entries meet quality standards and maintain consistency across the system.

This specification replaces ad-hoc journal entry numbering with a robust, timestamp-based system that prevents ordering conflicts and provides clear file lineage.