#!/bin/sh
# ShellSpec test for greet.sh
# This file follows ShellSpec BDD syntax

# Include the library under test
# shellcheck source=greet.sh
. "./greet.sh"

Describe 'greet()'
  It 'greets the world by default'
    When call greet
    The output should eq "Hello, World!"
  End

  It 'greets a specific name'
    When call greet "Bazel"
    The output should eq "Hello, Bazel!"
  End
End

Describe 'add()'
  It 'adds two numbers'
    When call add 2 3
    The output should eq "5"
  End

  It 'handles zero'
    When call add 0 0
    The output should eq "0"
  End

  It 'defaults to zero for missing arguments'
    When call add
    The output should eq "0"
  End
End
