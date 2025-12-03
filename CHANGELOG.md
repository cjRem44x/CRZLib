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

### Changed
- Reorganized project structure for better maintainability
- Updated README with installation instructions and better examples
- Improved documentation with build/test instructions

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
