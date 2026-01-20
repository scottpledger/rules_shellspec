"""Repository rules for downloading ShellSpec.

These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("//shellspec/private:versions.bzl", "DEFAULT_SHELLSPEC_VERSION", "SHELLSPEC_VERSIONS")

def rules_shellspec_dependencies():
    """Fetch dependencies required by rules_shellspec.

    Users should call this in their WORKSPACE file.
    """
    # The minimal version of bazel_skylib we require
    maybe(
        http_archive,
        name = "bazel_skylib",
        sha256 = "6e78f0e57de26801f6f564fa7c4a48dc8b36873e416257a92bbb0937eeac8446",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.8.2/bazel-skylib-1.8.2.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.8.2/bazel-skylib-1.8.2.tar.gz",
        ],
    )

    # rules_shell for sh_library/sh_binary compatibility
    maybe(
        http_archive,
        name = "rules_shell",
        sha256 = "19f11c1a7cde3d88e7a11c80b9411fef0fec7f5c28d1df2b1eaf9f3e756d5cfe",
        strip_prefix = "rules_shell-0.4.1",
        urls = [
            "https://github.com/bazelbuild/rules_shell/releases/download/v0.4.1/rules_shell-v0.4.1.tar.gz",
        ],
    )

_BUILD_FILE_CONTENT = '''
package(default_visibility = ["//visibility:public"])

# Filegroup containing all shellspec files for runfiles
filegroup(
    name = "shellspec_files",
    srcs = glob([
        "shellspec",
        "lib/**",
        "libexec/**",
    ]),
)
'''

def _shellspec_repository_impl(repository_ctx):
    """Downloads and extracts ShellSpec."""
    version = repository_ctx.attr.version
    if version not in SHELLSPEC_VERSIONS:
        fail("Unknown ShellSpec version: {}. Known versions: {}".format(
            version,
            ", ".join(SHELLSPEC_VERSIONS.keys()),
        ))

    url = "https://github.com/shellspec/shellspec/archive/refs/tags/{version}.tar.gz".format(
        version = version,
    )

    repository_ctx.download_and_extract(
        url = url,
        integrity = SHELLSPEC_VERSIONS[version],
        stripPrefix = "shellspec-{}".format(version),
    )

    repository_ctx.file("BUILD.bazel", _BUILD_FILE_CONTENT)

shellspec_repository = repository_rule(
    implementation = _shellspec_repository_impl,
    attrs = {
        "version": attr.string(
            default = DEFAULT_SHELLSPEC_VERSION,
            doc = "The version of ShellSpec to download.",
        ),
    },
    doc = "Downloads ShellSpec from GitHub releases.",
)

def shellspec_register(name = "shellspec", version = DEFAULT_SHELLSPEC_VERSION):
    """Convenience macro to download ShellSpec.

    Args:
        name: The name of the repository to create (default: "shellspec")
        version: The version of ShellSpec to download (default: latest supported)
    """
    shellspec_repository(
        name = name,
        version = version,
    )
