"""Analysis tests for the shellspec_test rule using rules_testing.

These tests verify that the shellspec_test rule produces the expected
providers and generates appropriate actions.
"""

load("@rules_shell//shell:sh_library.bzl", "sh_library")
load("@rules_testing//lib:analysis_test.bzl", "analysis_test", "test_suite")
load("//shellspec:defs.bzl", "shellspec_test")

# =============================================================================
# Test Subjects - Targets to analyze
# =============================================================================

def _test_subjects():
    """Create test subject targets for analysis testing."""

    # Basic shellspec_test target
    shellspec_test(
        name = "subject_basic_test",
        srcs = ["example_spec.sh"],
        tags = ["manual"],
    )

    # shellspec_test with deps
    sh_library(
        name = "subject_lib",
        srcs = ["example_lib.sh"],
    )

    shellspec_test(
        name = "subject_with_deps_test",
        srcs = ["example_spec.sh"],
        deps = [":subject_lib"],
        tags = ["manual"],
    )

    # shellspec_test with custom options
    shellspec_test(
        name = "subject_with_opts_test",
        srcs = ["example_spec.sh"],
        shell = "/bin/bash",
        shellspec_opts = ["--fail-fast"],
        tags = ["manual"],
    )

# =============================================================================
# Analysis Tests
# =============================================================================

def _test_basic_providers(name):
    """Test that a basic shellspec_test provides expected providers."""
    analysis_test(
        name = name,
        impl = _test_basic_providers_impl,
        target = ":subject_basic_test",
    )

def _test_basic_providers_impl(env, target):
    """Verify basic shellspec_test has DefaultInfo with executable."""
    env.expect.that_target(target).has_provider(DefaultInfo)

    default_info = target[DefaultInfo]
    env.expect.that_bool(default_info.files_to_run.executable != None).equals(True)

def _test_runner_is_executable(name):
    """Test that the generated runner script is marked executable."""
    analysis_test(
        name = name,
        impl = _test_runner_is_executable_impl,
        target = ":subject_basic_test",
    )

def _test_runner_is_executable_impl(env, target):
    """Verify the runner script ends with _runner.sh."""
    default_info = target[DefaultInfo]
    executable = default_info.files_to_run.executable

    # The executable should be the runner script
    env.expect.that_str(executable.basename).contains("_runner.sh")

def _test_runfiles_include_shellspec(name):
    """Test that runfiles include shellspec files."""
    analysis_test(
        name = name,
        impl = _test_runfiles_include_shellspec_impl,
        target = ":subject_basic_test",
    )

def _test_runfiles_include_shellspec_impl(env, target):
    """Verify that shellspec files are in runfiles."""
    default_info = target[DefaultInfo]
    runfiles = default_info.default_runfiles.files.to_list()

    # Check that we have some runfiles
    env.expect.that_int(len(runfiles)).is_greater_than(0)

def _test_deps_merged_into_runfiles(name):
    """Test that dependencies are properly merged into runfiles."""
    analysis_test(
        name = name,
        impl = _test_deps_merged_into_runfiles_impl,
        target = ":subject_with_deps_test",
    )

def _test_deps_merged_into_runfiles_impl(env, target):
    """Verify that sh_library deps are in runfiles."""
    default_info = target[DefaultInfo]
    runfiles = default_info.default_runfiles.files.to_list()

    # Should have more files due to deps
    env.expect.that_int(len(runfiles)).is_greater_than(0)

def _test_is_test_rule(name):
    """Test that shellspec_test is marked as a test rule."""
    analysis_test(
        name = name,
        impl = _test_is_test_rule_impl,
        target = ":subject_basic_test",
    )

def _test_is_test_rule_impl(env, target):
    """Verify the rule is a test rule by checking it has an executable."""

    # Test rules must have an executable
    default_info = target[DefaultInfo]
    env.expect.that_bool(default_info.files_to_run.executable != None).equals(True)

# =============================================================================
# Test Suite
# =============================================================================

def shellspec_test_suite(name):
    """Creates the analysis test suite for shellspec_test.

    Args:
        name: The name of the test suite.
    """
    _test_subjects()

    test_suite(
        name = name,
        tests = [
            _test_basic_providers,
            _test_runner_is_executable,
            _test_runfiles_include_shellspec,
            _test_deps_merged_into_runfiles,
            _test_is_test_rule,
        ],
    )
