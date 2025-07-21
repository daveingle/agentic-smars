# SMARS Lexical Layer Specification (v1.0)

**Comprehensive lexical foundation for SMARS DSL parsing**

## Overview

This specification defines the complete lexical layer for SMARS, including whitespace handling, comment syntax, escape sequences, Unicode support, and numeric formats with scientific notation.

## Lexical Grammar (EBNF)

```ebnf
(* ========== WHITESPACE AND LAYOUT ========== *)
whitespace     = space | tab | newline | carriage_return ;
space          = U+0020 ;
tab            = U+0009 ;
newline        = U+000A ;
carriage_return = U+000D ;
line_ending    = newline | carriage_return newline | carriage_return ;

layout         = { whitespace | comment } ;

(* ========== COMMENTS ========== *)
comment        = line_comment | block_comment ;
line_comment   = "//" { any_char - line_ending } line_ending ;
block_comment  = "/*" { any_char - "*/" } "*/" ;

(* Note: Comments can be nested *)
block_comment  = "/*" { any_char - "*/" | nested_block_comment } "*/" ;
nested_block_comment = "/*" { any_char - "*/" | nested_block_comment } "*/" ;

(* ========== STRING LITERALS ========== *)
STRING         = '"' { string_char } '"' ;
string_char    = escape_sequence | unicode_char | (any_char - '"' - '\\') ;

escape_sequence = simple_escape | unicode_escape | hex_escape ;
simple_escape  = '\\' ( '"' | '\\' | '/' | 'b' | 'f' | 'n' | 'r' | 't' ) ;
unicode_escape = '\\' 'u' hex_digit hex_digit hex_digit hex_digit ;
hex_escape     = '\\' 'x' hex_digit hex_digit ;

(* ========== UNICODE SUPPORT ========== *)
unicode_char   = U+0000..U+10FFFF - ( U+0000..U+001F | U+007F..U+009F ) ;
identifier_start = letter | unicode_id_start ;
identifier_continue = letter | digit | '_' | unicode_id_continue ;

unicode_id_start = U+00AA | U+00B5 | U+00BA | U+00C0..U+00D6 | U+00D8..U+00F6 | 
                   U+00F8..U+02C1 | U+02C6..U+02D1 | U+02E0..U+02E4 | U+02EC | 
                   U+02EE | U+0370..U+0374 | U+0376..U+0377 | U+037A..U+037D ;

unicode_id_continue = unicode_id_start | U+0030..U+0039 | U+005F | U+00B7 | 
                      U+0300..U+036F | U+203F..U+2040 ;

(* ========== IDENTIFIERS ========== *)
IDENTIFIER     = identifier_start { identifier_continue } ;
letter         = 'A'..'Z' | 'a'..'z' ;
digit          = '0'..'9' ;

(* Reserved words that cannot be used as identifiers *)
reserved_word  = "kind" | "datum" | "maplet" | "apply" | "contract" | "plan" | 
                 "branch" | "default" | "test" | "agent" | "memory" | 
                 "confidence" | "validation" | "cue" | "when" | "else" | 
                 "requires" | "ensures" | "expects" | "steps" | "suggests" |
                 "capabilities" | "uncertainty_sources" | "confidence_calibration" ;

(* ========== NUMERIC LITERALS ========== *)
number         = integer | float ;

integer        = decimal_int | hex_int | octal_int | binary_int ;
decimal_int    = [ sign ] non_zero_digit { digit | '_' } | '0' ;
hex_int        = [ sign ] '0' ( 'x' | 'X' ) hex_digit { hex_digit | '_' } ;
octal_int      = [ sign ] '0' ( 'o' | 'O' ) octal_digit { octal_digit | '_' } ;
binary_int     = [ sign ] '0' ( 'b' | 'B' ) binary_digit { binary_digit | '_' } ;

float          = decimal_float | hex_float ;
decimal_float  = [ sign ] ( 
                   digit { digit | '_' } '.' digit { digit | '_' } [ exponent ] |
                   digit { digit | '_' } exponent |
                   '.' digit { digit | '_' } [ exponent ]
                 ) ;
hex_float      = [ sign ] '0' ( 'x' | 'X' ) hex_significand [ binary_exponent ] ;

hex_significand = hex_digit { hex_digit | '_' } '.' hex_digit { hex_digit | '_' } |
                  hex_digit { hex_digit | '_' } |
                  '.' hex_digit { hex_digit | '_' } ;

exponent       = ( 'e' | 'E' ) [ sign ] digit { digit | '_' } ;
binary_exponent = ( 'p' | 'P' ) [ sign ] digit { digit | '_' } ;

sign           = '+' | '-' ;
non_zero_digit = '1'..'9' ;
hex_digit      = digit | 'A'..'F' | 'a'..'f' ;
octal_digit    = '0'..'7' ;
binary_digit   = '0' | '1' ;

(* ========== SPECIAL SYMBOLS ========== *)
symbol         = single_char_symbol | multi_char_symbol | unicode_symbol ;

single_char_symbol = '(' | ')' | '{' | '}' | '[' | ']' | ',' | ':' | '=' | 
                     '<' | '>' | '!' | '?' | '+' | '-' | '*' | '/' | '%' |
                     '&' | '|' | '^' | '~' | '@' | '#' | '$' ;

multi_char_symbol = "∷" | "→" | "≠" | "≤" | "≥" | "∧" | "∨" | "¬" | "::" | 
                    "->" | "!=" | "<=" | ">=" | "&&" | "||" | "==" ;

unicode_symbol = "⟦" | "⟧" | "▸" | "§" | "⎇" | "⊨" ;

(* ========== TOKEN DEFINITIONS ========== *)
token          = IDENTIFIER | STRING | number | symbol | reserved_word ;

(* ========== LEXICAL RULES ========== *)
(* Longest match rule: prefer longer tokens when multiple matches possible *)
(* Case sensitivity: SMARS is case-sensitive *)
(* Normalization: Unicode identifiers normalized to NFC form *)

any_char       = U+0000..U+10FFFF ;
```

## Whitespace Handling Rules

### 1. Whitespace Characters
- **Space** (U+0020): Standard ASCII space
- **Tab** (U+0009): Horizontal tab, equivalent to spaces for indentation
- **Newline** (U+000A): Line feed, primary line terminator
- **Carriage Return** (U+000D): Carriage return, handled in CRLF sequences

### 2. Layout Sensitivity
- **Layout-insensitive**: Whitespace between tokens is ignored
- **Line endings**: Significant for line comments, otherwise ignored
- **Indentation**: Not syntactically significant in SMARS

### 3. Normalization
- **Unicode normalization**: All input normalized to NFC (Canonical Decomposition followed by Canonical Composition)
- **Line ending normalization**: All line endings converted to LF (U+000A)

## Comment Syntax

### 1. Line Comments
```smars
// This is a line comment
(kind User ∷ { name: STRING }) // End-of-line comment
```

### 2. Block Comments
```smars
/* This is a block comment */
/* This is a
   multi-line
   block comment */
```

### 3. Nested Block Comments
```smars
/* Outer comment
   /* Nested comment */
   Still in outer comment
*/
```

### 4. Documentation Comments
```smars
/// Documentation comment for the following declaration
(kind User ∷ { name: STRING, email: STRING })

/** 
 * Multi-line documentation comment
 * Provides detailed documentation
 */
(contract user_validation ⊨ requires: valid_email = true)
```

## Escape Sequences

### 1. Simple Escapes
| Sequence | Meaning | Unicode |
|----------|---------|---------|
| `\"` | Quotation mark | U+0022 |
| `\\` | Backslash | U+005C |
| `\/` | Solidus (forward slash) | U+002F |
| `\b` | Backspace | U+0008 |
| `\f` | Form feed | U+000C |
| `\n` | Line feed | U+000A |
| `\r` | Carriage return | U+000D |
| `\t` | Horizontal tab | U+0009 |

### 2. Unicode Escapes
- **4-digit Unicode**: `\uXXXX` (e.g., `\u03B1` for α)
- **Hex escapes**: `\xXX` (e.g., `\x41` for A)

### 3. Examples
```smars
(datum ⟦greeting⟧ ∷ STRING = "Hello, \"World\"!\n")
(datum ⟦unicode_text⟧ ∷ STRING = "Greek letter alpha: \u03B1")
(datum ⟦tab_separated⟧ ∷ STRING = "Name\tEmail\tAge")
```

## Unicode Support

### 1. Character Encoding
- **UTF-8**: Primary encoding for SMARS source files
- **UTF-16/UTF-32**: Accepted with BOM detection
- **ASCII**: Subset of UTF-8, fully supported

### 2. Identifier Characters
- **Start characters**: Letters, underscore, Unicode identifier start characters
- **Continue characters**: Letters, digits, underscore, Unicode identifier continue characters
- **Normalization**: All identifiers normalized to NFC form

### 3. String Content
- **Full Unicode**: All valid Unicode code points except control characters
- **Normalization**: String content preserved without normalization
- **Encoding**: Internal representation as UTF-8

### 4. Examples
```smars
(kind Ψυχή ∷ { 意味: STRING })  // Greek and Japanese identifiers
(datum ⟦émoji⟧ ∷ STRING = "🚀 Rocket launch! 🌟")
```

## Numeric Formats

### 1. Integer Formats
```smars
(datum ⟦decimal⟧ ∷ INTEGER = 42)
(datum ⟦hex⟧ ∷ INTEGER = 0xFF)
(datum ⟦octal⟧ ∷ INTEGER = 0o755)  
(datum ⟦binary⟧ ∷ INTEGER = 0b1010)
(datum ⟦large_number⟧ ∷ INTEGER = 1_000_000)
```

### 2. Floating Point Formats
```smars
(datum ⟦simple_float⟧ ∷ FLOAT = 3.14159)
(datum ⟦scientific⟧ ∷ FLOAT = 6.022e23)
(datum ⟦negative_exp⟧ ∷ FLOAT = 1.5e-10)
(datum ⟦hex_float⟧ ∷ FLOAT = 0x1.fp3)
```

### 3. Signs and Exponents
- **Positive sign**: Optional `+` prefix
- **Negative sign**: Required `-` prefix for negative numbers
- **Scientific notation**: `e` or `E` followed by optional sign and digits
- **Binary exponents**: `p` or `P` for hexadecimal floats

### 4. Underscores in Numbers
- **Digit separators**: Underscores allowed between digits for readability
- **Not significant**: Underscores ignored during parsing
- **Placement rules**: Cannot start or end with underscore, cannot be adjacent

## Lexical Error Handling

### 1. Invalid Characters
- **Unknown Unicode**: Characters not in allowed Unicode ranges
- **Invalid escapes**: Unrecognized escape sequences in strings
- **Malformed numbers**: Invalid digit sequences or formats

### 2. Error Recovery
- **Skip invalid characters**: Continue parsing after error
- **Report position**: Line and column information for errors
- **Helpful messages**: Suggest corrections for common mistakes

### 3. Reserved Word Conflicts
- **Context sensitivity**: Some reserved words allowed as field names
- **Error reporting**: Clear messages when reserved words used as identifiers
- **Suggestions**: Recommend alternative identifiers

## Implementation Notes

### 1. Tokenization Strategy
- **Maximal munch**: Always prefer longest possible token
- **Lookahead**: Single character lookahead sufficient
- **State management**: Minimal lexer state required

### 2. Performance Considerations
- **Unicode handling**: Efficient UTF-8 processing
- **Number parsing**: Lazy evaluation for large numbers
- **Comment skipping**: Fast comment recognition and skipping

### 3. Tool Integration
- **Syntax highlighting**: Token types support editor integration
- **Error reporting**: Rich error information for development tools
- **Formatter support**: Preserve whitespace and comment structure

This lexical specification provides a robust foundation for SMARS parsing with comprehensive Unicode support, flexible numeric formats, and clear error handling.