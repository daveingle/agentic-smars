@role(meta)

# MetaCycle definition — governing loop for evolving SMARS

kind MetaCycle = {
  cycle_id: String,
  start_date: Date,
  end_date: Optional[Date],
  cue_reviews: List[String],
  specs_created: List[String],
  specs_updated: List[String],
  cues_archived: List[String],
  notes: Optional[String],
}
