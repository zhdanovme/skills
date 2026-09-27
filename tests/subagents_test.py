#!/usr/bin/env python3
"""Validate subagent definitions shipped by skills and relative links in skill documents.

The installers copy `<skill>/subagents/<platform>/<skill>-*` into agent homes and treat
that prefix as the ownership boundary, so every definition must follow it. A role ships
for both platforms with identical instructions.
"""

import re
import sys
import tomllib
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
EXTENSIONS = {"claude": ".md", "codex": ".toml"}
NO_RECURSION_TOOLS = {"Skill", "Agent"}
WRITE_TOOLS = {"Edit", "Write", "NotebookEdit"}
CODEX_SANDBOXES = {"read-only", "workspace-write"}
LINK = re.compile(r"\]\(([^)\s]+)\)")

failures = []


def fail(message):
    failures.append(message.replace(f"{REPO}/", ""))


def parse_claude(path):
    match = re.fullmatch(r"---\n(.*?)\n---\n(.*)", path.read_text(encoding="utf-8"), re.S)
    if not match:
        fail(f"{path}: missing YAML frontmatter")
        return {}, ""
    fields = {}
    for line in match.group(1).splitlines():
        key, separator, value = line.partition(":")
        if not separator:
            fail(f"{path}: unparsable frontmatter line {line!r}")
            continue
        fields[key.strip()] = value.strip()
    return fields, match.group(2).strip()


def parse_codex(path):
    try:
        return tomllib.loads(path.read_text(encoding="utf-8"))
    except tomllib.TOMLDecodeError as error:
        fail(f"{path}: invalid TOML: {error}")
        return {}


def check_claude(skill, role, path):
    fields, body = parse_claude(path)
    if fields.get("name") != role:
        fail(f"{path}: name must be {role!r}")
    if not fields.get("description"):
        fail(f"{path}: description is required")
    if not body:
        fail(f"{path}: instructions are empty")
    denied = {tool.strip() for tool in fields.get("disallowedTools", "").split(",") if tool.strip()}
    if not NO_RECURSION_TOOLS <= denied:
        fail(f"{path}: disallowedTools must include {sorted(NO_RECURSION_TOOLS)}")
    if role.endswith("-reviewer") and not WRITE_TOOLS <= denied:
        fail(f"{path}: a reviewer must disallow {sorted(WRITE_TOOLS)}")
    return fields.get("description", ""), body


def check_codex(skill, role, path):
    data = parse_codex(path)
    if data.get("name") != role:
        fail(f"{path}: name must be {role!r}")
    for key in ("description", "developer_instructions"):
        if not isinstance(data.get(key), str) or not data[key].strip():
            fail(f"{path}: {key} is required")
    sandbox = data.get("sandbox_mode")
    if sandbox not in CODEX_SANDBOXES:
        fail(f"{path}: sandbox_mode must be one of {sorted(CODEX_SANDBOXES)}")
    if role.endswith("-reviewer") and sandbox != "read-only":
        fail(f"{path}: a reviewer must use sandbox_mode = 'read-only'")
    skill_rules = data.get("skills", {}).get("config", [])
    if {"name": skill, "enabled": False} not in skill_rules:
        fail(f"{path}: [[skills.config]] must disable the {skill!r} skill")
    return data.get("description", ""), str(data.get("developer_instructions", "")).strip()


def check_subagents(skill_dir):
    skill = skill_dir.name
    root = skill_dir / "subagents"
    if not root.exists():
        return 0
    roles = {}
    for platform_dir in sorted(root.iterdir()):
        platform = platform_dir.name
        if platform not in EXTENSIONS or not platform_dir.is_dir():
            fail(f"{platform_dir}: unknown platform; expected one of {sorted(EXTENSIONS)}")
            continue
        for path in sorted(platform_dir.iterdir()):
            if path.suffix != EXTENSIONS[platform] or not path.name.startswith(f"{skill}-"):
                fail(f"{path}: expected a {skill}-*{EXTENSIONS[platform]} file")
                continue
            check = check_claude if platform == "claude" else check_codex
            roles.setdefault(path.stem, {})[platform] = check(skill, path.stem, path)
    for role, definitions in sorted(roles.items()):
        if set(definitions) != set(EXTENSIONS):
            fail(f"{skill}/{role}: must ship for {sorted(EXTENSIONS)}, found {sorted(definitions)}")
        elif definitions["claude"] != definitions["codex"]:
            fail(f"{skill}/{role}: Claude and Codex descriptions or instructions differ")
    return len(roles)


def check_links(skill_dir):
    documents = [skill_dir / "SKILL.md", *sorted(skill_dir.glob("references/*.md"))]
    for document in documents:
        for target in LINK.findall(document.read_text(encoding="utf-8")):
            if re.match(r"[a-z]+:|#", target):
                continue
            if not (document.parent / target.split("#")[0]).exists():
                fail(f"{document}: broken link {target}")


skill_dirs = sorted(path.parent for path in REPO.glob("*/SKILL.md"))
if not skill_dirs:
    fail("no repository skills were discovered")
role_count = 0
for skill_dir in skill_dirs:
    role_count += check_subagents(skill_dir)
    check_links(skill_dir)
if role_count == 0:
    fail("no subagent definitions were discovered")

if failures:
    for failure in failures:
        print(f"FAIL: {failure}", file=sys.stderr)
    sys.exit(1)
print(f"subagent definition tests passed ({role_count} roles)")
