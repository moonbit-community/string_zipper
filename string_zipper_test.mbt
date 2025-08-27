///| Comprehensive tests for StringZipper functionality

///|
test "basic creation and conversion" {
  let zipper = @string_zipper.StringZipper::of_string("hello")
  inspect(zipper.to_string(), content="hello")
  inspect(zipper.offset(), content="0")
  inspect(zipper.line(), content="0")
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
  inspect(zipper.line(), content="0")

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
  inspect(
    zipper2.to_string(),
    content=(
      #|line0
      #|line1
      #|line2
    ),
  )

  // Test that goto_end goes to the actual end
  let zipper3 = zipper2.insert("!")
  inspect(
    zipper3.to_string(),
    content=(
      #|line0
      #|line1
      #|line2!
    ),
  )
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
  inspect(
    zipper2.to_string(),
    content=(
      #|line A
      #|line B2
      #|line3
    ),
  )
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
  // New debug format shows cursor position
  inspect(debug_str, content="|hello")
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

///|
/// OCaml string_zipper test port - Helper types and functions
/// Original from: https://raw.githubusercontent.com/ocaml/ocaml-lsp/refs/heads/master/lsp/test/string_zipper_tests.ml

///|
/// Operation types for the test framework
enum Op {
  GotoLine(Int)
  Insert(String)
} derive(Eq)

///|
/// Display mode for test results
enum DisplayMode {
  String // Display as "line N: \"text|cursor\""
} derive(Eq)

///|
/// Test execution mode
enum TestMode {
  All // Show all operations
  Last // Show only the last result
} derive(Eq)

///|
/// Helper function to format test results like OCaml's expect tests
fn format_result(
  mode : DisplayMode,
  zipper : @string_zipper.StringZipper,
) -> String {
  match mode {
    String => {
      let line_num = zipper.line()
      let debug_str = zipper.to_string_debug()
      "line \{line_num}: \"\{debug_str}\""
    }
  }
}

///|
/// Execute a series of operations on a string zipper and collect results
fn test_operations(
  mode : DisplayMode,
  start : @string_zipper.StringZipper,
  operations : Array[Op],
  which? : TestMode = All,
) -> Array[String] {
  let results = Array::new()
  let mut current_zipper = start

  // Add initial state for All mode
  if which == All {
    results.push(format_result(mode, current_zipper))
  }

  // Execute operations
  for op in operations {
    match op {
      GotoLine(line) => current_zipper = current_zipper.goto_line(line)
      Insert(text) => current_zipper = current_zipper.insert(text)
    }
    match which {
      All => results.push(format_result(mode, current_zipper))
      Last => () // We'll add the final result at the end
    }
  }

  // Add final result for Last mode
  if which == Last {
    results.push(format_result(mode, current_zipper))
  }
  results
}

///|
/// Helper to execute operations and return formatted results for inspection
fn execute_and_format(
  start_text : String,
  operations : Array[Op],
  which? : TestMode = All,
) -> Array[String] {
  let zipper = @string_zipper.StringZipper::of_string(start_text)
  test_operations(String, zipper, operations, which~)
}

///|
/// Port of OCaml's "goto line" expect test
test "ocaml goto line test" {
  // Test single goto_line 0
  let results1 = execute_and_format("foo\nX\nY", [GotoLine(0)], which=Last)
  inspect(
    results1[0],
    content=(
      #|line 0: "|foo
      #|X
      #|Y"
    ),
  )

  // Test multiple goto_line operations
  let operations = [
    GotoLine(0),
    GotoLine(1),
    GotoLine(2),
    GotoLine(3),
    GotoLine(2),
    GotoLine(1),
    GotoLine(0),
    GotoLine(0),
  ]
  let results2 = execute_and_format("foo\nX\nY", operations)

  // Check each expected result
  inspect(
    results2[0],
    content=(
      #|line 0: "|foo
      #|X
      #|Y"
    ),
  ) // initial
  inspect(
    results2[1],
    content=(
      #|line 0: "|foo
      #|X
      #|Y"
    ),
  ) // goto 0
  inspect(
    results2[2],
    content=(
      #|line 1: "foo
      #||X
      #|Y"
    ),
  ) // goto 1
  inspect(
    results2[3],
    content=(
      #|line 2: "foo
      #|X
      #||Y"
    ),
  ) // goto 2
  inspect(
    results2[4],
    content=(
      #|line 2: "foo
      #|X
      #|Y|"
    ),
  ) // goto 3 (beyond end)
  inspect(
    results2[5],
    content=(
      #|line 2: "foo
      #|X
      #||Y"
    ),
  ) // goto 2
  inspect(
    results2[6],
    content=(
      #|line 1: "foo
      #||X
      #|Y"
    ),
  ) // goto 1
  inspect(
    results2[7],
    content=(
      #|line 0: "|foo
      #|X
      #|Y"
    ),
  ) // goto 0
  inspect(
    results2[8],
    content=(
      #|line 0: "|foo
      #|X
      #|Y"
    ),
  ) // goto 0

  // Test with empty string
  let results3 = execute_and_format("", [GotoLine(100), GotoLine(0)])
  inspect(
    results3[0],
    content=(
      #|line 0: "|"
    ),
  ) // initial
  inspect(
    results3[1],
    content=(
      #|line 0: "|"
    ),
  ) // goto 100
  inspect(
    results3[2],
    content=(
      #|line 0: "|"
    ),
  ) // goto 0

  // Test insert then goto
  let mixed_ops = [Insert("baz"), GotoLine(1), Insert("1")]
  let results4 = execute_and_format("foo\nX\nY", mixed_ops)
  inspect(
    results4[0],
    content=(
      #|line 0: "|foo
      #|X
      #|Y"
    ),
  ) // initial
  inspect(
    results4[1],
    content=(
      #|line 0: "|bazfoo
      #|X
      #|Y"
    ),
  ) // insert "baz"
  inspect(
    results4[2],
    content=(
      #|line 1: "bazfoo
      #||X
      #|Y"
    ),
  ) // goto line 1
  inspect(
    results4[3],
    content=(
      #|line 1: "bazfoo
      #||1X
      #|Y"
    ),
  ) // insert "1"
}

///|

///|
/// Port of OCaml's "insertions" expect test
test "ocaml insertions test" {
  // Test insertions on a simple "foo" string

  // Test empty insertion
  let results1 = execute_and_format("foo", [Insert("")])
  inspect(
    results1[0],
    content=(
      #|line 0: "|foo"
    ),
  ) // initial
  inspect(
    results1[1],
    content=(
      #|line 0: "|foo"
    ),
  ) // insert ""

  // Test single character insertion
  let results2 = execute_and_format("foo", [Insert("a")])
  inspect(
    results2[0],
    content=(
      #|line 0: "|foo"
    ),
  ) // initial  
  inspect(
    results2[1],
    content=(
      #|line 0: "|afoo"
    ),
  ) // insert "a"

  // Test multiple insertions 
  let results3 = execute_and_format("foo", [Insert("a"), Insert("b")])
  inspect(
    results3[0],
    content=(
      #|line 0: "|foo"
    ),
  ) // initial
  inspect(
    results3[1],
    content=(
      #|line 0: "|afoo"
    ),
  ) // insert "a"
  inspect(
    results3[2],
    content=(
      #|line 0: "|bafoo"
    ),
  ) // insert "b"
}

///|
/// Port of OCaml's "mixed insert goto" expect test  
test "ocaml mixed insert goto test" {
  // Test multiple insertions in sequence
  let results = execute_and_format("foo", [
    Insert("XXX"),
    Insert("YYY"),
    Insert("zzz"),
  ])
  inspect(
    results[0],
    content=(
      #|line 0: "|foo"
    ),
  ) // initial
  inspect(results[1], content="line 0: \"|XXXfoo\"") // insert "XXX"
  inspect(results[2], content="line 0: \"|YYYXXXfoo\"") // insert "YYY"
  inspect(results[3], content="line 0: \"|zzzYYYXXXfoo\"") // insert "zzz"
}

///|
/// Port of OCaml's "drop_until" expect test
test "ocaml drop_until test" {
  // First test: drop from line 1 to line 2
  let t = @string_zipper.StringZipper::of_string("foo\nbar\nxxx")
  let t1 = t.goto_line(1)
  let t2 = t.goto_line(2)
  let result1 = t1.drop_until(t2)
  inspect(
    result1.to_string_debug(),
    content=(
      #|foo
      #||xxx
    ),
  )

  // Second test: drop_until same position  
  let t3 = @string_zipper.StringZipper::of_string("foo\nbar\n")
  let t4 = t3.goto_line(2)
  let result2 = t4.drop_until(t4)
  inspect(
    result2.to_string_debug(),
    content=(
      #|foo
      #|bar
      #||
    ),
  )

  // Third test: drop_until from line 1 to line 1 (same position)
  let t5 = @string_zipper.StringZipper::of_string("123\n")
  let t6 = t5.goto_line(1)
  let result3 = t6.drop_until(t6)
  inspect(
    result3.to_string_debug(),
    content=(
      #|123
      #||
    ),
  )
}

///|
/// Port of OCaml's "squashing" expect test
test "ocaml squashing test" {
  let str = "foo\nbar"
  let t = @string_zipper.StringZipper::of_string(str)
  let t_at_line1 = t.goto_line(1)
  let (squashed_t, str_result) = t_at_line1.squash()

  // Check that the string was preserved
  assert_eq(str, str_result)

  // Check the squashed zipper position
  inspect(
    squashed_t.to_string_debug(),
    content=(
      #|foo
      #||bar
    ),
  )
}

///|
/// Port of OCaml's "add buffer between" expect test
test "ocaml add buffer between test" {
  let str = "foo\nbar"
  let t = @string_zipper.StringZipper::of_string(str)
  let t_at_line1 = t.goto_line(1)
  let buffer = StringBuilder::new()
  @string_zipper.StringZipper::add_buffer_between(t, buffer, t_at_line1)
  let result = buffer.to_string()
  inspect(result, content="bar")
}

///|
/// Port of OCaml's "drop_until bug" expect test
test "ocaml drop_until bug test" {
  let t = @string_zipper.StringZipper::of_string("foo\nbar\nxxx")
  let t_end = t.goto_line(10) // Go to line 10 (beyond end)
  let t_line2 = t.goto_line(2) // Go to line 2
  let result = t_line2.drop_until(t_end)

  // Check the debug representation
  inspect(
    result.to_string_debug(),
    content=(
      #|foo
      #|bar
      #||
    ),
  )

  // Check the absolute position
  let abs_pos = result.offset()
  inspect(abs_pos, content="16")
}
