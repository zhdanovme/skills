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
mkdir -p "$target/skills/dev-task"
printf 'stale\n' > "$target/skills/dev-task/stale.txt"
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

installed_skills=0
for skill in "$repo"/*/SKILL.md; do
  source_dir=${skill%/SKILL.md}
  name=${source_dir##*/}
  [ -f "$target/skills/$name/SKILL.md" ] || fail "$name was not installed"
  diff -r "$source_dir" "$target/skills/$name" >/dev/null || fail "$name was not copied completely"
  installed_skills=$((installed_skills + 1))
done
[ "$installed_skills" -gt 0 ] || fail "no repository skills were discovered"
[ -f "$target/skills/unrelated/data.txt" ] || fail "unrelated skill was removed"
[ ! -e "$target/skills/dev-task/stale.txt" ] || fail "stale files in a managed skill were preserved"
grep -F 'Keep this text.' "$target/AGENTS.md" >/dev/null || fail "existing rules were removed"
grep -F 'Keep this too.' "$target/AGENTS.md" >/dev/null || fail "rules after managed block were removed"
[ "$(grep -c '^<!-- ZHDANOVME:SKILLS:START -->$' "$target/AGENTS.md")" -eq 1 ] || fail "start marker was duplicated"
[ "$(grep -c '^<!-- ZHDANOVME:SKILLS:END -->$' "$target/AGENTS.md")" -eq 1 ] || fail "end marker was duplicated"
if grep -F 'old managed rules' "$target/AGENTS.md" >/dev/null; then
  fail "old managed rules were not replaced"
fi

{
  printf '%s\n' '<!-- ZHDANOVME:SKILLS:START -->'
  awk '1' "$repo/AGENTS.md"
  printf '%s\n' '<!-- ZHDANOVME:SKILLS:END -->'
} > "$tmp/expected-managed-block.md"
awk '
  $0 == "<!-- ZHDANOVME:SKILLS:START -->" { managed = 1 }
  managed { print }
  $0 == "<!-- ZHDANOVME:SKILLS:END -->" { exit }
' "$target/AGENTS.md" > "$tmp/actual-managed-block.md"
cmp "$tmp/expected-managed-block.md" "$tmp/actual-managed-block.md" >/dev/null || fail "managed AGENTS.md block does not match repository rules"
cmp "$tmp/agents-after-first-install.md" "$target/AGENTS.md" >/dev/null || fail "repeated install changed AGENTS.md"

default_home="$tmp/default home"
CODEX_HOME="$default_home" "$repo/install.sh" >/dev/null
[ -f "$default_home/skills/learn-from-pr-reviews/SKILL.md" ] || fail "CODEX_HOME default was ignored"
[ -f "$default_home/AGENTS.md" ] || fail "default AGENTS.md was not created"

printf 'shell installer tests passed\n'
