#!/usr/bin/env python3
"""
SMARS Grammar Parser - PEG-based parser for SMARS DSL validation
Implements Phase 5 of grammar formalization roadmap
"""

import json
import re
from pathlib import Path
from typing import Dict, List, Optional, Union, Any
from dataclasses import dataclass
from enum import Enum

class TokenType(Enum):
    # Literals
    IDENTIFIER = "IDENTIFIER"
    STRING = "STRING"
    NUMBER = "NUMBER"
    BOOLEAN = "BOOLEAN"
    
    # Symbols
    LPAREN = "LPAREN"           # (
    RPAREN = "RPAREN"           # )
    LBRACE = "LBRACE"           # {
    RBRACE = "RBRACE"           # }
    LBRACKET = "LBRACKET"       # [
    RBRACKET = "RBRACKET"       # ]
    COLON = "COLON"             # :
    COMMA = "COMMA"             # ,
    DASH = "DASH"               # -
    
    # SMARS-specific symbols
    TYPE_ANNOTATION = "TYPE_ANNOTATION"     # ∷
    FUNCTION_ARROW = "FUNCTION_ARROW"       # →
    APPLICATION = "APPLICATION"             # ▸
    SECTION_DELIMITER = "SECTION_DELIMITER" # §
    BRANCH_SYMBOL = "BRANCH_SYMBOL"         # ⎇
    ENTAILMENT = "ENTAILMENT"               # ⊨
    AGENT_BRACKETS = "AGENT_BRACKETS"       # ⟦⟧
    
    # Keywords
    KIND = "KIND"
    DATUM = "DATUM"
    CONTRACT = "CONTRACT"
    PLAN = "PLAN"
    BRANCH = "BRANCH"
    AGENT = "AGENT"
    CUE = "CUE"
    MAPLET = "MAPLET"
    APPLY = "APPLY"
    DEFAULT = "DEFAULT"
    TEST = "TEST"
    MEMORY = "MEMORY"
    CONFIDENCE = "CONFIDENCE"
    VALIDATION = "VALIDATION"
    
    # Metadata keywords
    REQUIRES = "REQUIRES"
    ENSURES = "ENSURES"
    STEPS = "STEPS"
    WHEN = "WHEN"
    ELSE = "ELSE"
    SUGGESTS = "SUGGESTS"
    
    # Whitespace and comments
    WHITESPACE = "WHITESPACE"
    COMMENT = "COMMENT"
    EOF = "EOF"

@dataclass
class Token:
    type: TokenType
    value: str
    line: int
    column: int

@dataclass
class ParseError:
    message: str
    line: int
    column: int
    token: Optional[Token] = None

class SMARSLexer:
    """Lexical analyzer for SMARS DSL"""
    
    def __init__(self, text: str):
        self.text = text
        self.pos = 0
        self.line = 1
        self.column = 1
        self.tokens = []
        
    def tokenize(self) -> List[Token]:
        """Tokenize the input text"""
        while self.pos < len(self.text):
            if self._match_whitespace():
                continue
            elif self._match_comment():
                continue
            elif self._match_symbols():
                continue
            elif self._match_keywords():
                continue
            elif self._match_string():
                continue
            elif self._match_number():
                continue
            elif self._match_identifier():
                continue
            else:
                raise ParseError(f"Unexpected character: {self.text[self.pos]}", 
                               self.line, self.column)
        
        self.tokens.append(Token(TokenType.EOF, "", self.line, self.column))
        return self.tokens
    
    def _match_whitespace(self) -> bool:
        """Match whitespace characters"""
        if self.pos >= len(self.text):
            return False
            
        char = self.text[self.pos]
        if char in ' \t\r\n':
            if char == '\n':
                self.line += 1
                self.column = 1
            else:
                self.column += 1
            self.pos += 1
            return True
        return False
    
    def _match_comment(self) -> bool:
        """Match comments (# to end of line)"""
        if self.pos >= len(self.text) or self.text[self.pos] != '#':
            return False
            
        start_pos = self.pos
        while self.pos < len(self.text) and self.text[self.pos] != '\n':
            self.pos += 1
            
        return True
    
    def _match_symbols(self) -> bool:
        """Match SMARS symbols"""
        if self.pos >= len(self.text):
            return False
            
        # Multi-character symbols first
        remaining = self.text[self.pos:]
        
        symbol_map = {
            '∷': TokenType.TYPE_ANNOTATION,
            '→': TokenType.FUNCTION_ARROW,
            '▸': TokenType.APPLICATION,
            '§': TokenType.SECTION_DELIMITER,
            '⎇': TokenType.BRANCH_SYMBOL,
            '⊨': TokenType.ENTAILMENT,
            '⟦': TokenType.AGENT_BRACKETS,
            '⟧': TokenType.AGENT_BRACKETS,
            '(': TokenType.LPAREN,
            ')': TokenType.RPAREN,
            '{': TokenType.LBRACE,
            '}': TokenType.RBRACE,
            '[': TokenType.LBRACKET,
            ']': TokenType.RBRACKET,
            ':': TokenType.COLON,
            ',': TokenType.COMMA,
            '-': TokenType.DASH,
        }
        
        for symbol, token_type in symbol_map.items():
            if remaining.startswith(symbol):
                self.tokens.append(Token(token_type, symbol, self.line, self.column))
                self.pos += len(symbol)
                self.column += len(symbol)
                return True
                
        return False
    
    def _match_keywords(self) -> bool:
        """Match SMARS keywords"""
        if self.pos >= len(self.text):
            return False
            
        # Extract potential keyword
        start = self.pos
        while (self.pos < len(self.text) and 
               (self.text[self.pos].isalnum() or self.text[self.pos] == '_')):
            self.pos += 1
            
        if start == self.pos:
            return False
            
        word = self.text[start:self.pos]
        
        keyword_map = {
            'kind': TokenType.KIND,
            'datum': TokenType.DATUM,
            'contract': TokenType.CONTRACT,
            'plan': TokenType.PLAN,
            'branch': TokenType.BRANCH,
            'agent': TokenType.AGENT,
            'cue': TokenType.CUE,
            'maplet': TokenType.MAPLET,
            'apply': TokenType.APPLY,
            'default': TokenType.DEFAULT,
            'test': TokenType.TEST,
            'memory': TokenType.MEMORY,
            'confidence': TokenType.CONFIDENCE,
            'validation': TokenType.VALIDATION,
            'requires': TokenType.REQUIRES,
            'ensures': TokenType.ENSURES,
            'steps': TokenType.STEPS,
            'when': TokenType.WHEN,
            'else': TokenType.ELSE,
            'suggests': TokenType.SUGGESTS,
        }
        
        if word in keyword_map:
            self.tokens.append(Token(keyword_map[word], word, self.line, self.column - len(word)))
        else:
            # Put back the position for identifier matching
            self.pos = start
            return False
            
        return True
    
    def _match_string(self) -> bool:
        """Match string literals"""
        if self.pos >= len(self.text) or self.text[self.pos] != '"':
            return False
            
        start_pos = self.pos
        start_column = self.column
        self.pos += 1  # Skip opening quote
        self.column += 1
        
        value = ""
        while self.pos < len(self.text) and self.text[self.pos] != '"':
            char = self.text[self.pos]
            if char == '\\' and self.pos + 1 < len(self.text):
                # Handle escape sequences
                next_char = self.text[self.pos + 1]
                if next_char in '"\\nrt':
                    escape_map = {'n': '\n', 'r': '\r', 't': '\t', '\\': '\\', '"': '"'}
                    value += escape_map.get(next_char, next_char)
                    self.pos += 2
                    self.column += 2
                else:
                    value += char
                    self.pos += 1
                    self.column += 1
            else:
                value += char
                self.pos += 1
                if char == '\n':
                    self.line += 1
                    self.column = 1
                else:
                    self.column += 1
                    
        if self.pos >= len(self.text):
            raise ParseError("Unterminated string literal", self.line, start_column)
            
        self.pos += 1  # Skip closing quote
        self.column += 1
        
        self.tokens.append(Token(TokenType.STRING, value, self.line, start_column))
        return True
    
    def _match_number(self) -> bool:
        """Match numeric literals"""
        if self.pos >= len(self.text):
            return False
            
        start = self.pos
        start_column = self.column
        
        # Handle optional sign
        if self.text[self.pos] in '+-':
            self.pos += 1
            self.column += 1
            
        # Match digits
        if not (self.pos < len(self.text) and self.text[self.pos].isdigit()):
            self.pos = start
            self.column = start_column
            return False
            
        while self.pos < len(self.text) and self.text[self.pos].isdigit():
            self.pos += 1
            self.column += 1
            
        # Handle decimal point
        if (self.pos < len(self.text) and self.text[self.pos] == '.' and
            self.pos + 1 < len(self.text) and self.text[self.pos + 1].isdigit()):
            self.pos += 1
            self.column += 1
            while self.pos < len(self.text) and self.text[self.pos].isdigit():
                self.pos += 1
                self.column += 1
                
        # Handle scientific notation
        if (self.pos < len(self.text) and self.text[self.pos].lower() == 'e'):
            self.pos += 1
            self.column += 1
            if self.pos < len(self.text) and self.text[self.pos] in '+-':
                self.pos += 1
                self.column += 1
            if not (self.pos < len(self.text) and self.text[self.pos].isdigit()):
                raise ParseError("Invalid scientific notation", self.line, self.column)
            while self.pos < len(self.text) and self.text[self.pos].isdigit():
                self.pos += 1
                self.column += 1
                
        value = self.text[start:self.pos]
        self.tokens.append(Token(TokenType.NUMBER, value, self.line, start_column))
        return True
    
    def _match_identifier(self) -> bool:
        """Match identifiers"""
        if self.pos >= len(self.text):
            return False
            
        start = self.pos
        start_column = self.column
        
        # First character must be letter or underscore
        if not (self.text[self.pos].isalpha() or self.text[self.pos] == '_'):
            return False
            
        while (self.pos < len(self.text) and 
               (self.text[self.pos].isalnum() or self.text[self.pos] == '_')):
            self.pos += 1
            self.column += 1
            
        value = self.text[start:self.pos]
        self.tokens.append(Token(TokenType.IDENTIFIER, value, self.line, start_column))
        return True

class SMARSParser:
    """PEG-based parser for SMARS DSL"""
    
    def __init__(self, tokens: List[Token]):
        self.tokens = tokens
        self.pos = 0
        self.errors = []
        
    def parse(self) -> Optional[Dict[str, Any]]:
        """Parse the token stream into an AST"""
        try:
            return self._parse_smars_file()
        except ParseError as e:
            self.errors.append(e)
            return None
    
    def _current_token(self) -> Token:
        """Get current token"""
        if self.pos >= len(self.tokens):
            return self.tokens[-1]  # EOF token
        return self.tokens[self.pos]
    
    def _peek_token(self, offset: int = 1) -> Token:
        """Peek at future token"""
        pos = self.pos + offset
        if pos >= len(self.tokens):
            return self.tokens[-1]  # EOF token
        return self.tokens[pos]
    
    def _consume_token(self, expected_type: Optional[TokenType] = None) -> Token:
        """Consume and return current token"""
        token = self._current_token()
        if expected_type and token.type != expected_type:
            raise ParseError(f"Expected {expected_type}, got {token.type}", 
                           token.line, token.column, token)
        self.pos += 1
        return token
    
    def _parse_smars_file(self) -> Dict[str, Any]:
        """Parse a complete SMARS file"""
        declarations = []
        
        # Skip any leading role declarations for now
        while self._current_token().type != TokenType.EOF:
            if self._current_token().type == TokenType.LPAREN:
                decl = self._parse_declaration()
                if decl:
                    declarations.append(decl)
            else:
                self.pos += 1  # Skip unexpected tokens
                
        return {"declarations": declarations, "errors": self.errors}
    
    def _parse_declaration(self) -> Optional[Dict[str, Any]]:
        """Parse any SMARS declaration"""
        if self._current_token().type != TokenType.LPAREN:
            return None
            
        self._consume_token(TokenType.LPAREN)
        
        decl_type_token = self._current_token()
        
        parsers = {
            TokenType.KIND: self._parse_kind_declaration,
            TokenType.DATUM: self._parse_datum_declaration,
            TokenType.CONTRACT: self._parse_contract_declaration,
            TokenType.PLAN: self._parse_plan_declaration,
            TokenType.BRANCH: self._parse_branch_declaration,
            TokenType.AGENT: self._parse_agent_declaration,
            TokenType.CUE: self._parse_cue_declaration,
            TokenType.MAPLET: self._parse_maplet_declaration,
            TokenType.APPLY: self._parse_apply_declaration,
            TokenType.DEFAULT: self._parse_default_declaration,
            TokenType.TEST: self._parse_test_declaration,
            TokenType.MEMORY: self._parse_memory_declaration,
            TokenType.CONFIDENCE: self._parse_confidence_declaration,
            TokenType.VALIDATION: self._parse_validation_declaration,
        }
        
        parser = parsers.get(decl_type_token.type)
        if parser:
            return parser()
        else:
            self.errors.append(ParseError(f"Unknown declaration type: {decl_type_token.value}",
                                        decl_type_token.line, decl_type_token.column))
            return None
    
    def _parse_kind_declaration(self) -> Dict[str, Any]:
        """Parse kind declaration: (kind IDENTIFIER fields)"""
        self._consume_token(TokenType.KIND)
        name = self._consume_token(TokenType.IDENTIFIER)
        
        fields = []
        while (self._current_token().type != TokenType.RPAREN and 
               self._current_token().type != TokenType.EOF):
            if self._current_token().type == TokenType.IDENTIFIER:
                field_name = self._consume_token(TokenType.IDENTIFIER)
                if self._current_token().type == TokenType.TYPE_ANNOTATION:
                    self._consume_token(TokenType.TYPE_ANNOTATION)
                    field_type = self._consume_token(TokenType.IDENTIFIER)
                    fields.append({"name": field_name.value, "type": field_type.value})
                else:
                    fields.append({"name": field_name.value})
            else:
                self.pos += 1
                
        self._consume_token(TokenType.RPAREN)
        
        return {
            "type": "kind",
            "name": name.value,
            "fields": fields,
            "line": name.line
        }
    
    def _parse_datum_declaration(self) -> Dict[str, Any]:
        """Parse datum declaration: (datum IDENTIFIER ⟦value⟧)"""
        self._consume_token(TokenType.DATUM)
        name = self._consume_token(TokenType.IDENTIFIER)
        
        # Look for value brackets
        value = None
        if self._current_token().type == TokenType.AGENT_BRACKETS:  # Using same token for ⟦
            self._consume_token(TokenType.AGENT_BRACKETS)
            # Parse value - could be string, number, identifier, etc.
            value_token = self._current_token()
            if value_token.type in [TokenType.STRING, TokenType.NUMBER, TokenType.IDENTIFIER]:
                value = self._consume_token().value
            self._consume_token(TokenType.AGENT_BRACKETS)  # Closing ⟧
            
        self._consume_token(TokenType.RPAREN)
        
        return {
            "type": "datum",
            "name": name.value,
            "value": value,
            "line": name.line
        }
    
    def _parse_contract_declaration(self) -> Dict[str, Any]:
        """Parse contract declaration with requires/ensures clauses"""
        self._consume_token(TokenType.CONTRACT)
        name = self._consume_token(TokenType.IDENTIFIER)
        
        requires_clauses = []
        ensures_clauses = []
        
        while (self._current_token().type != TokenType.RPAREN and 
               self._current_token().type != TokenType.EOF):
            if self._current_token().type == TokenType.ENTAILMENT:
                self._consume_token(TokenType.ENTAILMENT)
                if self._current_token().type == TokenType.REQUIRES:
                    self._consume_token(TokenType.REQUIRES)
                    self._consume_token(TokenType.COLON)
                    # Parse condition - simplified for now
                    condition = self._parse_condition()
                    requires_clauses.append(condition)
                elif self._current_token().type == TokenType.ENSURES:
                    self._consume_token(TokenType.ENSURES)
                    self._consume_token(TokenType.COLON)
                    condition = self._parse_condition()
                    ensures_clauses.append(condition)
            else:
                self.pos += 1
                
        self._consume_token(TokenType.RPAREN)
        
        return {
            "type": "contract",
            "name": name.value,
            "requires": requires_clauses,
            "ensures": ensures_clauses,
            "line": name.line
        }
    
    def _parse_condition(self) -> str:
        """Parse a condition expression (simplified)"""
        condition_parts = []
        while (self._current_token().type not in [TokenType.ENTAILMENT, TokenType.RPAREN, TokenType.EOF] and
               self._current_token().type not in [TokenType.REQUIRES, TokenType.ENSURES]):
            condition_parts.append(self._current_token().value)
            self.pos += 1
        return " ".join(condition_parts)
    
    def _parse_plan_declaration(self) -> Dict[str, Any]:
        """Parse plan declaration with steps"""
        self._consume_token(TokenType.PLAN)
        name = self._consume_token(TokenType.IDENTIFIER)
        
        # Skip metadata for now
        steps = []
        
        # Look for section delimiter and steps
        if self._current_token().type == TokenType.SECTION_DELIMITER:
            self._consume_token(TokenType.SECTION_DELIMITER)
            if self._current_token().type == TokenType.STEPS:
                self._consume_token(TokenType.STEPS)
                self._consume_token(TokenType.COLON)
                
                # Parse steps list
                while (self._current_token().type != TokenType.RPAREN and 
                       self._current_token().type != TokenType.EOF):
                    if self._current_token().type == TokenType.DASH:
                        self._consume_token(TokenType.DASH)
                        step_token = self._current_token()
                        if step_token.type == TokenType.IDENTIFIER:
                            steps.append(self._consume_token().value)
                    else:
                        self.pos += 1
                        
        self._consume_token(TokenType.RPAREN)
        
        return {
            "type": "plan",
            "name": name.value,
            "steps": steps,
            "line": name.line
        }
    
    # Simplified parsers for other declaration types
    def _parse_branch_declaration(self) -> Dict[str, Any]:
        """Parse branch declaration (simplified)"""
        self._consume_token(TokenType.BRANCH)
        name = self._consume_token(TokenType.IDENTIFIER)
        
        # Skip to end for now
        while (self._current_token().type != TokenType.RPAREN and 
               self._current_token().type != TokenType.EOF):
            self.pos += 1
            
        self._consume_token(TokenType.RPAREN)
        
        return {"type": "branch", "name": name.value, "line": name.line}
    
    def _parse_agent_declaration(self) -> Dict[str, Any]:
        """Parse agent declaration (simplified)"""
        self._consume_token(TokenType.AGENT)
        
        # Look for agent brackets ⟦name⟧
        if self._current_token().type == TokenType.AGENT_BRACKETS:
            self._consume_token(TokenType.AGENT_BRACKETS)
            name = self._consume_token(TokenType.IDENTIFIER)
            self._consume_token(TokenType.AGENT_BRACKETS)
        else:
            name = self._consume_token(TokenType.IDENTIFIER)
            
        # Skip to end
        while (self._current_token().type != TokenType.RPAREN and 
               self._current_token().type != TokenType.EOF):
            self.pos += 1
            
        self._consume_token(TokenType.RPAREN)
        
        return {"type": "agent", "name": name.value, "line": name.line}
    
    def _parse_cue_declaration(self) -> Dict[str, Any]:
        """Parse cue declaration (simplified)"""
        self._consume_token(TokenType.CUE)
        name = self._consume_token(TokenType.IDENTIFIER)
        
        # Skip to end
        while (self._current_token().type != TokenType.RPAREN and 
               self._current_token().type != TokenType.EOF):
            self.pos += 1
            
        self._consume_token(TokenType.RPAREN)
        
        return {"type": "cue", "name": name.value, "line": name.line}
    
    def _parse_maplet_declaration(self) -> Dict[str, Any]:
        """Parse maplet declaration (simplified)"""
        self._consume_token(TokenType.MAPLET)
        name = self._consume_token(TokenType.IDENTIFIER)
        
        # Skip to end
        while (self._current_token().type != TokenType.RPAREN and 
               self._current_token().type != TokenType.EOF):
            self.pos += 1
            
        self._consume_token(TokenType.RPAREN)
        
        return {"type": "maplet", "name": name.value, "line": name.line}
    
    def _parse_apply_declaration(self) -> Dict[str, Any]:
        """Parse apply declaration (simplified)"""
        self._consume_token(TokenType.APPLY)
        name = self._consume_token(TokenType.IDENTIFIER)
        
        # Skip to end
        while (self._current_token().type != TokenType.RPAREN and 
               self._current_token().type != TokenType.EOF):
            self.pos += 1
            
        self._consume_token(TokenType.RPAREN)
        
        return {"type": "apply", "name": name.value, "line": name.line}
    
    def _parse_default_declaration(self) -> Dict[str, Any]:
        """Parse default declaration (simplified)"""
        self._consume_token(TokenType.DEFAULT)
        name = self._consume_token(TokenType.IDENTIFIER)
        
        # Skip to end
        while (self._current_token().type != TokenType.RPAREN and 
               self._current_token().type != TokenType.EOF):
            self.pos += 1
            
        self._consume_token(TokenType.RPAREN)
        
        return {"type": "default", "name": name.value, "line": name.line}
    
    def _parse_test_declaration(self) -> Dict[str, Any]:
        """Parse test declaration (simplified)"""
        self._consume_token(TokenType.TEST)
        name = self._consume_token(TokenType.IDENTIFIER)
        
        # Skip to end
        while (self._current_token().type != TokenType.RPAREN and 
               self._current_token().type != TokenType.EOF):
            self.pos += 1
            
        self._consume_token(TokenType.RPAREN)
        
        return {"type": "test", "name": name.value, "line": name.line}
    
    def _parse_memory_declaration(self) -> Dict[str, Any]:
        """Parse memory declaration (simplified)"""
        self._consume_token(TokenType.MEMORY)
        name = self._consume_token(TokenType.IDENTIFIER)
        
        # Skip to end
        while (self._current_token().type != TokenType.RPAREN and 
               self._current_token().type != TokenType.EOF):
            self.pos += 1
            
        self._consume_token(TokenType.RPAREN)
        
        return {"type": "memory", "name": name.value, "line": name.line}
    
    def _parse_confidence_declaration(self) -> Dict[str, Any]:
        """Parse confidence declaration (simplified)"""
        self._consume_token(TokenType.CONFIDENCE)
        name = self._consume_token(TokenType.IDENTIFIER)
        
        # Skip to end
        while (self._current_token().type != TokenType.RPAREN and 
               self._current_token().type != TokenType.EOF):
            self.pos += 1
            
        self._consume_token(TokenType.RPAREN)
        
        return {"type": "confidence", "name": name.value, "line": name.line}
    
    def _parse_validation_declaration(self) -> Dict[str, Any]:
        """Parse validation declaration (simplified)"""
        self._consume_token(TokenType.VALIDATION)
        name = self._consume_token(TokenType.IDENTIFIER)
        
        # Skip to end
        while (self._current_token().type != TokenType.RPAREN and 
               self._current_token().type != TokenType.EOF):
            self.pos += 1
            
        self._consume_token(TokenType.RPAREN)
        
        return {"type": "validation", "name": name.value, "line": name.line}

def validate_test_corpus():
    """Validate all test corpus files against the parser"""
    test_corpus_dir = Path("grammar/test-corpus")
    results = {"passed": 0, "failed": 0, "details": []}
    
    for test_file in test_corpus_dir.glob("*.json"):
        print(f"\nValidating {test_file.name}...")
        
        with open(test_file, 'r') as f:
            test_data = json.load(f)
            
        declaration_type = test_data["declaration_type"]
        
        # Test valid samples
        for sample in test_data["valid_samples"]:
            try:
                lexer = SMARSLexer(sample["code"])
                tokens = lexer.tokenize()
                parser = SMARSParser(tokens)
                ast = parser.parse()
                
                if ast and not parser.errors:
                    results["passed"] += 1
                    results["details"].append({
                        "file": test_file.name,
                        "sample_id": sample["id"],
                        "status": "PASS",
                        "type": "valid"
                    })
                else:
                    results["failed"] += 1
                    results["details"].append({
                        "file": test_file.name,
                        "sample_id": sample["id"],
                        "status": "FAIL",
                        "type": "valid",
                        "errors": [err.message for err in parser.errors],
                        "code": sample["code"]
                    })
                    
            except Exception as e:
                results["failed"] += 1
                results["details"].append({
                    "file": test_file.name,
                    "sample_id": sample["id"],
                    "status": "ERROR",
                    "type": "valid",
                    "error": str(e),
                    "code": sample["code"]
                })
        
        # Test invalid samples - these should fail parsing
        for sample in test_data["invalid_samples"]:
            try:
                lexer = SMARSLexer(sample["code"])
                tokens = lexer.tokenize()
                parser = SMARSParser(tokens)
                ast = parser.parse()
                
                if parser.errors or not ast:
                    results["passed"] += 1
                    results["details"].append({
                        "file": test_file.name,
                        "sample_id": sample["id"],
                        "status": "PASS",
                        "type": "invalid",
                        "expected_error": sample["error_type"]
                    })
                else:
                    results["failed"] += 1
                    results["details"].append({
                        "file": test_file.name,
                        "sample_id": sample["id"],
                        "status": "FAIL",
                        "type": "invalid",
                        "expected_error": sample["error_type"],
                        "message": "Should have failed but parsed successfully",
                        "code": sample["code"]
                    })
                    
            except Exception as e:
                # Exceptions are expected for invalid samples
                results["passed"] += 1
                results["details"].append({
                    "file": test_file.name,
                    "sample_id": sample["id"],
                    "status": "PASS",
                    "type": "invalid",
                    "expected_error": sample["error_type"],
                    "actual_error": str(e)
                })
    
    return results

def validate_smars_files():
    """Validate existing .smars.md files in the spec directory"""
    spec_files = Path("spec").rglob("*.smars.md")
    results = {"parsed": 0, "failed": 0, "details": []}
    
    for spec_file in spec_files:
        print(f"\nParsing {spec_file}...")
        
        try:
            with open(spec_file, 'r') as f:
                content = f.read()
            
            # Extract SMARS declarations from markdown
            smars_blocks = extract_smars_from_markdown(content)
            
            for i, block in enumerate(smars_blocks):
                try:
                    lexer = SMARSLexer(block)
                    tokens = lexer.tokenize()
                    parser = SMARSParser(tokens)
                    ast = parser.parse()
                    
                    if ast and not parser.errors:
                        results["parsed"] += 1
                        results["details"].append({
                            "file": str(spec_file),
                            "block": i,
                            "status": "PARSED",
                            "declarations": len(ast["declarations"])
                        })
                    else:
                        results["failed"] += 1
                        results["details"].append({
                            "file": str(spec_file),
                            "block": i,
                            "status": "FAILED",
                            "errors": [err.message for err in parser.errors],
                            "content": block[:200] + "..." if len(block) > 200 else block
                        })
                        
                except Exception as e:
                    results["failed"] += 1
                    results["details"].append({
                        "file": str(spec_file),
                        "block": i,
                        "status": "ERROR",
                        "error": str(e),
                        "content": block[:200] + "..." if len(block) > 200 else block
                    })
                    
        except Exception as e:
            results["failed"] += 1
            results["details"].append({
                "file": str(spec_file),
                "status": "FILE_ERROR",
                "error": str(e)
            })
    
    return results

def extract_smars_from_markdown(content: str) -> List[str]:
    """Extract SMARS code blocks from markdown content"""
    # Look for SMARS declarations that start with '(' and contain keywords
    smars_keywords = ['kind', 'datum', 'contract', 'plan', 'branch', 'agent', 'cue', 
                     'maplet', 'apply', 'default', 'test', 'memory', 'confidence', 'validation']
    
    blocks = []
    lines = content.split('\n')
    current_block = []
    in_smars = False
    paren_count = 0
    
    for line in lines:
        stripped = line.strip()
        
        # Start of potential SMARS block
        if stripped.startswith('(') and any(keyword in stripped for keyword in smars_keywords):
            if current_block:
                blocks.append('\n'.join(current_block))
            current_block = [line]
            in_smars = True
            paren_count = stripped.count('(') - stripped.count(')')
        elif in_smars:
            current_block.append(line)
            paren_count += stripped.count('(') - stripped.count(')')
            
            # End of SMARS block when parentheses are balanced
            if paren_count <= 0:
                blocks.append('\n'.join(current_block))
                current_block = []
                in_smars = False
                paren_count = 0
    
    # Add final block if exists
    if current_block:
        blocks.append('\n'.join(current_block))
    
    return blocks

if __name__ == "__main__":
    print("SMARS Grammar Parser - Phase 5 Validation")
    print("=" * 50)
    
    # Validate test corpus
    print("\n1. Validating JSON test corpus...")
    corpus_results = validate_test_corpus()
    
    print(f"\nTest Corpus Results:")
    print(f"Passed: {corpus_results['passed']}")
    print(f"Failed: {corpus_results['failed']}")
    print(f"Success Rate: {corpus_results['passed'] / (corpus_results['passed'] + corpus_results['failed']) * 100:.1f}%")
    
    # Show failures
    failures = [d for d in corpus_results['details'] if d['status'] in ['FAIL', 'ERROR']]
    if failures:
        print(f"\nFirst 5 failures:")
        for failure in failures[:5]:
            print(f"  - {failure['file']}:{failure['sample_id']} ({failure['status']})")
            if 'error' in failure:
                print(f"    Error: {failure['error']}")
            elif 'errors' in failure:
                print(f"    Errors: {failure['errors']}")
    
    # Validate existing SMARS files
    print("\n2. Validating existing .smars.md files...")
    smars_results = validate_smars_files()
    
    print(f"\nSMARS Files Results:")
    print(f"Parsed: {smars_results['parsed']}")
    print(f"Failed: {smars_results['failed']}")
    if smars_results['parsed'] + smars_results['failed'] > 0:
        print(f"Success Rate: {smars_results['parsed'] / (smars_results['parsed'] + smars_results['failed']) * 100:.1f}%")
    
    # Show sample parsing results
    print(f"\nSample parsing results:")
    for detail in smars_results['details'][:10]:
        print(f"  - {detail['file']}: {detail['status']}")
        if detail['status'] == 'PARSED':
            print(f"    Declarations: {detail.get('declarations', 'N/A')}")
        elif 'error' in detail:
            print(f"    Error: {detail['error']}")
    
    print(f"\nPhase 5 validation complete.")