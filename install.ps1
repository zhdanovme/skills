param([string]$Target)

$ErrorActionPreference = "Stop"
$repo = Split-Path -Parent $MyInvocation.MyCommand.Path
$start = "<!-- ZHDANOVME:SKILLS:START -->"
$end = "<!-- ZHDANOVME:SKILLS:END -->"

if ([string]::IsNullOrWhiteSpace($Target)) {
    $Target = if ($env:CODEX_HOME) { $env:CODEX_HOME } else { Join-Path $HOME ".codex" }
}

$skillsTarget = Join-Path $Target "skills"
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

$agentsPath = Join-Path $Target "AGENTS.md"
$agents = if (Test-Path -LiteralPath $agentsPath) {
    Get-Content -LiteralPath $agentsPath -Raw
} else {
    ""
}
$managedBlock = "(?ms)^" + [regex]::Escape($start) + ".*?^" + [regex]::Escape($end) + "\r?\n?"
$agents = [regex]::Replace($agents, $managedBlock, "").TrimEnd()
$rules = Get-Content -LiteralPath (Join-Path $repo "AGENTS.md") -Raw
$content = $agents + "`n`n" + $start + "`n" + $rules.TrimEnd() + "`n" + $end + "`n"
Set-Content -LiteralPath $agentsPath -Value $content -NoNewline

Write-Output "Installed skills and AGENTS.md into $Target"
