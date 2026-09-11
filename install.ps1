[CmdletBinding()]
param(
    [string]$Target,
    [string]$ClaudeTarget,
    [switch]$Codex,
    [switch]$Claude
)

$ErrorActionPreference = "Stop"
$repo = Split-Path -Parent $MyInvocation.MyCommand.Path
$start = "<!-- ZHDANOVME:SKILLS:START -->"
$end = "<!-- ZHDANOVME:SKILLS:END -->"

function Get-CodexHome {
    if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
}

function Get-ClaudeHome {
    if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME ".claude" }
}

function Install-Skills {
    param([string]$TargetPath)

    $skillsTarget = Join-Path $TargetPath "skills"
    New-Item -ItemType Directory -Path $skillsTarget -Force | Out-Null

    Get-ChildItem -LiteralPath $repo -Directory | Where-Object {
        Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md")
    } | ForEach-Object {
        $destination = Join-Path $skillsTarget $_.Name
        if (Test-Path -LiteralPath $destination) {
            Remove-Item -LiteralPath $destination -Recurse -Force
        }
        Copy-Item -LiteralPath $_.FullName -Destination $destination -Recurse
    }
}

function Install-Memory {
    param([string]$MemoryPath)

    $memory = if (Test-Path -LiteralPath $MemoryPath) {
        Get-Content -LiteralPath $MemoryPath -Raw
    } else {
        ""
    }
    $managedBlock = "(?ms)^" + [regex]::Escape($start) + ".*?^" + [regex]::Escape($end) + "\r?\n?"
    $memory = [regex]::Replace($memory, $managedBlock, "").TrimEnd()
    $rules = Get-Content -LiteralPath (Join-Path $repo "AGENTS.md") -Raw
    $content = $memory + "`n`n" + $start + "`n" + $rules.TrimEnd() + "`n" + $end + "`n"
    Set-Content -LiteralPath $MemoryPath -Value $content -NoNewline
}

$agentProfiles = [System.Collections.ArrayList]::new()

if (-not [string]::IsNullOrWhiteSpace($Target)) {
    [void]$agentProfiles.Add(@{ Path = $Target; Memory = "AGENTS.md" })
} elseif ($Codex) {
    [void]$agentProfiles.Add(@{ Path = (Get-CodexHome); Memory = "AGENTS.md" })
}

if (-not [string]::IsNullOrWhiteSpace($ClaudeTarget)) {
    [void]$agentProfiles.Add(@{ Path = $ClaudeTarget; Memory = "CLAUDE.md" })
} elseif ($Claude) {
    [void]$agentProfiles.Add(@{ Path = (Get-ClaudeHome); Memory = "CLAUDE.md" })
}

if ($agentProfiles.Count -eq 0) {
    [void]$agentProfiles.Add(@{ Path = (Get-CodexHome); Memory = "AGENTS.md" })
    [void]$agentProfiles.Add(@{ Path = (Get-ClaudeHome); Memory = "CLAUDE.md" })
}

foreach ($agentProfile in $agentProfiles) {
    New-Item -ItemType Directory -Path $agentProfile.Path -Force | Out-Null
    Install-Skills -TargetPath $agentProfile.Path
    Install-Memory -MemoryPath (Join-Path $agentProfile.Path $agentProfile.Memory)
    Write-Output ("Installed skills and " + $agentProfile.Memory + " into " + $agentProfile.Path)
}
