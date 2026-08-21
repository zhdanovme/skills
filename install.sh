#!/bin/sh

set -eu

repo=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
start='<!-- ZHDANOVME:SKILLS:START -->'
end='<!-- ZHDANOVME:SKILLS:END -->'

if [ "${1:-}" = "--target" ]; then
  target=${2:?Usage: ./install.sh [--target] [directory]}
elif [ "$#" -gt 0 ]; then
  target=$1
else
  target=${CODEX_HOME:-${HOME:?HOME is not set}/.codex}
fi

mkdir -p "$target/skills"

for skill in "$repo"/*/SKILL.md; do
  [ -f "$skill" ] || continue
  source_dir=${skill%/SKILL.md}
  name=${source_dir##*/}
  rm -rf "$target/skills/$name"
  cp -R "$source_dir" "$target/skills/$name"
done

agents="$target/AGENTS.md"
clean="$target/.AGENTS.md.clean.$$"

if [ -f "$agents" ]; then
  awk -v start="$start" -v end="$end" '
    $0 == start { managed = 1; next }
    $0 == end { managed = 0; next }
    !managed { print }
  ' "$agents" > "$clean"
else
  : > "$clean"
fi

{
  awk '
    NF { blank = 0 }
    !NF { blank = 1; next }
    { if (blank && wrote) print ""; print; wrote = 1 }
  ' "$clean"
  if [ -s "$clean" ]; then printf '\n'; fi
  printf '%s\n' "$start"
  cat "$repo/AGENTS.md"
  printf '%s\n' "$end"
} > "$agents"

rm -f "$clean"
printf 'Installed skills and AGENTS.md into %s\n' "$target"
