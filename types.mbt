///| Types module - Position and Range definitions for LSP-style text editing

///|
/// Represents a position in a text document
pub struct Position {
  line : Int32 // 0-based line number
  character : Int32 // 0-based character offset within the line
}

///|
/// Creates a new position
pub fn Position::new(line : Int32, character : Int32) -> Position {
  { line, character, }
}

///|
/// Represents a range in a text document
pub struct Range {
  start : Position // The start position of the range
  end : Position // The end position of the range
}

///|
/// Creates a new range
pub fn Range::new(start : Position, end : Position) -> Range {
  { start, end, }
}
