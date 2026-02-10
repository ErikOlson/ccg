#!/usr/bin/env bats

# Tests for: ccg add

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

@test "ccg add stages product file in product repo" {
    echo "code" > app.js
    ccg add app.js
    run git --git-dir=.git diff --cached --name-only
    [[ "$output" == *"app.js"* ]]
}

@test "ccg add stages process file in process repo" {
    echo "# Claude" > CLAUDE.md
    ccg add CLAUDE.md
    run git --git-dir=.pgit/layers/process/.git diff --cached --name-only
    [[ "$output" == *"CLAUDE.md"* ]]
}

@test "ccg add dot routes product and process files correctly" {
    echo "code" > app.js
    echo "# Claude" > CLAUDE.md
    ccg add .

    run git --git-dir=.git diff --cached --name-only
    [[ "$output" == *"app.js"* ]]
    [[ "$output" != *"CLAUDE.md"* ]]

    run git --git-dir=.pgit/layers/process/.git diff --cached --name-only
    [[ "$output" == *"CLAUDE.md"* ]]
    [[ "$output" != *"app.js"* ]]
}

@test "ccg add product file does not stage it in process repo" {
    echo "code" > app.js
    ccg add app.js
    run git --git-dir=.pgit/layers/process/.git diff --cached --name-only
    [[ "$output" != *"app.js"* ]]
}

@test "ccg add outside pgit directory fails" {
    OTHER_DIR="$(mktemp -d)"
    cd "$OTHER_DIR"
    echo "x" > file.txt
    run ccg add file.txt
    [ "$status" -ne 0 ]
    rm -rf "$OTHER_DIR"
}
