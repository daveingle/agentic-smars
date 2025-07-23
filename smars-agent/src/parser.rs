use anyhow::{Result, anyhow};
use nom::{
    IResult,
    bytes::complete::{tag, take_until, take_while1},
    character::complete::{char, space0, space1, alpha1, alphanumeric1},
    sequence::tuple,
    multi::many0,
    combinator::recognize,
    branch::alt,
};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum SmarsNode {
    RoleDirective(RoleDirective),
    Plan(PlanDef),
    Maplet(MapletDef),
    Contract(ContractDef),
    Apply(ApplyCall),
    Kind(KindDef),
    Datum(DatumDef),
    Branch(BranchDef),
    Default(DefaultDef),
    Test(TestDef),
    Agent(AgentDef),
    Memory(MemoryDef),
    Confidence(ConfidenceDef),
    Validation(ValidationDef),
    Cue(CueDef),
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct PlanDef {
    pub name: String,
    pub steps: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MapletDef {
    pub name: String,
    pub signature: String,
    pub local_impl: Option<String>,
    pub remote_llm: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ContractDef {
    pub name: String,
    pub requires: Vec<String>,
    pub ensures: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ApplyCall {
    pub target: String,
    pub args: Vec<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct KindDef {
    pub name: String,
    pub fields: HashMap<String, String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DatumDef {
    pub name: String,
    pub type_name: String,
    pub value: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RoleDirective {
    pub role_type: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BranchDef {
    pub name: String,
    pub cases: Vec<BranchCase>,
    pub else_target: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct BranchCase {
    pub condition: String,
    pub target: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct DefaultDef {
    pub name: String,
    pub value: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TestDef {
    pub name: String,
    pub expected_outcome: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AgentDef {
    pub name: String,
    pub type_expr: String,
    pub capabilities: Vec<String>,
    pub memory_ref: Option<String>,
    pub confidence_calibration: Option<f64>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MemoryDef {
    pub name: String,
    pub structure: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ConfidenceDef {
    pub name: String,
    pub structure: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ValidationDef {
    pub name: String,
    pub structure: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CueDef {
    pub name: String,
    pub suggestion: String,
}

pub struct SmarsParser {
    // Parser state if needed
}

impl SmarsParser {
    pub fn new() -> Self {
        Self {}
    }
    
    pub fn parse(&mut self, content: &str) -> Result<Vec<SmarsNode>> {
        let mut nodes = Vec::new();
        
        // Extract SMARS code blocks from markdown
        let smars_blocks = self.extract_smars_blocks(content)?;
        
        for block in smars_blocks {
            let parsed_nodes = self.parse_smars_block(&block)?;
            nodes.extend(parsed_nodes);
        }
        
        Ok(nodes)
    }
    
    fn extract_smars_blocks(&self, content: &str) -> Result<Vec<String>> {
        use pulldown_cmark::{Parser, Event, Tag};
        
        let parser = Parser::new(content);
        let mut blocks = Vec::new();
        let mut in_smars_block = false;
        let mut current_block = String::new();
        
        for event in parser {
            match event {
                Event::Start(Tag::CodeBlock(pulldown_cmark::CodeBlockKind::Fenced(lang))) => {
                    if lang.as_ref() == "smars" {
                        in_smars_block = true;
                        current_block.clear();
                    }
                }
                Event::End(Tag::CodeBlock(_)) => {
                    if in_smars_block {
                        blocks.push(current_block.clone());
                        in_smars_block = false;
                    }
                }
                Event::Text(text) => {
                    if in_smars_block {
                        current_block.push_str(&text);
                    }
                }
                _ => {}
            }
        }
        
        // If no SMARS code blocks were found, but the content contains SMARS syntax,
        // treat the entire content as one SMARS block
        if blocks.is_empty() && (content.contains("@role(") || content.contains("(kind ") || content.contains("(plan ")) {
            blocks.push(content.to_string());
        }
        
        Ok(blocks)
    }
    
    fn parse_smars_block(&self, block: &str) -> Result<Vec<SmarsNode>> {
        let mut nodes = Vec::new();
        
        for line in block.lines() {
            let line = line.trim();
            if line.is_empty() || line.starts_with("//") {
                continue;
            }
            
            if let Ok(node) = self.parse_line(line) {
                nodes.push(node);
            }
        }
        
        Ok(nodes)
    }
    
    fn parse_line(&self, line: &str) -> Result<SmarsNode> {
        // Try parsing different SMARS constructs
        if let Ok((_, node)) = parse_role_directive(line) {
            return Ok(SmarsNode::RoleDirective(node));
        }
        if let Ok((_, node)) = parse_plan(line) {
            return Ok(SmarsNode::Plan(node));
        }
        if let Ok((_, node)) = parse_maplet(line) {
            return Ok(SmarsNode::Maplet(node));
        }
        if let Ok((_, node)) = parse_contract(line) {
            return Ok(SmarsNode::Contract(node));
        }
        if let Ok((_, node)) = parse_apply(line) {
            return Ok(SmarsNode::Apply(node));
        }
        if let Ok((_, node)) = parse_kind(line) {
            return Ok(SmarsNode::Kind(node));
        }
        if let Ok((_, node)) = parse_datum(line) {
            return Ok(SmarsNode::Datum(node));
        }
        if let Ok((_, node)) = parse_branch(line) {
            return Ok(SmarsNode::Branch(node));
        }
        if let Ok((_, node)) = parse_default(line) {
            return Ok(SmarsNode::Default(node));
        }
        if let Ok((_, node)) = parse_test(line) {
            return Ok(SmarsNode::Test(node));
        }
        if let Ok((_, node)) = parse_agent(line) {
            return Ok(SmarsNode::Agent(node));
        }
        if let Ok((_, node)) = parse_memory(line) {
            return Ok(SmarsNode::Memory(node));
        }
        if let Ok((_, node)) = parse_confidence(line) {
            return Ok(SmarsNode::Confidence(node));
        }
        if let Ok((_, node)) = parse_validation(line) {
            return Ok(SmarsNode::Validation(node));
        }
        if let Ok((_, node)) = parse_cue(line) {
            return Ok(SmarsNode::Cue(node));
        }
        
        Err(anyhow!("Failed to parse line: {}", line))
    }
}

// Nom parsers for each SMARS construct

fn parse_plan(input: &str) -> IResult<&str, PlanDef> {
    let (input, _) = tuple((char('('), tag("plan"), space1))(input)?;
    let (input, name) = identifier(input)?;
    let (input, _) = tuple((space0, char('§'), space0, tag("steps:"), space0))(input)?;
    
    // Parse until closing paren
    let (input, content) = take_until(")")(input)?;
    let (input, _) = char(')')(input)?;
    
    // Extract steps marked with '-'
    let steps: Vec<String> = content
        .lines()
        .filter_map(|line| {
            let line = line.trim();
            if line.starts_with('-') {
                Some(line[1..].trim().to_string())
            } else {
                None
            }
        })
        .collect();
    
    Ok((input, PlanDef {
        name: name.to_string(),
        steps,
    }))
}

fn parse_maplet(input: &str) -> IResult<&str, MapletDef> {
    let (input, _) = tuple((char('('), tag("maplet"), space1))(input)?;
    let (input, name) = identifier(input)?;
    let (input, _) = tuple((space0, char('∷'), space0))(input)?;
    let (input, signature) = take_until(")")(input)?;
    let (input, _) = char(')')(input)?;
    
    Ok((input, MapletDef {
        name: name.to_string(),
        signature: signature.to_string(),
        local_impl: None,
        remote_llm: false,
    }))
}

fn parse_contract(input: &str) -> IResult<&str, ContractDef> {
    let (input, _) = tuple((char('('), char('⊨'), space0))(input)?;
    let (input, name) = take_while1(|c: char| c.is_alphanumeric() || c == '_')(input)?;
    let (input, _) = space0(input)?;
    
    // Simplified contract parsing
    let (input, content) = take_until(")")(input)?;
    let (input, _) = char(')')(input)?;
    
    let mut requires = Vec::new();
    let mut ensures = Vec::new();
    
    // Basic parsing of requires/ensures
    for line in content.lines() {
        let line = line.trim();
        if line.starts_with("requires:") {
            requires.push(line.strip_prefix("requires:").unwrap().trim().to_string());
        } else if line.starts_with("ensures:") {
            ensures.push(line.strip_prefix("ensures:").unwrap().trim().to_string());
        }
    }
    
    Ok((input, ContractDef {
        name: name.to_string(),
        requires,
        ensures,
    }))
}

fn parse_apply(input: &str) -> IResult<&str, ApplyCall> {
    let (input, _) = tuple((char('('), tag("apply"), space0))(input)?;
    let (input, target) = take_while1(|c: char| c.is_alphanumeric() || c == '_')(input)?;
    let (input, _) = tuple((space0, char('▸'), space0))(input)?;
    let (input, args_str) = take_until(")")(input)?;
    let (input, _) = char(')')(input)?;
    
    let args: Vec<String> = args_str
        .split(',')
        .map(|s| s.trim().to_string())
        .collect();
    
    Ok((input, ApplyCall {
        target: target.to_string(),
        args,
    }))
}

fn parse_kind(input: &str) -> IResult<&str, KindDef> {
    let (input, _) = tuple((char('('), tag("kind"), space1))(input)?;
    let (input, name) = identifier(input)?;
    let (input, _) = tuple((space0, char('∷'), space0))(input)?;
    let (input, type_content) = take_until(")")(input)?;
    let (input, _) = char(')')(input)?;
    
    let mut fields = HashMap::new();
    
    // Handle structured types like {field1: Type1, field2: Type2}
    if type_content.trim().starts_with('{') && type_content.trim().ends_with('}') {
        let inner = &type_content.trim()[1..type_content.trim().len()-1];
        for field in inner.split(',') {
            if let Some((key, value)) = field.split_once(':') {
                fields.insert(
                    key.trim().to_string(),
                    value.trim().to_string()
                );
            }
        }
    } else {
        // Simple type
        fields.insert("type".to_string(), type_content.trim().to_string());
    }
    
    Ok((input, KindDef {
        name: name.to_string(),
        fields,
    }))
}

fn parse_datum(input: &str) -> IResult<&str, DatumDef> {
    let (input, _) = tuple((char('('), tag("datum"), space0))(input)?;
    let (input, _) = char('⟦')(input)?;
    let (input, name) = take_until("⟧")(input)?;
    let (input, _) = char('⟧')(input)?;
    let (input, _) = tuple((space0, char('∷'), space0))(input)?;
    let (input, type_name) = take_while1(|c: char| c.is_alphanumeric())(input)?;
    let (input, _) = tuple((space0, char('='), space0))(input)?;
    let (input, value) = take_until(")")(input)?;
    let (input, _) = char(')')(input)?;
    
    Ok((input, DatumDef {
        name: name.to_string(),
        type_name: type_name.to_string(),
        value: value.to_string(),
    }))
}

// Helper parsers
fn identifier(input: &str) -> IResult<&str, &str> {
    recognize(tuple((
        alt((alpha1, tag("_"))),
        many0(alt((alphanumeric1, tag("_"))))
    )))(input)
}

fn parse_role_directive(input: &str) -> IResult<&str, RoleDirective> {
    let (input, _) = tag("@role")(input)?;
    let (input, _) = char('(')(input)?;
    let (input, role_type) = identifier(input)?;
    let (input, _) = char(')')(input)?;
    
    Ok((input, RoleDirective {
        role_type: role_type.to_string(),
    }))
}

fn parse_branch(input: &str) -> IResult<&str, BranchDef> {
    let (input, _) = tuple((char('('), tag("branch"), space1))(input)?;
    let (input, name) = identifier(input)?;
    let (input, _) = tuple((space0, char('⎇'), space0))(input)?;
    
    // Parse branch cases - simplified for now
    let (input, content) = take_until(")")(input)?;
    let (input, _) = char(')')(input)?;
    
    // Basic parsing of when clauses
    let mut cases = Vec::new();
    let mut else_target = None;
    
    for line in content.lines() {
        let line = line.trim();
        if line.starts_with("when") && line.contains("→") {
            if let Some(arrow_pos) = line.find("→") {
                let condition = line[4..line.find(':').unwrap_or(arrow_pos)].trim();
                let target = line[arrow_pos + 1..].trim();
                cases.push(BranchCase {
                    condition: condition.to_string(),
                    target: target.to_string(),
                });
            }
        } else if line.starts_with("else:") && line.contains("→") {
            if let Some(arrow_pos) = line.find("→") {
                else_target = Some(line[arrow_pos + 1..].trim().to_string());
            }
        }
    }
    
    Ok((input, BranchDef {
        name: name.to_string(),
        cases,
        else_target,
    }))
}

fn parse_default(input: &str) -> IResult<&str, DefaultDef> {
    let (input, _) = tuple((char('('), tag("default"), space1))(input)?;
    let (input, name) = identifier(input)?;
    let (input, _) = tuple((space0, char(':'), space0))(input)?;
    let (input, value) = take_until(")")(input)?;
    let (input, _) = char(')')(input)?;
    
    Ok((input, DefaultDef {
        name: name.to_string(),
        value: value.to_string(),
    }))
}

fn parse_test(input: &str) -> IResult<&str, TestDef> {
    let (input, _) = tuple((char('('), tag("test"), space1))(input)?;
    let (input, name) = identifier(input)?;
    let (input, _) = tuple((space0, tag("expects:"), space0))(input)?;
    let (input, outcome) = take_until(")")(input)?;
    let (input, _) = char(')')(input)?;
    
    Ok((input, TestDef {
        name: name.to_string(),
        expected_outcome: outcome.to_string(),
    }))
}

fn parse_agent(input: &str) -> IResult<&str, AgentDef> {
    let (input, _) = tuple((char('('), tag("agent"), space1))(input)?;
    let (input, _) = char('⟦')(input)?;
    let (input, name) = take_until("⟧")(input)?;
    let (input, _) = char('⟧')(input)?;
    let (input, _) = tuple((space0, char('∷'), space0))(input)?;
    let (input, type_expr) = take_while1(|c: char| c.is_alphanumeric() || c == '_')(input)?;
    
    // Parse optional fields
    let (input, content) = take_until(")")(input)?;
    let (input, _) = char(')')(input)?;
    
    let mut capabilities = Vec::new();
    let mut memory_ref = None;
    let mut confidence_calibration = None;
    
    for line in content.lines() {
        let line = line.trim();
        if line.starts_with("capabilities:") {
            let caps_str = line.strip_prefix("capabilities:").unwrap().trim();
            capabilities = caps_str.split(',')
                .map(|s| s.trim().trim_matches('"').to_string())
                .collect();
        } else if line.starts_with("memory:") {
            memory_ref = Some(line.strip_prefix("memory:").unwrap().trim().to_string());
        } else if line.starts_with("confidence_calibration:") {
            if let Ok(val) = line.strip_prefix("confidence_calibration:").unwrap().trim().parse::<f64>() {
                confidence_calibration = Some(val);
            }
        }
    }
    
    Ok((input, AgentDef {
        name: name.to_string(),
        type_expr: type_expr.to_string(),
        capabilities,
        memory_ref,
        confidence_calibration,
    }))
}

fn parse_memory(input: &str) -> IResult<&str, MemoryDef> {
    let (input, _) = tuple((char('('), tag("memory"), space1))(input)?;
    let (input, name) = identifier(input)?;
    let (input, _) = tuple((space0, char('∷'), space0))(input)?;
    let (input, structure) = take_until(")")(input)?;
    let (input, _) = char(')')(input)?;
    
    Ok((input, MemoryDef {
        name: name.to_string(),
        structure: structure.to_string(),
    }))
}

fn parse_confidence(input: &str) -> IResult<&str, ConfidenceDef> {
    let (input, _) = tuple((char('('), tag("confidence"), space1))(input)?;
    let (input, name) = identifier(input)?;
    let (input, _) = tuple((space0, char('∷'), space0))(input)?;
    let (input, structure) = take_until(")")(input)?;
    let (input, _) = char(')')(input)?;
    
    Ok((input, ConfidenceDef {
        name: name.to_string(),
        structure: structure.to_string(),
    }))
}

fn parse_validation(input: &str) -> IResult<&str, ValidationDef> {
    let (input, _) = tuple((char('('), tag("validation"), space1))(input)?;
    let (input, name) = identifier(input)?;
    let (input, _) = tuple((space0, char('∷'), space0))(input)?;
    let (input, structure) = take_until(")")(input)?;
    let (input, _) = char(')')(input)?;
    
    Ok((input, ValidationDef {
        name: name.to_string(),
        structure: structure.to_string(),
    }))
}

fn parse_cue(input: &str) -> IResult<&str, CueDef> {
    let (input, _) = tuple((char('('), tag("cue"), space1))(input)?;
    let (input, name) = identifier(input)?;
    let (input, _) = tuple((space0, char('⊨'), space0, tag("suggests:"), space0))(input)?;
    let (input, suggestion) = take_until(")")(input)?;
    let (input, _) = char(')')(input)?;
    
    Ok((input, CueDef {
        name: name.to_string(),
        suggestion: suggestion.trim_matches('"').to_string(),
    }))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_bare_role_directive() {
        let src = include_str!("../tests/fixtures/valid_role_directive.smars.md");
        let result = SmarsParser::new().parse(src);
        assert!(result.is_ok(), "parser failed: {:?}", result);
    }
}