"""End-to-end smoke tests for rules_shellspec.

This package provides a simple way to test rules_shellspec as an external workspace.
"""

load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("@rules_shell//shell:sh_binary.bzl", "sh_binary")
load("@rules_shell//shell:sh_library.bzl", "sh_library")
load("@rules_shellspec//shellspec:defs.bzl", "shellspec_test")

# =============================================================================
# sh_library tests
# =============================================================================

# Example shell library to test
sh_library(
    name = "greet_lib",
    srcs = ["greet.sh"],
)

# ShellSpec test for the shell library
shellspec_test(
    name = "greet_test",
    srcs = ["greet_spec.sh"],
    deps = [":greet_lib"],
)

# =============================================================================
# sh_binary tests
# =============================================================================

# Example shell binary to test
sh_binary(
    name = "calculator",
    srcs = ["calculator.sh"],
)

# ShellSpec test for the shell binary
shellspec_test(
    name = "calculator_test",
    srcs = ["calculator_spec.sh"],
    deps = [":calculator"],
)

# =============================================================================
# Build verification
# =============================================================================

# Build test to verify the rule can be loaded and instantiated
build_test(
    name = "smoke_test",
    targets = [
        ":greet_lib",
        ":calculator",
    ],
)
