#! /usr/bin/env bats

@test "core: check exported global constants" {
  [[ "$_GO_ROOTDIR" = "$PWD" ]]
  [[ "$_GO_SCRIPT" == "$_GO_ROOTDIR/go" ]]
  [[ -n $COLUMNS ]]
}

@test "core: produce help message with error return when no args" {
  run test/go
  [[ "$status" -eq '1' ]]
  [[ "${lines[0]}" = 'Usage: test/go <command> [arguments...]' ]]
}

@test "core: produce error for an unknown flag" {
  run test/go -foobar
  [[ "$status" -eq '1' ]]
  [[ "${lines[0]}" = 'Unknown flag: -foobar' ]]
  [[ "${lines[1]}" = 'Usage: test/go <command> [arguments...]' ]]
}

@test "core: invoke editor on edit command" {
  run env EDITOR=echo test/go edit 'editor invoked'
  [[ "$status" -eq '0' ]]
  [[ "$output" = 'editor invoked' ]]
}

@test "core: invoke run command" {
  run test/go run echo run command invoked
  [[ "$status" -eq '0' ]]
  [[ "$output" = 'run command invoked' ]]
}

@test "core: produce error on cd" {
  local expected
  expected+='cd is only available after using "test/go env" to set up '$'\n'
  expected+='your shell environment.'

  COLUMNS=60
  run test/go 'cd'
  [[ "$status" -eq '1' ]]
  [[ "$output" = "$expected" ]]
}

@test "core: produce error on pushd" {
  local expected
  expected+='pushd is only available after using "test/go env" to set up '$'\n'
  expected+='your shell environment.'

  COLUMNS=60
  run test/go 'pushd'
  [[ "$status" -eq '1' ]]
  [[ "$output" = "$expected" ]]
}

@test "core: produce error on unenv" {
  local expected
  expected+='unenv is only available after using "test/go env" to set up '$'\n'
  expected+='your shell environment.'

  COLUMNS=60
  run test/go 'unenv'
  [[ "$status" -eq '1' ]]
  [[ "$output" = "$expected" ]]
}

@test "core: run shell alias command" {
  run test/go grep "$BATS_TEST_DESCRIPTION" "$BATS_TEST_FILENAME" >&2

  if command -v 'grep'; then
    [[ "$status" -eq '0' ]]
    [[ "$output" = "@test \"$BATS_TEST_DESCRIPTION\" {" ]]
  else
    [[ "$status" -ne '0' ]]
  fi
}

@test "core: produce error and list available commands if command not found" {
  run test/go foobar
  [[ "status" -eq '1' ]]
  [[ "${lines[0]}" = 'Unknown command: foobar' ]]
  [[ "${lines[1]}" = 'Available commands are:' ]]
  [[ "${lines[2]}" = '  aliases' ]]
  [[ "${lines[$((${#lines[@]} - 1))]}" = '  unenv' ]]
}
