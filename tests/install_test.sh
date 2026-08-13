#!/bin/sh

set -eu

repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/skills-install-test.XXXXXX")
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

target="$tmp/codex home"
mkdir -p "$target/skills/unrelated"
printf 'keep\n' > "$target/skills/unrelated/data.txt"
cat > "$target/AGENTS.md" <<'EOF'
# Existing rules

Keep this text.

<!-- ZHDANOVME:SKILLS:START -->
old managed rules
<!-- ZHDANOVME:SKILLS:END -->

Keep this too.
EOF

"$repo/install.sh" --target "$target" >/dev/null
cp "$target/AGENTS.md" "$tmp/agents-after-first-install.md"
"$repo/install.sh" --target "$target" >/dev/null

[ -f "$target/skills/dev-task/SKILL.md" ] || fail "skill was not installed"
[ -f "$target/skills/unrelated/data.txt" ] || fail "unrelated skill was removed"
grep -F 'Keep this text.' "$target/AGENTS.md" >/dev/null || fail "existing rules were removed"
grep -F 'Keep this too.' "$target/AGENTS.md" >/dev/null || fail "rules after managed block were removed"
grep -F '## Complexity Budget' "$target/AGENTS.md" >/dev/null || fail "repository rules were not added"
[ "$(grep -c '^<!-- ZHDANOVME:SKILLS:START -->$' "$target/AGENTS.md")" -eq 1 ] || fail "start marker was duplicated"
[ "$(grep -c '^<!-- ZHDANOVME:SKILLS:END -->$' "$target/AGENTS.md")" -eq 1 ] || fail "end marker was duplicated"
if grep -F 'old managed rules' "$target/AGENTS.md" >/dev/null; then
  fail "old managed rules were not replaced"
fi
cmp "$tmp/agents-after-first-install.md" "$target/AGENTS.md" >/dev/null || fail "repeated install changed AGENTS.md"

default_home="$tmp/default home"
CODEX_HOME="$default_home" "$repo/install.sh" >/dev/null
[ -f "$default_home/skills/dev-task/SKILL.md" ] || fail "CODEX_HOME default was ignored"
[ -f "$default_home/AGENTS.md" ] || fail "default AGENTS.md was not created"

printf 'shell installer tests passed\n'
