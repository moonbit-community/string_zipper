///| Comprehensive tests to improve coverage for StringZipper functionality

///|
test "edge cases for view operations" {
  // Test take_view with len <= 0
  let zipper = @string_zipper.StringZipper::of_string("hello")
  let zipper2 = zipper.insert("") // Empty insert to trigger edge case
  inspect(zipper2.to_string(), content="hello")

  // Test drop_view with len <= 0  
  let zipper3 = @string_zipper.StringZipper::of_string("test")
  let pos = @string_zipper.Position::new(0, 0)
  let zipper4 = zipper3.goto_position(pos)
  let zipper5 = zipper4.insert("x")
  inspect(zipper5.to_string(), content="xtest")
}

///|
test "cons function with empty views" {
  // Create a scenario that will test the cons function with empty views
  let zipper = @string_zipper.StringZipper::of_string("hello")
  let pos = @string_zipper.Position::new(0, 5) // At end
  let zipper2 = zipper.goto_position(pos)
  let zipper3 = zipper2.insert("") // Empty string should test cons with empty view
  inspect(zipper3.to_string(), content="hello")
}

///|
test "multiline navigation and goto_line_backward" {
  let text = "line0\nline1\nline2\nline3"
  let zipper = @string_zipper.StringZipper::of_string(text)

  // Go to line 3 first
  let zipper2 = zipper.goto_line(3)
  inspect(zipper2.line(), content="3")

  // Now go backward to line 1 (should trigger goto_line_backward)
  let zipper3 = zipper2.goto_line(1)
  inspect(zipper3.line(), content="1")
  inspect(zipper3.offset(), content="6") // Should be at beginning of line1
}

///|
test "navigation at end of document" {
  let text = "line0\nline1"
  let zipper = @string_zipper.StringZipper::of_string(text)

  // Go to end
  let zipper2 = zipper.goto_end()

  // Try to go forward from end (should stay at end)
  let zipper3 = zipper2.goto_line(5) // Non-existent line
  inspect(
    zipper3.to_string(),
    content=(
      #|line0
      #|line1
    ),
  )
}

///|
test "advance_chars at document end" {
  let zipper = @string_zipper.StringZipper::of_string("hello")
  let pos = @string_zipper.Position::new(0, 5) // At end
  let zipper2 = zipper.goto_position(pos)

  // Try to advance beyond end  
  let pos_beyond = @string_zipper.Position::new(0, 10)
  let zipper3 = zipper.goto_position(pos_beyond)
  inspect(zipper3.offset(), content="5") // Should stay at end

  // Use zipper2 for additional test
  let zipper_final = zipper2.insert("final")
  inspect(zipper_final.to_string(), content="hellofinal")
}

///|
test "drop_until with empty result" {
  let zipper = @string_zipper.StringZipper::of_string("hello")
  let pos1 = @string_zipper.Position::new(0, 2)
  let pos2 = @string_zipper.Position::new(0, 2) // Same position
  let zipper1 = zipper.goto_position(pos1)
  let zipper2 = zipper.goto_position(pos2)
  let result = zipper1.drop_until(zipper2)
  inspect(result.to_string(), content="hello")
}

///|
test "complex multiline operations" {
  let text = "line0\nline1\nline2"
  let zipper = @string_zipper.StringZipper::of_string(text)

  // Go to middle of line1
  let pos = @string_zipper.Position::new(1, 2)
  let zipper2 = zipper.goto_position(pos)

  // Insert text that will create new segments
  let zipper3 = zipper2.insert("inserted")
  inspect(
    zipper3.to_string(),
    content=(
      #|line0
      #|liinsertedne1
      #|line2
    ),
  )
}

///|
test "navigation with newlines in segments" {
  // Create a zipper and modify it to have multiple segments
  let zipper = @string_zipper.StringZipper::of_string("abc\ndef\nghi")

  // Go to middle and insert, creating segments
  let pos = @string_zipper.Position::new(1, 1) // Middle of "def"
  let zipper2 = zipper.goto_position(pos)
  let zipper3 = zipper2.insert("XYZ")
  inspect(
    zipper3.to_string(),
    content=(
      #|abc
      #|dXYZef
      #|ghi
    ),
  )

  // Now navigate around to test segment handling
  let zipper4 = zipper3.goto_line(0)
  inspect(zipper4.line(), content="0")
  let zipper5 = zipper4.goto_line(2)
  inspect(zipper5.line(), content="2")
}

///|
test "add_buffer_between functionality" {
  let zipper = @string_zipper.StringZipper::of_string("hello world")
  let pos1 = @string_zipper.Position::new(0, 2)
  let pos2 = @string_zipper.Position::new(0, 8)
  let zipper1 = zipper.goto_position(pos1)
  let zipper2 = zipper.goto_position(pos2)
  let buffer = StringBuilder::new()
  zipper1.add_buffer_between(buffer, zipper2)
  let result = buffer.to_string()
  inspect(result, content="herld")
}

///|
test "squash with early termination" {
  // Create a zipper that will test the None branch in squash
  let zipper = @string_zipper.StringZipper::of_string("test")
  let pos = @string_zipper.Position::new(0, 2)
  let zipper2 = zipper.goto_position(pos)
  let (squashed, str) = zipper2.squash()
  inspect(str, content="test")
  inspect(squashed.offset(), content="2")
}

///|
test "insertion at various positions to test segments" {
  let zipper = @string_zipper.StringZipper::of_string("hello")

  // Insert at beginning (rel_pos == 0)
  let zipper2 = zipper.insert("start")
  inspect(zipper2.to_string(), content="starthello")

  // Insert at end
  let pos_end = @string_zipper.Position::new(0, 5)
  let zipper3 = zipper.goto_position(pos_end)
  let zipper4 = zipper3.insert("end")
  inspect(zipper4.to_string(), content="helloend")

  // Insert in middle
  let pos_mid = @string_zipper.Position::new(0, 2)
  let zipper5 = zipper.goto_position(pos_mid)
  let zipper6 = zipper5.insert("MID")
  inspect(zipper6.to_string(), content="heMIDllo")
}

///|
test "error conditions and edge cases" {
  // Test cases that might trigger error conditions
  let zipper = @string_zipper.StringZipper::of_string("a\nb\nc")

  // Try operations at various positions
  let pos = @string_zipper.Position::new(2, 0)
  let zipper2 = zipper.goto_position(pos)
  inspect(zipper2.line(), content="2")

  // Test going to line 0 from non-zero line  
  let zipper3 = zipper2.goto_line(0)
  inspect(zipper3.line(), content="0")
}

///|
test "complex drop_until scenarios" {
  let text = "abc\ndef\nghi"
  let zipper = @string_zipper.StringZipper::of_string(text)

  // Create scenarios with different segment configurations
  let pos1 = @string_zipper.Position::new(0, 1)
  let pos2 = @string_zipper.Position::new(2, 1)
  let zipper1 = zipper.goto_position(pos1)
  let zipper2 = zipper.goto_position(pos2)
  let result = zipper1.drop_until(zipper2)
  inspect(result.to_string(), content="ahi")
}

///|
test "boundary conditions for views" {
  // Test boundary conditions that weren't covered
  let zipper = @string_zipper.StringZipper::of_string("test string")

  // Operations that should trigger various view edge cases
  let pos = @string_zipper.Position::new(0, 4)
  let zipper2 = zipper.goto_position(pos)
  inspect(zipper2.offset(), content="4")

  // Apply change that involves complex view operations
  let start_pos = @string_zipper.Position::new(0, 2)
  let end_pos = @string_zipper.Position::new(0, 6)
  let range = @string_zipper.Range::new(start_pos, end_pos)
  let zipper3 = zipper.apply_change(range, replacement="NEW")
  inspect(zipper3.to_string(), content="teNEWtring")
}
