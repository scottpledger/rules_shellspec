"""Public API for rules_shellspec.

This module provides the shellspec_test rule for testing shell scripts
using the ShellSpec BDD testing framework.

It also provides integration with aspect-build/rules_lint for formatting
ShellSpec test files with altshfmt.
"""

load("//shellspec:lint.bzl", _lint_shellspec_aspect = "lint_shellspec_aspect")
load("//shellspec/private:shellspec_test.bzl", _shellspec_test = "shellspec_test")

shellspec_test = _shellspec_test

# rules_lint integration
lint_shellspec_aspect = _lint_shellspec_aspect
