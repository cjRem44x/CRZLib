#!/bin/bash
# Run tests for CRZLib from the project root
cd "$(dirname "$0")/.."
zig build test --summary all
