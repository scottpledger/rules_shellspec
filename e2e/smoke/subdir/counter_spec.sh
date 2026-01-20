#!/bin/sh
# ShellSpec test for counter.sh binary in subdirectory

# The binary is available via runfiles
counter_bin="./counter.sh"

Describe 'counter binary'
It 'counts from 0 by 1 five times by default'
When run script "$counter_bin"
The output should eq "0
1
2
3
4"
End

It 'starts from a custom value'
When run script "$counter_bin" 10 1 3
The output should eq "10
11
12"
End

It 'uses custom increment'
When run script "$counter_bin" 0 2 4
The output should eq "0
2
4
6"
End

It 'handles negative increment'
When run script "$counter_bin" 10 -2 3
The output should eq "10
8
6"
End
End
