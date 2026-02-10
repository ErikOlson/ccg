#!/usr/bin/env bats

# Tests for: ccg commit

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

@test "ccg commit requires -m flag" {
    run ccg commit
    [ "$status" -ne 0 ]
    [[ "$output" == *"-m"* ]]
}

@test "ccg commit with nothing staged exits with error" {
    run ccg commit -m "nothing here"
    [ "$status" -ne 0 ]
    [[ "$output" == *"nothing to commit"* ]]
}

@test "ccg commit stores product message in product repo" {
    echo "code" > app.js
    pgit add app.js
    ccg commit -m "add app"
    run git --git-dir=.git log --oneline -1
    [[ "$output" == *"add app"* ]]
}

@test "ccg commit stores sync:product@hash in process repo" {
    echo "code" > app.js
    echo "# Claude" > CLAUDE.md
    pgit add .
    ccg commit -m "add app"

    _hash=$(git --git-dir=.git rev-parse --short HEAD)
    run git --git-dir=.pgit/layers/process/.git log --oneline -1
    [[ "$output" == *"sync: product@$_hash"* ]]
}

@test "ccg commit with only product changes does not commit process" {
    echo "code" > app.js
    pgit add app.js
    ccg commit -m "product only"

    run git --git-dir=.pgit/layers/process/.git log --oneline -1
    [ "$status" -ne 0 ]
}

@test "ccg commit with only process changes uses message directly" {
    echo "# Claude" > CLAUDE.md
    pgit add CLAUDE.md
    run ccg commit -m "process only"
    [ "$status" -eq 0 ]

    run git --git-dir=.pgit/layers/process/.git log --oneline -1
    [[ "$output" == *"process only"* ]]
}

@test "ccg commit with only process changes does not commit product" {
    # product has one commit from setup (initial)
    echo "# Claude" > CLAUDE.md
    pgit add CLAUDE.md
    ccg commit -m "process only"

    # product log should still only have the initial commit
    run git --git-dir=.git log --oneline
    [ "$(echo "$output" | wc -l | tr -d ' ')" -eq 1 ]
}

@test "ccg commit outside pgit directory fails" {
    OTHER_DIR="$(mktemp -d)"
    cd "$OTHER_DIR"
    run ccg commit -m "no pgit here"
    [ "$status" -ne 0 ]
    [[ "$output" == *".pgit"* ]]
    rm -rf "$OTHER_DIR"
}
