$ErrorActionPreference = "Stop"

function Show-Usage {
    Write-Host "Usage: init-novel.bat <novel-name> [--clean]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Initialize a ximen-aimazi workspace for a new novel." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "  --clean      Reset project-level files before initialization"
    Write-Host "  -h, --help   Show this help message"
}

function Write-Step([string]$Message) {
    Write-Host "[step] $Message" -ForegroundColor Cyan
}

function Write-Info([string]$Message) {
    Write-Host "[info] $Message" -ForegroundColor Green
}

function Write-Warn([string]$Message) {
    Write-Host "[warn] $Message" -ForegroundColor Yellow
}

function Join-Chars([int[]]$Codes) {
    return (-join ($Codes | ForEach-Object { [char]$_ }))
}

function Copy-Template([string]$RelativePath, [bool]$Force) {
    $Source = Join-Path $TemplateDir $RelativePath
    $Destination = Join-Path $SkillDir $RelativePath
    $DestinationDir = Split-Path -Parent $Destination

    if (-not (Test-Path -LiteralPath $DestinationDir)) {
        New-Item -ItemType Directory -Path $DestinationDir -Force | Out-Null
    }

    if ($Force -or -not (Test-Path -LiteralPath $Destination)) {
        Copy-Item -LiteralPath $Source -Destination $Destination -Force
    }
}

function Write-TemplateFile([string]$TemplateRelativePath, [string]$DestinationPath, [string]$NovelName, [bool]$Force) {
    if (-not $Force -and (Test-Path -LiteralPath $DestinationPath)) {
        return
    }

    $TemplatePath = Join-Path $TemplateDir $TemplateRelativePath
    $DestinationDir = Split-Path -Parent $DestinationPath

    if (-not (Test-Path -LiteralPath $DestinationDir)) {
        New-Item -ItemType Directory -Path $DestinationDir -Force | Out-Null
    }

    $Content = Get-Content -LiteralPath $TemplatePath -Raw -Encoding UTF8
    $Content = $Content.Replace("__NOVEL_NAME__", $NovelName)
    Set-Content -LiteralPath $DestinationPath -Value $Content -Encoding utf8
}

$NovelName = $null
$Clean = $false
$ShowHelp = $false

foreach ($Argument in $args) {
    switch ($Argument) {
        "--clean" { $Clean = $true; continue }
        "-h" { $ShowHelp = $true; continue }
        "--help" { $ShowHelp = $true; continue }
        default {
            if (-not $NovelName) {
                $NovelName = $Argument
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

if (-not $NovelName) {
    Write-Host "[error] Novel name is required." -ForegroundColor Red
    Show-Usage
    exit 1
}

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillDir = Split-Path -Parent $ScriptDir
$TemplateDir = Join-Path $SkillDir "assets\workspace"
$OutputDir = Join-Path $SkillDir "output"
$LearningsDir = Join-Path $SkillDir ".learnings"
$MemoryDir = Join-Path $SkillDir "memory"
$SessionFile = Join-Path $SkillDir "SESSION.md"
$NovelNameFile = Join-Path $SkillDir ".novel-name"
$PromptFileName = Join-Chars @(25552, 31034, 35789, 46, 109, 100)
$OutlineIterationFileName = Join-Chars @(32454, 32434, 36845, 20195, 35760, 24405, 46, 109, 100)
$OutlineInterventionFileName = Join-Chars @(32454, 32434, 24178, 39044, 20915, 31574, 46, 109, 100)
$OutlineFreezeFileName = Join-Chars @(32454, 32434, 20923, 32467, 28165, 21333, 46, 109, 100)
$PromptFile = Join-Path $OutputDir $PromptFileName
$ProjectStatusFile = Join-Path $MemoryDir "project_status.md"

$ExistingNovelName = ""
if (Test-Path -LiteralPath $NovelNameFile) {
    $ExistingNovelName = (Get-Content -LiteralPath $NovelNameFile -TotalCount 1).Trim()
}

if (-not $Clean -and $ExistingNovelName -and $ExistingNovelName -ne $NovelName) {
    Write-Host "[error] Workspace already belongs to '$ExistingNovelName'. Re-run with --clean to switch to '$NovelName'." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  ximen-aimazi workspace init" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  novel: $NovelName"
Write-Host "  clean: $Clean"
Write-Host ""

foreach ($Directory in @($OutputDir, $LearningsDir, $MemoryDir)) {
    if (-not (Test-Path -LiteralPath $Directory)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }
}

if ($Clean) {
    Write-Step "Removing generated markdown files from output/"
    Get-ChildItem -LiteralPath $OutputDir -Filter "*.md" -File -ErrorAction SilentlyContinue | Remove-Item -Force
}

$TemplateFiles = @(
    ".learnings\CHARACTERS.md",
    ".learnings\LOCATIONS.md",
    ".learnings\PLOT_POINTS.md",
    ".learnings\STORY_BIBLE.md",
    ".learnings\ERRORS.md",
    ".learnings\RESOURCES.md",
    ".learnings\SUBPLOTS.md",
    ".learnings\EMOTIONS.md",
    ".learnings\SUSPENSE.md",
    "memory\project_params.md",
    "memory\project_style.md",
    "output\CHAPTERS.md",
    "output\$OutlineIterationFileName",
    "output\$OutlineInterventionFileName",
    "output\$OutlineFreezeFileName"
)

Write-Step "Syncing project-level templates"
foreach ($TemplateFile in $TemplateFiles) {
    Copy-Template -RelativePath $TemplateFile -Force:$Clean
}

Write-Step "Writing session and prompt entry files"
Write-TemplateFile -TemplateRelativePath "SESSION.md" -DestinationPath $SessionFile -NovelName $NovelName -Force:$Clean
Write-TemplateFile -TemplateRelativePath "memory\project_status.md" -DestinationPath $ProjectStatusFile -NovelName $NovelName -Force:$Clean
Write-TemplateFile -TemplateRelativePath "output\PROMPT.md.template" -DestinationPath $PromptFile -NovelName $NovelName -Force:$Clean
Set-Content -LiteralPath $NovelNameFile -Value $NovelName -Encoding utf8

$Gitkeep = Join-Path $OutputDir ".gitkeep"
if (-not (Test-Path -LiteralPath $Gitkeep)) {
    Set-Content -LiteralPath $Gitkeep -Value "" -Encoding utf8
}

Write-Host ""
Write-Info "Workspace initialized for '$NovelName'."
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Refine output/$PromptFileName"
Write-Host "  2. Ask the AI for 3 concept options"
Write-Host "  3. Continue with worldbuilding, characters, and project params"
Write-Host "  4. Then move into outline, chapter plan, review, and drafting"
Write-Host ""

if (-not $Clean -and $ExistingNovelName) {
    Write-Warn "Existing project files were kept because --clean was not used."
}
