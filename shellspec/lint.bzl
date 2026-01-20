"""rules_lint integration for shellspec_test rules.

This module provides integration with aspect-build/rules_lint to format
ShellSpec test files using altshfmt instead of shfmt.

ShellSpec uses a DSL that extends shell syntax with special keywords like
`Describe`, `It`, `When`, etc. Standard shfmt doesn't understand this DSL
and will mangle the formatting. altshfmt is a fork of shfmt that adds
support for ShellSpec's DSL.

## Usage

In your `tools/lint/linters.bzl`:

```starlark
load("@rules_shellspec//shellspec:lint.bzl", "lint_shellspec_aspect")

shellspec_fmt = lint_shellspec_aspect(
    binary = Label("@altshfmt//:altshfmt"),  # Your altshfmt binary
    config = Label("//:.editorconfig"),  # Optional shfmt config
)
```

Then in your `.bazelrc`:

```
build --aspects=//tools/lint:linters.bzl%shellspec_fmt
```

Or use with `lint_test`:

```starlark
load("@aspect_rules_lint//lint:lint_test.bzl", "lint_test")

shellspec_fmt_test = lint_test(aspect = shellspec_fmt)
```
"""

# Mnemonic for build actions
_MNEMONIC = "ShellSpecFormat"

# Output file format string
_OUTFILE_FORMAT = "{label}.{mnemonic}.{suffix}"

def _format_action(ctx, executable, srcs, config, stdout, exit_code = None, options = []):
    """Run altshfmt/shfmt as an action.

    Args:
        ctx: Bazel Rule or Aspect evaluation context
        executable: label of the altshfmt/shfmt program
        srcs: shell files to be formatted
        config: optional config file (like .editorconfig)
        stdout: output file containing stdout
        exit_code: output file containing exit code (if None, fail on non-zero)
        options: additional command-line options
    """
    inputs = list(srcs)
    if config:
        inputs.append(config)

    args = ctx.actions.args()
    args.add_all(options)
    args.add_all(srcs)

    outputs = [stdout]

    if exit_code:
        command = "{formatter} $@ >{stdout} 2>&1; echo $? >" + exit_code.path
        outputs.append(exit_code)
    else:
        command = "{formatter} $@ && touch {stdout}"

    ctx.actions.run_shell(
        inputs = inputs,
        outputs = outputs,
        command = command.format(
            formatter = executable.path,
            stdout = stdout.path,
        ),
        arguments = [args],
        mnemonic = _MNEMONIC,
        progress_message = "Formatting %{label} with altshfmt",
        tools = [executable],
    )

def _get_srcs(rule):
    """Extract source files from the rule."""
    if hasattr(rule.attr, "srcs"):
        return [f for src in rule.attr.srcs for f in src.files.to_list()]
    return []

def _shellspec_format_aspect_impl(target, ctx):
    # Only visit shellspec_test rules
    if ctx.rule.kind != "shellspec_test":
        return []

    files_to_format = _get_srcs(ctx.rule)
    if not files_to_format:
        return []

    # Create output files
    human_out = ctx.actions.declare_file(
        _OUTFILE_FORMAT.format(
            label = target.label.name,
            mnemonic = _MNEMONIC,
            suffix = "out",
        ),
    )
    human_exit_code = ctx.actions.declare_file(
        _OUTFILE_FORMAT.format(
            label = target.label.name,
            mnemonic = _MNEMONIC,
            suffix = "exit_code",
        ),
    )

    # Determine config file
    config = ctx.file._config_file if hasattr(ctx.file, "_config_file") and ctx.file._config_file else None

    # Default options for check mode (diff output)
    check_options = ["--diff"]
    if config:
        # shfmt uses -f to find shell files, not for config
        # Config is auto-discovered from .editorconfig
        pass

    _format_action(
        ctx,
        ctx.executable._formatter,
        files_to_format,
        config,
        human_out,
        human_exit_code,
        check_options,
    )

    # Return OutputGroupInfo for rules_lint compatibility
    return [
        OutputGroupInfo(
            rules_lint_human = depset([human_out, human_exit_code]),
        ),
    ]

def lint_shellspec_aspect(binary, config = None):
    """Factory function to create a format aspect for shellspec_test rules.

    This aspect formats ShellSpec test files using altshfmt (or a compatible
    shfmt variant that understands ShellSpec's DSL).

    Args:
        binary: Label of the altshfmt/shfmt executable
        config: Optional label of a config file (e.g., .editorconfig)

    Returns:
        An aspect that can be used with rules_lint
    """
    attrs = {
        "_formatter": attr.label(
            default = binary,
            executable = True,
            cfg = "exec",
        ),
    }

    if config:
        attrs["_config_file"] = attr.label(
            default = config,
            allow_single_file = True,
        )

    return aspect(
        implementation = _shellspec_format_aspect_impl,
        attrs = attrs,
        doc = """Formats shellspec_test source files with altshfmt.

        This aspect visits shellspec_test rules and formats their source files
        using altshfmt, which understands ShellSpec's BDD DSL syntax.
        """,
    )
