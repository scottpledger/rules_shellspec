#!/bin/sh
# Example shell library for testing

# Greet a user by name
greet() {
    local name="${1:-World}"
    echo "Hello, ${name}!"
}

# Add two numbers
add() {
    local a="${1:-0}"
    local b="${2:-0}"
    echo $((a + b))
}
