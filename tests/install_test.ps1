$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$repo = Split-Path -Parent $PSScriptRoot
$tmp = Join-Path ([System.IO.Path]::GetTempPath()) ("skills-install-test-" + [guid]::NewGuid())
$target = Join-Path $tmp "codex home"

try {
    New-Item -ItemType Directory -Path (Join-Path $target "skills/unrelated") -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $target "skills/unrelated/data.txt") -Value "keep"
    New-Item -ItemType Directory -Path (Join-Path $target "skills/dev-task") -Force | Out-Null
    Set-Content -LiteralPath (Join-Path $target "skills/dev-task/stale.txt") -Value "stale"
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

    $skillDirectories = Get-ChildItem -LiteralPath $repo -Directory | Where-Object {
        Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md")
    }
    if ($skillDirectories.Count -eq 0) {
        throw "No repository skills were discovered"
    }
    foreach ($skillDirectory in $skillDirectories) {
        $installedSkill = Join-Path $target ("skills/" + $skillDirectory.Name)
        if (-not (Test-Path -LiteralPath (Join-Path $installedSkill "SKILL.md"))) {
            throw "$($skillDirectory.Name) was not installed"
        }
        $sourceFiles = Get-ChildItem -LiteralPath $skillDirectory.FullName -File -Recurse | ForEach-Object {
            $_.FullName.Substring($skillDirectory.FullName.Length + 1)
        }
        $installedFiles = Get-ChildItem -LiteralPath $installedSkill -File -Recurse | ForEach-Object {
            $_.FullName.Substring($installedSkill.Length + 1)
        }
        if (Compare-Object $sourceFiles $installedFiles) {
            throw "$($skillDirectory.Name) was not copied completely"
        }
    }
    if (-not (Test-Path -LiteralPath (Join-Path $target "skills/unrelated/data.txt"))) {
        throw "Unrelated skill was removed"
    }
    if (Test-Path -LiteralPath (Join-Path $target "skills/dev-task/stale.txt")) {
        throw "Stale files in a managed skill were preserved"
    }

    $agents = Get-Content -LiteralPath (Join-Path $target "AGENTS.md") -Raw
    if ($agents -notmatch [regex]::Escape("Keep this text.") -or $agents -notmatch [regex]::Escape("Keep this too.")) {
        throw "Existing rules were removed"
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
    $start = "<!-- ZHDANOVME:SKILLS:START -->"
    $end = "<!-- ZHDANOVME:SKILLS:END -->"
    $rules = (Get-Content -LiteralPath (Join-Path $repo "AGENTS.md") -Raw).TrimEnd()
    $expectedBlock = ($start + "`n" + $rules + "`n" + $end) -replace "`r`n", "`n"
    $managedBlock = [regex]::Match(
        $agents,
        "(?ms)^" + [regex]::Escape($start) + ".*?^" + [regex]::Escape($end)
    ).Value -replace "`r`n", "`n"
    if ($managedBlock -cne $expectedBlock) {
        throw "Managed AGENTS.md block does not match repository rules"
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
