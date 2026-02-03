# CRZLib

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Zig Version](https://img.shields.io/badge/Zig-0.13%2B-orange.svg)](https://ziglang.org/)
[![CI](https://github.com/cjRem44x/CRZLib/workflows/CI/badge.svg)](https://github.com/cjRem44x/CRZLib/actions)

A comprehensive utility library for Zig that simplifies common programming tasks.

## Features

### File System Operations
- File reading with line-by-line support
- File writing and appending
- File and directory existence checks
- File size retrieval
- Memory-safe file operations

### String Operations
- String comparison, concatenation, splitting
- Trimming (trim, trim_left, trim_right)
- Case conversion (to_upper, to_lower)
- Substring operations (contains, starts_with, ends_with, index_of)
- String replacement and repetition
- Substring counting

### Mathematical Functions
- Square root (f32, f64, f128)
- Inverse square root (f32, f64, f128)
- Trigonometric functions (sin, cos, tan)
- Power, factorial, GCD, LCM
- Min, max, clamp, sign
- Primality testing
- Angle conversions (degrees/radians)
- Linear interpolation (lerp, inv_lerp, map_range)

### Random Number Generation
- Integer generation (i32, i64, i128, usize)
- Float generation (f32, f64) with range support
- Random boolean
- Array shuffle and random choice

### Array/Slice Utilities
- Sum and average
- Min/max finding
- Reverse in place
- Binary search

### Bit Manipulation
- Population count (popcount)
- Leading/trailing zeros
- Power of two operations

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

    // Trimming and case conversion
    const trimmed = crz.trim("  hello  "); // "hello"
    const upper = try crz.to_upper(allocator, "hello");
    defer allocator.free(upper);

    // String checks
    if (crz.contains("hello world", "world")) {
        crz.log("Found!");
    }

    // Replace
    const replaced = try crz.replace(allocator, "foo bar foo", "foo", "baz");
    defer allocator.free(replaced); // "baz bar baz"
}
```

### Mathematical Functions
```zig
const crz = @import("crzlib");

pub fn main() void {
    // Square root and inverse
    const sqrt = crz.sqrt_f64(16.0);       // 4.0
    const inv_sqrt = crz.inv_sqrt_f64(16.0); // 0.25

    // Trigonometry
    const angle = crz.deg_to_rad(@as(f64, 45.0));
    const tan_val = crz.tan_f64(angle);    // 1.0

    // Min, max, clamp
    const clamped = crz.clamp(@as(i32, 15), 0, 10); // 10

    // Number theory
    const fact = crz.factorial(5);         // 120
    const g = crz.gcd(@as(i32, 48), 18);   // 6
    const prime = crz.is_prime(17);        // true

    // Interpolation
    const mid = crz.lerp(@as(f64, 0), 100, 0.5); // 50
}
```

### Random Number Generation
```zig
const crz = @import("crzlib");

pub fn main() void {
    // Integer random
    const rand_int = crz.rng_i32(1, 100);

    // Float random [0, 1)
    const rand_f = crz.rng_f64();

    // Float in range
    const rand_range = crz.rng_f64_range(5.0, 10.0);

    // Random boolean
    if (crz.rng_bool()) {
        crz.log("Heads!");
    }

    // Shuffle array
    var arr = [_]i32{ 1, 2, 3, 4, 5 };
    crz.shuffle(&arr);

    // Pick random element
    const choice = crz.rng_choice(&arr);
}
```

### Array/Slice Utilities
```zig
const crz = @import("crzlib");

pub fn main() void {
    const numbers = [_]i32{ 1, 2, 3, 4, 5 };

    const total = crz.sum(&numbers);       // 15
    const average = crz.avg(&numbers);     // 3.0
    const minimum = crz.slice_min(&numbers); // 1
    const maximum = crz.slice_max(&numbers); // 5

    // Binary search (sorted array)
    const sorted = [_]i32{ 1, 3, 5, 7, 9 };
    const idx = crz.binary_search(&sorted, 5); // 2

    // Reverse in place
    var to_reverse = [_]i32{ 1, 2, 3 };
    crz.reverse(&to_reverse); // { 3, 2, 1 }
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
zig build run-new_utils

# Generate documentation
zig build docs
```

## Examples

Check out the [examples](examples/) directory for comprehensive usage examples:
- `file_ops.zig` - File operations
- `string_ops.zig` - String manipulation
- `math_funcs.zig` - Mathematical functions
- `benchmark.zig` - Allocator benchmarking
- `new_utils.zig` - New utilities (string, math, array, random, bit manipulation)

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

CJ Remillard

## Acknowledgments

- Zig community for inspiration and support
- Contributors and users of the library
