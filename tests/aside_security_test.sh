#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"
ASIDE_SCRIPT="$REPO_ROOT/aside"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

assert_file_exists() {
  local path="$1" description="$2"
  [[ -e "$path" ]] || fail "$description"
}

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

repo="$tmpdir/repo"
store="$tmpdir/store"

mkdir -p "$repo" "$store"
git -C "$repo" init -q
git -C "$repo" remote add origin git@github.com:acme/demo.git

(
  cd "$repo"
  ASIDE_HOME="$store" "$ASIDE_SCRIPT" add notes.md >/dev/null
)
assert_file_exists "$store/github.com/acme/demo/notes.md" "aside add did not create the sidecar file"
[[ ! -e "$repo/notes.md" ]] || fail "aside add created a file inside the repo"

printf 'keep\n' > "$repo/keep.txt"
ln -s "$repo" "$store/github.com/acme/demo/link"

stderr="$tmpdir/stderr"
if (
  cd "$repo"
  ASIDE_HOME="$store" "$ASIDE_SCRIPT" rm link/keep.txt >/dev/null 2>"$stderr"
); then
  fail "aside rm succeeded through a symlink escape"
fi

assert_file_exists "$repo/keep.txt" "aside rm deleted a repo file through a symlink escape"
grep -q "symlinked directories are not allowed" "$stderr" || fail "aside rm did not explain the symlink escape rejection"

repo_store="$repo/.aside-store"
stderr_repo_store="$tmpdir/repo-store.stderr"
if (
  cd "$repo"
  ASIDE_HOME="$repo_store" "$ASIDE_SCRIPT" add repo.txt >/dev/null 2>"$stderr_repo_store"
); then
  fail "aside accepted a store path inside the repo"
fi

grep -q "ASIDE_HOME must be outside the current repo" "$stderr_repo_store" || fail "aside did not reject ASIDE_HOME inside the repo"

printf 'PASS: aside security regression checks\n'
