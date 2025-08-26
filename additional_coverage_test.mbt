///| Additional tests to improve coverage through public API

///|
test "comprehensive edge case coverage" {
  // Test various edge cases that might trigger internal functions
  
  // Test with empty string operations
  let empty_zipper = StringZipper::of_string("")
  let (squashed, str) = empty_zipper.squash()
  inspect(str, content="")
  inspect(squashed.offset(), content="0")
  
  // Test drop_until on empty zippers
  let empty_zipper2 = StringZipper::of_string("")
  let result = empty_zipper.drop_until(empty_zipper2)
  inspect(result.to_string(), content="")
  
  // Test operations at very end of document
  let text = "a"
  let zipper = StringZipper::of_string(text)
  let end_zipper = zipper.goto_end()
  
  // Try operations at end that might hit internal edge cases
  let buffer = StringBuilder::new()
  StringZipper::add_buffer_between(end_zipper, buffer, end_zipper)
  inspect(buffer.to_string(), content="a")
  
  // Test with single character strings and various positions
  let single_char = StringZipper::of_string("x")
  let pos0 = single_char.goto_position(Position::new(0, 0))
  let pos1 = single_char.goto_position(Position::new(0, 1))
  
  // Test drop_until from pos0 to pos1
  let result_drop = pos0.drop_until(pos1)
  inspect(result_drop.to_string(), content="")
}

///|
test "complex multiline scenarios" {
  // Test complex scenarios that might hit edge cases
  let text = "a\nb\nc"
  let zipper = StringZipper::of_string(text)
  
  // Navigate to various positions and test operations
  let line2 = zipper.goto_line(2)
  inspect(line2.offset(), content="4")
  
  // Test goto_end from different positions
  let end_from_line2 = line2.goto_end()
  inspect(end_from_line2.to_string(), content="a\nb\nc")
  
  // Test large position jumps that might trigger edge cases
  let large_pos = zipper.goto_position(Position::new(10, 50)) // Beyond document
  inspect(large_pos.to_string(), content="a\nb\nc")
}

///|
test "string view operations edge cases" {
  // Test scenarios that might exercise the internal view functions
  let text = "hello world test"
  let zipper = StringZipper::of_string(text)
  
  // Insert at various positions to create complex internal structure
  let pos5 = zipper.goto_position(Position::new(0, 5))
  let inserted1 = pos5.insert(" INSERTED")
  
  let pos10 = inserted1.goto_position(Position::new(0, 10))
  let inserted2 = pos10.insert(" MORE")
  
  inspect(inserted2.to_string(), content="hello INSE MORERTED world test")
  
  // Test squash on complex structure
  let (squashed, _) = inserted2.squash()
  inspect(squashed.to_string(), content="hello INSE MORERTED world test")
}

///|
test "boundary navigation edge cases" {
  // Test navigation that might hit internal edge cases
  let text = "line1\nline2\nline3\n"
  let zipper = StringZipper::of_string(text)
  
  // Navigate to end and try to go further
  let at_end = zipper.goto_end()
  let still_at_end = at_end.goto_line(100) // Try to go beyond
  inspect(still_at_end.to_string(), content="line1\nline2\nline3\n")
  
  // Test apply_change that might create edge case scenarios
  let range = Range::new(Position::new(1, 0), Position::new(2, 5))
  let changed = zipper.apply_change(range, replacement="REPLACED")
  inspect(changed.to_string(), content="line1\nREPLACED\n")
}