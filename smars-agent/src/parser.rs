use anyhow::{Result, anyhow};
use nom::{
    IResult,
    bytes::complete::{tag, take_until, take_while1},
    character::complete::{char, multispace0, alphanumeric1, space0},
    combinator::{map, opt},
    multi::{many0, separated_list0},
    sequence::{delimited, preceded, tuple},
    branch::alt,
};
use serde::{Deserialize, Serialize};
use std::collections::HashMap;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum SmarsNode {
    Plan(PlanDef),
    Maplet(MapletDef),
    Contract(ContractDef),
    Apply(ApplyCall),
    Kind(KindDef),
    Datum(DatumDef),
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
        
        Err(anyhow!("Failed to parse line: {}", line))
    }
}

// Nom parsers for each SMARS construct

fn parse_plan(input: &str) -> IResult<&str, PlanDef> {
    let (input, _) = tuple((char('('), char('§'), space0))(input)?;
    let (input, name) = take_while1(|c: char| c.is_alphanumeric() || c == '_')(input)?;
    let (input, _) = tuple((space0, tag("steps:"), space0))(input)?;
    
    // Simplified: just extract the remaining content as steps
    let (input, steps_str) = take_until(")")(input)?;
    let steps: Vec<String> = steps_str
        .split('-')
        .filter(|s| !s.trim().is_empty())
        .map(|s| s.trim().to_string())
        .collect();
    
    let (input, _) = char(')')(input)?;
    
    Ok((input, PlanDef {
        name: name.to_string(),
        steps,
    }))
}

fn parse_maplet(input: &str) -> IResult<&str, MapletDef> {
    let (input, _) = tuple((char('('), char('ƒ'), space0))(input)?;
    let (input, name) = take_while1(|c: char| c.is_alphanumeric() || c == '_')(input)?;
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
    let (input, _) = tuple((char('('), char('∷'), space0))(input)?;
    let (input, name) = take_while1(|c: char| c.is_alphanumeric() || c == '_')(input)?;
    let (input, _) = tuple((space0, char('{'), space0))(input)?;
    let (input, fields_str) = take_until("}")(input)?;
    let (input, _) = tuple((char('}'), char(')')))(input)?;
    
    let mut fields = HashMap::new();
    for field in fields_str.split(',') {
        if let Some((key, value)) = field.split_once(':') {
            fields.insert(
                key.trim().to_string(),
                value.trim().to_string()
            );
        }
    }
    
    Ok((input, KindDef {
        name: name.to_string(),
        fields,
    }))
}

fn parse_datum(input: &str) -> IResult<&str, DatumDef> {
    let (input, _) = tuple((char('('), char('•'), space0))(input)?;
    let (input, _) = tuple((char('⟦'), take_until("⟧"), char('⟧'), space0))(input)?;
    let (input, name) = take_while1(|c: char| c.is_alphanumeric() || c == '_')(input)?;
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