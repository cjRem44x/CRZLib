# CRZLib

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Zig Version](https://img.shields.io/badge/Zig-0.13%2B-orange.svg)](https://ziglang.org/)
[![CI](https://github.com/cjRem44x/CRZLib/workflows/CI/badge.svg)](https://github.com/cjRem44x/CRZLib/actions)

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

### Using Zig's Package Manager (Recommended)

1. Add CRZLib to your `build.zig.zon`:
```zig
.{
    .name = "my-project",
    .version = "0.1.0",
    .dependencies = .{
        .crzlib = .{
            .url = "https://github.com/cjRem44x/CRZLib/archive/refs/tags/v0.1.0.tar.gz",
            // Add the hash after first build attempt
        },
    },
}
```

2. Add to your `build.zig`:
```zig
const crzlib_dep = b.dependency("crzlib", .{
    .target = target,
    .optimize = optimize,
});
exe.root_module.addImport("crzlib", crzlib_dep.module("crzlib"));
```

### Manual Installation

1. Clone the repository:
```bash
git clone https://github.com/cjRem44x/CRZLib.git
```

2. Add to your `build.zig`:
```zig
const crzlib_module = b.addModule("crzlib", .{
    .root_source_file = b.path("path/to/CRZLib/src/crzlib.zig"),
});
exe.root_module.addImport("crzlib", crzlib_module);
```

## Usage Examples

### File Operations
```zig
const std = @import("std");
const crz = @import("crzlib");

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
const crz = @import("crzlib");

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
const crz = @import("crzlib");

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
const crz = @import("crzlib");

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
const crz = @import("crzlib");

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

## Building and Testing

```bash
# Run tests
zig build test

# Build all examples
zig build examples

# Run a specific example
zig build run-file_ops
zig build run-string_ops
zig build run-math_funcs
zig build run-benchmark

# Generate documentation
zig build docs
```

## Examples

Check out the [examples](examples/) directory for comprehensive usage examples:
- `file_ops.zig` - File operations
- `string_ops.zig` - String manipulation
- `math_funcs.zig` - Mathematical functions
- `benchmark.zig` - Allocator benchmarking

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

CJ Remillard

## Acknowledgments

- Zig community for inspiration and support
- Contributors and users of the library
