@echo off
REM Run tests for CRZLib from the project root
cd /d "%~dp0.."
zig build test --summary all
