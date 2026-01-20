"""Public API for rules_shellspec.

This module provides the shellspec_test rule for testing shell scripts
using the ShellSpec BDD testing framework.
"""

load("//shellspec/private:shellspec_test.bzl", _shellspec_test = "shellspec_test")

shellspec_test = _shellspec_test
