#!/usr/bin/env bats

# Tests for: ccg init

setup() {
    export PATH="$BATS_TEST_DIRNAME/../bin:$BATS_TEST_DIRNAME/../../pgit/bin:$PATH"
    TEST_DIR="$(mktemp -d)"
    export XDG_CONFIG_HOME="$TEST_DIR/config"
    export GIT_AUTHOR_NAME="Test"
    export GIT_AUTHOR_EMAIL="test@example.com"
    export GIT_COMMITTER_NAME="Test"
    export GIT_COMMITTER_EMAIL="test@example.com"
    cd "$TEST_DIR"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "ccg init creates .pgit/ in empty directory" {
    run ccg init
    [ "$status" -eq 0 ]
    [ -d ".pgit" ]
}

@test "ccg init creates .git/ if no git repo exists" {
    run ccg init
    [ "$status" -eq 0 ]
    [ -d ".git" ]
}

@test "ccg init works in existing git repo" {
    git init -q
    git commit --allow-empty -q -m "initial"
    run ccg init
    [ "$status" -eq 0 ]
    [ -d ".pgit" ]
}

@test "ccg init creates process layer" {
    run ccg init
    [ "$status" -eq 0 ]
    [ -d ".pgit/layers/process/.git" ]
}

@test "ccg init fails if already initialized" {
    ccg init
    run ccg init
    [ "$status" -ne 0 ]
    [[ "$output" == *"already initialized"* ]]
}

@test "ccg init excludes process files from product repo" {
    ccg init
    echo "# Claude" > CLAUDE.md
    run git --git-dir=.git status --short
    [[ "$output" != *"CLAUDE.md"* ]]
}

@test "ccg init makes process files visible to process repo" {
    ccg init
    echo "# Claude" > CLAUDE.md
    run git --git-dir=.pgit/layers/process/.git --work-tree=. status --short
    [[ "$output" == *"CLAUDE.md"* ]]
}

@test "ccg init prints ccg-branded next steps" {
    run ccg init
    [ "$status" -eq 0 ]
    [[ "$output" == *"ccg add"* ]]
    [[ "$output" == *"ccg commit"* ]]
    [[ "$output" == *"ccg remote"* ]]
}

@test "ccg init does not leak pgit instructions" {
    run ccg init
    [[ "$output" != *"pgit"* ]]
}
