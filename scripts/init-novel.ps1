$ErrorActionPreference = "Stop"

function Show-Usage {
    Write-Host "Usage: init-novel.bat <novel-name> [--workspace <path>] [--clean]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Initialize a ximen-aimazi workspace for a novel." -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Cyan
    Write-Host "  --workspace  Target workspace directory. Defaults to a sibling of this skill directory"
    Write-Host "  --clean      Overwrite project-level scaffold files in the target workspace"
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

function Resolve-WorkspacePath([string]$PathValue) {
    if ([System.IO.Path]::IsPathRooted($PathValue)) {
        return [System.IO.Path]::GetFullPath($PathValue)
    }

    return [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $PathValue))
}

function Join-Chars([int[]]$Codes) {
    return (-join ($Codes | ForEach-Object { [char]$_ }))
}

function Copy-Template([string]$RelativePath, [bool]$Force) {
    $Source = Join-Path $TemplateDir $RelativePath
    $Destination = Join-Path $WorkspaceDir $RelativePath
    $DestinationDir = Split-Path -Parent $Destination

    if (-not (Test-Path -LiteralPath $Source)) {
        throw "Template not found: $Source"
    }

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
    if (-not (Test-Path -LiteralPath $TemplatePath)) {
        throw "Template not found: $TemplatePath"
    }

    $DestinationDir = Split-Path -Parent $DestinationPath
    if (-not (Test-Path -LiteralPath $DestinationDir)) {
        New-Item -ItemType Directory -Path $DestinationDir -Force | Out-Null
    }

    $Content = Get-Content -LiteralPath $TemplatePath -Raw -Encoding UTF8
    $Content = $Content.Replace("__NOVEL_NAME__", $NovelName)
    Set-Content -LiteralPath $DestinationPath -Value $Content -Encoding utf8
}

$NovelName = $null
$WorkspaceArg = $null
$Clean = $false
$ShowHelp = $false

for ($Index = 0; $Index -lt $args.Count; $Index++) {
    $Argument = $args[$Index]

    switch ($Argument) {
        "--clean" { $Clean = $true; continue }
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
$WorkspaceDir = if ($WorkspaceArg) {
    Resolve-WorkspacePath $WorkspaceArg
} else {
    [System.IO.Path]::GetFullPath((Join-Path (Split-Path -Parent $SkillDir) $NovelName))
}

$OutputDir = Join-Path $WorkspaceDir "output"
$DraftDirName = Join-Chars @(27491, 25991)
$TrackingDirName = Join-Chars @(36861, 36394)
$OutlineDirName = Join-Chars @(22823, 32434)
$BatchOutlineDirName = Join-Chars @(25209, 27425, 32454, 32434)
$SettingsDirName = Join-Chars @(35774, 23450)
$WorldDirName = Join-Chars @(19990, 30028, 35266)
$CharacterDirName = Join-Chars @(35282, 33394)
$PromptFileName = Join-Chars @(25552, 31034, 35789, 46, 109, 100)
$PlotThreadFileName = Join-Chars @(20239, 31508, 46, 109, 100)
$TimelineFileName = Join-Chars @(26102, 38388, 32447, 46, 109, 100)
$OutlineFileName = Join-Chars @(22823, 32434, 46, 109, 100)
$ChapterPlanFileName = Join-Chars @(32454, 32434, 46, 109, 100)
$OutlineIterationFileName = Join-Chars @(32454, 32434, 36845, 20195, 35760, 24405, 46, 109, 100)
$OutlineInterventionFileName = Join-Chars @(32454, 32434, 24178, 39044, 20915, 31574, 46, 109, 100)
$OutlineFreezeFileName = Join-Chars @(32454, 32434, 20923, 32467, 28165, 21333, 46, 109, 100)

$DraftDir = Join-Path $WorkspaceDir $DraftDirName
$LearningsDir = Join-Path $WorkspaceDir ".learnings"
$MemoryDir = Join-Path $WorkspaceDir "memory"
$TrackingDir = Join-Path $WorkspaceDir $TrackingDirName
$OutlineDir = Join-Path $WorkspaceDir $OutlineDirName
$BatchOutlineDir = Join-Path $OutlineDir $BatchOutlineDirName
$SettingsDir = Join-Path $WorkspaceDir $SettingsDirName
$WorldDir = Join-Path $SettingsDir $WorldDirName
$CharacterDir = Join-Path $SettingsDir $CharacterDirName
$SessionFile = Join-Path $WorkspaceDir "SESSION.md"
$NovelNameFile = Join-Path $WorkspaceDir ".novel-name"
$PromptFile = Join-Path $SettingsDir $PromptFileName
$ProjectStatusFile = Join-Path $MemoryDir "project_status.md"

$ExistingNovelName = ""
if (Test-Path -LiteralPath $NovelNameFile) {
    $ExistingNovelName = (Get-Content -LiteralPath $NovelNameFile -TotalCount 1).Trim()
}

if (-not $Clean -and $ExistingNovelName -and $ExistingNovelName -ne $NovelName) {
    Write-Host "[error] Workspace already belongs to '$ExistingNovelName'. Re-run with --clean or choose a different --workspace path." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host "  ximen-aimazi workspace init" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  novel: $NovelName"
Write-Host "  workspace: $WorkspaceDir"
Write-Host "  clean: $Clean"
Write-Host ""

foreach ($Directory in @($WorkspaceDir, $OutputDir, $DraftDir, $LearningsDir, $MemoryDir, $TrackingDir, $OutlineDir, $BatchOutlineDir, $SettingsDir, $WorldDir, $CharacterDir)) {
    if (-not (Test-Path -LiteralPath $Directory)) {
        New-Item -ItemType Directory -Path $Directory -Force | Out-Null
    }
}

if ($Clean) {
    Write-Step "Overwriting scaffold markdown files in tracking, outline, settings, memory, and session areas"
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
    (Join-Path $TrackingDirName "CHAPTERS.md"),
    (Join-Path $TrackingDirName $PlotThreadFileName),
    (Join-Path $TrackingDirName $TimelineFileName),
    (Join-Path $OutlineDirName $OutlineFileName),
    (Join-Path $OutlineDirName $ChapterPlanFileName),
    (Join-Path $OutlineDirName $OutlineIterationFileName),
    (Join-Path $OutlineDirName $OutlineInterventionFileName),
    (Join-Path $OutlineDirName $OutlineFreezeFileName)
)

Write-Step "Syncing project-level templates"
foreach ($TemplateFile in $TemplateFiles) {
    Copy-Template -RelativePath $TemplateFile -Force:$Clean
}

Write-Step "Writing session and prompt entry files"
Write-TemplateFile -TemplateRelativePath "SESSION.md" -DestinationPath $SessionFile -NovelName $NovelName -Force:$Clean
Write-TemplateFile -TemplateRelativePath "memory\project_status.md" -DestinationPath $ProjectStatusFile -NovelName $NovelName -Force:$Clean
Write-TemplateFile -TemplateRelativePath (Join-Path $SettingsDirName $PromptFileName) -DestinationPath $PromptFile -NovelName $NovelName -Force:$Clean
Set-Content -LiteralPath $NovelNameFile -Value $NovelName -Encoding utf8

foreach ($GitkeepDir in @($OutputDir, $DraftDir, $BatchOutlineDir, $WorldDir, $CharacterDir)) {
    $Gitkeep = Join-Path $GitkeepDir ".gitkeep"
    if (-not (Test-Path -LiteralPath $Gitkeep)) {
        Set-Content -LiteralPath $Gitkeep -Value "" -Encoding utf8
    }
}

Write-Host ""
Write-Info "Workspace initialized for '$NovelName'."
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Refine $PromptFile"
Write-Host "  2. Ask the AI for 3 concept options"
Write-Host "  3. Continue with worldbuilding, characters, and project params"
Write-Host "  4. Then move into outline, chapter plan, review, and drafting"
Write-Host ""

if (-not $Clean -and $ExistingNovelName) {
    Write-Warn "Existing project files were kept because --clean was not used."
}
