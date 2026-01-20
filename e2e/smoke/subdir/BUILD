"""Tests for shell targets in a subdirectory."""

load("@rules_shell//shell:sh_binary.bzl", "sh_binary")
load("@rules_shell//shell:sh_library.bzl", "sh_library")
load("@rules_shellspec//shellspec:defs.bzl", "shellspec_test")

# Shell library in a subdirectory
sh_library(
    name = "math_lib",
    srcs = ["math.sh"],
)

# ShellSpec test for the subdirectory library
shellspec_test(
    name = "math_test",
    srcs = ["math_spec.sh"],
    deps = [":math_lib"],
)

# Shell binary in a subdirectory
sh_binary(
    name = "counter",
    srcs = ["counter.sh"],
)

# ShellSpec test for the subdirectory binary
shellspec_test(
    name = "counter_test",
    srcs = ["counter_spec.sh"],
    deps = [":counter"],
)
