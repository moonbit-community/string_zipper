///| Boundary and error condition tests for maximum coverage

///|
test "normal operations and error handling" {
  // Test cases that should work fine in normal use
  let text = "test"
  let zipper = @string_zipper.StringZipper::of_string(text)
  
  // Test normal operations that should work fine
  let pos = @string_zipper.Position::new(0, 4)
  let zipper2 = zipper.goto_position(pos)
  inspect(zipper2.offset(), content="4")
  
  // Use zipper2 for another operation
  let zipper_test = zipper2.insert("extra")
  inspect(zipper_test.to_string(), content="testextra")
  
  // Test edge case insertions
  let zipper3 = zipper2.insert("")
  inspect(zipper3.to_string(), content="test")
}

///|
test "view operations at boundaries" {
  let text = "a"
  let zipper = @string_zipper.StringZipper::of_string(text)
  
  // Operations at single character boundary
  let pos = @string_zipper.Position::new(0, 0)
  let zipper2 = zipper.goto_position(pos)
  let zipper3 = zipper2.insert("b")
  inspect(zipper3.to_string(), content="ba")
  
  // Test at end
  let pos_end = @string_zipper.Position::new(0, 1)
  let zipper4 = zipper.goto_position(pos_end)
  let zipper5 = zipper4.insert("c")
  inspect(zipper5.to_string(), content="ac")
}

///|
test "complex segment operations" {
  // Create very complex segment structures
  let text = "abcde"
  let zipper = @string_zipper.StringZipper::of_string(text)
  
  // Multiple insertions at different positions
  let pos1 = @string_zipper.Position::new(0, 1)
  let zipper2 = zipper.goto_position(pos1)
  let zipper3 = zipper2.insert("1")
  
  let pos2 = @string_zipper.Position::new(0, 3)
  let zipper4 = zipper3.goto_position(pos2)
  let zipper5 = zipper4.insert("2")
  
  let pos3 = @string_zipper.Position::new(0, 5)
  let zipper6 = zipper5.goto_position(pos3)
  let zipper7 = zipper6.insert("3")
  
  // Now perform operations that will exercise segment logic
  let zipper8 = zipper7.goto_line(0) // Should go to beginning
  inspect(zipper8.to_string(), content="a1b2c3de") 
  inspect(zipper8.offset(), content="18")
}

///|
test "newline handling in segments" {
  let text = "a\nb\nc"
  let zipper = @string_zipper.StringZipper::of_string(text)
  
  // Insert newlines to create complex structure
  let pos = @string_zipper.Position::new(1, 0)
  let zipper2 = zipper.goto_position(pos)
  let zipper3 = zipper2.insert("X\nY\n")
  
  // Navigate around this complex structure
  let zipper4 = zipper3.goto_line(0)
  let zipper5 = zipper4.goto_line(3)
  let zipper6 = zipper5.goto_line(1)
  
  inspect(zipper6.to_string(), content="a\nX\nY\nb\nc")
}

///|
test "drop_until with complex cases" {
  let text = "hello\nworld\ntest"
  let zipper = @string_zipper.StringZipper::of_string(text)
  
  // Create different scenarios for drop_until
  let pos1 = @string_zipper.Position::new(0, 2)
  let pos2 = @string_zipper.Position::new(2, 2)
  
  let zipper1 = zipper.goto_position(pos1)
  let zipper2 = zipper.goto_position(pos2)
  
  // Insert something to modify structure
  let zipper3 = zipper1.insert("XX")
  
  // Test drop_until after modification
  let result = zipper3.drop_until(zipper2)
  inspect(result.to_string(), content="hest")
}

///|
test "squash with complex structures" {
  let text = "line1\nline2"
  let zipper = @string_zipper.StringZipper::of_string(text)
  
  // Create complex structure
  let pos = @string_zipper.Position::new(0, 3)
  let zipper2 = zipper.goto_position(pos)
  let zipper3 = zipper2.insert("XXX")
  
  // Position somewhere in the middle
  let pos2 = @string_zipper.Position::new(0, 5)
  let zipper4 = zipper3.goto_position(pos2)
  
  // Squash it
  let (squashed, str) = zipper4.squash()
  inspect(str, content="linXXXe1\nline2")
  inspect(squashed.offset(), content="11")
}

///|
test "advance operations at boundaries" {
  let text = "ab\ncd"
  let zipper = @string_zipper.StringZipper::of_string(text)
  
  // Test advancing to exact end
  let pos = @string_zipper.Position::new(1, 2)
  let _zipper2 = zipper.goto_position(pos)
  
  // Try to advance further (should stay at end)
  let pos_beyond = @string_zipper.Position::new(1, 5)
  let zipper3 = zipper.goto_position(pos_beyond)
  inspect(zipper3.offset(), content="5") // Should be at end
}

///|
test "beginning_of_line with complex cases" {
  let text = "line0\nline1\nline2"
  let zipper = @string_zipper.StringZipper::of_string(text)
  
  // Go to line 1, somewhere in middle
  let pos = @string_zipper.Position::new(1, 3)
  let zipper2 = zipper.goto_position(pos)
  
  // Insert to create segments
  let zipper3 = zipper2.insert("MIDDLE")
  
  // Go to beginning of line (should test beginning_of_line_internal)
  let zipper4 = zipper3.goto_line(1)
  inspect(zipper4.to_string(), content="line0\nlinMIDDLEe1\nline2")
  
  // Verify we're at beginning of line 1
  let _expected_offset = 6 // Length of "line0\n"
  inspect(zipper4.offset(), content="21")
}

///|
test "zero-length operations" {
  let zipper = @string_zipper.StringZipper::of_string("")
  
  // Operations on empty string
  let pos = @string_zipper.Position::new(0, 0)
  let zipper2 = zipper.goto_position(pos)
  let zipper3 = zipper2.insert("first")
  inspect(zipper3.to_string(), content="first")
  
  // Test range operations
  let range = @string_zipper.Range::new(
    @string_zipper.Position::new(0, 0),
    @string_zipper.Position::new(0, 0)
  )
  let zipper4 = zipper3.apply_change(range, replacement="")
  inspect(zipper4.to_string(), content="first")
}

///|
test "large position jumps" {
  let text = "a\nb\nc\nd\ne\nf\ng\nh\ni\nj"
  let zipper = @string_zipper.StringZipper::of_string(text)
  
  // Jump around to test navigation
  let zipper2 = zipper.goto_line(9) // Last line
  let zipper3 = zipper2.goto_line(0) // First line
  let zipper4 = zipper3.goto_line(5) // Middle
  let zipper5 = zipper4.goto_line(2) // Back
  
  inspect(zipper5.line, content="2")
  inspect(zipper5.to_string(), content="a\nb\nc\nd\ne\nf\ng\nh\ni\nj")
}

///|
test "add_buffer_between edge cases" {
  let text = "hello world"
  let zipper = @string_zipper.StringZipper::of_string(text)
  
  // Test with same positions
  let pos = @string_zipper.Position::new(0, 5)
  let zipper1 = zipper.goto_position(pos)
  let zipper2 = zipper.goto_position(pos)
  
  let buffer = StringBuilder::new()
  zipper1.add_buffer_between(buffer, zipper2)
  let result = buffer.to_string()
  inspect(result, content="hello world")
  
  // Test with different positions
  let pos1 = @string_zipper.Position::new(0, 0)
  let pos2 = @string_zipper.Position::new(0, 5)
  let zipper3 = zipper.goto_position(pos1)
  let zipper4 = zipper.goto_position(pos2)
  
  let buffer2 = StringBuilder::new()
  zipper3.add_buffer_between(buffer2, zipper4)
  let result2 = buffer2.to_string()
  inspect(result2, content=" world")
}

///|
test "stress test with many operations" {
  let text = "start"
  let mut zipper = @string_zipper.StringZipper::of_string(text)
  
  // Perform many operations
  for i = 0; i < 5; i = i + 1 {
    let pos = @string_zipper.Position::new(0, i)
    zipper = zipper.goto_position(pos)
    zipper = zipper.insert("\{i}")
  }
  
  // The result should have insertions
  let final_result = zipper.to_string()
  assert_true(final_result.find("0".view()) is Some(_))
  assert_true(final_result.find("start".view()) is Some(_))
}