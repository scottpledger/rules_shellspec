#!/bin/sh
# Calculator binary for testing sh_binary in root
# Usage: calculator.sh <operation> <a> <b>
# Operations: add, sub, mul, div

operation="${1:-add}"
a="${2:-0}"
b="${3:-0}"

case "$operation" in
    add)
        echo $((a + b))
        ;;
    sub)
        echo $((a - b))
        ;;
    mul)
        echo $((a * b))
        ;;
    div)
        if [ "$b" -eq 0 ]; then
            echo "Error: division by zero" >&2
            exit 1
        fi
        echo $((a / b))
        ;;
    *)
        echo "Error: unknown operation '$operation'" >&2
        echo "Usage: calculator.sh <add|sub|mul|div> <a> <b>" >&2
        exit 1
        ;;
esac
