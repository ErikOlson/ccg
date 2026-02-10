#!/usr/bin/env bats

# Tests for: ccg push

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
    ccg init >/dev/null
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "ccg push fails outside pgit directory" {
    OTHER_DIR="$(mktemp -d)"
    cd "$OTHER_DIR"
    run ccg push
    [ "$status" -ne 0 ]
    [[ "$output" == *".pgit"* ]]
    rm -rf "$OTHER_DIR"
}

@test "ccg push fails when no remotes configured" {
    run ccg push
    [ "$status" -ne 0 ]
    [[ "$output" == *"ccg remote"* ]]
}

@test "ccg push pushes product repo when product remote exists" {
    _prod_bare="$TEST_DIR/prod-remote.git"
    git init --bare -q "$_prod_bare"
    git --git-dir="$TEST_DIR/.git" remote add origin "$_prod_bare"

    echo "code" > app.js
    ccg add app.js
    ccg commit -m "add app" >/dev/null

    run ccg push
    [ "$status" -eq 0 ]

    # Verify the commit landed in the bare repo
    run git --git-dir="$_prod_bare" log --oneline -1
    [[ "$output" == *"add app"* ]]
}

@test "ccg push pushes claude repo when process remote exists" {
    _proc_bare="$TEST_DIR/proc-remote.git"
    git init --bare -q "$_proc_bare"
    git --git-dir="$TEST_DIR/.pgit/layers/process/.git" remote add origin "$_proc_bare"

    echo "# Claude" > CLAUDE.md
    ccg add CLAUDE.md
    ccg commit -m "add claude" >/dev/null

    run ccg push
    [ "$status" -eq 0 ]

    run git --git-dir="$_proc_bare" log --oneline -1
    [[ "$output" == *"add claude"* ]]
}

@test "ccg push skips repos with no remote" {
    # Only product remote — should succeed without complaining about process
    _prod_bare="$TEST_DIR/prod-remote.git"
    git init --bare -q "$_prod_bare"
    git --git-dir="$TEST_DIR/.git" remote add origin "$_prod_bare"

    echo "code" > app.js
    ccg add app.js
    ccg commit -m "add app" >/dev/null

    run ccg push
    [ "$status" -eq 0 ]
}
