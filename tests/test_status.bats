#!/usr/bin/env bats

# Tests for: ccg status — focused on uncommitted work

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
    git commit --allow-empty -q -m "initial"
    pgit init
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "ccg status shows product repo section" {
    run ccg status
    [ "$status" -eq 0 ]
    [[ "$output" == *"product repo"* ]]
}

@test "ccg status shows claude repo section" {
    run ccg status
    [ "$status" -eq 0 ]
    [[ "$output" == *"claude repo"* ]]
}

@test "ccg status shows untracked product files" {
    echo "code" > app.js
    run ccg status
    [[ "$output" == *"app.js"* ]]
}

@test "ccg status shows untracked process files" {
    echo "# Claude" > CLAUDE.md
    run ccg status
    [[ "$output" == *"CLAUDE.md"* ]]
}

@test "ccg status exits cleanly with nothing to show" {
    run ccg status
    [ "$status" -eq 0 ]
}

@test "ccg status fails outside pgit directory" {
    OTHER_DIR="$(mktemp -d)"
    cd "$OTHER_DIR"
    run ccg status
    [ "$status" -ne 0 ]
    [[ "$output" == *".pgit"* ]]
    rm -rf "$OTHER_DIR"
}
