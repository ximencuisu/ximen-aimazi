param(
    [string]$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
)

$ErrorActionPreference = 'Stop'

$rootPath = (Resolve-Path -LiteralPath $Root).Path
$errors = New-Object System.Collections.Generic.List[string]

function Add-Error([string]$Message) {
    $script:errors.Add($Message) | Out-Null
}

function Get-Text([string]$Path) {
    return Get-Content -LiteralPath $Path -Raw -Encoding UTF8
}

function Test-Frontmatter {
    $skillPath = Join-Path $rootPath 'SKILL.md'
    if (-not (Test-Path -LiteralPath $skillPath)) {
        Add-Error 'SKILL.md is missing.'
        return
    }

    $text = Get-Text $skillPath
    if (-not $text.StartsWith("---`n") -and -not $text.StartsWith("---`r`n")) {
        Add-Error 'SKILL.md must start with YAML frontmatter.'
        return
    }

    $match = [regex]::Match($text, '(?s)^---\r?\n(.*?)\r?\n---')
    if (-not $match.Success) {
        Add-Error 'SKILL.md frontmatter is not closed.'
        return
    }

    $keys = @()
    foreach ($line in ($match.Groups[1].Value -split "\r?\n")) {
        if ($line.Trim() -eq '') { continue }
        if ($line -notmatch '^\s*([A-Za-z0-9_-]+)\s*:') {
            Add-Error "Invalid frontmatter line: $line"
            continue
        }
        $keys += $Matches[1]
    }

    $required = @('name', 'description')
    $allowed = @('name', 'description', 'install_method')
    foreach ($req in $required) {
        if ($keys -notcontains $req) {
            Add-Error "SKILL.md frontmatter missing required key: $req"
        }
    }
    foreach ($key in $keys) {
        if ($allowed -notcontains $key) {
            Add-Error "SKILL.md frontmatter has unsupported key: $key"
        }
    }
}

function Test-VersionPins {
    $expected = '2.6.0'

    $metaPath = Join-Path $rootPath '_meta.json'
    $pluginPath = Join-Path $rootPath 'plugin.json'
    $readmePath = Join-Path $rootPath 'README.md'

    if (Test-Path -LiteralPath $metaPath) {
        $meta = Get-Content -LiteralPath $metaPath -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($meta.version -ne $expected) {
            Add-Error "_meta.json version is $($meta.version), expected $expected."
        }
    } else {
        Add-Error '_meta.json is missing.'
    }

    if (Test-Path -LiteralPath $pluginPath) {
        $plugin = Get-Content -LiteralPath $pluginPath -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($plugin.version -ne $expected) {
            Add-Error "plugin.json version is $($plugin.version), expected $expected."
        }
    } else {
        Add-Error 'plugin.json is missing.'
    }

    if (Test-Path -LiteralPath $readmePath) {
        $readme = Get-Text $readmePath
        if ($readme -notmatch [regex]::Escape("version-v$expected")) {
            Add-Error "README.md badge does not reference v$expected."
        }
    } else {
        Add-Error 'README.md is missing.'
    }
}

function Test-NoSecondarySkillDoc {
    $secondarySkillName = 'SKILL.' + 'en' + '.md'
    $secondarySkillPath = Join-Path $rootPath $secondarySkillName
    if (Test-Path -LiteralPath $secondarySkillPath) {
        Add-Error 'Secondary skill doc should not exist; this skill uses a single Chinese entrypoint.'
    }

    $scanFiles = @('README.md', 'CHANGELOG.md', 'plugin.json', '_meta.json') |
        ForEach-Object { Join-Path $rootPath $_ } |
        Where-Object { Test-Path -LiteralPath $_ }

    foreach ($file in $scanFiles) {
        $text = Get-Text $file
        if ($text -match [regex]::Escape($secondarySkillName)) {
            Add-Error "Secondary skill doc reference found in $([IO.Path]::GetFileName($file))."
        }
    }
}

function Test-AgentMetadata {
    $metadataPath = Join-Path $rootPath 'agents\openai.yaml'
    if (-not (Test-Path -LiteralPath $metadataPath)) {
        Add-Error 'agents/openai.yaml is missing.'
        return
    }

    $text = Get-Text $metadataPath
    $requiredSnippets = @(
        'interface:',
        'display_name:',
        'short_description:',
        'default_prompt:',
        '$ximen-aimazi',
        'policy:',
        'allow_implicit_invocation: true'
    )

    foreach ($snippet in $requiredSnippets) {
        if (-not $text.Contains($snippet)) {
            Add-Error "agents/openai.yaml missing required snippet: $snippet"
        }
    }
}

function Resolve-MarkdownReference([string]$Reference) {
    $normalized = $Reference -replace '/', [IO.Path]::DirectorySeparatorChar

    $candidates = New-Object System.Collections.Generic.List[string]
    $candidates.Add((Join-Path $rootPath $normalized)) | Out-Null

    # Build known-dir regex with codepoints so source stays ASCII-only (see Test-WorkspaceConsistency note).
    $zhengWen = "$([char]0x6B63)$([char]0x6587)"     # main-text dir (zheng-wen)
    $daGang = "$([char]0x5927)$([char]0x7EB2)"       # outline dir (da-gang)
    $sheDing = "$([char]0x8BBE)$([char]0x5B9A)"      # settings dir (she-ding)
    $zhuiZong = "$([char]0x8FFD)$([char]0x8E2A)"     # tracking dir (zhui-zong)
    $knownDirPattern = '^(references|assets|memory|scripts|output|\.learnings|' + $zhengWen + '|' + $daGang + '|' + $sheDing + '|' + $zhuiZong + ')/'
    if ($Reference -notmatch $knownDirPattern) {
        $candidates.Add((Join-Path (Join-Path $rootPath 'references') $normalized)) | Out-Null
        $candidates.Add((Join-Path (Join-Path $rootPath 'assets') $normalized)) | Out-Null
        $candidates.Add((Join-Path (Join-Path $rootPath 'memory') $normalized)) | Out-Null
    }

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) {
            return $candidate
        }
    }

    return $null
}

function Test-MarkdownReferences {
    $scanRoots = @('SKILL.md', 'README.md', 'references', 'assets', 'memory') |
        ForEach-Object { Join-Path $rootPath $_ } |
        Where-Object { Test-Path -LiteralPath $_ }

    $files = foreach ($item in $scanRoots) {
        if ((Get-Item -LiteralPath $item).PSIsContainer) {
            Get-ChildItem -LiteralPath $item -Recurse -File -Filter '*.md'
        } else {
            Get-Item -LiteralPath $item
        }
    }

    # Build Chinese runtime-output dir/file patterns from codepoints (ASCII-only source).
    $zhengWen = "$([char]0x6B63)$([char]0x6587)"                     # 正文
    $daGang = "$([char]0x5927)$([char]0x7EB2)"                       # 大纲
    $sheDing = "$([char]0x8BBE)$([char]0x5B9A)"                      # 设定
    $zhuiZong = "$([char]0x8FFD)$([char]0x8E2A)"                     # 追踪
    $shiJianXian = "$([char]0x65F6)$([char]0x95F4)$([char]0x7EBF)"  # 时间线
    $xiGang = "$([char]0x7EC6)$([char]0x7EB2)"                       # 细纲
    $chaiWenBaoGao = "$([char]0x62C6)$([char]0x6587)$([char]0x62A5)$([char]0x544A)"  # 拆文报告

    $ignoredPatterns = @(
        '^\{',
        '^[A-Za-z0-9_-]+:\s+',
        '^https?:',
        '^\.\./',
        '^/',
        '\*',
        '\{.*\}',
        '^output/',
        '^\.learnings/',
        ("^$zhengWen/"),
        ("^$daGang/"),
        ("^$sheDing/"),
        ("^$zhuiZong/"),
        '^CHARACTERS\.md$',
        '^EMOTIONS\.md$',
        '^ERRORS\.md$',
        '^LOCATIONS\.md$',
        '^PLOT_SUSPENSE\.md$',
        '^RESOURCES\.md$',
        '^STORY_BIBLE\.md$',
        '^SUBPLOTS\.md$',
        ("^$shiJianXian\.md$"),
        ("^$xiGang\.md$"),
        ("^$chaiWenBaoGao\.md$")
    )

    $missing = New-Object System.Collections.Generic.HashSet[string]
    $referencePattern = @'
`([^`]+\.md)`|\[([^\]]+)\]\(([^)]+\.md)\)
'@

    foreach ($file in $files) {
        $text = Get-Text $file.FullName
        foreach ($match in [regex]::Matches($text, $referencePattern)) {
            $ref = if ($match.Groups[1].Success) { $match.Groups[1].Value } else { $match.Groups[3].Value }
            $ref = ($ref -split '#')[0].Trim()
            if ($ref -eq '') { continue }

            $ignore = $false
            foreach ($pattern in $ignoredPatterns) {
                if ($ref -match $pattern) {
                    $ignore = $true
                    break
                }
            }
            if ($ignore) { continue }

            if (-not (Resolve-MarkdownReference $ref)) {
                $missing.Add($ref) | Out-Null
            }
        }
    }

    foreach ($ref in ($missing | Sort-Object)) {
        Add-Error "Missing markdown reference: $ref"
    }
}

function Compare-FileSet([string]$LeftDir, [string]$RightDir, [string]$LeftLabel, [string]$RightLabel) {
    if (-not (Test-Path -LiteralPath $LeftDir)) { return }
    if (-not (Test-Path -LiteralPath $RightDir)) {
        Add-Error "$RightLabel is missing while $LeftLabel exists."
        return
    }
    $leftNames = @(Get-ChildItem -LiteralPath $LeftDir -File | ForEach-Object { $_.Name })
    $rightNames = @(Get-ChildItem -LiteralPath $RightDir -File | ForEach-Object { $_.Name })
    foreach ($name in ($leftNames | Where-Object { $rightNames -notcontains $_ })) {
        Add-Error "$LeftLabel/$name has no counterpart in $RightLabel."
    }
    foreach ($name in ($rightNames | Where-Object { $leftNames -notcontains $_ })) {
        Add-Error "$RightLabel/$name has no counterpart in $LeftLabel."
    }
}

function Test-WorkspaceConsistency {
    Compare-FileSet (Join-Path $rootPath 'memory') `
                     (Join-Path $rootPath 'assets\workspace\memory') `
                     'memory' 'assets/workspace/memory'
    Compare-FileSet (Join-Path $rootPath '.learnings') `
                     (Join-Path $rootPath 'assets\workspace\.learnings') `
                     '.learnings' 'assets/workspace/.learnings'

    # Build Chinese path/marker from codepoints so this script source stays ASCII-only.
    # (Windows PowerShell 5.1 reads no-BOM .ps1 as system ANSI codepage, which would
    # mojibake literal Chinese and break parsing. See Task E3 note.)
    $daGang = "$([char]0x5927)$([char]0x7EB2)"           # outline dir (da-gang)
    $xiGang = "$([char]0x7EC6)$([char]0x7EB2)"           # outline detail file (xi-gang)
    $marker = "$([char]0x51BB)$([char]0x7ED3)$([char]0x68C0)$([char]0x67E5)"  # freeze-check marker

    $outlinePath = Join-Path $rootPath "assets\workspace\$daGang\$xiGang.md"
    if (-not (Test-Path -LiteralPath $outlinePath)) {
        Add-Error "assets/workspace/$daGang/$xiGang.md is missing."
        return
    }
    $outlineText = Get-Text $outlinePath
    if (-not $outlineText.Contains($marker)) {
        Add-Error "assets/workspace/$daGang/$xiGang.md missing '$marker' marker (Phase 9 freeze checklist)."
    }
}

Test-Frontmatter
Test-VersionPins
Test-NoSecondarySkillDoc
Test-AgentMetadata
Test-MarkdownReferences
Test-WorkspaceConsistency

if ($errors.Count -gt 0) {
    Write-Host "Skill validation failed:" -ForegroundColor Red
    foreach ($errorMessage in $errors) {
        Write-Host " - $errorMessage" -ForegroundColor Red
    }
    exit 1
}

Write-Host "Skill validation passed." -ForegroundColor Green
