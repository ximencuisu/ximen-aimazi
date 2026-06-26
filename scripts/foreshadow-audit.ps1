$ErrorActionPreference = "Stop"

function Show-Usage {
    Write-Host "Usage: foreshadow-audit.ps1 [-Workspace <path>] [-CurrentChapter <int>]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Scan foreshadow tracking files and report unresolved items."
    Write-Host "Reads:  <workspace>/追踪/伏笔.md  and  <workspace>/.learnings/PLOT_SUSPENSE.md"
    Write-Host "Current chapter auto-detected from <workspace>/追踪/CHAPTERS.md unless -CurrentChapter given."
    Write-Host "Exit code: 0 = no overdue/unresolved foreshadows; 1 = issues found; 2 = usage error."
}

function Resolve-WorkspacePath([string]$PathValue) {
    if ([string]::IsNullOrEmpty($PathValue)) { $PathValue = "." }
    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }
    return [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $PathValue))
}

function Join-Chars([int[]]$Codes) {
    return (-join ($Codes | ForEach-Object { [char]$_ }))
}

# Chinese string constants built from code points to avoid encoding issues on PowerShell 5.x.
$TraceDirName       = Join-Chars @(36844, 36394)                    # 追踪
$ForeshadowBaseName = Join-Chars @(20239, 31508)                     # 伏笔
$ActiveSectionName  = Join-Chars @(27963, 36291) + $ForeshadowBaseName  # 活跃伏笔

# Field markers for PLOT_SUSPENSE.md blocks.
$DoubleStar = '*' + '*'
$PlantedFieldMarker = $DoubleStar + (Join-Chars @(22475, 35774, 31456, 33410)) + $DoubleStar  # **埋设章节**
$StatusFieldMarker  = $DoubleStar + (Join-Chars @(29366, 24577)) + $DoubleStar                 # **状态**
$PlannedFieldMarker = $DoubleStar + (Join-Chars @(39044, 26399, 22238, 25910)) + $DoubleStar   # **预期回收**
$LatestChapterLabel = (Join-Chars @(26368, 26032, 31456, 33410))                                # 最新章节
$HeaderSkipPattern  = Join-Chars @(20239, 31508, 20869, 23481)  # 伏笔内容 (table header text to skip)

# Parse a chapter reference like "第12章" / "12" / "第12-13章" -> first integer found.
function ConvertTo-ChapterNumber([string]$Text) {
    if ([string]::IsNullOrEmpty($Text)) { return $null }
    if ($Text -match '(\d+)') { return [int]$Matches[1] }
    return $null
}

# Parse the active foreshadow table in 追踪/伏笔.md.
# Columns: | ID | 伏笔内容 | 埋设章节 | 预计回收 | 相关角色 | 状态 | 备注 |
function Parse-ForeshadowFile([string]$Path) {
    $items = @()
    if (-not (Test-Path -LiteralPath $Path)) { return $items }
    $content = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    $lines = $content -split "`r?`n"
    $inActive = $false
    foreach ($line in $lines) {
        if ($line -match ('^\s*##\s*' + [regex]::Escape($ActiveSectionName))) { $inActive = $true; continue }
        if ($line -match '^\s*##\s') { $inActive = $false; continue }
        if (-not $inActive) { continue }
        if ($line -notmatch '^\s*\|') { continue }
        if ($line -match '^\s*\|[\s\-:|]+\|\s*$') { continue }
        $cols = ($line -split '\|' | ForEach-Object { $_.Trim() } | Where-Object { $_ -ne '' })
        if ($cols.Count -lt 6) { continue }
        $id = $cols[0]
        if ($id -eq 'ID') { continue }
        if ($id -match ('^' + [regex]::Escape($HeaderSkipPattern))) { continue }
        $items += [PSCustomObject]@{
            Source      = 'foreshadow.md'
            ID          = $id
            Description = $cols[1]
            PlantedChap = (ConvertTo-ChapterNumber $cols[2])
            PlantedRaw  = $cols[2]
            PlannedChap = (ConvertTo-ChapterNumber $cols[3])
            PlannedRaw  = $cols[3]
            Status      = $cols[5]
            Remarks     = if ($cols.Count -ge 7) { $cols[6] } else { '' }
        }
    }
    return $items
}

# Parse the active suspense blocks in .learnings/PLOT_SUSPENSE.md.
function Parse-PlotSuspenseFile([string]$Path) {
    $items = @()
    if (-not (Test-Path -LiteralPath $Path)) { return $items }
    $content = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    $blockMatches = [regex]::Matches($content, '(?ms)^###\s+\[([^\]]+)\][^\n]*\r?\n(.*?)(?=^###\s+\[|\z)')
    foreach ($bm in $blockMatches) {
        $id = $bm.Groups[1].Value.Trim()
        $body = $bm.Groups[2].Value
        $planted = $null; $planned = $null; $status = $null
        $plantedPat = [regex]::Escape($PlantedFieldMarker) + '\s*[:：]\s*([^|\r\n]+)'
        $statusPat  = [regex]::Escape($StatusFieldMarker)  + '\s*[:：]\s*([^|\r\n]+)'
        $plannedPat = [regex]::Escape($PlannedFieldMarker) + '\s*[:：]\s*([^\r\n]+)'
        if ($body -match $plantedPat) { $planted = (ConvertTo-ChapterNumber $Matches[1]) }
        if ($body -match $statusPat)  { $status = ($Matches[1].Trim()) }
        if ($body -match $plannedPat) { $planned = (ConvertTo-ChapterNumber $Matches[1]) }
        $items += [PSCustomObject]@{
            Source      = 'PLOT_SUSPENSE.md'
            ID          = $id
            Description = ''
            PlantedChap = $planted
            PlantedRaw  = ''
            PlannedChap = $planned
            PlannedRaw  = ''
            Status      = if ($status) { $status } else { 'unknown' }
            Remarks     = ''
        }
    }
    return $items
}

# Detect the latest chapter number from 追踪/CHAPTERS.md.
function Get-LatestChapter([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { return $null }
    $content = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    $labelPat = [regex]::Escape($LatestChapterLabel) + '\s*\|\s*[^|]*?(\d+)'
    if ($content -match $labelPat) { return [int]$Matches[1] }
    $nums = [regex]::Matches($content, '第\s*(\d+)\s*章') | ForEach-Object { [int]$_.Groups[1].Value }
    if ($nums.Count -gt 0) { return ($nums | Measure-Object -Maximum).Maximum }
    return $null
}

# ---- Argument parsing (if/elseif chain to avoid switch-Regex quoting issues) ----
$WorkspaceArg = "."
$CurrentChapter = $null
$ShowHelp = $false

$i = 0
while ($i -lt $args.Count) {
    $arg = $args[$i]
    if ($arg -eq '-h' -or $arg -eq '--help') {
        $ShowHelp = $true; $i++; continue
    }
    if ($arg -eq '-Workspace' -or $arg -eq '-workspace' -or $arg -eq '--workspace') {
        $i++
        if ($i -ge $args.Count) { Write-Host "[error] -Workspace requires a path." -ForegroundColor Red; Show-Usage; exit 2 }
        $WorkspaceArg = $args[$i]; $i++; continue
    }
    if ($arg -eq '-CurrentChapter' -or $arg -eq '-currentchapter' -or $arg -eq '--current-chapter') {
        $i++
        if ($i -ge $args.Count) { Write-Host "[error] -CurrentChapter requires an integer." -ForegroundColor Red; Show-Usage; exit 2 }
        $CurrentChapter = [int]$args[$i]; $i++; continue
    }
    # Positional: first positional becomes workspace.
    if ($WorkspaceArg -eq ".") { $WorkspaceArg = $arg } else { Write-Host "[error] Unexpected argument: $arg" -ForegroundColor Red; Show-Usage; exit 2 }
    $i++
}

if ($ShowHelp) { Show-Usage; exit 0 }

$WorkspaceDir = Resolve-WorkspacePath $WorkspaceArg
$ForeshadowFile = Join-Path (Join-Path $WorkspaceDir $TraceDirName) ($ForeshadowBaseName + '.md')
$PlotSuspenseFile = Join-Path (Join-Path $WorkspaceDir '.learnings') 'PLOT_SUSPENSE.md'
$ChaptersFile = Join-Path (Join-Path $WorkspaceDir $TraceDirName) 'CHAPTERS.md'

if (-not (Test-Path -LiteralPath $WorkspaceDir)) {
    Write-Host "[error] workspace not found: $WorkspaceDir" -ForegroundColor Red
    exit 2
}

Write-Host "========================================"
Write-Host "  Foreshadow Audit"
Write-Host "========================================"
Write-Host ("workspace:        {0}" -f $WorkspaceDir)
Write-Host ("foreshadow file:  {0}" -f $ForeshadowFile)
Write-Host ("plot suspense:    {0}" -f $PlotSuspenseFile)
Write-Host ("chapters index:   {0}" -f $ChaptersFile)

if (-not $CurrentChapter) {
    $CurrentChapter = Get-LatestChapter $ChaptersFile
}
if ($CurrentChapter) {
    Write-Host ("current chapter:  {0}" -f $CurrentChapter)
} else {
    Write-Host "current chapter:  unknown (pass -CurrentChapter to specify)" -ForegroundColor Yellow
}
Write-Host ""

$fromForeshadow = Parse-ForeshadowFile $ForeshadowFile
$fromSuspense = Parse-PlotSuspenseFile $PlotSuspenseFile

Write-Host ("parsed from foreshadow.md:      {0} entries" -f $fromForeshadow.Count)
Write-Host ("parsed from PLOT_SUSPENSE.md:   {0} entries" -f $fromSuspense.Count)
Write-Host ""

$all = @()
$all += $fromForeshadow
$all += $fromSuspense

# Status patterns (resolved / not-planted) built via Join-Chars to avoid encoding issues.
$ResolvedPattern = (Join-Chars @(24050, 22238, 25910)) + '|' + (Join-Chars @(24050, 23436, 32467)) + '|' + (Join-Chars @(24050, 24223, 24323)) + '|' + (Join-Chars @(24050, 26242, 32531)) + '|' + (Join-Chars @(24223, 24323)) + '|' + (Join-Chars @(26242, 32531)) + '|' + (Join-Chars @(24402, 26723))
$NotPlantedPattern = (Join-Chars @(26410, 22475)) + '|' + (Join-Chars @(26410, 35774))

$unresolved = @($all | Where-Object {
    $_.Status -and ($_.Status -notmatch $ResolvedPattern) -and ($_.Status -notmatch $NotPlantedPattern)
})

$overdue = @()
if ($CurrentChapter) {
    $overdue = @($unresolved | Where-Object {
        $_.PlannedChap -ne $null -and $CurrentChapter -gt $_.PlannedChap
    })
}

# Cross-file status inconsistency: same ID with different statuses.
$inconsistent = @()
$byId = $all | Group-Object -Property ID
foreach ($g in $byId) {
    if ($g.Count -lt 2) { continue }
    $statuses = $g.Group | ForEach-Object { $_.Status } | Sort-Object -Unique
    if ($statuses.Count -gt 1) { $inconsistent += $g.Group }
}

$idsF = $fromForeshadow | ForEach-Object { $_.ID }
$idsS = $fromSuspense | ForEach-Object { $_.ID }
$onlyF = $idsF | Where-Object { $_ -notin $idsS }
$onlyS = $idsS | Where-Object { $_ -notin $idsF }

Write-Host "========================================"
Write-Host "  Unresolved Foreshadows"
Write-Host "========================================"
if ($unresolved.Count -eq 0) {
    Write-Host "  (none)" -ForegroundColor Green
} else {
    foreach ($u in $unresolved) {
        $pl = if ($u.PlantedChap) { $u.PlantedChap } else { '?' }
        $pn = if ($u.PlannedChap) { $u.PlannedChap } else { '?' }
        Write-Host ("  [{0}] {1} | status={2} | planted={3} | planned={4}" -f $u.Source, $u.ID, $u.Status, $pl, $pn)
    }
}
Write-Host ""

Write-Host "========================================"
Write-Host "  Overdue (planted, not resolved, past planned chapter)"
Write-Host "========================================"
if ($overdue.Count -eq 0) {
    Write-Host "  (none)" -ForegroundColor Green
} else {
    foreach ($o in $overdue) {
        Write-Host ("  [{0}] {1} | planned chapter {2} | current {3} | status={4}" -f $o.Source, $o.ID, $o.PlannedChap, $CurrentChapter, $o.Status) -ForegroundColor Red
    }
}
Write-Host ""

Write-Host "========================================"
Write-Host "  Cross-file Status Inconsistency"
Write-Host "========================================"
if ($inconsistent.Count -eq 0) {
    Write-Host "  (none)" -ForegroundColor Green
} else {
    foreach ($ic in $inconsistent) {
        Write-Host ("  [{0}] {1} | status={2}" -f $ic.Source, $ic.ID, $ic.Status) -ForegroundColor Yellow
    }
}
Write-Host ""

Write-Host "========================================"
Write-Host "  Single-file-only IDs (informational)"
Write-Host "========================================"
if ($onlyF.Count -eq 0 -and $onlyS.Count -eq 0) {
    Write-Host "  (full match)" -ForegroundColor Green
} else {
    if ($onlyF.Count -gt 0) { Write-Host ("  only in foreshadow.md:     {0}" -f ($onlyF -join ', ')) }
    if ($onlyS.Count -gt 0) { Write-Host ("  only in PLOT_SUSPENSE.md:  {0}" -f ($onlyS -join ', ')) }
}
Write-Host ""

if ($overdue.Count -gt 0 -or $unresolved.Count -gt 0) {
    Write-Host ("Result: {0} overdue, {1} unresolved -> exit 1" -f $overdue.Count, $unresolved.Count) -ForegroundColor Red
    exit 1
}
Write-Host "Result: no overdue/unresolved foreshadows -> exit 0" -ForegroundColor Green
exit 0
