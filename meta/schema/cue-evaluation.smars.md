@role(meta)

# Cue Evaluation schema — how cues are triaged

kind CueEvaluation = {
  cue_id: String,
  evaluation_date: Date,
  status: Enum[Implemented, Archived, Ignored],
  justification: String,
  resulting_spec: Optional[String],
}
