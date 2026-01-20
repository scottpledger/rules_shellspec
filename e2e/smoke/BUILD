"""End-to-end smoke tests for rules_shellspec.

This package provides a simple way to test rules_shellspec as an external workspace.
"""

load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("@rules_shell//shell:sh_library.bzl", "sh_library")
load("@rules_shellspec//shellspec:defs.bzl", "shellspec_test")

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

# Build test to verify the rule can be loaded and instantiated
build_test(
    name = "smoke_test",
    targets = [
        ":greet_lib",
    ],
)
