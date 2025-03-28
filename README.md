# CRZLib

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive utility library for Zig that provides a collection of commonly used functions for file operations, string manipulation, mathematical calculations, and more.

## Overview

CRZLib is designed to simplify common programming tasks in Zig by providing a set of well-tested, efficient utility functions. It aims to reduce boilerplate code and improve developer productivity while maintaining Zig's focus on safety and performance.

## Features

### File and Directory Operations
- `read_file`: Read file contents line by line
- `is_file`: Check if a path points to a file
- `is_dir`: Check if a path points to a directory
- `list_dir`: List contents of a directory

### String Manipulation
- `streql`: Compare two strings for equality
- `strcat`: Concatenate two strings
- `strsplit`: Split a string based on a pattern
- `strout`: Print string without newline
- `log`: Print string with newline
- `cin`: Read input from console with prompt

### Mathematical Functions
- `sqrt_f64`: Calculate square root using Newton's method
- `inv_sqrt`: Calculate inverse square root
- `pow`: Calculate power of a number
- `rng_*`: Random number generation for various integer types

### System Operations
- `get_args`: Get command line arguments
- `c_system`: Execute system commands
- `term`: Execute terminal commands
- `open_url`: Open URLs in default browser (Windows)
- `open_file`: Open files with default application (Windows)

### Number Parsing
- `str_*`: Convert strings to various numeric types (i8, i16, i32, i64, i128, f32, f64, f128)

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/CRZLib.git
```

2. Add the library to your Zig project:
```zig
const crzlib = @import("path/to/CRZLib/crzlib.zig");
```

## Usage Examples

### File Operations
```zig
const allocator = std.heap.page_allocator;
const lines = try crzlib.read_file(allocator, "example.txt");
defer allocator.free(lines);

for (lines) |line| {
    crzlib.log(line);
}
```

### String Manipulation
```zig
const allocator = std.heap.page_allocator;
const result = try crzlib.strcat(allocator, "Hello, ", "World!");
defer allocator.free(result);
crzlib.log(result);
```

### Mathematical Functions
```zig
const sqrt_result = crzlib.sqrt_f64(16.0);
const random_num = crzlib.rng_i32(1, 100);
```

### System Commands
```zig
try crzlib.term(&[_][]const u8{ "ls", "-la" });
```

## Memory Management

CRZLib follows Zig's memory management principles:
- Functions that allocate memory require an allocator parameter
- Memory must be freed by the caller using `defer allocator.free()`
- Arena allocator is used internally where appropriate for better performance

## Error Handling

The library uses Zig's error handling system:
- Functions that can fail return error unions
- Error messages are formatted with the CRZLib prefix
- Platform-specific functions (like `open_url`) handle errors gracefully

## Performance Considerations

- The library is designed for efficiency and minimal overhead
- Uses appropriate allocators for different scenarios
- Implements optimized algorithms for mathematical functions
- Minimizes unnecessary allocations and copies

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. By contributing, you agree that your contributions will be licensed under the same MIT License as the project.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

The MIT License is a permissive license that is short and to the point. It lets people do anything they want with your code as long as they provide attribution back to you and don't hold you liable.

### What you can do with this code:
- Use it commercially
- Modify it
- Distribute it
- Use it privately
- Sublicense it

### What you must do:
- Include the original copyright notice
- Include the license text

### What you cannot do:
- Hold the author liable for any issues

## Author

CJ Remillard

## Acknowledgments

- Built with Zig programming language
- Uses Zig's standard library for core functionality
- Inspired by various utility libraries in other languages
