$ErrorActionPreference = "Stop"

function Show-Usage {
    Write-Host "Usage: pave-chain-check.ps1 [-Workspace <path>] [-BatchFile <path>]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Scan a batch outline file and validate three-stage pave-chain completeness."
    Write-Host "Stages: 1.micro-foreshadow  2.logical-bridge  3.somatic-landing"
    Write-Host "Order must be preserved; total span must be <= 3 chapters."
    Write-Host ""
    Write-Host "Exit code: 0 = all complete; 1 = issues found; 2 = usage error."
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
$PaveChainKeyword  = Join-Chars @(38138, 22443, 38142)           # 铺垫链
$CompleteKeyword   = Join-Chars @(23436, 25104)                   # 完成
$MicroStage        = Join-Chars @(24494, 20239, 31508)            # 微伏笔
$LogicStage        = Join-Chars @(36923, 36753, 26725, 26753)     # 逻辑桥梁 (梁=U+6881=26753)
$SomaticStage      = Join-Chars @(20307, 24863, 33853, 22320)     # 体感落地
$NewConceptMark    = Join-Chars @(26032, 27010, 24565)            # 新概念
$FirstAppearMark   = Join-Chars @(39318, 27425, 30331, 22330)     # 首次登场
$StageChar         = Join-Chars @(38454)                          # 阶
$ChapterPrefix     = Join-Chars @(31532)                          # 第
$BatchDirName      = Join-Chars @(22823, 32434)                   # 大纲
$BatchSubDirName   = Join-Chars @(25209, 27425, 32454, 32434)     # 批次细纲

# ---- Argument parsing ----
$WorkspaceArg = "."
$BatchFileArg = ""
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
    if ($arg -eq '-BatchFile' -or $arg -eq '-batchfile' -or $arg -eq '--batch-file') {
        $i++
        if ($i -ge $args.Count) { Write-Host "[error] -BatchFile requires a path." -ForegroundColor Red; Show-Usage; exit 2 }
        $BatchFileArg = $args[$i]; $i++; continue
    }
    if ($WorkspaceArg -eq ".") { $WorkspaceArg = $arg } else { Write-Host "[error] Unexpected argument: $arg" -ForegroundColor Red; Show-Usage; exit 2 }
    $i++
}

if ($ShowHelp) { Show-Usage; exit 0 }

$WorkspaceDir = Resolve-WorkspacePath $WorkspaceArg
if (-not (Test-Path -LiteralPath $WorkspaceDir)) {
    Write-Host "[error] workspace not found: $WorkspaceDir" -ForegroundColor Red
    exit 2
}

# Resolve batch file.
$BatchDir = Join-Path (Join-Path $WorkspaceDir $BatchDirName) $BatchSubDirName
if ([string]::IsNullOrEmpty($BatchFileArg)) {
    if (-not (Test-Path -LiteralPath $BatchDir)) {
        Write-Host "[error] batch outline directory not found: $BatchDir" -ForegroundColor Red
        Write-Host "       Please specify a file with -BatchFile." -ForegroundColor Red
        exit 2
    }
    $latest = Get-ChildItem -LiteralPath $BatchDir -Filter "*.md" -File -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if (-not $latest) {
        Write-Host "[error] no .md files in $BatchDir" -ForegroundColor Red
        exit 2
    }
    $BatchFilePath = $latest.FullName
} else {
    $BatchFilePath = if ([System.IO.Path]::IsPathRooted($BatchFileArg)) { $BatchFileArg } else { [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $BatchFileArg)) }
}

if (-not (Test-Path -LiteralPath $BatchFilePath)) {
    Write-Host "[error] batch outline file not found: $BatchFilePath" -ForegroundColor Red
    exit 2
}

Write-Host "========================================"
Write-Host "  Pave Chain Check"
Write-Host "========================================"
Write-Host ("workspace:   {0}" -f $WorkspaceDir)
Write-Host ("batch file:  {0}" -f $BatchFilePath)
Write-Host ""

# ---- Parse the batch file ----
$content = Get-Content -LiteralPath $BatchFilePath -Raw -Encoding UTF8
$lines = $content -split "`r?`n"

$rawRecords = @()
$curChapter = 0
$lastConcept = ""

# Bracket regex: matches [concept] or 【concept】 (CJK brackets U+3010/U+3011).
$bracketPattern = '[\u3010\[]([^\u3011\]]+)[\u3011\]]'

foreach ($line in $lines) {
    # Track current chapter.
    $chapMatch = [regex]::Match($line, ($ChapterPrefix + '\s*(\d+)\s*' + [char]0x7AE0))
    if ($chapMatch.Success) {
        $curChapter = [int]$chapMatch.Groups[1].Value
    }
    if ($curChapter -eq 0) { continue }

    # Extract concept name from brackets on this line.
    $concept = ""
    $brMatch = [regex]::Match($line, $bracketPattern)
    if ($brMatch.Success) {
        $concept = $brMatch.Groups[1].Value.Trim()
    }

    # Detect pave-chain annotation.
    if ($line -match $PaveChainKeyword) {
        if ($concept -ne "") {
            $lastConcept = $concept
            $recordType = if ($line -match ($PaveChainKeyword + $CompleteKeyword)) { "completion" } else { "annotation" }
            $rawRecords += [PSCustomObject]@{
                Type = "concept"
                Chapter = $curChapter
                Concept = $concept
                Stage = $recordType
            }
        }
        # Extract stages from completion record: 微伏笔(L##) → 逻辑桥梁(L##) → 体感落地(L##).
        $stagePatterns = @(
            @{ Stage = $MicroStage; Pattern = ($MicroStage + '\s*[\uFF08(]L?(\d+)[\uFF09)]') },
            @{ Stage = $LogicStage; Pattern = ($LogicStage + '\s*[\uFF08(]L?(\d+)[\uFF09)]') },
            @{ Stage = $SomaticStage; Pattern = ($SomaticStage + '\s*[\uFF08(]L?(\d+)[\uFF09)]') }
        )
        foreach ($sp in $stagePatterns) {
            $matches = [regex]::Matches($line, $sp.Pattern)
            foreach ($m in $matches) {
                $rawRecords += [PSCustomObject]@{
                    Type = "stage"
                    Chapter = [int]$m.Groups[1].Value
                    Concept = $concept
                    Stage = $sp.Stage
                }
            }
        }
    }

    # Detect individual stage lines (only on annotation-style lines: bullet points or containing 阶).
    $isAnnotationLine = ($line -match '^\s*[-*]\s') -or ($line -match $StageChar)
    if ($isAnnotationLine) {
        $effectiveConcept = if ($concept -ne "") { $concept } else { $lastConcept }
        $stageChecks = @(
            @{ Stage = $MicroStage; Pattern = $MicroStage },
            @{ Stage = $LogicStage; Pattern = $LogicStage },
            @{ Stage = $SomaticStage; Pattern = $SomaticStage }
        )
        foreach ($sc in $stageChecks) {
            if ($line -match $sc.Pattern) {
                $rawRecords += [PSCustomObject]@{
                    Type = "stage"
                    Chapter = $curChapter
                    Concept = $effectiveConcept
                    Stage = $sc.Stage
                }
            }
        }
    }

    # Detect new concept markers.
    if ($line -match $NewConceptMark -or $line -match $FirstAppearMark) {
        if ($concept -ne "") {
            $lastConcept = $concept
            $rawRecords += [PSCustomObject]@{
                Type = "concept"
                Chapter = $curChapter
                Concept = $concept
                Stage = "new-concept"
            }
        }
    }
}

# Collect unique concepts.
$conceptNames = $rawRecords | Where-Object { $_.Type -eq "concept" -and $_.Concept -ne "" } |
    Select-Object -ExpandProperty Concept -Unique
$conceptCount = @($conceptNames).Count

Write-Host "========================================"
Write-Host "  Concepts Found"
Write-Host "========================================"
if ($conceptCount -eq 0) {
    Write-Host "  (no new concept annotations found in this batch)"
    Write-Host ""
    Write-Host "Result: no new concepts -> exit 0"
    exit 0
} else {
    foreach ($name in $conceptNames) {
        $firstChap = ($rawRecords | Where-Object { $_.Type -eq "concept" -and $_.Concept -eq $name } |
            Select-Object -ExpandProperty Chapter -First 1)
        Write-Host ("  [chap {0}] {1}" -f $firstChap, $name)
    }
}
Write-Host ""

Write-Host "========================================"
Write-Host "  Three-Stage Completeness"
Write-Host "========================================"

$issues = 0
$violations = @()

foreach ($name in $conceptNames) {
    $firstChap = ($rawRecords | Where-Object { $_.Type -eq "concept" -and $_.Concept -eq $name } |
        Select-Object -ExpandProperty Chapter -First 1)

    $microChap = $rawRecords | Where-Object { $_.Type -eq "stage" -and $_.Concept -eq $name -and $_.Stage -eq $MicroStage } |
        Select-Object -ExpandProperty Chapter -First 1
    $logicChap = $rawRecords | Where-Object { $_.Type -eq "stage" -and $_.Concept -eq $name -and $_.Stage -eq $LogicStage } |
        Select-Object -ExpandProperty Chapter -First 1
    $somaticChap = $rawRecords | Where-Object { $_.Type -eq "stage" -and $_.Concept -eq $name -and $_.Stage -eq $SomaticStage } |
        Select-Object -ExpandProperty Chapter -First 1

    Write-Host ("  {0} (first appearance: chap {1}):" -f $name, $firstChap)

    $hasMicro = $false; $hasLogic = $false; $hasSomatic = $false
    if ($microChap) { Write-Host ("    [OK] {0} (L{1})" -f $MicroStage, $microChap); $hasMicro = $true }
    else { Write-Host ("    [MISSING] {0}" -f $MicroStage) -ForegroundColor Red }
    if ($logicChap) { Write-Host ("    [OK] {0} (L{1})" -f $LogicStage, $logicChap); $hasLogic = $true }
    else { Write-Host ("    [MISSING] {0}" -f $LogicStage) -ForegroundColor Red }
    if ($somaticChap) { Write-Host ("    [OK] {0} (L{1})" -f $SomaticStage, $somaticChap); $hasSomatic = $true }
    else { Write-Host ("    [MISSING] {0}" -f $SomaticStage) -ForegroundColor Red }

    # Check spacing.
    if ($microChap -and $somaticChap) {
        $span = $somaticChap - $microChap
        if ($span -gt 3) {
            Write-Host ("    [FAIL] span: {0} chapters (>3, overdue)" -f $span) -ForegroundColor Red
            $violations += ("{0}: span {1} chapters overdue (micro L{2} -> somatic L{3})" -f $name, $span, $microChap, $somaticChap)
            $issues++
        } else {
            Write-Host ("    [OK] span: {0} chapters (<=3)" -f $span)
        }
    }

    # Check order.
    if ($microChap -and $logicChap -and $somaticChap) {
        if ($microChap -gt $logicChap -or $logicChap -gt $somaticChap) {
            Write-Host "    [FAIL] three-stage disorder" -ForegroundColor Red
            $violations += ("{0}: three-stage disorder (micro L{1} -> logic L{2} -> somatic L{3})" -f $name, $microChap, $logicChap, $somaticChap)
            $issues++
        }
    }

    # Check missing stages.
    $missing = @()
    if (-not $hasMicro) { $missing += $MicroStage }
    if (-not $hasLogic) { $missing += $LogicStage }
    if (-not $hasSomatic) { $missing += $SomaticStage }
    if ($missing.Count -gt 0) {
        $violations += ("{0}: missing {1}" -f $name, ($missing -join ", "))
        $issues++
    }

    Write-Host ""
}

Write-Host "========================================"
Write-Host "  Violations"
Write-Host "========================================"
if ($violations.Count -eq 0) {
    Write-Host "  (none)" -ForegroundColor Green
} else {
    foreach ($v in $violations) {
        Write-Host ("  {0}" -f $v) -ForegroundColor Yellow
    }
}
Write-Host ""

if ($issues -gt 0) {
    Write-Host ("Result: {0} concepts, {1} issues -> exit 1" -f $conceptCount, $issues) -ForegroundColor Red
    exit 1
}
Write-Host ("Result: {0} concepts, all three stages complete -> exit 0" -f $conceptCount) -ForegroundColor Green
exit 0
