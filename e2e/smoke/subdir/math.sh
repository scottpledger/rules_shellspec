#!/bin/sh
# Math library for testing sh_library in subdirectory

# Multiply two numbers
multiply() {
    local a="${1:-0}"
    local b="${2:-0}"
    echo $((a * b))
}

# Subtract two numbers
subtract() {
    local a="${1:-0}"
    local b="${2:-0}"
    echo $((a - b))
}

# Check if a number is positive
is_positive() {
    local n="${1:-0}"
    [ "$n" -gt 0 ]
}
