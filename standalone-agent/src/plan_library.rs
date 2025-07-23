use anyhow::Result;
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use std::fs;
use std::path::Path;
use regex::Regex;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PlanLibrary {
    pub plans: HashMap<String, SMARSPlan>,
    pub patterns: HashMap<String, SMARSPattern>,
    pub contracts: HashMap<String, SMARSContract>,
    pub maplets: HashMap<String, SMARSMaplet>,
    pub kinds: HashMap<String, SMARSKind>,
    pub metadata: LibraryMetadata,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SMARSPlan {
    pub name: String,
    pub steps: Vec<String>,
    pub domain: String,
    pub complexity: String,
    pub source_file: String,
    pub description: String,
    pub keywords: Vec<String>,
    pub estimated_duration_minutes: u32,
    pub requires_user_input: bool,
    pub artifacts_created: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SMARSPattern {
    pub name: String,
    pub source_file: String,
    pub concepts: Vec<String>,
    pub description: String,
    pub applicability: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SMARSContract {
    pub name: String,
    pub requires: Vec<String>,
    pub ensures: Vec<String>,
    pub source_file: String,
    pub domain: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SMARSMaplet {
    pub name: String,
    pub signature: String,
    pub source_file: String,
    pub input_types: Vec<String>,
    pub output_type: String,
    pub domain: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SMARSKind {
    pub name: String,
    pub fields: HashMap<String, String>,
    pub source_file: String,
    pub domain: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct LibraryMetadata {
    pub total_plans: usize,
    pub total_patterns: usize,
    pub total_contracts: usize,
    pub total_maplets: usize,
    pub total_kinds: usize,
    pub domains: Vec<String>,
    pub complexity_levels: Vec<String>,
    pub generated_at: String,
}

pub struct PlanLibraryBuilder {
    library: PlanLibrary,
    smars_root: String,
}

impl PlanLibraryBuilder {
    pub fn new(smars_root: &str) -> Self {
        Self {
            library: PlanLibrary {
                plans: HashMap::new(),
                patterns: HashMap::new(),
                contracts: HashMap::new(),
                maplets: HashMap::new(),
                kinds: HashMap::new(),
                metadata: LibraryMetadata {
                    total_plans: 0,
                    total_patterns: 0,
                    total_contracts: 0,
                    total_maplets: 0,
                    total_kinds: 0,
                    domains: Vec::new(),
                    complexity_levels: Vec::new(),
                    generated_at: chrono::Utc::now().to_rfc3339(),
                },
            },
            smars_root: smars_root.to_string(),
        }
    }
    
    pub fn build_library(&mut self) -> Result<()> {
        println!("🔍 Scanning for SMARS files in: {}", self.smars_root);
        
        // Find all .smars.md files
        let smars_files = self.find_smars_files()?;
        println!("Found {} SMARS files", smars_files.len());
        
        // Process each file
        for file_path in smars_files {
            if let Ok(relative_path) = file_path.strip_prefix(&self.smars_root) {
                println!("  Processing: {}", relative_path.display());
                self.process_smars_file(&file_path)?;
            }
        }
        
        // Generate metadata
        self.generate_metadata();
        
        println!("✅ Plan library built with:");
        println!("  📋 Plans: {}", self.library.plans.len());
        println!("  🎨 Patterns: {}", self.library.patterns.len());
        println!("  📜 Contracts: {}", self.library.contracts.len());
        println!("  🔧 Maplets: {}", self.library.maplets.len());
        println!("  📦 Kinds: {}", self.library.kinds.len());
        
        Ok(())
    }
    
    fn find_smars_files(&self) -> Result<Vec<std::path::PathBuf>> {
        let mut smars_files = Vec::new();
        
        // Recursively find .smars.md files
        self.find_files_recursive(Path::new(&self.smars_root), &mut smars_files)?;
        
        Ok(smars_files)
    }
    
    fn find_files_recursive(&self, dir: &Path, files: &mut Vec<std::path::PathBuf>) -> Result<()> {
        if dir.is_dir() {
            for entry in fs::read_dir(dir)? {
                let entry = entry?;
                let path = entry.path();
                
                if path.is_dir() {
                    self.find_files_recursive(&path, files)?;
                } else if let Some(file_name) = path.file_name() {
                    if let Some(name_str) = file_name.to_str() {
                        if name_str.ends_with(".smars.md") {
                            files.push(path);
                        }
                    }
                }
            }
        }
        Ok(())
    }
    
    fn process_smars_file(&mut self, file_path: &Path) -> Result<()> {
        let content = fs::read_to_string(file_path)?;
        let source_file = file_path.strip_prefix(&self.smars_root)
            .unwrap_or(file_path)
            .to_string_lossy()
            .to_string();
        
        // Extract different SMARS components
        self.extract_plans(&content, &source_file);
        self.extract_patterns(&content, &source_file, file_path);
        self.extract_contracts(&content, &source_file);
        self.extract_maplets(&content, &source_file);
        self.extract_kinds(&content, &source_file);
        
        Ok(())
    }
    
    fn extract_plans(&mut self, content: &str, source_file: &str) {
        let plan_regex = Regex::new(r"(?s)\(plan\s+(\w+)\s*§\s*steps:\s*(.*?)\)").unwrap();
        
        for captures in plan_regex.captures_iter(content) {
            let plan_name = captures.get(1).unwrap().as_str().to_string();
            let steps_content = captures.get(2).unwrap().as_str();
            
            // Extract individual steps
            let steps: Vec<String> = steps_content
                .lines()
                .filter_map(|line| {
                    let trimmed = line.trim();
                    if trimmed.starts_with("- ") {
                        Some(trimmed[2..].trim().to_string())
                    } else {
                        None
                    }
                })
                .collect();
            
            if !steps.is_empty() {
                let domain = self.infer_domain(&plan_name, &steps, source_file);
                let complexity = self.infer_complexity(&steps);
                
                let plan = SMARSPlan {
                    name: plan_name.clone(),
                    steps: steps.clone(),
                    domain: domain.clone(),
                    complexity: complexity.clone(),
                    source_file: source_file.to_string(),
                    description: self.generate_plan_description(&plan_name, &steps),
                    keywords: self.extract_keywords(&plan_name, &steps),
                    estimated_duration_minutes: self.estimate_duration(&steps),
                    requires_user_input: self.requires_user_input(&steps),
                    artifacts_created: self.identify_artifacts(&steps),
                };
                
                self.library.plans.insert(plan_name, plan);
            }
        }
    }
    
    fn extract_patterns(&mut self, content: &str, source_file: &str, file_path: &Path) {
        // Look for pattern-like structures
        if source_file.to_lowercase().contains("pattern") || 
           source_file.to_lowercase().contains("patterns") {
            
            let pattern_name = file_path.file_stem()
                .unwrap_or_default()
                .to_string_lossy()
                .replace('-', "_");
            
            let concepts = self.extract_key_concepts(content);
            let applicability = self.determine_applicability(content);
            
            let pattern = SMARSPattern {
                name: pattern_name.clone(),
                source_file: source_file.to_string(),
                concepts,
                description: self.generate_pattern_description(&pattern_name),
                applicability,
            };
            
            self.library.patterns.insert(pattern_name, pattern);
        }
    }
    
    fn extract_contracts(&mut self, content: &str, source_file: &str) {
        let contract_regex = Regex::new(r"(?s)\(contract\s+(\w+)\s*(.*?)\)").unwrap();
        
        for captures in contract_regex.captures_iter(content) {
            let contract_name = captures.get(1).unwrap().as_str().to_string();
            let contract_body = captures.get(2).unwrap().as_str();
            
            let requires = self.extract_contract_clauses(contract_body, "requires");
            let ensures = self.extract_contract_clauses(contract_body, "ensures");
            
            let domain = self.infer_domain(&contract_name, &[requires.join(" "), ensures.join(" ")], source_file);
            
            let contract = SMARSContract {
                name: contract_name.clone(),
                requires,
                ensures,
                source_file: source_file.to_string(),
                domain,
            };
            
            self.library.contracts.insert(contract_name, contract);
        }
    }
    
    fn extract_maplets(&mut self, content: &str, source_file: &str) {
        let maplet_regex = Regex::new(r"\(maplet\s+(\w+)\s*∷\s*(.*?)\)").unwrap();
        
        for captures in maplet_regex.captures_iter(content) {
            let maplet_name = captures.get(1).unwrap().as_str().to_string();
            let signature = captures.get(2).unwrap().as_str().trim().to_string();
            
            let input_types = self.parse_maplet_inputs(&signature);
            let output_type = self.parse_maplet_output(&signature);
            let domain = self.infer_domain(&maplet_name, &[signature.clone()], source_file);
            
            let maplet = SMARSMaplet {
                name: maplet_name.clone(),
                signature,
                source_file: source_file.to_string(),
                input_types,
                output_type,
                domain,
            };
            
            self.library.maplets.insert(maplet_name, maplet);
        }
    }
    
    fn extract_kinds(&mut self, content: &str, source_file: &str) {
        let kind_regex = Regex::new(r"(?s)\(kind\s+(\w+)\s*\{(.*?)\}").unwrap();
        
        for captures in kind_regex.captures_iter(content) {
            let kind_name = captures.get(1).unwrap().as_str().to_string();
            let fields_content = captures.get(2).unwrap().as_str();
            
            let mut fields = HashMap::new();
            for line in fields_content.lines() {
                let line = line.trim();
                if line.contains(':') && !line.starts_with("//") {
                    if let Some(colon_pos) = line.find(':') {
                        let field_name = line[..colon_pos].trim().to_string();
                        let field_type = line[colon_pos + 1..].trim().trim_end_matches(',').to_string();
                        fields.insert(field_name, field_type);
                    }
                }
            }
            
            if !fields.is_empty() {
                let domain = self.infer_domain(&kind_name, &fields.keys().cloned().collect::<Vec<_>>(), source_file);
                
                let kind = SMARSKind {
                    name: kind_name.clone(),
                    fields,
                    source_file: source_file.to_string(),
                    domain,
                };
                
                self.library.kinds.insert(kind_name, kind);
            }
        }
    }
    
    // Helper methods for domain inference, complexity analysis, etc.
    
    fn infer_domain(&self, name: &str, content: &[String], source_file: &str) -> String {
        let combined_text = format!("{} {} {}", name, content.join(" "), source_file).to_lowercase();
        
        if combined_text.contains("saas") || combined_text.contains("web") || combined_text.contains("api") {
            "web_development".to_string()
        } else if combined_text.contains("kaggle") || combined_text.contains("ml") || combined_text.contains("model") {
            "machine_learning".to_string()
        } else if combined_text.contains("agent") || combined_text.contains("coordination") {
            "multi_agent".to_string()
        } else if combined_text.contains("validation") || combined_text.contains("test") {
            "validation".to_string()
        } else if combined_text.contains("runtime") || combined_text.contains("execution") {
            "runtime".to_string()
        } else {
            "general".to_string()
        }
    }
    
    fn infer_complexity(&self, steps: &[String]) -> String {
        match steps.len() {
            0..=3 => "simple".to_string(),
            4..=8 => "medium".to_string(),
            _ => "complex".to_string(),
        }
    }
    
    fn generate_plan_description(&self, name: &str, steps: &[String]) -> String {
        format!("SMARS plan '{}' with {} steps covering comprehensive implementation phases", name, steps.len())
    }
    
    fn generate_pattern_description(&self, name: &str) -> String {
        format!("Reusable SMARS pattern for {} scenarios", name.replace('_', " "))
    }
    
    fn extract_keywords(&self, name: &str, steps: &[String]) -> Vec<String> {
        let mut keywords = vec![name.to_lowercase()];
        
        for step in steps {
            let words: Vec<String> = step.split_whitespace()
                .map(|w| w.to_lowercase())
                .filter(|w| w.len() > 2)
                .collect();
            keywords.extend(words);
        }
        
        keywords.sort();
        keywords.dedup();
        keywords.truncate(20);
        keywords
    }
    
    fn estimate_duration(&self, steps: &[String]) -> u32 {
        let base_time = 15; // minutes per step
        let mut total = 0;
        
        for step in steps {
            let step_lower = step.to_lowercase();
            if step_lower.contains("implement") || step_lower.contains("build") {
                total += base_time * 3;
            } else if step_lower.contains("test") || step_lower.contains("validate") {
                total += base_time * 2;
            } else {
                total += base_time;
            }
        }
        
        total
    }
    
    fn requires_user_input(&self, steps: &[String]) -> bool {
        let input_indicators = ["clarification", "requirements", "approval", "decision", "configuration"];
        
        steps.iter().any(|step| {
            let step_lower = step.to_lowercase();
            input_indicators.iter().any(|indicator| step_lower.contains(indicator))
        })
    }
    
    fn identify_artifacts(&self, steps: &[String]) -> Vec<String> {
        let mut artifacts = Vec::new();
        
        for step in steps {
            let step_lower = step.to_lowercase();
            if step_lower.contains("create") || step_lower.contains("generate") || step_lower.contains("build") {
                if step_lower.contains("database") {
                    artifacts.push("database_schema".to_string());
                } else if step_lower.contains("api") {
                    artifacts.push("api_specification".to_string());
                } else if step_lower.contains("test") {
                    artifacts.push("test_suite".to_string());
                } else if step_lower.contains("documentation") {
                    artifacts.push("documentation".to_string());
                } else {
                    artifacts.push("implementation_artifact".to_string());
                }
            }
        }
        
        artifacts.sort();
        artifacts.dedup();
        artifacts
    }
    
    fn extract_key_concepts(&self, content: &str) -> Vec<String> {
        let mut concepts = Vec::new();
        
        for line in content.lines() {
            let line = line.trim();
            if line.starts_with('#') && !line.starts_with("##") {
                let concept = line.trim_start_matches('#').trim().to_string();
                if !concept.is_empty() {
                    concepts.push(concept);
                }
            }
        }
        
        concepts.truncate(10);
        concepts
    }
    
    fn determine_applicability(&self, content: &str) -> Vec<String> {
        let mut applicability = Vec::new();
        let content_lower = content.to_lowercase();
        
        if content_lower.contains("multi-agent") {
            applicability.push("multi_agent_coordination".to_string());
        }
        if content_lower.contains("validation") {
            applicability.push("validation_required".to_string());
        }
        if content_lower.contains("real-time") {
            applicability.push("real_time_systems".to_string());
        }
        if content_lower.contains("web") || content_lower.contains("api") {
            applicability.push("web_development".to_string());
        }
        
        applicability
    }
    
    fn extract_contract_clauses(&self, contract_body: &str, clause_type: &str) -> Vec<String> {
        let mut clauses = Vec::new();
        let lines: Vec<&str> = contract_body.lines().collect();
        let mut in_clause = false;
        
        for line in lines {
            let line = line.trim();
            if line.starts_with(&format!("{}:", clause_type)) {
                in_clause = true;
                let clause = line[clause_type.len() + 1..].trim();
                if !clause.is_empty() {
                    clauses.push(clause.to_string());
                }
            } else if in_clause && (line.starts_with("ensures:") && clause_type == "requires") {
                break;
            } else if in_clause && line.starts_with(')') {
                break;
            } else if in_clause && !line.is_empty() {
                clauses.push(line.to_string());
            }
        }
        
        clauses
    }
    
    fn parse_maplet_inputs(&self, signature: &str) -> Vec<String> {
        if let Some(arrow_pos) = signature.find('→') {
            let input_part = signature[..arrow_pos].trim();
            if !input_part.is_empty() {
                vec![input_part.to_string()]
            } else {
                Vec::new()
            }
        } else {
            Vec::new()
        }
    }
    
    fn parse_maplet_output(&self, signature: &str) -> String {
        if let Some(arrow_pos) = signature.find('→') {
            signature[arrow_pos + 1..].trim().to_string()
        } else {
            String::new()
        }
    }
    
    fn generate_metadata(&mut self) {
        let mut domains = std::collections::HashSet::new();
        let mut complexity_levels = std::collections::HashSet::new();
        
        for plan in self.library.plans.values() {
            domains.insert(plan.domain.clone());
            complexity_levels.insert(plan.complexity.clone());
        }
        
        self.library.metadata = LibraryMetadata {
            total_plans: self.library.plans.len(),
            total_patterns: self.library.patterns.len(),
            total_contracts: self.library.contracts.len(),
            total_maplets: self.library.maplets.len(),
            total_kinds: self.library.kinds.len(),
            domains: domains.into_iter().collect(),
            complexity_levels: complexity_levels.into_iter().collect(),
            generated_at: chrono::Utc::now().to_rfc3339(),
        };
    }
    
    pub fn save_library(&self, output_path: &str) -> Result<()> {
        let json_content = serde_json::to_string_pretty(&self.library)?;
        fs::write(output_path, json_content)?;
        println!("📁 Plan library saved to: {}", output_path);
        Ok(())
    }
    
    pub fn get_library(&self) -> &PlanLibrary {
        &self.library
    }
}

pub struct PlanLibraryLoader;

impl PlanLibraryLoader {
    pub fn load_embedded_library() -> Result<PlanLibrary> {
        // This will contain the pre-built library embedded in the binary
        let library_json = include_str!("../plan_library/plan_library.json");
        let library: PlanLibrary = serde_json::from_str(library_json)?;
        Ok(library)
    }
    
    pub fn load_from_file(path: &str) -> Result<PlanLibrary> {
        let content = fs::read_to_string(path)?;
        let library: PlanLibrary = serde_json::from_str(&content)?;
        Ok(library)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    
    #[test]
    fn test_plan_extraction() {
        let content = r#"
        (plan test_plan
          § steps:
            - analyze_requirements
            - implement_solution
            - validate_results
        )
        "#;
        
        let mut builder = PlanLibraryBuilder::new("test");
        builder.extract_plans(content, "test.smars.md");
        
        assert_eq!(builder.library.plans.len(), 1);
        assert!(builder.library.plans.contains_key("test_plan"));
        
        let plan = &builder.library.plans["test_plan"];
        assert_eq!(plan.steps.len(), 3);
        assert_eq!(plan.steps[0], "analyze_requirements");
    }
    
    #[test]
    fn test_domain_inference() {
        let builder = PlanLibraryBuilder::new("test");
        
        assert_eq!(builder.infer_domain("saas_plan", &["web".to_string()], "test.md"), "web_development");
        assert_eq!(builder.infer_domain("ml_model", &["kaggle".to_string()], "test.md"), "machine_learning");
        assert_eq!(builder.infer_domain("agent_coord", &["coordination".to_string()], "test.md"), "multi_agent");
    }
}