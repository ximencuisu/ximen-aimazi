$ErrorActionPreference = "Stop"

function Show-Usage {
    Write-Host "Usage: word-count.bat [--workspace <path>]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Count Chinese characters in chapter markdown files."
    Write-Host "Default scope: draft chapters; legacy fallback: output chapters"
}

function Resolve-WorkspacePath([string]$PathValue) {
    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $PathValue))
}

function Join-Chars([int[]]$Codes) {
    return (-join ($Codes | ForEach-Object { [char]$_ }))
}

$WorkspaceArg = "."
$ShowHelp = $false

for ($Index = 0; $Index -lt $args.Count; $Index++) {
    $Argument = $args[$Index]
    switch ($Argument) {
        "-h" { $ShowHelp = $true; continue }
        "--help" { $ShowHelp = $true; continue }
        "--workspace" {
            $Index++
            if ($Index -ge $args.Count) {
                Write-Host "[error] --workspace requires a path." -ForegroundColor Red
                Show-Usage
                exit 1
            }
            $WorkspaceArg = $args[$Index]
            continue
        }
        default {
            if ($WorkspaceArg -eq ".") {
                $WorkspaceArg = $Argument
            } else {
                Write-Host "[error] Unexpected argument: $Argument" -ForegroundColor Red
                Show-Usage
                exit 1
            }
        }
    }
}

if ($ShowHelp) {
    Show-Usage
    exit 0
}

$WorkspaceDir = Resolve-WorkspacePath $WorkspaceArg
$DraftDirName = Join-Chars @(27491, 25991)
$ChapterPrefix = Join-Chars @(31532)
$ReportFileName = Join-Chars @(23383, 25968, 32479, 35745, 46, 109, 100)
$DraftDir = Join-Path $WorkspaceDir $DraftDirName
$LegacyOutputDir = Join-Path $WorkspaceDir "output"
$ReportDir = $LegacyOutputDir
$ChapterPattern = $ChapterPrefix + "*.md"
$ReportFile = Join-Path $ReportDir $ReportFileName

if (-not (Test-Path -LiteralPath $WorkspaceDir)) {
    Write-Host "[error] workspace was not found: $WorkspaceDir" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path -LiteralPath $ReportDir)) {
    New-Item -ItemType Directory -Path $ReportDir -Force | Out-Null
}

$ChapterFiles = @()
if (Test-Path -LiteralPath $DraftDir) {
    $ChapterFiles += Get-ChildItem -LiteralPath $DraftDir -Filter $ChapterPattern -File -ErrorAction SilentlyContinue |
        ForEach-Object { [PSCustomObject]@{ File = $_; Source = "draft" } }
}
if (Test-Path -LiteralPath $LegacyOutputDir) {
    $ChapterFiles += Get-ChildItem -LiteralPath $LegacyOutputDir -Filter $ChapterPattern -File -ErrorAction SilentlyContinue |
        ForEach-Object { [PSCustomObject]@{ File = $_; Source = "output-legacy" } }
}

$ChapterFiles = $ChapterFiles | Sort-Object Source, { $_.File.Name }
$Rows = @()
$TotalChars = 0

Write-Host "========================================"
Write-Host "  Novel Character Count"
Write-Host "========================================"
Write-Host ""
Write-Host ("workspace: {0}" -f $WorkspaceDir)
Write-Host ("primary:   {0}" -f $DraftDir)
Write-Host ("legacy:    {0}" -f $LegacyOutputDir)
Write-Host ""

foreach ($Entry in $ChapterFiles) {
    $File = $Entry.File
    $Content = Get-Content -LiteralPath $File.FullName -Raw -Encoding UTF8
    $Count = [regex]::Matches($Content, "[\u3400-\u9FFF]").Count
    $TotalChars += $Count
    $Rows += [PSCustomObject]@{
        Source = $Entry.Source
        FileName = $File.Name
        Characters = $Count
    }
    Write-Host ("[{0}] {1}: {2} chars" -f $Entry.Source, $File.Name, $Count)
}

$ChapterCount = $Rows.Count
$AverageChars = if ($ChapterCount -gt 0) { [math]::Floor($TotalChars / $ChapterCount) } else { 0 }
$Percent30 = if ($TotalChars -gt 0) { [math]::Floor($TotalChars * 100 / 300000) } else { 0 }
$Percent50 = if ($TotalChars -gt 0) { [math]::Floor($TotalChars * 100 / 500000) } else { 0 }
$Percent100 = if ($TotalChars -gt 0) { [math]::Floor($TotalChars * 100 / 1000000) } else { 0 }

$Lines = @(
    "# Character Count Report",
    "",
    "> Scope: primary draft directory chapter files; legacy-compatible with `output/` chapter files.",
    "",
    "## Summary",
    "",
    "| Metric | Value |",
    "|------|-----|",
    "| Chapters | $ChapterCount |",
    "| Total chars | $TotalChars |",
    "| Average per chapter | $AverageChars |",
    "",
    "## Chapters",
    "",
    "| Source | File | Chars |",
    "|------|------|------|"
)

if ($Rows.Count -eq 0) {
    $Lines += "| _No chapters yet_ | - | 0 |"
} else {
    foreach ($Row in $Rows) {
        $Lines += "| $($Row.Source) | ``$($Row.FileName)`` | $($Row.Characters) |"
    }
}

$Lines += @(
    "",
    "## Progress",
    "",
    "| Target | Completion |",
    "|------|--------|",
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
