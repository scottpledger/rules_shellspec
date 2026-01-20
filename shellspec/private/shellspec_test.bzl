"""Implementation of the shellspec_test rule.

This rule runs ShellSpec tests against shell scripts and produces
Bazel-compatible test outputs.
"""

def _shellspec_test_impl(ctx):
    # Get the ShellSpec files (script + lib files)
    shellspec_files = ctx.files._shellspec_files

    # Find the main shellspec script
    shellspec_script = None
    for f in shellspec_files:
        if f.basename == "shellspec" and f.dirname.endswith("shellspec") or f.short_path.endswith("/shellspec"):
            shellspec_script = f
            break

    if not shellspec_script:
        # Fallback: look for shellspec in the file list
        for f in shellspec_files:
            if f.basename == "shellspec":
                shellspec_script = f
                break

    if not shellspec_script:
        fail("Could not find shellspec script in shellspec_files")

    # Collect all spec files
    spec_files = ctx.files.srcs

    # Create the test runner script
    runner = ctx.actions.declare_file(ctx.label.name + "_runner.sh")

    # Build the spec file paths for the runner
    spec_paths = " ".join([f.short_path for f in spec_files])

    # Get additional shellspec options
    shellspec_opts = " ".join(ctx.attr.shellspec_opts)

    # Expand the runner template
    ctx.actions.expand_template(
        template = ctx.file._runner_template,
        output = runner,
        substitutions = {
            "{{SHELLSPEC_BIN}}": shellspec_script.short_path,
            "{{SPEC_FILES}}": spec_paths,
            "{{SHELLSPEC_OPTS}}": shellspec_opts,
            "{{SHELL}}": ctx.attr.shell,
        },
        is_executable = True,
    )

    # Build the complete runfiles
    runfiles = ctx.runfiles(files = spec_files + shellspec_files + ctx.files.data)

    # Merge runfiles from dependencies (sh_library, sh_binary targets)
    for dep in ctx.attr.deps:
        runfiles = runfiles.merge(dep[DefaultInfo].default_runfiles)

    return [
        DefaultInfo(
            executable = runner,
            runfiles = runfiles,
        ),
    ]

shellspec_test = rule(
    implementation = _shellspec_test_impl,
    test = True,
    attrs = {
        "srcs": attr.label_list(
            allow_files = [".sh"],
            mandatory = True,
            doc = "The ShellSpec spec files to run. These should follow ShellSpec naming conventions (*_spec.sh).",
        ),
        "deps": attr.label_list(
            doc = "Shell library or binary targets that the specs depend on (sh_library, sh_binary).",
        ),
        "data": attr.label_list(
            allow_files = True,
            doc = "Additional data files needed at runtime.",
        ),
        "shell": attr.string(
            default = "/bin/sh",
            doc = "The shell to use for running tests. Default is /bin/sh.",
        ),
        "shellspec_opts": attr.string_list(
            doc = "Additional options to pass to shellspec.",
        ),
        "_shellspec_files": attr.label(
            default = "@shellspec//:shellspec_files",
            doc = "All ShellSpec files needed at runtime.",
        ),
        "_runner_template": attr.label(
            default = "//shellspec/private:runner.sh.tpl",
            allow_single_file = True,
            doc = "Template for the test runner script.",
        ),
    },
    doc = """Runs ShellSpec tests on shell scripts.

This rule executes ShellSpec, a BDD-style testing framework for shell scripts.
It integrates with Bazel's test infrastructure, producing JUnit XML output
for test result reporting.

**Sharding**: This rule does not support test sharding. If sharding is
requested, the test will fail with an appropriate error message.

**Coverage**: ShellSpec requires kcov for coverage reporting. If coverage
is requested but kcov is not installed, a warning will be printed.

Example:
```starlark
load("@rules_shellspec//shellspec:defs.bzl", "shellspec_test")

shellspec_test(
    name = "my_script_test",
    srcs = ["my_script_spec.sh"],
    deps = [":my_script"],
    data = ["test_data.txt"],
)
```
""",
)
