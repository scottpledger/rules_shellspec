"""Linter aspect definitions for rules_shellspec repository."""

load("@aspect_rules_lint//lint:lint_test.bzl", "lint_test")
load("@aspect_rules_lint//lint:shellcheck.bzl", "lint_shellcheck_aspect")

# ShellCheck aspect for linting shell scripts
# Visits sh_binary, sh_library, and sh_test rules
shellcheck = lint_shellcheck_aspect(
    binary = "@multitool//tools/shellcheck",
    config = Label("//:.shellcheckrc"),
)

# Rule factory for creating shellcheck lint tests
shellcheck_test = lint_test(aspect = shellcheck)
