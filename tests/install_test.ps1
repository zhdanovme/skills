$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repo = Split-Path -Parent $PSScriptRoot
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("skills-install-test-" + [guid]::NewGuid())
$target = Join-Path $tmp "codex home"

try {
    New-Item -ItemType Directory -Path (Join-Path $target "skills/unrelated") -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $target "skills/unrelated/data.txt") -Value "keep"
    @"
# Existing rules

Keep this text.

<!-- ZHDANOVME:SKILLS:START -->
old managed rules
<!-- ZHDANOVME:SKILLS:END -->

Keep this too.
"@ | Set-Content -LiteralPath (Join-Path $target "AGENTS.md")

    & (Join-Path $repo "install.ps1") -Target $target | Out-Null
    $agentsAfterFirstInstall = Get-Content -LiteralPath (Join-Path $target "AGENTS.md") -Raw
    & (Join-Path $repo "install.ps1") -Target $target | Out-Null

    if (-not (Test-Path -LiteralPath (Join-Path $target "skills/dev-task/SKILL.md"))) {
        throw "Skill was not installed"
    }
    if (-not (Test-Path -LiteralPath (Join-Path $target "skills/unrelated/data.txt"))) {
        throw "Unrelated skill was removed"
    }

    $agents = Get-Content -LiteralPath (Join-Path $target "AGENTS.md") -Raw
    if ($agents -notmatch [regex]::Escape("Keep this text.") -or $agents -notmatch [regex]::Escape("Keep this too.")) {
        throw "Existing rules were removed"
    }
    if ($agents -notmatch [regex]::Escape("## Complexity Budget")) {
        throw "Repository rules were not added"
    }
    if ([regex]::Matches($agents, [regex]::Escape("<!-- ZHDANOVME:SKILLS:START -->")).Count -ne 1) {
        throw "Start marker was duplicated"
    }
    if ([regex]::Matches($agents, [regex]::Escape("<!-- ZHDANOVME:SKILLS:END -->")).Count -ne 1) {
        throw "End marker was duplicated"
    }
    if ($agents -match [regex]::Escape("old managed rules")) {
        throw "Old managed rules were not replaced"
    }
    if ($agents -cne $agentsAfterFirstInstall) {
        throw "Repeated install changed AGENTS.md"
    }

    Write-Output "PowerShell installer tests passed"
}
finally {
    if (Test-Path -LiteralPath $tmp) {
        Remove-Item -LiteralPath $tmp -Recurse -Force
    }
}
