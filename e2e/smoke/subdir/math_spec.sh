#!/bin/sh
# ShellSpec test for math.sh library in subdirectory

# Source the library under test
# shellcheck source=math.sh
. "./math.sh"

Describe 'multiply()'
It 'multiplies two numbers'
When call multiply 3 4
The output should eq "12"
End

It 'handles zero'
When call multiply 5 0
The output should eq "0"
End

It 'handles negative numbers'
When call multiply -2 3
The output should eq "-6"
End
End

Describe 'subtract()'
It 'subtracts two numbers'
When call subtract 10 4
The output should eq "6"
End

It 'handles negative results'
When call subtract 3 7
The output should eq "-4"
End
End

Describe 'is_positive()'
It 'returns success for positive numbers'
When call is_positive 5
The status should be success
End

It 'returns failure for zero'
When call is_positive 0
The status should be failure
End

It 'returns failure for negative numbers'
When call is_positive -3
The status should be failure
End
End
