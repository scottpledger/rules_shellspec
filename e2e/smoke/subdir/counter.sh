#!/bin/sh
# Counter binary for testing sh_binary in subdirectory
# Usage: counter.sh [start] [increment] [count]

start="${1:-0}"
increment="${2:-1}"
count="${3:-5}"

i=0
current="$start"
while [ "$i" -lt "$count" ]; do
    echo "$current"
    current=$((current + increment))
    i=$((i + 1))
done
