"""Module extensions for bzlmod.

Provides ShellSpec as a repository for use with Bazel modules.
"""

load("@bazel_skylib//lib:versions.bzl", bazel_skylib_versions = "versions")
load("//shellspec/private:versions.bzl", "DEFAULT_SHELLSPEC_VERSION", "SHELLSPEC_VERSIONS")
load(":repositories.bzl", "shellspec_repository")

_DEFAULT_NAME = "shellspec"

shellspec_toolchain = tag_class(attrs = {
    "name": attr.string(
        doc = "Base name for the generated repository.",
        default = _DEFAULT_NAME,
    ),
    "version": attr.string(
        doc = "Version of ShellSpec to download.",
        default = DEFAULT_SHELLSPEC_VERSION,
    ),
})

def _shellspec_extension_impl(module_ctx):
    registrations = {}
    for mod in module_ctx.modules:
        for toolchain in mod.tags.toolchain:
            if toolchain.name != _DEFAULT_NAME and not mod.is_root:
                fail("""\
Only the root module may override the default name for the ShellSpec repository.
This prevents conflicting registrations in the global namespace of external repos.
""")
            if toolchain.name not in registrations:
                registrations[toolchain.name] = []
            registrations[toolchain.name].append(toolchain.version)

    for name, versions in registrations.items():
        if len(versions) > 1:
            # Select the highest version using simple string comparison
            # (works for semver-like version strings)
            selected = sorted(versions, reverse = True)[0]

            # buildifier: disable=print
            print("NOTE: ShellSpec {} has multiple versions {}, selected {}".format(
                name,
                versions,
                selected,
            ))
        else:
            selected = versions[0]

        if selected not in SHELLSPEC_VERSIONS:
            fail("Unknown ShellSpec version: {}. Known versions: {}".format(
                selected,
                ", ".join(SHELLSPEC_VERSIONS.keys()),
            ))

        shellspec_repository(
            name = name,
            version = selected,
        )

    # extension_metadata with reproducible was added in Bazel 7.1
    # For compatibility with Bazel 6.x, we check the version
    if bazel_skylib_versions.is_at_least("7.1.0", native.bazel_version):
        return module_ctx.extension_metadata(
            reproducible = True,
        )
    return None

shellspec = module_extension(
    implementation = _shellspec_extension_impl,
    tag_classes = {"toolchain": shellspec_toolchain},
    os_dependent = False,
    arch_dependent = False,
)
