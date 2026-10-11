#!/usr/bin/env bash
# Usage: ./tests/run_smoke_tests.sh [--static] [--dist DIR]
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST="$ROOT_DIR/dist"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --static)
      DIST="$ROOT_DIR/dist-static"
      shift
      ;;
    --dist)
      DIST="$(cd "$2" && pwd)"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

BIN="$DIST/bin/tmux"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pass() { echo "ok: $*"; }
fail() {
  echo "FAIL: $*" >&2
  exit 1
}

version="$("$BIN" -V)"
echo "$version" | grep -q '^tmux ' || fail "tmux -V: $version"
pass "$version"

# runs a server on a terminal without terminfo, and reads what a pane printed
export TERM=xterm-256color TERMINFO=/nonexistent TERMINFO_DIRS=/nonexistent
sock="$TMP/sock"
"$BIN" -S "$sock" -f /dev/null new-session -d -x 80 -y 24 "echo pmg-tmux; sleep 30"
for _ in 1 2 3 4 5 6 7 8 9 10; do
  out="$("$BIN" -S "$sock" capture-pane -p 2>/dev/null || true)"
  case "$out" in *pmg-tmux*) break ;; esac
  sleep 1
done
"$BIN" -S "$sock" kill-server 2>/dev/null || true
case "$out" in *pmg-tmux*) ;; *) fail "pane output: $out" ;; esac
pass "runs a session and captures a pane"

if [ "$(uname -s)" = Linux ] && ! LC_ALL=C grep -a -q 'ld-musl' "$BIN"; then
  max="$(LC_ALL=C grep -aoh 'GLIBC_2\.[0-9]*' "$BIN" | sort -uV | tail -n 1)" || true
  if [ -n "$max" ]; then
    [ "$(printf '%s\n' "$max" GLIBC_2.17 | sort -V | tail -n 1)" = GLIBC_2.17 ] \
      || fail "needs $max, newer than GLIBC_2.17"
    pass "glibc floor ($max)"
  fi
fi

echo "all smoke tests passed"
