#!/usr/bin/env bats

# Tests for: ccg (no args) — quick overview

setup() {
    export PATH="$BATS_TEST_DIRNAME/../bin:$BATS_TEST_DIRNAME/../../pgit/bin:$PATH"
    TEST_DIR="$(mktemp -d)"
    export XDG_CONFIG_HOME="$TEST_DIR/config"
    export GIT_AUTHOR_NAME="Test"
    export GIT_AUTHOR_EMAIL="test@example.com"
    export GIT_COMMITTER_NAME="Test"
    export GIT_COMMITTER_EMAIL="test@example.com"
    cd "$TEST_DIR"
    git init -q
    git commit --allow-empty -q -m "initial product commit"
    pgit init
    echo "# Claude" > CLAUDE.md
    git --git-dir=".pgit/layers/process/.git" --work-tree="." add CLAUDE.md
    git --git-dir=".pgit/layers/process/.git" --work-tree="." commit -q -m "initial process commit"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "ccg with no args shows product repo and claude repo" {
    run ccg
    [ "$status" -eq 0 ]
    [[ "$output" == *"product repo"* ]]
    [[ "$output" == *"claude repo"* ]]
}

@test "ccg with no args shows last commit for each repo" {
    run ccg
    [[ "$output" == *"initial product commit"* ]]
    [[ "$output" == *"initial process commit"* ]]
}

@test "ccg with no args shows branch names" {
    run ccg
    [[ "$output" == *"["* ]]
    [[ "$output" == *"]"* ]]
}

@test "ccg with no args shows clean when nothing modified" {
    run ccg
    [[ "$output" == *"clean"* ]]
}

@test "ccg with no args shows dirty when files modified" {
    echo "modified" >> CLAUDE.md
    run ccg
    [[ "$output" == *"dirty"* ]]
}

@test "ccg with no args fails outside pgit directory" {
    OTHER_DIR="$(mktemp -d)"
    cd "$OTHER_DIR"
    git init -q
    run ccg
    [ "$status" -ne 0 ]
    rm -rf "$OTHER_DIR"
}
