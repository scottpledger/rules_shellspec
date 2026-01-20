"""Unit tests for shellspec versions.bzl

See https://bazel.build/rules/testing#testing-starlark-utilities
"""

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//shellspec/private:versions.bzl", "DEFAULT_SHELLSPEC_VERSION", "SHELLSPEC_VERSIONS")

def _default_version_exists_test_impl(ctx):
    """Test that the default version exists in the versions map."""
    env = unittest.begin(ctx)
    asserts.true(
        env,
        DEFAULT_SHELLSPEC_VERSION in SHELLSPEC_VERSIONS,
        "Default version {} must exist in SHELLSPEC_VERSIONS".format(DEFAULT_SHELLSPEC_VERSION),
    )
    return unittest.end(env)

_default_version_exists_test = unittest.make(_default_version_exists_test_impl)

def _versions_have_checksums_test_impl(ctx):
    """Test that all versions have SHA checksums."""
    env = unittest.begin(ctx)
    for version, checksum in SHELLSPEC_VERSIONS.items():
        asserts.true(
            env,
            checksum.startswith("sha256-") or checksum.startswith("sha384-"),
            "Version {} must have a valid SHA checksum, got: {}".format(version, checksum),
        )
    return unittest.end(env)

_versions_have_checksums_test = unittest.make(_versions_have_checksums_test_impl)

def _at_least_one_version_test_impl(ctx):
    """Test that at least one version is defined."""
    env = unittest.begin(ctx)
    asserts.true(
        env,
        len(SHELLSPEC_VERSIONS) > 0,
        "At least one ShellSpec version must be defined",
    )
    return unittest.end(env)

_at_least_one_version_test = unittest.make(_at_least_one_version_test_impl)

def versions_test_suite(name):
    """Creates the test suite for versions.bzl tests.

    Args:
        name: The name of the test suite.
    """
    unittest.suite(
        name,
        _default_version_exists_test,
        _versions_have_checksums_test,
        _at_least_one_version_test,
    )
