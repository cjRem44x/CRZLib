# Security Policy

## Supported Versions

We release patches for security vulnerabilities in the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 0.1.x   | :white_check_mark: |

## Reporting a Vulnerability

The CRZLib team takes security bugs seriously. We appreciate your efforts to responsibly disclose your findings.

### How to Report a Security Vulnerability

**Please do not report security vulnerabilities through public GitHub issues.**

Instead, please report security vulnerabilities by email to:

**[INSERT SECURITY CONTACT EMAIL]**

You should receive a response within 48 hours. If for some reason you do not, please follow up via email to ensure we received your original message.

### What to Include

Please include the following information in your report:

- Type of issue (e.g., buffer overflow, code injection, etc.)
- Full paths of source file(s) related to the manifestation of the issue
- The location of the affected source code (tag/branch/commit or direct URL)
- Any special configuration required to reproduce the issue
- Step-by-step instructions to reproduce the issue
- Proof-of-concept or exploit code (if possible)
- Impact of the issue, including how an attacker might exploit it

### Response Process

1. **Confirmation**: We'll confirm receipt of your vulnerability report
2. **Investigation**: We'll investigate and validate the vulnerability
3. **Fix Development**: We'll develop a fix for the vulnerability
4. **Testing**: The fix will be tested thoroughly
5. **Release**: We'll release a patched version
6. **Disclosure**: We'll publicly disclose the vulnerability

### Timeline

- **Initial Response**: Within 48 hours
- **Status Update**: Within 7 days
- **Fix Target**: Within 30 days for critical issues, 90 days for others

### Preferred Languages

We prefer all communications to be in English.

## Security Best Practices

When using CRZLib:

### Memory Safety

- Always use proper allocators and free memory when done
- Check return values for error conditions
- Use the provided error handling mechanisms
- Be aware of buffer sizes when using file operations

### Input Validation

- Validate file paths before passing to file operations
- Sanitize user input before using string operations
- Check numeric parsing results before using them

### System Commands

- Be cautious when using `c_system` or `term` functions
- Never pass unsanitized user input to system commands
- Consider security implications of executing system commands

### File Operations

- Verify file paths are within expected directories
- Check file permissions before operations
- Handle file operation errors appropriately

## Known Security Considerations

### Platform-Specific Functions

Some functions (like `open_url` and `open_file`) are Windows-specific and execute system commands. Use these with caution:

- Only use with trusted input
- Validate URLs and file paths
- Consider alternative cross-platform solutions for production use

### C Standard Library

The library uses C's `system()` function in `c_system()`:

- This function has inherent security risks
- Never pass unsanitized user input
- Consider using Zig's native process execution instead

### Random Number Generation

The library uses cryptographic random number generation (`std.crypto.random`), which is secure for most use cases. However:

- For security-critical applications, review the implementation
- Consider using additional entropy sources for high-security scenarios

## Disclosure Policy

When we receive a security bug report, we will:

1. Confirm the problem and determine affected versions
2. Audit code to find similar problems
3. Prepare fixes for all supported versions
4. Release new security fix versions as soon as possible

## Comments on This Policy

If you have suggestions on how this process could be improved, please submit a pull request or open an issue to discuss.

## Security Updates

Subscribe to release notifications on GitHub to stay informed about security updates.

## Attribution

We will credit security researchers who responsibly disclose vulnerabilities in our release notes and security advisories (unless you prefer to remain anonymous).

Thank you for helping keep CRZLib and its users safe!
