#!/usr/bin/env bash
#
# This scripts invokes all unignored tests, update pass list (append-only)
# and print the list of failing tests.
# 
#

set -eu

err_handler () {
   ./scripts/_/notify.sh 'Check failed!'
   exit 1
}

trap err_handler ERR

export CARGO_TERM_COLOR=always
export RUST_BACKTRACE=1
export RUST_MIN_STACK=$((16 * 1024 * 1024))

# We prevent regression using faster checks
touch ../stc_ts_file_analyzer/tests/base.rs
UPDATE=1 cargo test -p stc_ts_file_analyzer --lib --test base -- -Zunstable-options --report-time

RUST_LOG=off TEST='' DONT_PRINT_MATCHED=1 cargo test --test tsc \
  | tee /dev/stderr \
  | grep 'ts .\.\. ok$' \
  | sed -e 's!test conformance::!!' \
  | sed -e 's! ... ok!!' \
  | sed -e 's!::!/!g' \
  | sed -e 's!test !!' \
  >> tests/conformance.pass.txt

./scripts/sort.sh

./scripts/_/notify.sh 'Check done!'
