# System Architecture Reflection

**Journal Entry**: 016  
**Date**: Current Session  
**Focus**: Separating journaling from request tracking and fixing cue system integration

## Observation

The journaling system has become entangled with request tracking, creating confusion between:
- **Journal entries** (numbered reflections on system evolution)  
- **Request specifications** (formal SMARS declarations in spec/requests/)
- **Request summaries** (outcomes tracked in requests/completed/)

## Current State Analysis

### What's Working
- SMARS grammar and symbolic consistency maintained
- Request management workflow defined in `spec/requests/meta-request-management.smars.md`
- Cue system generates valuable insights
- Directory structure supports separation of concerns

### What's Tangled
- Journal entries mixing request tracking with system reflection
- Examples directory contains request-specific artifacts that should be in spec/requests/
- Cue system not properly integrated with request workflow
- Request numbering scattered across different systems

## Proposed Architecture

### Clean Separation
1. **Journal** (`journal/NNN-topic.md`) - System evolution reflections, insights, learning
2. **Request Specs** (`spec/requests/REQ-NNN-name.smars.md`) - Formal SMARS declarations
3. **Request Summaries** (`requests/completed/REQ-NNN-summary.md`) - Outcome tracking
4. **Cues** (`cues/topic.md`) - Advisory suggestions from analysis

### Workflow Integration
1. User makes request → Capture in `spec/requests/REQ-NNN-name.smars.md`
2. Analysis generates insights → Record in `journal/NNN-analysis-topic.md`
3. Insights suggest improvements → Generate `cues/topic-insights.md`
4. Valuable cues promoted → Create formal specs in appropriate `spec/` subdirectory
5. Request completion → Summary in `requests/completed/REQ-NNN-summary.md`

## Key Principle

**Journals are for system learning, not request tracking.**  
Journals should reflect on patterns, insights, and system evolution - not duplicate request management workflow.

## Next Steps

1. Move request-specific artifacts from examples/ to spec/requests/
2. Clean up journal entries to focus on system insights
3. Ensure cue system properly references both journals and requests
4. Validate that request workflow uses proper SMARS specifications

This separation will restore clarity and enable the system to scale both request handling and evolutionary learning.