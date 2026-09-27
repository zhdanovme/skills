#!/bin/sh

set -eu

repo=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tmp=$(mktemp -d "${TMPDIR:-/tmp}/skills-install-test.XXXXXX")
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

assert_skills_installed() {
  target=$1
  installed_skills=0
  for skill in "$repo"/*/SKILL.md; do
    source_dir=${skill%/SKILL.md}
    name=${source_dir##*/}
    [ -f "$target/skills/$name/SKILL.md" ] || fail "$name was not installed into $target"
    diff -r "$source_dir" "$target/skills/$name" >/dev/null || fail "$name was not copied completely into $target"
    installed_skills=$((installed_skills + 1))
  done
  [ "$installed_skills" -gt 0 ] || fail "no repository skills were discovered"
}

# Installed subagents mirror <skill>/subagents/<platform>/<skill>-* byte for byte,
# and a home never receives the other platform's definitions.
assert_subagents_installed() {
  target=$1
  platform=$2
  case $platform in
    claude) extension=md; other_platform=codex; other=toml ;;
    codex) extension=toml; other_platform=claude; other=md ;;
  esac
  installed_agents=0
  for skill in "$repo"/*/SKILL.md; do
    source_dir=${skill%/SKILL.md}
    name=${source_dir##*/}
    for agent in "$source_dir/subagents/$platform/$name"-*."$extension"; do
      [ -f "$agent" ] || continue
      cmp "$agent" "$target/agents/${agent##*/}" >/dev/null 2>&1 ||
        fail "${agent##*/} was not installed into $target/agents"
      installed_agents=$((installed_agents + 1))
    done
    for foreign in "$source_dir/subagents/$other_platform/$name"-*."$other"; do
      [ -f "$foreign" ] || continue
      if [ -e "$target/agents/${foreign##*/}" ]; then
        fail "$platform home $target received ${foreign##*/}"
      fi
    done
  done
  [ "$installed_agents" -gt 0 ] || fail "no $platform subagents were discovered"
}

# Seeds agents the installer must leave alone (another agent, another skill's prefix,
# the managed prefix with the other platform's extension) and one stale managed agent.
seed_agents() {
  mkdir -p "$1/agents"
  printf 'keep\n' > "$1/agents/unrelated.$2"
  printf 'keep\n' > "$1/agents/codebase-map-custom.$2"
  printf 'keep\n' > "$1/agents/dev-task-custom.$3"
  printf 'stale\n' > "$1/agents/dev-task-retired.$2"
}

assert_agents_preserved() {
  target=$1
  extension=$2
  other=$3
  [ "$(cat "$target/agents/unrelated.$extension" 2>/dev/null)" = keep ] || fail "an unrelated agent was changed in $target"
  [ "$(cat "$target/agents/codebase-map-custom.$extension" 2>/dev/null)" = keep ] ||
    fail "an agent of a skill without subagents was changed in $target"
  [ "$(cat "$target/agents/dev-task-custom.$other" 2>/dev/null)" = keep ] ||
    fail "an agent with the other platform's extension was changed in $target"
  [ ! -e "$target/agents/dev-task-retired.$extension" ] || fail "a stale managed agent survived in $target"
}

assert_managed_block() {
  memory=$1
  [ -f "$memory" ] || fail "$memory was not created"
  [ "$(grep -c '^<!-- ZHDANOVME:SKILLS:START -->$' "$memory")" -eq 1 ] || fail "start marker was duplicated in $memory"
  [ "$(grep -c '^<!-- ZHDANOVME:SKILLS:END -->$' "$memory")" -eq 1 ] || fail "end marker was duplicated in $memory"

  {
    printf '%s\n' '<!-- ZHDANOVME:SKILLS:START -->'
    awk '1' "$repo/AGENTS.md"
    printf '%s\n' '<!-- ZHDANOVME:SKILLS:END -->'
  } > "$tmp/expected-managed-block.md"
  awk '
    $0 == "<!-- ZHDANOVME:SKILLS:START -->" { managed = 1 }
    managed { print }
    $0 == "<!-- ZHDANOVME:SKILLS:END -->" { exit }
  ' "$memory" > "$tmp/actual-managed-block.md"
  cmp "$tmp/expected-managed-block.md" "$tmp/actual-managed-block.md" >/dev/null ||
    fail "managed block in $memory does not match repository rules"
}

seed_memory() {
  cat > "$1" <<'EOF'
# Existing rules

Keep this text.

<!-- ZHDANOVME:SKILLS:START -->
old managed rules
<!-- ZHDANOVME:SKILLS:END -->

Keep this too.
EOF
}

assert_existing_rules_preserved() {
  memory=$1
  grep -F 'Keep this text.' "$memory" >/dev/null || fail "existing rules were removed from $memory"
  grep -F 'Keep this too.' "$memory" >/dev/null || fail "rules after managed block were removed from $memory"
  if grep -F 'old managed rules' "$memory" >/dev/null; then
    fail "old managed rules were not replaced in $memory"
  fi
}

# --target keeps installing a Codex home with AGENTS.md.
target="$tmp/codex home"
mkdir -p "$target/skills/unrelated"
printf 'keep\n' > "$target/skills/unrelated/data.txt"
mkdir -p "$target/skills/dev-task"
printf 'stale\n' > "$target/skills/dev-task/stale.txt"
seed_memory "$target/AGENTS.md"
seed_agents "$target" toml md

"$repo/install.sh" --target "$target" >/dev/null
cp "$target/AGENTS.md" "$tmp/agents-after-first-install.md"
"$repo/install.sh" --target "$target" >/dev/null

assert_skills_installed "$target"
assert_subagents_installed "$target" codex
assert_agents_preserved "$target" toml md
[ -f "$target/skills/unrelated/data.txt" ] || fail "unrelated skill was removed"
[ ! -e "$target/skills/dev-task/stale.txt" ] || fail "stale files in a managed skill were preserved"
assert_existing_rules_preserved "$target/AGENTS.md"
assert_managed_block "$target/AGENTS.md"
cmp "$tmp/agents-after-first-install.md" "$target/AGENTS.md" >/dev/null || fail "repeated install changed AGENTS.md"
[ ! -e "$target/CLAUDE.md" ] || fail "--target wrote a CLAUDE.md"

# --claude installs a Claude Code home with CLAUDE.md and leaves AGENTS.md alone.
claude_target="$tmp/claude home"
mkdir -p "$claude_target"
seed_memory "$claude_target/CLAUDE.md"
seed_agents "$claude_target" md toml

"$repo/install.sh" --claude "$claude_target" >/dev/null
cp "$claude_target/CLAUDE.md" "$tmp/claude-after-first-install.md"
"$repo/install.sh" --claude "$claude_target" >/dev/null

assert_skills_installed "$claude_target"
assert_subagents_installed "$claude_target" claude
assert_agents_preserved "$claude_target" md toml
assert_existing_rules_preserved "$claude_target/CLAUDE.md"
assert_managed_block "$claude_target/CLAUDE.md"
cmp "$tmp/claude-after-first-install.md" "$claude_target/CLAUDE.md" >/dev/null || fail "repeated install changed CLAUDE.md"
[ ! -e "$claude_target/AGENTS.md" ] || fail "--claude wrote an AGENTS.md"

# --codex is the explicit spelling of the AGENTS.md profile.
codex_target="$tmp/explicit codex"
"$repo/install.sh" --codex "$codex_target" >/dev/null
assert_skills_installed "$codex_target"
assert_subagents_installed "$codex_target" codex
assert_managed_block "$codex_target/AGENTS.md"
[ ! -e "$codex_target/CLAUDE.md" ] || fail "--codex wrote a CLAUDE.md"

# A bare directory argument stays a Codex home.
positional_target="$tmp/positional codex"
"$repo/install.sh" "$positional_target" >/dev/null
assert_managed_block "$positional_target/AGENTS.md"
assert_subagents_installed "$positional_target" codex
[ ! -e "$positional_target/CLAUDE.md" ] || fail "a positional directory wrote a CLAUDE.md"

# Without arguments both homes are installed from the environment defaults.
default_codex="$tmp/default codex"
default_claude="$tmp/default claude"
CODEX_HOME="$default_codex" CLAUDE_CONFIG_DIR="$default_claude" "$repo/install.sh" >/dev/null
assert_skills_installed "$default_codex"
assert_subagents_installed "$default_codex" codex
assert_managed_block "$default_codex/AGENTS.md"
assert_skills_installed "$default_claude"
assert_subagents_installed "$default_claude" claude
assert_managed_block "$default_claude/CLAUDE.md"
[ ! -e "$default_codex/CLAUDE.md" ] || fail "the Codex default home received a CLAUDE.md"
[ ! -e "$default_claude/AGENTS.md" ] || fail "the Claude default home received an AGENTS.md"

# Selecting one agent must not install the other.
only_claude="$tmp/only claude"
unused_codex="$tmp/unused codex"
CODEX_HOME="$unused_codex" CLAUDE_CONFIG_DIR="$only_claude" "$repo/install.sh" --claude >/dev/null
assert_managed_block "$only_claude/CLAUDE.md"
[ ! -e "$unused_codex" ] || fail "--claude installed the Codex default home"

# Existing content outside the managed block survives byte for byte.
formatted="$tmp/formatted home"
mkdir -p "$formatted"
cat > "$tmp/formatted-source.md" <<'EOF'
# My rules

## First section

- one
- two

Paragraph after the list.

## Second section

Final paragraph.
EOF
cp "$tmp/formatted-source.md" "$formatted/CLAUDE.md"
"$repo/install.sh" --claude "$formatted" >/dev/null
awk '/^<!-- ZHDANOVME:SKILLS:START -->$/ { exit } { print }' "$formatted/CLAUDE.md" > "$tmp/formatted-kept.md"
awk '{ lines[++count] = $0 } NF { last = count } END { for (i = 1; i <= last; i++) print lines[i] }' \
  "$tmp/formatted-kept.md" > "$tmp/formatted-kept-trimmed.md"
cmp "$tmp/formatted-source.md" "$tmp/formatted-kept-trimmed.md" >/dev/null ||
  fail "existing memory content was reformatted"

# Unknown options fail loudly.
if "$repo/install.sh" --nope >/dev/null 2>&1; then
  fail "an unknown option was accepted"
fi

# Leftover working files must not be published into the target.
if find "$tmp" -name '*.zhdanovme-kept.*' | grep -q .; then
  fail "a temporary memory file was left behind"
fi

printf 'shell installer tests passed\n'
