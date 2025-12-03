# Contributing to CRZLib

Thank you for your interest in contributing to CRZLib! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [How to Contribute](#how-to-contribute)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Enhancements](#suggesting-enhancements)

## Code of Conduct

This project adheres to a Code of Conduct. By participating, you are expected to uphold this code. Please read [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) for details.

## Getting Started

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/CRZLib.git
   cd CRZLib
   ```
3. Add the upstream repository:
   ```bash
   git remote add upstream https://github.com/cjRem44x/CRZLib.git
   ```

## How to Contribute

### Types of Contributions

We welcome various types of contributions:

- Bug fixes
- New features
- Documentation improvements
- Performance optimizations
- Test coverage improvements
- Example programs
- Code quality improvements

### Development Setup

1. Ensure you have Zig 0.13.0 or later installed
2. Run tests to verify your setup:
   ```bash
   zig build test
   ```
3. Build examples to ensure everything works:
   ```bash
   zig build examples
   ```

## Coding Standards

### Zig Style Guide

- Follow the official Zig style guide
- Use `zig fmt` to format your code before committing
- Use meaningful variable and function names
- Write clear, concise comments

### Naming Conventions

- **Functions**: `snake_case` (e.g., `read_file`, `sqrt_f64`)
- **Constants**: `SCREAMING_SNAKE_CASE` (e.g., `MAX_SIZE`)
- **Types**: `PascalCase` (e.g., `MyType`)
- **Type suffixes**: Use `_f32`, `_f64`, `_i32`, etc. for type-specific functions

### Documentation

- Every public function must have a doc comment (`///`)
- Include usage examples in doc comments
- Document function parameters and return values
- Explain error conditions and edge cases

Example:
```zig
/// Calculates the square root of a 64-bit float
/// Returns -1 for negative inputs
/// Example: const root = sqrt_f64(16.0);
pub fn sqrt_f64(n: f64) f64 {
    // Implementation
}
```

### Code Organization

- Group related functions together
- Use clear section headers with `//===` markers
- Keep functions focused and single-purpose
- Minimize dependencies on external libraries

## Testing Guidelines

### Writing Tests

- Write tests for all new functionality
- Use descriptive test names
- Test edge cases and error conditions
- Ensure tests are deterministic

Example:
```zig
test "sqrt_f64 handles positive numbers" {
    try testing.expectApproxEqAbs(@as(f64, 4.0), crz.sqrt_f64(16.0), 1e-10);
}

test "sqrt_f64 handles zero" {
    try testing.expectEqual(@as(f64, 0.0), crz.sqrt_f64(0.0));
}

test "sqrt_f64 handles negative numbers" {
    try testing.expectEqual(@as(f64, -1.0), crz.sqrt_f64(-1.0));
}
```

### Running Tests

```bash
# Run all tests
zig build test

# Run tests with verbose output
zig build test --summary all
```

## Pull Request Process

### Before Submitting

1. Update your fork with the latest upstream changes:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. Ensure all tests pass:
   ```bash
   zig build test
   ```

3. Format your code:
   ```bash
   zig fmt src/ tests/ examples/
   ```

4. Update documentation if needed
5. Add or update tests for your changes
6. Update CHANGELOG.md with your changes

### Submitting a Pull Request

1. Create a new branch for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes and commit them:
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

3. Push to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

4. Open a pull request on GitHub

### PR Requirements

- Clear, descriptive title
- Detailed description of changes
- Reference any related issues
- All tests must pass
- Code must be formatted with `zig fmt`
- Documentation must be updated
- CHANGELOG.md must be updated

### Commit Messages

Follow conventional commits:

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `test:` - Test additions or changes
- `refactor:` - Code refactoring
- `perf:` - Performance improvements
- `chore:` - Maintenance tasks

Examples:
```
feat: add string trimming function
fix: correct sqrt calculation for large numbers
docs: improve installation instructions
test: add tests for random number generation
```

## Reporting Bugs

### Before Reporting

- Check if the bug has already been reported
- Verify the bug exists in the latest version
- Collect relevant information

### Bug Report Template

Use the bug report template in `.github/ISSUE_TEMPLATE/bug_report.md`

Include:
- Clear description of the issue
- Steps to reproduce
- Expected behavior
- Actual behavior
- Zig version
- Operating system
- Minimal code example

## Suggesting Enhancements

### Enhancement Template

Use the feature request template in `.github/ISSUE_TEMPLATE/feature_request.md`

Include:
- Clear description of the enhancement
- Use cases and benefits
- Possible implementation approach
- Examples of similar features in other libraries

## Questions?

If you have questions, feel free to:
- Open a discussion on GitHub
- Create an issue with the "question" label
- Contact the maintainers

## License

By contributing to CRZLib, you agree that your contributions will be licensed under the MIT License.

## Recognition

Contributors will be acknowledged in the project documentation and CHANGELOG.

Thank you for contributing to CRZLib!
