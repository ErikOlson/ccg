#!/usr/bin/env bats

# Tests for: ccg remote

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

# --- Guard: not a ccg directory ---

@test "ccg remote fails outside pgit directory" {
    OTHER_DIR="$(mktemp -d)"
    cd "$OTHER_DIR"
    run ccg remote
    [ "$status" -ne 0 ]
    [[ "$output" == *".pgit"* ]]
    rm -rf "$OTHER_DIR"
}

# --- Guard: gh not installed ---

@test "ccg remote fails if gh not installed" {
    # Run with a PATH that has ccg and pgit but no gh
    run env PATH="$BATS_TEST_DIRNAME/../bin:$BATS_TEST_DIRNAME/../../pgit/bin:/usr/bin:/bin" ccg remote
    [ "$status" -ne 0 ]
    [[ "$output" == *"gh"* ]]
}

@test "ccg remote gh-not-found message mentions install url" {
    run env PATH="$BATS_TEST_DIRNAME/../bin:$BATS_TEST_DIRNAME/../../pgit/bin:/usr/bin:/bin" ccg remote
    [[ "$output" == *"cli.github.com"* ]]
}

# --- Guard: gh not authenticated ---

_fake_gh_unauthenticated() {
    mkdir -p "$TEST_DIR/fake-bin"
    printf '#!/bin/sh\nexit 1\n' > "$TEST_DIR/fake-bin/gh"
    chmod +x "$TEST_DIR/fake-bin/gh"
    # Prepend fake-bin so it shadows the real gh; keep rest of PATH for system tools
    export PATH="$TEST_DIR/fake-bin:$PATH"
}

@test "ccg remote fails if gh not authenticated" {
    _fake_gh_unauthenticated
    run ccg remote
    [ "$status" -ne 0 ]
    [[ "$output" == *"gh auth login"* ]]
}

# --- Both remotes already configured ---

@test "ccg remote reports status when both remotes exist" {
    # Set up local bare repos as stand-in remotes
    _prod_bare="$TEST_DIR/prod-remote.git"
    _proc_bare="$TEST_DIR/proc-remote.git"
    git init --bare -q "$_prod_bare"
    git init --bare -q "$_proc_bare"

    git --git-dir="$TEST_DIR/.git" remote add origin "$_prod_bare"
    git --git-dir="$TEST_DIR/.pgit/layers/process/.git" remote add origin "$_proc_bare"

    # Fake gh that reports authenticated (all calls succeed)
    mkdir -p "$TEST_DIR/fake-bin"
    printf '#!/bin/sh\nexit 0\n' > "$TEST_DIR/fake-bin/gh"
    chmod +x "$TEST_DIR/fake-bin/gh"
    export PATH="$TEST_DIR/fake-bin:$PATH"

    run ccg remote
    [ "$status" -eq 0 ]
    [[ "$output" == *"already configured"* ]]
}
