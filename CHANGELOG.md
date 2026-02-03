# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Professional project structure with src/, tests/, and examples/ directories
- Comprehensive build system with build.zig
- Package manifest (build.zig.zon) for Zig package manager
- Unit tests using Zig's test framework
- Example programs demonstrating library usage
- CI/CD pipeline with GitHub Actions
- Documentation: CONTRIBUTING.md, CODE_OF_CONDUCT.md, SECURITY.md
- GitHub issue and pull request templates

#### New String Operations
- `trim`, `trim_left`, `trim_right` - Whitespace trimming
- `to_upper`, `to_lower` - Case conversion
- `contains` - Substring check
- `starts_with`, `ends_with` - Prefix/suffix checks
- `replace` - Replace all occurrences of a pattern
- `repeat` - Repeat a string n times
- `count_substr` - Count substring occurrences
- `index_of` - Find substring index

#### New Mathematical Functions
- `tan_f32`, `tan_f64` - Tangent functions
- `min`, `max` - Generic min/max
- `clamp` - Clamp value to range
- `factorial` - Factorial calculation
- `gcd`, `lcm` - Greatest common divisor / Least common multiple
- `is_prime` - Primality testing
- `deg_to_rad`, `rad_to_deg` - Angle conversions
- `lerp`, `inv_lerp` - Linear interpolation
- `map_range` - Map value between ranges
- `sign` - Sign function

#### New File Operations
- `write_file` - Write content to file
- `append_file` - Append to file
- `file_size` - Get file size
- `exists` - Check if path exists

#### New Array/Slice Utilities
- `sum` - Sum all elements
- `avg` - Calculate average
- `reverse` - Reverse slice in place
- `binary_search` - Binary search in sorted slice
- `slice_min`, `slice_max` - Find min/max values

#### New Random Number Generation
- `rng_f32`, `rng_f64` - Random floats [0, 1)
- `rng_f32_range`, `rng_f64_range` - Random floats in range
- `rng_bool` - Random boolean
- `shuffle` - Shuffle array in place
- `rng_choice` - Pick random element from slice

#### New Bit Manipulation Utilities
- `popcount` - Count set bits
- `leading_zeros`, `trailing_zeros` - Count zeros
- `is_power_of_two` - Check if power of two
- `next_power_of_two` - Find next power of two

#### New Tests and Examples
- Added 65+ new unit tests for all new utilities
- Added `new_utils.zig` example demonstrating all new features

### Changed
- Reorganized project structure for better maintainability
- Updated README with installation instructions and better examples
- Improved documentation with build/test instructions
- Updated for Zig 0.16 compatibility

## [0.1.0] - 2024-12-03

### Added
- File system operations (read_file, is_file, is_dir)
- String operations (streql, strcat, strsplit)
- Mathematical functions (sqrt, inv_sqrt, pow)
- Trigonometric functions (sin, cos) for f32 and f64
- Random number generation (rng_i32, rng_i64, rng_i128, rng_usize)
- Number parsing (str_i8 through str_i128, str_f32 through str_f128)
- Console I/O operations (strout, log, cin)
- Command line argument parsing
- System command execution
- Thread sleep functions (sleep_ms, sleep_sec)
- Error reporting utilities
- MIT License

### Fixed
- Updated for Zig 0.15+ compatibility
- Fixed file reader API for new Zig versions
- Improved cross-platform support

[Unreleased]: https://github.com/cjRem44x/CRZLib/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/cjRem44x/CRZLib/releases/tag/v0.1.0
