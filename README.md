# CRZLib

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive utility library for Zig that simplifies common programming tasks.

## Features

### File System Operations
- File reading with line-by-line support
- File and directory existence checks
- Memory-safe file operations

### String Operations
- String comparison
- String concatenation
- String splitting
- Memory-safe string manipulation

### Mathematical Functions
- Square root (f32, f64, f128)
- Inverse square root (f32, f64, f128)
- Power function
- Random number generation (i32, i64, i128, usize)

### System Operations
- Command line argument parsing
- System command execution
- OS-specific operations (Windows support)
- URL and file opening

### Console I/O
- Formatted output
- Input with prompts
- Error reporting
- Cross-platform support

### Number Parsing
- String to integer conversion (i8-i128)
- String to float conversion (f32-f128)
- Safe parsing with default values

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/CRZLib.git
```

2. Add to your build.zig:
```zig
const crzlib = @import("path/to/CRZLib/crzlib.zig");
```

## Usage Examples

### File Operations
```zig
const std = @import("std");
const crz = @import("crzlib.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const lines = try crz.read_file(allocator, "input.txt");
    defer allocator.free(lines);

    for (lines) |line| {
        crz.log(line);
    }
}
```

### String Operations
```zig
const std = @import("std");
const crz = @import("crzlib.zig");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    
    // String concatenation
    const result = try crz.strcat(allocator, "Hello ", "World");
    defer allocator.free(result);
    
    // String splitting
    const parts = try crz.strsplit("a,b,c", ",");
    defer allocator.free(parts);
    
    crz.log(result);
    for (parts) |part| {
        crz.log(part);
    }
}
```

### Mathematical Functions
```zig
const crz = @import("crzlib.zig");

pub fn main() void {
    // Square root
    const sqrt = crz.sqrt_f64(16.0);
    
    // Inverse square root
    const inv_sqrt = crz.inv_sqrt_f64(16.0);
    
    // Random numbers
    const random = crz.rng_i32(1, 100);
    
    // Power function
    const power = crz.pow(2, 3); // 8
}
```

### Console I/O
```zig
const crz = @import("crzlib.zig");

pub fn main() !void {
    var buf: [256]u8 = undefined;
    
    // Print without newline
    crz.strout("Enter your name: ");
    
    // Read input
    const name = try crz.cin(&buf, "");
    
    // Print with newline
    crz.log("Hello, ");
    crz.log(name);
}
```

### Number Parsing
```zig
const crz = @import("crzlib.zig");

pub fn main() void {
    // Integer parsing
    const num = crz.str_i32("42");
    
    // Float parsing
    const float = crz.str_f64("42.5");
}
```

## Performance

The library is designed for efficiency:
- Uses fast algorithms for mathematical operations
- Minimizes memory allocations
- Provides safe memory management
- Optimized for common use cases

## Error Handling

- All functions that can fail return error unions
- Memory operations are safe and properly managed
- File operations include proper error checking
- String operations handle edge cases

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

CJ Remillard

## Acknowledgments

- Zig community for inspiration and support
- Contributors and users of the library
