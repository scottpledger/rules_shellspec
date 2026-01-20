"""ShellSpec version information.

The integrity hashes can be computed with:
    shasum -b -a 256 [downloaded file] | awk '{ print "sha256-" $1 }' | xxd -r -p | base64
Or more simply by running bazel with the sha256 omitted and copying the error message.
"""

# Map of ShellSpec versions to their SHA256 checksums
SHELLSPEC_VERSIONS = {
    "0.28.1": "sha256-QA2DVGZCml/mx3pid1qRc3KdYd1D4F36iT6M9stRF4M=",
}

# The default version to use if none is specified
DEFAULT_SHELLSPEC_VERSION = "0.28.1"
