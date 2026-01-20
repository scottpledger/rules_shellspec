# rules_shellspec

Bazel rules for [ShellSpec](https://shellspec.info/), a BDD-style testing framework for shell scripts.

## Features

- `shellspec_test` rule for running ShellSpec tests in Bazel
- Integration with `sh_library` and `sh_binary` targets from `rules_shell`
- JUnit XML output for test result reporting
- Proper handling of Bazel test sharding (fails with clear error if sharding is requested)
- Coverage warning when `kcov` is not installed

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
    urls = ["https://github.com/yourorg/rules_shellspec/releases/download/v0.1.0/rules_shellspec-v0.1.0.tar.gz"],
)

load("@rules_shellspec//shellspec:repositories.bzl", "rules_shellspec_dependencies", "shellspec_register")

rules_shellspec_dependencies()
shellspec_register()
```

## Usage

### Basic Example

Create a spec file following [ShellSpec conventions](https://github.com/shellspec/shellspec#tutorial):

```shell
# greet_spec.sh
Describe 'greet()'
  Include ./greet.sh

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

### Rule Reference

#### `shellspec_test`

Runs ShellSpec tests on shell scripts.

**Attributes:**

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `srcs` | `label_list` | required | ShellSpec spec files (`*_spec.sh`) |
| `deps` | `label_list` | `[]` | Shell library or binary targets to test |
| `data` | `label_list` | `[]` | Additional data files needed at runtime |
| `shell` | `string` | `/bin/sh` | Shell to use for running tests |
| `shellspec_opts` | `string_list` | `[]` | Additional options to pass to shellspec |

**Example with options:**

```starlark
shellspec_test(
    name = "my_test",
    srcs = ["my_spec.sh"],
    deps = [":my_lib"],
    shell = "/bin/bash",
    shellspec_opts = [
        "--fail-fast",
        "--jobs", "4",
    ],
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
