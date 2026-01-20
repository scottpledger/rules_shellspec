# Smoke Test

This directory contains end-to-end tests for rules_shellspec.

## Running Tests

```bash
cd e2e/smoke
bazel test //...
```

## What's Tested

- `shellspec_test` rule can be loaded from the external workspace
- Basic ShellSpec tests run successfully
- Shell library dependencies are properly resolved
