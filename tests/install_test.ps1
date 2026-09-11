$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repo = Split-Path -Parent $PSScriptRoot
$installer = Join-Path $repo "install.ps1"
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("skills-install-test-" + [guid]::NewGuid())
$start = "<!-- ZHDANOVME:SKILLS:START -->"
$end = "<!-- ZHDANOVME:SKILLS:END -->"

function New-SeededMemory {
    param([string]$MemoryPath)

    New-Item -ItemType Directory -Path (Split-Path -Parent $MemoryPath) -Force | Out-Null
    @"
# Existing rules

Keep this text.

$start
old managed rules
$end

Keep this too.
"@ | Set-Content -LiteralPath $MemoryPath
}

function Assert-SkillsInstalled {
    param([string]$TargetPath)

    $skillDirectories = Get-ChildItem -LiteralPath $repo -Directory | Where-Object {
        Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md")
    }
    if ($skillDirectories.Count -eq 0) {
        throw "No repository skills were discovered"
    }
    foreach ($skillDirectory in $skillDirectories) {
        $installedSkill = Join-Path $TargetPath ("skills/" + $skillDirectory.Name)
        if (-not (Test-Path -LiteralPath (Join-Path $installedSkill "SKILL.md"))) {
            throw "$($skillDirectory.Name) was not installed into $TargetPath"
        }
        $sourceFiles = Get-ChildItem -LiteralPath $skillDirectory.FullName -File -Recurse | ForEach-Object {
            $_.FullName.Substring($skillDirectory.FullName.Length + 1)
        }
        $installedFiles = Get-ChildItem -LiteralPath $installedSkill -File -Recurse | ForEach-Object {
            $_.FullName.Substring($installedSkill.Length + 1)
        }
        if (Compare-Object $sourceFiles $installedFiles) {
            throw "$($skillDirectory.Name) was not copied completely into $TargetPath"
        }
    }
}

function Assert-ManagedBlock {
    param([string]$MemoryPath)

    if (-not (Test-Path -LiteralPath $MemoryPath)) {
        throw "$MemoryPath was not created"
    }
    $memory = Get-Content -LiteralPath $MemoryPath -Raw
    if ([regex]::Matches($memory, [regex]::Escape($start)).Count -ne 1) {
        throw "Start marker was duplicated in $MemoryPath"
    }
    if ([regex]::Matches($memory, [regex]::Escape($end)).Count -ne 1) {
        throw "End marker was duplicated in $MemoryPath"
    }
    $rules = (Get-Content -LiteralPath (Join-Path $repo "AGENTS.md") -Raw).TrimEnd()
    $expectedBlock = ($start + "`n" + $rules + "`n" + $end) -replace "`r`n", "`n"
    $managedBlock = [regex]::Match(
        $memory,
        "(?ms)^" + [regex]::Escape($start) + ".*?^" + [regex]::Escape($end)
    ).Value -replace "`r`n", "`n"
    if ($managedBlock -cne $expectedBlock) {
        throw "Managed block in $MemoryPath does not match repository rules"
    }
}

function Assert-ExistingRulesPreserved {
    param([string]$MemoryPath)

    $memory = Get-Content -LiteralPath $MemoryPath -Raw
    if ($memory -notmatch [regex]::Escape("Keep this text.") -or $memory -notmatch [regex]::Escape("Keep this too.")) {
        throw "Existing rules were removed from $MemoryPath"
    }
    if ($memory -match [regex]::Escape("old managed rules")) {
        throw "Old managed rules were not replaced in $MemoryPath"
    }
}

$originalCodexHome = $env:CODEX_HOME
$originalClaudeConfigDir = $env:CLAUDE_CONFIG_DIR

try {
    # -Target keeps installing a Codex home with AGENTS.md.
    $target = Join-Path $tmp "codex home"
    New-Item -ItemType Directory -Path (Join-Path $target "skills/unrelated") -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $target "skills/unrelated/data.txt") -Value "keep"
    New-Item -ItemType Directory -Path (Join-Path $target "skills/dev-task") -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $target "skills/dev-task/stale.txt") -Value "stale"
    New-SeededMemory -MemoryPath (Join-Path $target "AGENTS.md")

    & $installer -Target $target | Out-Null
    $agentsAfterFirstInstall = Get-Content -LiteralPath (Join-Path $target "AGENTS.md") -Raw
    & $installer -Target $target | Out-Null

    Assert-SkillsInstalled -TargetPath $target
    if (-not (Test-Path -LiteralPath (Join-Path $target "skills/unrelated/data.txt"))) {
        throw "Unrelated skill was removed"
    }
    if (Test-Path -LiteralPath (Join-Path $target "skills/dev-task/stale.txt")) {
        throw "Stale files in a managed skill were preserved"
    }
    Assert-ExistingRulesPreserved -MemoryPath (Join-Path $target "AGENTS.md")
    Assert-ManagedBlock -MemoryPath (Join-Path $target "AGENTS.md")
    if ((Get-Content -LiteralPath (Join-Path $target "AGENTS.md") -Raw) -cne $agentsAfterFirstInstall) {
        throw "Repeated install changed AGENTS.md"
    }
    if (Test-Path -LiteralPath (Join-Path $target "CLAUDE.md")) {
        throw "-Target wrote a CLAUDE.md"
    }

    # -ClaudeTarget installs a Claude Code home with CLAUDE.md and leaves AGENTS.md alone.
    $claudeTarget = Join-Path $tmp "claude home"
    New-SeededMemory -MemoryPath (Join-Path $claudeTarget "CLAUDE.md")

    & $installer -ClaudeTarget $claudeTarget | Out-Null
    $claudeAfterFirstInstall = Get-Content -LiteralPath (Join-Path $claudeTarget "CLAUDE.md") -Raw
    & $installer -ClaudeTarget $claudeTarget | Out-Null

    Assert-SkillsInstalled -TargetPath $claudeTarget
    Assert-ExistingRulesPreserved -MemoryPath (Join-Path $claudeTarget "CLAUDE.md")
    Assert-ManagedBlock -MemoryPath (Join-Path $claudeTarget "CLAUDE.md")
    if ((Get-Content -LiteralPath (Join-Path $claudeTarget "CLAUDE.md") -Raw) -cne $claudeAfterFirstInstall) {
        throw "Repeated install changed CLAUDE.md"
    }
    if (Test-Path -LiteralPath (Join-Path $claudeTarget "AGENTS.md")) {
        throw "-ClaudeTarget wrote an AGENTS.md"
    }

    # Without parameters both homes are installed from the environment defaults.
    $defaultCodex = Join-Path $tmp "default codex"
    $defaultClaude = Join-Path $tmp "default claude"
    $env:CODEX_HOME = $defaultCodex
    $env:CLAUDE_CONFIG_DIR = $defaultClaude
    & $installer | Out-Null
    Assert-SkillsInstalled -TargetPath $defaultCodex
    Assert-ManagedBlock -MemoryPath (Join-Path $defaultCodex "AGENTS.md")
    Assert-SkillsInstalled -TargetPath $defaultClaude
    Assert-ManagedBlock -MemoryPath (Join-Path $defaultClaude "CLAUDE.md")
    if (Test-Path -LiteralPath (Join-Path $defaultCodex "CLAUDE.md")) {
        throw "The Codex default home received a CLAUDE.md"
    }
    if (Test-Path -LiteralPath (Join-Path $defaultClaude "AGENTS.md")) {
        throw "The Claude default home received an AGENTS.md"
    }

    # Selecting one agent must not install the other.
    $onlyClaude = Join-Path $tmp "only claude"
    $unusedCodex = Join-Path $tmp "unused codex"
    $env:CODEX_HOME = $unusedCodex
    $env:CLAUDE_CONFIG_DIR = $onlyClaude
    & $installer -Claude | Out-Null
    Assert-ManagedBlock -MemoryPath (Join-Path $onlyClaude "CLAUDE.md")
    if (Test-Path -LiteralPath $unusedCodex) {
        throw "-Claude installed the Codex default home"
    }

    $onlyCodex = Join-Path $tmp "only codex"
    $unusedClaude = Join-Path $tmp "unused claude"
    $env:CODEX_HOME = $onlyCodex
    $env:CLAUDE_CONFIG_DIR = $unusedClaude
    & $installer -Codex | Out-Null
    Assert-ManagedBlock -MemoryPath (Join-Path $onlyCodex "AGENTS.md")
    if (Test-Path -LiteralPath $unusedClaude) {
        throw "-Codex installed the Claude default home"
    }

    # Existing content outside the managed block survives byte for byte.
    $formatted = Join-Path $tmp "formatted home"
    New-Item -ItemType Directory -Path $formatted -Force | Out-Null
    $formattedSource = @"
# My rules

## First section

- one
- two

Paragraph after the list.

## Second section

Final paragraph.
"@ -replace "`r`n", "`n"
    Set-Content -LiteralPath (Join-Path $formatted "CLAUDE.md") -Value ($formattedSource + "`n") -NoNewline

    & $installer -ClaudeTarget $formatted | Out-Null

    $formattedMemory = (Get-Content -LiteralPath (Join-Path $formatted "CLAUDE.md") -Raw) -replace "`r`n", "`n"
    $keptContent = $formattedMemory.Substring(0, $formattedMemory.IndexOf($start)).TrimEnd()
    if ($keptContent -cne $formattedSource) {
        throw "Existing memory content was reformatted"
    }

    Write-Output "PowerShell installer tests passed"
}
finally {
    $env:CODEX_HOME = $originalCodexHome
    $env:CLAUDE_CONFIG_DIR = $originalClaudeConfigDir
    if (Test-Path -LiteralPath $tmp) {
        Remove-Item -LiteralPath $tmp -Recurse -Force
    }
}
