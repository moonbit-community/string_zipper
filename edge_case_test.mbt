///| Edge case tests to achieve high coverage

///|
test "rindex_from_view functionality" {
  // Test backward search functionality indirectly through navigation
  let text = "abc\ndef\nabc"
  let zipper = @string_zipper.StringZipper::of_string(text)
  
  // Go to line 2 then back to test backward navigation
  let zipper2 = zipper.goto_line(2)
  let zipper3 = zipper2.goto_line(1)
  inspect(zipper3.line, content="1")
}

///|
test "prev_newline with segments" {
  // Create a complex scenario to test prev_newline
  let text = "line1\nline2\nline3"
  let zipper = @string_zipper.StringZipper::of_string(text)
  
  // Go to line 2, insert something, then navigate backward
  let pos = @string_zipper.Position::new(2, 2)
  let zipper2 = zipper.goto_position(pos)
  let zipper3 = zipper2.insert("XX")
  
  // Now try to go back to line 0 to trigger prev_newline
  let zipper4 = zipper3.goto_line(0)
  inspect(zipper4.line, content="0")
}

///|
test "find_next_nl with right segments" {
  // Create a scenario that will have right segments
  let text = "line1\nline2"
  let zipper = @string_zipper.StringZipper::of_string(text)
  
  // Go to beginning and insert to create segments
  let zipper2 = zipper.insert("prefix")
  
  // Now navigate to test find_next_nl with segments
  let zipper3 = zipper2.goto_line(1)
  inspect(zipper3.to_string(), content="prefixline1\nline2")
}

///|
test "advance_char_internal with right segments" {
  let text = "ab\ncd"
  let zipper = @string_zipper.StringZipper::of_string(text)
  
  // Insert at beginning to create left segment
  let zipper2 = zipper.insert("X")
  
  // Navigate to create a scenario with right segments
  let pos = @string_zipper.Position::new(0, 1) // After X
  let zipper3 = zipper2.goto_position(pos)
  
  // Continue navigating to test advance_char_internal
  let pos2 = @string_zipper.Position::new(1, 1)
  let zipper4 = zipper3.goto_position(pos2)
  inspect(zipper4.to_string(), content="Xab\ncd")
}

///|
test "is_end_internal edge cases" {
  let zipper = @string_zipper.StringZipper::of_string("test")
  let pos = @string_zipper.Position::new(0, 4) // At end
  let zipper2 = zipper.goto_position(pos)
  
  // Test that we're at end
  let zipper3 = zipper2.insert("!")
  inspect(zipper3.to_string(), content="test!")
}

///|
test "beginning_of_line_internal complex case" {
  let text = "line0\nline1\nline2"
  let zipper = @string_zipper.StringZipper::of_string(text)
  
  // Go to middle of line 1
  let pos = @string_zipper.Position::new(1, 3)
  let zipper2 = zipper.goto_position(pos)
  
  // Insert to create segments
  let zipper3 = zipper2.insert("XXX")
  
  // Now go to beginning of line to test beginning_of_line_internal
  let zipper4 = zipper3.goto_line(1)
  inspect(zipper4.to_string(), content="line0\nlinXXXe1\nline2")
}

///|
test "cons with non-empty views" {
  // Create scenarios that will test cons function with non-empty views
  let text = "hello world"
  let zipper = @string_zipper.StringZipper::of_string(text)
  
  // Operations that will create multiple segments
  let pos1 = @string_zipper.Position::new(0, 2)
  let zipper2 = zipper.goto_position(pos1)
  let zipper3 = zipper2.insert("AA")
  
  let pos2 = @string_zipper.Position::new(0, 4)
  let zipper4 = zipper3.goto_position(pos2)
  let zipper5 = zipper4.insert("BB")
  
  inspect(zipper5.to_string(), content="heAABBllo world")
}

///|
test "take_view and drop_view edge cases" {
  // Test various edge cases for take_view and drop_view through complex operations
  let text = "abcdefgh"
  let zipper = @string_zipper.StringZipper::of_string(text)
  
  // Create a range that will test view operations
  let start_pos = @string_zipper.Position::new(0, 0)
  let end_pos = @string_zipper.Position::new(0, 0) // Empty range
  let range = @string_zipper.Range::new(start_pos, end_pos)
  
  let zipper2 = zipper.apply_change(range, replacement="")
  inspect(zipper2.to_string(), content="abcdefgh")
  
  // Test with range at end
  let start_pos2 = @string_zipper.Position::new(0, 8)
  let end_pos2 = @string_zipper.Position::new(0, 8)
  let range2 = @string_zipper.Range::new(start_pos2, end_pos2)
  
  let zipper3 = zipper.apply_change(range2, replacement="END")
  inspect(zipper3.to_string(), content="abcdefghEND")
}

///|
test "drop_until_internal edge cases" {
  let text = "hello"
  let zipper = @string_zipper.StringZipper::of_string(text)
  
  // Test drop_until from same position
  let pos = @string_zipper.Position::new(0, 2)
  let zipper1 = zipper.goto_position(pos)
  let zipper2 = zipper.goto_position(pos)
  
  let result = zipper1.drop_until(zipper2)
  inspect(result.to_string(), content="hello")
  
  // Test drop_until that results in empty
  let pos_start = @string_zipper.Position::new(0, 0)
  let pos_end = @string_zipper.Position::new(0, 0)
  let zipper3 = zipper.goto_position(pos_start)
  let zipper4 = zipper.goto_position(pos_end)
  
  let result2 = zipper3.drop_until(zipper4)
  inspect(result2.to_string(), content="hello")
}

///|
test "multiline operations with complex segments" {
  let text = "a\nb\nc\nd"
  let zipper = @string_zipper.StringZipper::of_string(text)
  
  // Insert at multiple positions to create complex segment structure
  let pos1 = @string_zipper.Position::new(1, 0)
  let zipper2 = zipper.goto_position(pos1)
  let zipper3 = zipper2.insert("X1")
  
  let pos2 = @string_zipper.Position::new(2, 1)
  let zipper4 = zipper3.goto_position(pos2)
  let zipper5 = zipper4.insert("X2")
  
  // Navigate around to test various internal functions
  let zipper6 = zipper5.goto_line(0)
  let zipper7 = zipper6.goto_line(3)
  let zipper8 = zipper7.goto_line(1)
  
  inspect(zipper8.to_string(), content="a\nX1b\ncX2\nd")
}

///|
test "error boundary testing" {
  // Test operations near boundaries that might trigger error conditions
  let text = "short"
  let zipper = @string_zipper.StringZipper::of_string(text)
  
  // Try to go beyond document boundaries
  let pos_beyond = @string_zipper.Position::new(0, 100)
  let zipper2 = zipper.goto_position(pos_beyond)
  
  // Should stop at end
  inspect(zipper2.offset(), content="5")
  
  // Test with negative-like scenarios through complex operations
  let range = @string_zipper.Range::new(
    @string_zipper.Position::new(0, 1),
    @string_zipper.Position::new(0, 4)
  )
  let zipper3 = zipper.apply_change(range, replacement="LONG REPLACEMENT")
  inspect(zipper3.to_string(), content="sLONG REPLACEMENTt")
}

///|
test "types module coverage" {
  // Test Position and Range creation to ensure types.mbt is covered
  let pos1 = @string_zipper.Position::new(5, 10)
  inspect(pos1.line, content="5")
  inspect(pos1.character, content="10")
  
  let pos2 = @string_zipper.Position::new(7, 15)
  let range = @string_zipper.Range::new(pos1, pos2)
  inspect(range.start.line, content="5")
  inspect(range.start.character, content="10")
  inspect(range.end.line, content="7")
  inspect(range.end.character, content="15")
}

///|
test "comprehensive navigation test" {
  // Test that exercises many code paths
  let text = "line0\nline1\nline2\nline3"
  let zipper = @string_zipper.StringZipper::of_string(text)
  
  // Series of operations to hit many code paths
  let zipper2 = zipper.goto_line(2)
  let pos = @string_zipper.Position::new(2, 2)
  let zipper3 = zipper2.goto_position(pos)
  let zipper4 = zipper3.insert("INSERTED")
  let zipper5 = zipper4.goto_line(0)
  let zipper6 = zipper5.goto_end()
  let zipper7 = zipper6.goto_line(1)
  
  inspect(zipper7.to_string(), content="line0\nline1\nliINSERTEDne2\nline3")
  inspect(zipper7.line, content="1")
}