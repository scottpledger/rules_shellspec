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
        sha256 = "37cdfbc6faefea94f7b37760a305c98c08981116c2bc9e821e3b423221fad8c8",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.9.2/bazel-skylib-1.9.2.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.9.2/bazel-skylib-1.9.2.tar.gz",
        ],
    )

    # rules_shell for sh_library/sh_binary compatibility
    maybe(
        http_archive,
        name = "rules_shell",
        sha256 = "20721f63908879c083f94869e618ea8d4ff5edb91ff9a72a2ebee357fdbc352d",
        strip_prefix = "rules_shell-0.8.0",
        urls = [
            "https://github.com/bazelbuild/rules_shell/releases/download/v0.8.0/rules_shell-v0.8.0.tar.gz",
        ],
    )

    # bazel_lib for Windows launcher support
    maybe(
        http_archive,
        name = "bazel_lib",
        sha256 = "10f232c10df1ba5cbbbfbcde947090463348f0344d4153e25371b13ee3daf0ce",
        strip_prefix = "bazel-lib-3.7.1",
        urls = [
            "https://github.com/aspect-build/bazel-lib/releases/download/v3.7.1/bazel-lib-v3.7.1.tar.gz",
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
