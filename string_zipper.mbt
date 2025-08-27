///| String Zipper - A data structure for efficient text editing operations
///
/// A zipper represents a position in a text document and allows efficient
/// insertion, deletion, and navigation operations. The cursor position is
/// maintained with line/column information.

///|
/// The main zipper data structure
pub struct StringZipper {
  priv left : Array[@string.View] // string views to the left of cursor
  priv rel_pos : Int // cursor position within current string view
  priv abs_pos : Int // total length of strings in left
  priv current : @string.View // current string view containing cursor
  priv line : Int // number of '\n' characters traversed
  priv right : Array[@string.View] // string views to the right of cursor
}

///|
/// Creates a string zipper from a string
pub fn StringZipper::of_string(s : String) -> StringZipper {
  { left: [], rel_pos: 0, abs_pos: 0, current: s.view(), right: [], line: 0 }
}

///|
/// Gets the absolute offset position of the cursor
pub fn offset(self : StringZipper) -> Int {
  self.abs_pos + self.rel_pos
}

///|
/// Gets the current line number (0-based)
pub fn line(self : StringZipper) -> Int {
  self.line
}

///|
/// Converts zipper to string and returns position info (internal helper)
fn to_string_and_pos(self : StringZipper) -> (String, Int, Int) {
  // Use StringBuilder for efficient string building
  let builder = StringBuilder::new()

  // Add left string views in reverse order
  for i = self.left.length() - 1; i >= 0; i = i - 1 {
    builder.write_string(self.left[i].to_string())
  }
  let final_pos = builder.to_string().length() + self.rel_pos

  // Add current string view
  builder.write_string(self.current.to_string())

  // Add right string views
  for view in self.right {
    builder.write_string(view.to_string())
  }
  (builder.to_string(), final_pos, self.line)
}

///|
/// Converts zipper to string
pub fn to_string(self : StringZipper) -> String {
  let (s, _, _) = self.to_string_and_pos()
  s
}

///|
/// Helper function to add string view to array if not empty
fn cons(view : @string.View, arr : Array[@string.View]) -> Array[@string.View] {
  if view.length() == 0 {
    arr
  } else {
    // Use proper Array operations from standard library
    let new_arr : Array[@string.View] = Array::new(capacity=arr.length() + 1)
    new_arr.push(view)
    for elem in arr {
      new_arr.push(elem)
    }
    new_arr
  }
}

///|
/// Creates a view by dropping the first n characters from the string view
fn drop_view(view : @string.View, len : Int) -> @string.View {
  let view_len = view.length()
  if len >= view_len {
    "".view()
  } else if len <= 0 {
    view
  } else {
    view.view(start_offset=len)
  }
}

///|
/// Creates a view by taking the first n characters from the string view
fn take_view(view : @string.View, len : Int) -> @string.View {
  let view_len = view.length()
  if len >= view_len {
    view
  } else if len <= 0 {
    "".view()
  } else {
    view.view(end_offset=len)
  }
}

///|
/// Splits string view at position n, returns (prefix, suffix)
fn split_view_at(view : @string.View, n : Int) -> (@string.View, @string.View) {
  (take_view(view, n), drop_view(view, n))
}

///|
/// Finds the index of character c starting from position pos
fn index_from_view(view : @string.View, pos~ : Int, c : Char) -> Int? {
  let view_len = view.length()
  if pos < 0 || pos >= view_len {
    abort("index_from_view: out of bounds")
  }
  // Use the view starting from the given position
  let search_view = view.view(start_offset=pos)
  match search_view.find_by(fn(ch) { ch == c }) {
    Some(relative_idx) => Some(pos + relative_idx)
    None => None
  }
}

///|
/// Finds the last index of character c before position pos (searching backwards)
fn rindex_from_view(view : @string.View, pos~ : Int, c : Char) -> Int? {
  let view_len = view.length()
  if pos < 0 || pos > view_len {
    abort("rindex_from_view: out of bounds")
  }
  // Search backwards manually using get_char
  for i = pos - 1; i >= 0; i = i - 1 {
    match view.get_char(i) {
      Some(ch) if ch == c => return Some(i)
      _ => continue
    }
  }
  None
}

///|
/// Gets character at index i, throws if out of bounds
fn get_char_exn(view : @string.View, i : Int) -> Char {
  match view.get_char(i) {
    Some(c) => c
    None => abort("get_char_exn: out of bounds")
  }
}

///|
/// Inserts text at the current cursor position
pub fn insert(self : StringZipper, x : String) -> StringZipper {
  if x.length() == 0 {
    return self
  }
  let current = x.view()
  if self.rel_pos == 0 {
    // At the beginning of current string view
    { ..self, current, right: cons(self.current, self.right) }
  } else if self.rel_pos == self.current.length() {
    // At the end of current string view
    let abs_pos = self.abs_pos + self.current.length()
    {
      ..self,
      current,
      rel_pos: 0,
      left: cons(self.current, self.left),
      abs_pos,
    }
  } else {
    // In the middle of current string view
    let (l, r) = split_view_at(self.current, self.rel_pos)
    let abs_pos = self.abs_pos + l.length()
    let new_left = cons(l, self.left)
    let new_right = cons(r, self.right)
    { ..self, current, rel_pos: 0, left: new_left, right: new_right, abs_pos }
  }
}

///|
/// Finds the next newline character (internal helper)
fn find_next_nl(self : StringZipper) -> StringZipper {
  if self.is_end_internal() {
    return self
  }
  match index_from_view(self.current, pos=self.rel_pos, '\n') {
    Some(rel_pos) => { ..self, rel_pos, }
    None =>
      if self.right.length() == 0 {
        { ..self, rel_pos: self.current.length() }
      } else {
        let current = self.right[0]
        let new_right = self.right[1:].to_array()
        let abs_pos = self.abs_pos + self.current.length()
        let new_zipper = {
          ..self,
          current,
          left: cons(self.current, self.left),
          right: new_right,
          rel_pos: 0,
          abs_pos,
        }
        new_zipper.find_next_nl()
      }
  }
}

///|
/// Goes to the specified line (forward direction) (internal helper)
fn goto_line_forward(self : StringZipper, n : Int) -> StringZipper {
  if n == 0 {
    return self
  }
  if self.is_end_internal() {
    return self
  }
  let mut zipper = self.find_next_nl()
  zipper = zipper.advance_char_internal()
  zipper.goto_line_forward(n - 1)
}

///|
/// Finds the previous newline character (internal helper)
fn prev_newline(self : StringZipper) -> StringZipper {
  if self.is_begin_internal() {
    return self
  }
  match rindex_from_view(self.current, pos=self.rel_pos, '\n') {
    Some(rel_pos) => { ..self, rel_pos, line: self.line - 1 }
    None =>
      if self.left.length() == 0 {
        { ..self, rel_pos: 0 }
      } else {
        let current = self.left[0]
        let new_left = self.left[1:].to_array()
        let new_zipper = {
          ..self,
          current,
          left: new_left,
          rel_pos: current.length(),
          abs_pos: self.abs_pos + self.current.length(),
          right: cons(self.current, self.right),
        }
        new_zipper.prev_newline()
      }
  }
}

///|
/// Goes to the specified line (backward direction) (internal helper)
fn goto_line_backward(self : StringZipper, n : Int) -> StringZipper {
  if n == 0 {
    return self.beginning_of_line_internal()
  }
  let zipper = self.prev_newline()
  zipper.goto_line_backward(n - 1)
}

///|
/// Goes to the specified line number
pub fn goto_line(self : StringZipper, n : Int) -> StringZipper {
  if self.line == n {
    self.beginning_of_line_internal()
  } else if self.line > n {
    self.goto_line_backward(self.line - n)
  } else {
    self.goto_line_forward(n - self.line)
  }
}

///|
/// Goes to the end of the document
pub fn goto_end(self : StringZipper) -> StringZipper {
  if self.is_end_internal() {
    return self
  }
  let mut zipper = self.find_next_nl()
  zipper = zipper.advance_char_internal()
  zipper.goto_end()
}

///|
/// Drops content from one zipper position until another
pub fn StringZipper::drop_until(
  self : StringZipper,
  until : StringZipper,
) -> StringZipper {
  drop_until_internal(self, until)
}

///|
/// Goes to a specific position in the document
/// Since MoonBit strings are UTF-16 encoded, character positions correspond to UTF-16 code units
pub fn goto_position(self : StringZipper, position : Position) -> StringZipper {
  let zipper = self.goto_line(position.line)
  zipper.advance_chars(position.character)
}

///|
/// Applies a text change to the zipper
/// Since MoonBit strings are UTF-16 encoded, character positions correspond to UTF-16 code units
pub fn apply_change(
  self : StringZipper,
  range : Range,
  replacement~ : String,
) -> StringZipper {
  let zipper = self.goto_line(range.start.line)
  let zipper = zipper.advance_chars(range.start.character)
  let delta_line = range.end.line - range.start.line
  let delta_character = if delta_line == 0 {
    range.end.character - range.start.character
  } else {
    range.end.character
  }
  let end_zipper = if delta_line == 0 {
    zipper
  } else {
    zipper.goto_line(range.end.line)
  }
  let end_zipper = end_zipper.advance_chars(delta_character)
  let result = zipper.drop_until(end_zipper)
  result.insert(replacement)
}

///|
/// Squash the zipper and return the zipper with the string representation
/// Corresponds to OCaml's squash : t -> t * string
pub fn squash(self : StringZipper) -> (StringZipper, String) {
  let str = self.to_string()
  let new_zipper = StringZipper::of_string(str)
  // Advance to the same position
  let target_offset = self.offset()
  let mut zipper = new_zipper
  let mut current_offset = 0
  while current_offset < target_offset {
    match zipper.current.get_char(zipper.rel_pos) {
      Some(_) => {
        zipper = zipper.advance_char_internal()
        current_offset = current_offset + 1
      }
      None => break
    }
  }
  (zipper, str)
}

///|
/// Debug representation of the zipper with cursor position
/// Corresponds to OCaml's to_string_debug : t -> string
/// Formats as: line N: "text|with|cursor" with escaped newlines
pub fn to_string_debug(self : StringZipper) -> String {
  let builder = StringBuilder::new()

  // Add left string views in reverse order
  for i = self.left.length() - 1; i >= 0; i = i - 1 {
    builder.write_string(self.left[i].to_string())
  }

  // Add current string view up to cursor position
  let current_str = self.current.to_string()
  let prefix = if self.rel_pos <= current_str.length() {
    current_str.substring(start=0, end=self.rel_pos)
  } else {
    current_str
  }
  builder.write_string(prefix)

  // Add cursor marker
  builder.write_string("|")

  // Add rest of current string view
  let suffix = if self.rel_pos < current_str.length() {
    current_str.substring(start=self.rel_pos)
  } else {
    ""
  }
  builder.write_string(suffix)

  // Add right string views
  for view in self.right {
    builder.write_string(view.to_string())
  }
  builder.to_string()
}

///|
/// Add buffer between two zipper positions
/// Corresponds to OCaml's add_buffer_between : Buffer.t -> t -> t -> unit
pub fn StringZipper::add_buffer_between(
  self : StringZipper,
  buffer : StringBuilder,
  until : StringZipper,
) -> Unit {
  // Extract the text between the two positions and add to buffer
  let text_between = self.drop_until(until).to_string()
  buffer.write_string(text_between)
}

// === PRIVATE UTILITY FUNCTIONS ===
// These are internal helper functions used by the original API

///|
/// Checks if cursor is at the end of the text (internal helper)
fn StringZipper::is_end_internal(self : StringZipper) -> Bool {
  let res = self.current.length() == self.rel_pos
  if res {
    if self.right.length() > 0 {
      abort("invalid state: current = \{self.current.to_string()}")
    }
  }
  res
}

///|
/// Checks if cursor is at the beginning of the text (internal helper)
fn StringZipper::is_begin_internal(self : StringZipper) -> Bool {
  self.left.length() == 0 && self.rel_pos == 0
}

///|
/// Goes to the beginning of the current line (internal helper)
fn StringZipper::beginning_of_line_internal(
  self : StringZipper,
) -> StringZipper {
  let line = self.line
  let zipper = self.prev_newline()
  if zipper.is_begin_internal() && zipper.line == line {
    zipper
  } else {
    zipper.advance_char_internal()
  }
}

///|
/// Advances cursor by one character (internal helper)
fn StringZipper::advance_char_internal(self : StringZipper) -> StringZipper {
  let current_len = self.current.length()
  if current_len == self.rel_pos {
    return self // at end
  }
  let line = match get_char_exn(self.current, self.rel_pos) {
    '\n' => self.line + 1
    _ => self.line
  }
  let rel_pos = self.rel_pos + 1
  if rel_pos < current_len {
    { ..self, rel_pos, line }
  } else if self.right.length() == 0 {
    { ..self, rel_pos, line }
  } else {
    let current = self.right[0]
    let new_right = self.right[1:].to_array()
    {
      abs_pos: self.abs_pos + self.current.length(),
      left: cons(self.current, self.left),
      current,
      line,
      right: new_right,
      rel_pos: 0,
    }
  }
}

///|
/// Advances cursor by the specified number of characters
/// Since MoonBit strings are UTF-16 encoded, this advances by UTF-16 code units
fn StringZipper::advance_chars(
  self : StringZipper,
  char_count : Int,
) -> StringZipper {
  let mut zipper = self
  let mut chars_advanced = 0
  while chars_advanced < char_count {
    let current_len = zipper.current.length()
    if current_len == zipper.rel_pos && zipper.right.length() == 0 {
      break // at end
    }
    zipper = zipper.advance_char_internal()
    chars_advanced = chars_advanced + 1
  }
  zipper
}

///|
/// Drops content from one zipper position until another (internal helper)
fn drop_until_internal(
  from : StringZipper,
  until : StringZipper,
) -> StringZipper {
  if from.is_end_internal() {
    return from
  }
  let right = cons(drop_view(until.current, until.rel_pos), until.right)
  let left = cons(take_view(from.current, from.rel_pos), from.left)
  if right.length() > 0 {
    let current = right[0]
    let new_right = right[1:].to_array()
    let abs_pos = from.abs_pos + from.current.length()
    { ..from, right: new_right, left, abs_pos, current, rel_pos: 0 }
  } else if left.length() == 0 {
    StringZipper::of_string("")
  } else {
    let current = left[0]
    let new_left = left[1:].to_array()
    let rel_pos = current.length()
    let abs_pos = from.abs_pos + rel_pos
    { ..from, right, left: new_left, current, rel_pos, abs_pos }
  }
}
