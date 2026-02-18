#!/usr/bin/env bash

# Load bats helpers
load '../node_modules/bats-support/load'
load '../node_modules/bats-assert/load'

# Repo root for script paths
export REPO_ROOT
REPO_ROOT="$(cd "$(dirname "${BATS_TEST_FILENAME}")/.." && pwd)"
