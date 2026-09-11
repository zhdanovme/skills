#!/bin/sh

set -eu

repo=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
start='<!-- ZHDANOVME:SKILLS:START -->'
end='<!-- ZHDANOVME:SKILLS:END -->'
tab=$(printf '\t')

usage() {
  cat <<'USAGE'
Usage: ./install.sh [options] [directory]

Options:
  --codex [directory]   Install into a Codex home and extend its AGENTS.md.
                        Defaults to $CODEX_HOME, or ~/.codex.
  --claude [directory]  Install into a Claude Code home and extend its CLAUDE.md.
                        Defaults to $CLAUDE_CONFIG_DIR, or ~/.claude.
  --target directory    Same as --codex directory.
  -h, --help            Show this help.

With no options, the installer targets both the Codex and the Claude Code home.
A bare directory argument is treated as a Codex home.
USAGE
}

codex_home() {
  printf '%s\n' "${CODEX_HOME:-${HOME:?HOME is not set}/.codex}"
}

claude_home() {
  printf '%s\n' "${CLAUDE_CONFIG_DIR:-${HOME:?HOME is not set}/.claude}"
}

profiles=''

add_profile() {
  profiles="$profiles$1$tab$2
"
}

install_skills() {
  target=$1
  mkdir -p "$target/skills"
  for skill in "$repo"/*/SKILL.md; do
    [ -f "$skill" ] || continue
    source_dir=${skill%/SKILL.md}
    name=${source_dir##*/}
    rm -rf "$target/skills/$name"
    cp -R "$source_dir" "$target/skills/$name"
  done
}

install_memory() {
  memory=$1
  kept="$memory.zhdanovme-kept.$$"

  # Keep every line outside the managed block, then drop the trailing blank
  # lines the removed block leaves behind. Content is otherwise byte-identical.
  if [ -f "$memory" ]; then
    awk -v start="$start" -v end="$end" '
      $0 == start { managed = 1; next }
      $0 == end { managed = 0; next }
      managed { next }
      { lines[++count] = $0 }
      NF { last = count }
      END { for (i = 1; i <= last; i++) print lines[i] }
    ' "$memory" > "$kept"
  else
    : > "$kept"
  fi

  {
    cat "$kept"
    if [ -s "$kept" ]; then printf '\n'; fi
    printf '%s\n' "$start"
    cat "$repo/AGENTS.md"
    printf '%s\n' "$end"
  } > "$memory"

  rm -f "$kept"
}

while [ "$#" -gt 0 ]; do
  case $1 in
    --codex|--claude)
      flag=$1
      shift
      if [ "$#" -gt 0 ] && [ "${1#-}" = "$1" ]; then
        directory=$1
        shift
      elif [ "$flag" = "--codex" ]; then
        directory=$(codex_home)
      else
        directory=$(claude_home)
      fi
      if [ "$flag" = "--codex" ]; then
        add_profile "$directory" AGENTS.md
      else
        add_profile "$directory" CLAUDE.md
      fi
      ;;
    --target)
      directory=${2:?Usage: ./install.sh [options] [directory]}
      shift 2
      add_profile "$directory" AGENTS.md
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    -*)
      printf 'Unknown option: %s\n\n' "$1" >&2
      usage >&2
      exit 2
      ;;
    *)
      add_profile "$1" AGENTS.md
      shift
      ;;
  esac
done

if [ -z "$profiles" ]; then
  add_profile "$(codex_home)" AGENTS.md
  add_profile "$(claude_home)" CLAUDE.md
fi

printf '%s' "$profiles" | while IFS="$tab" read -r target memory_name; do
  [ -n "$target" ] || continue
  mkdir -p "$target"
  install_skills "$target"
  install_memory "$target/$memory_name"
  printf 'Installed skills and %s into %s\n' "$memory_name" "$target"
done
