///| Comprehensive tests for StringZipper functionality

///|
test "basic creation and conversion" {
  let zipper = @string_zipper.StringZipper::of_string("hello")
  inspect(zipper.to_string(), content="hello")
  inspect(zipper.offset(), content="0")
  inspect(zipper.line, content="0")
}

///|
test "empty zipper" {
  let zipper = @string_zipper.StringZipper::of_string("")
  inspect(zipper.to_string(), content="")
  inspect(zipper.offset(), content="0")
}

///|
test "goto_position functionality" {
  let zipper = @string_zipper.StringZipper::of_string("hello")
  let position = @string_zipper.Position::new(0, 2)
  let zipper2 = zipper.goto_position(position)
  inspect(zipper2.offset(), content="2")

  // Test another position
  let position3 = @string_zipper.Position::new(0, 3)
  let zipper3 = zipper.goto_position(position3)
  inspect(zipper3.offset(), content="3")
}

///|
test "apply_change functionality" {
  // Start with a simple document
  let zipper = @string_zipper.StringZipper::of_string("Hello World")

  // Replace 'World' with 'MoonBit' using apply_change
  let start_pos = @string_zipper.Position::new(0, 6)
  let end_pos = @string_zipper.Position::new(0, 11)
  let range = @string_zipper.Range::new(start_pos, end_pos)
  let zipper2 = zipper.apply_change(range, replacement="MoonBit")
  inspect(zipper2.to_string(), content="Hello MoonBit")
}

///|
test "text insertion" {
  let zipper = @string_zipper.StringZipper::of_string("hello")
  let zipper2 = zipper.insert(" world")
  inspect(zipper2.to_string(), content=" worldhello")
  inspect(zipper2.offset(), content="0")
}

///|
test "goto_line functionality" {
  let zipper = @string_zipper.StringZipper::of_string("line1\nline2\nline3")
  inspect(zipper.line, content="0")

  // Go to line 1
  let zipper2 = zipper.goto_line(1)
  inspect(zipper2.offset(), content="6")

  // Go to line 2  
  let zipper3 = zipper.goto_line(2)
  inspect(zipper3.offset(), content="12")
}

///|
test "goto_end functionality" {
  let zipper = @string_zipper.StringZipper::of_string("line0\nline1\nline2")
  let zipper2 = zipper.goto_end()
  inspect(zipper2.to_string(), content="line0\nline1\nline2")

  // Test that goto_end goes to the actual end
  let zipper3 = zipper2.insert("!")
  inspect(zipper3.to_string(), content="line0\nline1\nline2!")
}

///|
test "drop_until functionality" {
  let zipper1 = @string_zipper.StringZipper::of_string("hello world")
  let pos1 = @string_zipper.Position::new(0, 6) // At "w"
  let pos2 = @string_zipper.Position::new(0, 11) // At end
  let zipper2 = zipper1.goto_position(pos1)
  let zipper3 = zipper1.goto_position(pos2)
  let result = zipper2.drop_until(zipper3)
  inspect(result.to_string(), content="hello ")
}

///|
test "squash functionality" {
  let zipper = @string_zipper.StringZipper::of_string("hello world")
  let pos = @string_zipper.Position::new(0, 6)
  let zipper2 = zipper.goto_position(pos)
  let (squashed, str) = zipper2.squash()
  inspect(str, content="hello world")
  inspect(squashed.offset(), content="6")
}

///|
test "multiline apply_change" {
  // Start with a multi-line document
  let zipper = @string_zipper.StringZipper::of_string("line1\nline2\nline3")

  // Replace across lines using apply_change
  let start_pos = @string_zipper.Position::new(0, 4)
  let end_pos = @string_zipper.Position::new(1, 4)
  let range = @string_zipper.Range::new(start_pos, end_pos)
  let zipper2 = zipper.apply_change(range, replacement=" A\nline B")
  inspect(zipper2.to_string(), content="line A\nline B2\nline3")
}

///|
test "text insertion at position" {
  let zipper = @string_zipper.StringZipper::of_string("test")
  let zipper2 = zipper.insert("")
  inspect(zipper2.to_string(), content="test")
}

///|
test "to_string_debug" {
  let zipper = @string_zipper.StringZipper::of_string("hello")
  let debug_str = zipper.to_string_debug()
  // Just verify it contains expected parts
  assert_true(debug_str.find("StringZipper".view()) is Some(_))
  assert_true(debug_str.find("hello".view()) is Some(_))
}

///|
test "offset functionality" {
  let zipper = @string_zipper.StringZipper::of_string("hello world")
  inspect(zipper.offset(), content="0")
  let pos = @string_zipper.Position::new(0, 6)
  let zipper2 = zipper.goto_position(pos)
  inspect(zipper2.offset(), content="6")
}

///|
test "unicode string handling" {
  // Test with unicode characters
  let zipper = @string_zipper.StringZipper::of_string("Hello 世界")
  let pos = @string_zipper.Position::new(0, 7) // After "Hello 世"
  let zipper2 = zipper.goto_position(pos)
  inspect(zipper2.offset(), content="7")

  // Test insertion with unicode
  let zipper3 = zipper2.insert("👋")
  inspect(zipper3.to_string(), content="Hello 世👋界")
}

///|
test "edge case: empty string operations" {
  let zipper = @string_zipper.StringZipper::of_string("")
  let pos = @string_zipper.Position::new(0, 0)
  let zipper2 = zipper.goto_position(pos)
  inspect(zipper2.offset(), content="0")
  let zipper3 = zipper2.insert("test")
  inspect(zipper3.to_string(), content="test")
}
