[![check](https://github.com/moonbit-community/string_zipper/actions/workflows/ci.yml/badge.svg)](https://github.com/moonbit-community/string_zipper/actions/workflows/ci.yml) [![Coverage Status](https://coveralls.io/repos/github/moonbit-community/string_zipper/badge.svg?branch=main)](https://coveralls.io/github/moonbit-community/string_zipper?branch=main)


# StringZipper

A MoonBit port of the OCaml LSP string zipper data structure. This library provides efficient text editing operations with cursor position tracking, specifically designed for LSP (Language Server Protocol) implementations.

## Overview

This is a port of the [OCaml LSP string zipper](https://github.com/ocaml/ocaml-lsp/blob/master/lsp/src/string_zipper.ml), adapted for MoonBit's native UTF-16 string handling. A StringZipper represents a position (cursor) in a text document and provides operations to:

- Navigate to specific positions using Position information
- Insert text at the current position
- Delete text between positions
- Apply text changes
- Track line and column information

The zipper maintains efficient operations by using a gap buffer-like approach with string views directly.

## Simplified MoonBit API

This MoonBit implementation provides a simplified API that takes advantage of MoonBit's native UTF-16 string encoding:

### Creating a StringZipper

```moonbit
test "create zipper from string" {
  let zipper = @string_zipper.StringZipper::of_string("Hello World")
  inspect(zipper.to_string(), content="Hello World")
}
```

### Position-based Navigation

```moonbit
test "navigate to position" {
  let zipper = @string_zipper.StringZipper::of_string("Hello World")
  let position = @string_zipper.Position::new(0, 6) // Line 0, character 6
  let new_zipper = zipper.goto_position(position)
  inspect(new_zipper.offset(), content="6")
}
```

### Text Editing

```moonbit
test "insert text" {
  let zipper = @string_zipper.StringZipper::of_string("Hello World")
  let zipper2 = zipper.insert("Beautiful ")
  inspect(zipper2.to_string(), content="Beautiful Hello World")
}

test "apply text change - replace World with MoonBit" {
  let zipper = @string_zipper.StringZipper::of_string("Hello World")
  let start_pos = @string_zipper.Position::new(0, 6)
  let end_pos = @string_zipper.Position::new(0, 11)
  let range = @string_zipper.Range::new(start_pos, end_pos)
  let zipper3 = zipper.apply_change(range, replacement="MoonBit")
  inspect(zipper3.to_string(), content="Hello MoonBit")
}
```

### Line Operations

```moonbit
test "line navigation" {
  let zipper = @string_zipper.StringZipper::of_string("line1\nline2\nline3")

  // Go to line 1 (0-based)
  let zipper2 = zipper.goto_line(1)
  inspect(zipper2.offset(), content="6")

  // Go to end of document
  let zipper3 = zipper.goto_end()
  let final_zipper = zipper3.insert("!")
  inspect(final_zipper.to_string(), content="line1\nline2\nline3!")
}
```

## Features

- **Simplified API**: No encoding parameters needed - MoonBit strings are natively UTF-16
- **Direct String Views**: Uses MoonBit's `@string.View` directly for efficiency
- **Unicode Support**: Full Unicode support through MoonBit's native string handling
- **Production Ready**: Uses MoonBit standard library functions
- **LSP Compatible**: Character positions correspond to UTF-16 code units (standard in LSP)
- **Efficient Navigation**: O(1) character advance, O(n) for line operations
- **Memory Efficient**: Uses string views to avoid copying
- **Line Tracking**: Maintains line numbers automatically
- **Immutable**: All operations return new zipper instances

## API Reference

### Core Functions

| Function                                  | Description                        | Example                                              |
| ----------------------------------------- | ---------------------------------- | ---------------------------------------------------- |
| `StringZipper::of_string(text)`           | Create zipper from string          | `StringZipper::of_string("hello")`                   |
| `zipper.to_string()`                      | Convert zipper to string           | `zipper.to_string()`                                 |
| `zipper.offset()`                         | Get current position offset        | `zipper.offset()`                                    |
| `zipper.insert(text)`                     | Insert text at position            | `zipper.insert(" world")`                            |
| `zipper.goto_position(position)`          | Navigate to position               | `zipper.goto_position(Position::new(0, 5))`          |
| `zipper.goto_line(line)`                  | Navigate to line                   | `zipper.goto_line(1)`                                |
| `zipper.goto_end()`                       | Navigate to end                    | `zipper.goto_end()`                                  |
| `zipper.apply_change(range, replacement)` | Apply text change                  | `zipper.apply_change(range, replacement="new text")` |
| `drop_until(start, end)`                  | Delete text between positions      | `drop_until(zipper1, zipper2)`                       |
| `zipper.squash()`                         | Squash and return (zipper, string) | `let (z, s) = zipper.squash()`                       |

### Utility Functions

| Function                                 | Description                          |
| ---------------------------------------- | ------------------------------------ |
| `zipper.to_string_debug()`               | Debug representation                 |
| `add_buffer_between(buffer, start, end)` | Add text between positions to buffer |

## Types

The library defines the following types for position and range operations:

- `Position`: Represents a position in a text document with line (0-based) and character (0-based, UTF-16 code units) fields
- `Range`: Represents a range with start and end Position values
- `StringZipper`: The main data structure for efficient text editing operations

## Use Cases

This library is ideal for:

- Language Server Protocol (LSP) implementations
- Text editors and IDEs
- Code transformation tools
- Any application requiring efficient text manipulation with cursor tracking

## Advantages of the MoonBit Version

1. **Simplified API**: No encoding parameters needed
2. **Native Performance**: Leverages MoonBit's native UTF-16 string handling
3. **Type Safety**: Strong type system prevents encoding-related bugs
4. **Modern Design**: Uses MoonBit's string views for zero-copy operations
5. **LSP Ready**: Character positions are UTF-16 code units by default
