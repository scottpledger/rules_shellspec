#!/bin/sh
# ShellSpec test for calculator.sh binary

# The binary is available via runfiles
calc_bin="./calculator.sh"

Describe 'calculator binary'

Describe 'add operation'
It 'adds two positive numbers'
When run script "$calc_bin" add 5 3
The output should eq "8"
The status should be success
End

It 'adds negative numbers'
When run script "$calc_bin" add -5 3
The output should eq "-2"
End
End

Describe 'sub operation'
It 'subtracts two numbers'
When run script "$calc_bin" sub 10 4
The output should eq "6"
End
End

Describe 'mul operation'
It 'multiplies two numbers'
When run script "$calc_bin" mul 6 7
The output should eq "42"
End
End

Describe 'div operation'
It 'divides two numbers'
When run script "$calc_bin" div 20 4
The output should eq "5"
End

It 'fails on division by zero'
When run script "$calc_bin" div 10 0
The stderr should include "division by zero"
The status should be failure
End
End

Describe 'error handling'
It 'fails on unknown operation'
When run script "$calc_bin" unknown 1 2
The stderr should include "unknown operation"
The status should be failure
End
End

End
