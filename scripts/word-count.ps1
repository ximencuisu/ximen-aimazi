$ErrorActionPreference = "Stop"

function Join-Chars([int[]]$Codes) {
    return (-join ($Codes | ForEach-Object { [char]$_ }))
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillDir = Split-Path -Parent $ScriptDir
$OutputDir = Join-Path $SkillDir "output"
$ChapterPattern = (Join-Chars @(31532)) + "*.md"
$ReportFile = Join-Path $OutputDir (Join-Chars @(23383, 25968, 32479, 35745, 46, 109, 100))

if (-not (Test-Path -LiteralPath $OutputDir)) {
    Write-Host "[error] output/ was not found. Run the script from the project root." -ForegroundColor Red
    exit 1
}

$ChapterFiles = Get-ChildItem -LiteralPath $OutputDir -Filter $ChapterPattern -File -ErrorAction SilentlyContinue |
    Sort-Object Name

$Rows = @()
$TotalChars = 0

Write-Host "========================================"
Write-Host "  Novel Character Count"
Write-Host "========================================"
Write-Host ""

foreach ($File in $ChapterFiles) {
    $Content = Get-Content -LiteralPath $File.FullName -Raw -Encoding UTF8
    $Count = [regex]::Matches($Content, "[\u3400-\u9FFF]").Count
    $TotalChars += $Count
    $Rows += [PSCustomObject]@{
        FileName = $File.Name
        Characters = $Count
    }
    Write-Host ("{0}: {1} chars" -f $File.Name, $Count)
}

$ChapterCount = $Rows.Count
$AverageChars = if ($ChapterCount -gt 0) { [math]::Floor($TotalChars / $ChapterCount) } else { 0 }
$Percent30 = if ($TotalChars -gt 0) { [math]::Floor($TotalChars * 100 / 300000) } else { 0 }
$Percent50 = if ($TotalChars -gt 0) { [math]::Floor($TotalChars * 100 / 500000) } else { 0 }
$Percent100 = if ($TotalChars -gt 0) { [math]::Floor($TotalChars * 100 / 1000000) } else { 0 }

$Lines = @(
    "# Character Count Report",
    "",
    "> Scope: all chapter markdown files under `output/` that use the standard chapter filename prefix.",
    "",
    "## Summary",
    "",
    "| Metric | Value |",
    "|--------|-------|",
    "| Chapters | $ChapterCount |",
    "| Total chars | $TotalChars |",
    "| Average per chapter | $AverageChars |",
    "",
    "## Chapters",
    "",
    "| File | Chars |",
    "|------|-------|"
)

if ($Rows.Count -eq 0) {
    $Lines += "| _No chapters yet_ | 0 |"
} else {
    foreach ($Row in $Rows) {
        $Lines += "| ``$($Row.FileName)`` | $($Row.Characters) |"
    }
}

$Lines += @(
    "",
    "## Progress",
    "",
    "| Target | Completion |",
    "|--------|------------|",
    "| 300k chars | $Percent30% |",
    "| 500k chars | $Percent50% |",
    "| 1,000k chars | $Percent100% |"
)

Set-Content -LiteralPath $ReportFile -Value $Lines -Encoding utf8

Write-Host ""
Write-Host "========================================"
Write-Host "  Summary"
Write-Host "========================================"
Write-Host ("chapters: {0}" -f $ChapterCount)
Write-Host ("total chars: {0}" -f $TotalChars)
Write-Host ("average: {0}" -f $AverageChars)
Write-Host ""
Write-Host "========================================"
Write-Host "  Progress"
Write-Host "========================================"
Write-Host ("300k target: {0}%" -f $Percent30)
Write-Host ("500k target: {0}%" -f $Percent50)
Write-Host ("1,000k target: {0}%" -f $Percent100)
Write-Host ""
Write-Host ("Report written to {0}" -f $ReportFile)
