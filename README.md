# rules_shellspec

Bazel rules for [ShellSpec](https://shellspec.info/), a BDD-style testing framework for shell scripts.

## Features

- `shellspec_test` rule for running ShellSpec tests in Bazel
- Integration with `sh_library` and `sh_binary` targets from `rules_shell`
- JUnit XML output for test result reporting
- `--test_filter` support for running specific examples
- Proper handling of Bazel test sharding (fails with clear error if sharding is requested)
- Coverage warning when `kcov` is not installed
- Integration with [rules_lint](https://github.com/aspect-build/rules_lint) for formatting with altshfmt

## Installation

### Bzlmod (recommended)

Add to your `MODULE.bazel`:

```starlark
bazel_dep(name = "rules_shellspec", version = "0.1.0")

# Optional: specify a different ShellSpec version
shellspec = use_extension("@rules_shellspec//shellspec:extensions.bzl", "shellspec")
shellspec.toolchain(version = "0.28.1")
use_repo(shellspec, "shellspec")
```

### WORKSPACE

Add to your `WORKSPACE`:

```starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_shellspec",
    sha256 = "...",  # Get from release
    urls = ["https://github.com/scottpledger/rules_shellspec/releases/download/v0.1.0/rules_shellspec-v0.1.0.tar.gz"],
)

load("@rules_shellspec//shellspec:repositories.bzl", "rules_shellspec_dependencies", "shellspec_register")

rules_shellspec_dependencies()
shellspec_register()
```

## Usage

### Basic Example

Create a shell library:

```shell
# greet.sh
greet() {
    echo "Hello, ${1:-World}!"
}
```

Create a spec file following [ShellSpec conventions](https://github.com/shellspec/shellspec#tutorial):

```shell
# greet_spec.sh
#!/bin/sh

# Source the library under test - deps are in the runfiles
. "./greet.sh"

Describe 'greet()'
  It 'greets the world'
    When call greet "World"
    The output should eq "Hello, World!"
  End
End
```

Create a `BUILD.bazel` file:

```starlark
load("@rules_shellspec//shellspec:defs.bzl", "shellspec_test")
load("@rules_shell//shell:sh_library.bzl", "sh_library")

sh_library(
    name = "greet_lib",
    srcs = ["greet.sh"],
)

shellspec_test(
    name = "greet_test",
    srcs = ["greet_spec.sh"],
    deps = [":greet_lib"],
)
```

Run the tests:

```bash
bazel test //:greet_test
```

### Filtering Tests with `--test_filter`

You can run specific examples by name using Bazel's `--test_filter` flag:

```bash
# Run only examples matching "greets the world"
bazel test //:greet_test --test_filter="greets the world"

# Run examples in a specific Describe block
bazel test //:greet_test --test_filter="greet()"
```

This maps to ShellSpec's `--example` (`-E`) option, which filters examples whose names include the given pattern.

### Sourcing Dependencies

Shell libraries specified in `deps` are available in the test's runfiles directory.
You can source them with a relative path from the runfiles root:

```shell
# For a dep at //my/package:lib, source it as:
. "./my/package/lib.sh"
```

### Rule Reference

#### `shellspec_test`

Runs ShellSpec tests on shell scripts.

**Attributes:**

| Attribute          | Type          | Default  | Description                                   |
| ------------------ | ------------- | -------- | --------------------------------------------- |
| `srcs`             | `label_list`  | required | ShellSpec spec files (`*_spec.sh`)            |
| `deps`             | `label_list`  | `[]`     | Shell library or binary targets to test       |
| `data`             | `label_list`  | `[]`     | Additional data files needed at runtime       |
| `shellspec_opts`   | `string_list` | `[]`     | Additional options to pass to shellspec       |
| `shellspec_config` | `label`       | `None`   | Optional custom .shellspec configuration file |

**Note:** The rule uses Bazel's bash toolchain for hermetic, reproducible tests.

**Example with options:**

```starlark
shellspec_test(
    name = "my_test",
    srcs = ["my_spec.sh"],
    deps = [":my_lib"],
    shellspec_opts = [
        "--fail-fast",
        "--jobs", "4",
    ],
)
```

## Integration with rules_lint

ShellSpec uses a DSL that extends shell syntax with special keywords like `Describe`, `It`, `When`, etc. Standard `shfmt` doesn't understand this DSL and will mangle the formatting. We recommend using [altshfmt](https://github.com/aspect-build/altshfmt), a fork of shfmt that adds support for ShellSpec's DSL.

### Setting up altshfmt with rules_lint

1. Add altshfmt to your MODULE.bazel (or use rules_multitool to fetch it):

```starlark
# Example using http_archive
http_archive(
    name = "altshfmt",
    # ... your altshfmt binary
)
```

2. Create a linter aspect in `tools/lint/linters.bzl`:

```starlark
load("@rules_shellspec//shellspec:defs.bzl", "lint_shellspec_aspect")
load("@aspect_rules_lint//lint:lint_test.bzl", "lint_test")

# Format aspect for shellspec_test rules
shellspec_fmt = lint_shellspec_aspect(
    binary = Label("@altshfmt//:altshfmt"),  # Your altshfmt binary
    config = Label("//:.editorconfig"),  # Optional: shfmt config
)

# Create a test target factory
shellspec_fmt_test = lint_test(aspect = shellspec_fmt)
```

3. Apply the aspect in your `.bazelrc`:

```
# Format shellspec test files
build --aspects=//tools/lint:linters.bzl%shellspec_fmt
build --output_groups=+rules_lint_human
```

4. Or create explicit format test targets:

```starlark
load("//tools/lint:linters.bzl", "shellspec_fmt_test")

shellspec_fmt_test(
    name = "my_spec_format_test",
    srcs = [":my_test"],  # Reference to a shellspec_test target
)
```

## Limitations

### Test Sharding

ShellSpec does not support Bazel's test sharding mechanism. If you set `shard_count > 1` on a `shellspec_test` target, the test will fail with an error message. This is because ShellSpec runs all specs as a single test suite.

### Coverage

ShellSpec uses [kcov](https://github.com/SimonKagstrom/kcov) for coverage reporting. Currently, kcov is not available as a Bazel module in the BCR, so coverage requires a system-installed kcov.

When running `bazel coverage` without kcov installed, you'll see a warning:

```
WARNING: Coverage was requested but 'kcov' is not installed.
ShellSpec requires kcov for shell script coverage reporting.
Coverage data will not be collected for this test.
```

## Compatibility

- Bazel 7.0+
- ShellSpec 0.28.1 (other versions can be configured)
- `rules_shell` for `sh_library`/`sh_binary` targets

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup and guidelines.

## License

Apache 2.0 - see [LICENSE](LICENSE)
