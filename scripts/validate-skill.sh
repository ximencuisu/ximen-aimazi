#!/usr/bin/env bash
# validate-skill.sh — bash port of validate-skill.ps1
#
# 用途：校验 ximen-aimazi skill 的 frontmatter / 版本号 / 单入口 / agents 元数据 /
#       Markdown 引用断链 / 跨目录一致性。
#
# 用法：
#   scripts/validate-skill.sh [ROOT]
#   ROOT 默认为本脚本所在目录的父目录。
#
# 启用可执行权限（首次运行前执行一次）：
#   chmod +x scripts/validate-skill.sh
#
# 退出码：0 = 通过，1 = 失败。
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ $# -ge 1 ]]; then
    ROOT="$(cd "$1" && pwd)"
fi

declare -a ERRORS=()

add_error() {
    ERRORS+=("$1")
}

get_text() {
    cat "$1"
}

# ---------------------------------------------------------------------------
# Task E1 / 对应 Test-Frontmatter
# ---------------------------------------------------------------------------
test_frontmatter() {
    local skill_path="$ROOT/SKILL.md"
    if [[ ! -f "$skill_path" ]]; then
        add_error "SKILL.md is missing."
        return 0
    fi

    local first_line
    first_line=$(head -n1 "$skill_path")
    if [[ "$first_line" != "---" ]]; then
        add_error "SKILL.md must start with YAML frontmatter."
        return 0
    fi

    local closing
    closing=$(awk 'NR>1 && $0=="---"{print NR; exit}' "$skill_path")
    if [[ -z "$closing" ]]; then
        add_error "SKILL.md frontmatter is not closed."
        return 0
    fi

    local has_name=0 has_desc=0 key line trimmed
    while IFS= read -r line; do
        trimmed="$line"
        trimmed="${trimmed#"${trimmed%%[![:space:]]*}"}"
        trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"
        [[ -z "$trimmed" ]] && continue
        if [[ "$line" =~ ^[[:space:]]*([A-Za-z0-9_-]+)[[:space:]]*: ]]; then
            key="${BASH_REMATCH[1]}"
            case "$key" in
                name) has_name=1 ;;
                description) has_desc=1 ;;
                install_method) ;;  # allowed but not required
                *) add_error "SKILL.md frontmatter has unsupported key: $key" ;;
            esac
        else
            add_error "Invalid frontmatter line: $line"
        fi
    done < <(sed -n "2,$((closing-1))p" "$skill_path")

    [[ $has_name -eq 1 ]] || add_error "SKILL.md frontmatter missing required key: name"
    [[ $has_desc -eq 1 ]] || add_error "SKILL.md frontmatter missing required key: description"
}

# ---------------------------------------------------------------------------
# Task E1 / 对应 Test-VersionPins
# ---------------------------------------------------------------------------
extract_json_version() {
    sed -nE 's/.*"version"[[:space:]]*:[[:space:]]*"([^"]+)".*/\1/p' "$1" 2>/dev/null | head -n1 || true
}

test_version_pins() {
    local expected="2.6.0"
    local meta_path="$ROOT/_meta.json"
    local plugin_path="$ROOT/plugin.json"
    local readme_path="$ROOT/README.md"

    if [[ -f "$meta_path" ]]; then
        local meta_version
        meta_version=$(extract_json_version "$meta_path")
        if [[ "$meta_version" != "$expected" ]]; then
            add_error "_meta.json version is $meta_version, expected $expected."
        fi
    else
        add_error "_meta.json is missing."
    fi

    if [[ -f "$plugin_path" ]]; then
        local plugin_version
        plugin_version=$(extract_json_version "$plugin_path")
        if [[ "$plugin_version" != "$expected" ]]; then
            add_error "plugin.json version is $plugin_version, expected $expected."
        fi
    else
        add_error "plugin.json is missing."
    fi

    if [[ -f "$readme_path" ]]; then
        if ! grep -qF "version-v$expected" "$readme_path"; then
            add_error "README.md badge does not reference v$expected."
        fi
    else
        add_error "README.md is missing."
    fi
}

# ---------------------------------------------------------------------------
# Task E1 / 对应 Test-NoSecondarySkillDoc
# ---------------------------------------------------------------------------
test_no_secondary_skill_doc() {
    local secondary="SKILL.en.md"
    if [[ -f "$ROOT/$secondary" ]]; then
        add_error "Secondary skill doc should not exist; this skill uses a single Chinese entrypoint."
    fi

    local f p
    for f in README.md CHANGELOG.md plugin.json _meta.json; do
        p="$ROOT/$f"
        [[ -f "$p" ]] || continue
        if grep -qF "$secondary" "$p"; then
            add_error "Secondary skill doc reference found in $f."
        fi
    done
}

# ---------------------------------------------------------------------------
# Task E1 / 对应 Test-AgentMetadata
# ---------------------------------------------------------------------------
test_agent_metadata() {
    local meta_path="$ROOT/agents/openai.yaml"
    if [[ ! -f "$meta_path" ]]; then
        add_error "agents/openai.yaml is missing."
        return 0
    fi

    local text
    text=$(cat "$meta_path")
    local required_snippets=("interface:" "display_name:" "short_description:" "default_prompt:" '$ximen-aimazi' "policy:" "allow_implicit_invocation: true")
    local snippet
    for snippet in "${required_snippets[@]}"; do
        if [[ "$text" != *"$snippet"* ]]; then
            add_error "agents/openai.yaml missing required snippet: $snippet"
        fi
    done
}

# ---------------------------------------------------------------------------
# Task E1 / 对应 Resolve-MarkdownReference + Test-MarkdownReferences
# ---------------------------------------------------------------------------
resolve_markdown_reference() {
    local ref="$1"
    local -a candidates=("$ROOT/$ref")
    if [[ ! "$ref" =~ ^(references|assets|memory|scripts|output|\.learnings|正文|大纲|设定|追踪)/ ]]; then
        candidates+=("$ROOT/references/$ref" "$ROOT/assets/$ref" "$ROOT/memory/$ref")
    fi
    local c
    for c in "${candidates[@]}"; do
        if [[ -e "$c" ]]; then
            return 0
        fi
    done
    return 1
}

# Task E2 修复：不再用 [^\x00-\x7F] 一刀切过滤中文路径。
# 改为精细的路径合法性判断——忽略 URL/相对路径/绝对路径/通配符/模板占位符/
# 运行期生成目录/裸真相档案文件名，但保留对中文路径的断链检测。
should_ignore() {
    local ref="$1"
    # ^\{  模板占位符 {var}
    if [[ "$ref" =~ ^\{ ]]; then return 0; fi
    # ^[A-Za-z0-9_-]+:\s+  frontmatter 风格 key: value
    if [[ "$ref" =~ ^[A-Za-z0-9_-]+:[[:space:]]+ ]]; then return 0; fi
    # ^https?:  外链
    if [[ "$ref" =~ ^https?: ]]; then return 0; fi
    # ^\.\./  相对路径
    if [[ "$ref" =~ ^\.\./ ]]; then return 0; fi
    # ^/  绝对路径
    if [[ "$ref" =~ ^/ ]]; then return 0; fi
    # \*  通配符
    if [[ "$ref" == *\** ]]; then return 0; fi
    # \{.*\}  含 { ... } 模板
    if [[ "$ref" =~ \{.*\} ]]; then return 0; fi
    # ^output/  运行期生成目录
    if [[ "$ref" =~ ^output/ ]]; then return 0; fi
    # ^\.learnings/  运行期真相档案目录（运行时写入，模板阶段允许断链）
    if [[ "$ref" =~ ^\.learnings/ ]]; then return 0; fi
    # 中文运行期输出目录（正文/大纲/设定/追踪 — 工作区产出，非 skill 模板）
    if [[ "$ref" =~ ^(正文|大纲|设定|追踪)/ ]]; then return 0; fi
    # 裸真相档案文件名（运行期生成）
    case "$ref" in
        CHARACTERS.md|EMOTIONS.md|ERRORS.md|LOCATIONS.md|PLOT_SUSPENSE.md|RESOURCES.md|STORY_BIBLE.md|SUBPLOTS.md) return 0 ;;
        # 中文运行期裸文件名
        时间线.md|细纲.md|拆文报告.md) return 0 ;;
    esac
    return 1
}

normalize_ref() {
    local s="$1"
    s="${s%%#*}"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    printf '%s' "$s"
}

_list_files() {
    local d="$1" f
    local -a arr=()
    shopt -s nullglob dotglob
    for f in "$d"/*; do
        [[ -f "$f" ]] && arr+=("$(basename "$f")")
    done
    shopt -u nullglob dotglob
    printf '%s\n' "${arr[@]}" | sort
}

test_markdown_references() {
    local -a scan_paths=("$ROOT/SKILL.md" "$ROOT/README.md")
    [[ -d "$ROOT/references" ]] && scan_paths+=("$ROOT/references")
    [[ -d "$ROOT/assets" ]] && scan_paths+=("$ROOT/assets")
    [[ -d "$ROOT/memory" ]] && scan_paths+=("$ROOT/memory")

    local missing_file
    missing_file=$(mktemp)

    local file raw ref
    while IFS= read -r file; do
        [[ -f "$file" ]] || continue
        # backtick refs: `path.md`
        while IFS= read -r raw; do
            [[ -z "$raw" ]] && continue
            ref=$(normalize_ref "$(printf '%s' "$raw" | sed -E 's/^`(.*)`$/\1/')")
            [[ -z "$ref" ]] && continue
            if should_ignore "$ref"; then continue; fi
            if ! resolve_markdown_reference "$ref"; then
                printf '%s\n' "$ref" >> "$missing_file"
            fi
        done < <(grep -hoE '`[^`]+\.md`' "$file" 2>/dev/null)
        # markdown link refs: [text](path.md)
        while IFS= read -r raw; do
            [[ -z "$raw" ]] && continue
            ref=$(normalize_ref "$(printf '%s' "$raw" | sed -E 's/.*\(([^)]+)\)$/\1/')")
            [[ -z "$ref" ]] && continue
            if should_ignore "$ref"; then continue; fi
            if ! resolve_markdown_reference "$ref"; then
                printf '%s\n' "$ref" >> "$missing_file"
            fi
        done < <(grep -hoE '\[[^]]+\]\([^)]+\.md\)' "$file" 2>/dev/null)
    done < <(
        local p
        for p in "${scan_paths[@]}"; do
            if [[ -f "$p" ]]; then
                printf '%s\n' "$p"
            elif [[ -d "$p" ]]; then
                find "$p" -type f -name '*.md'
            fi
        done
    )

    local m
    while IFS= read -r m; do
        [[ -z "$m" ]] && continue
        add_error "Missing markdown reference: $m"
    done < <(sort -u "$missing_file")

    rm -f "$missing_file"
}

# ---------------------------------------------------------------------------
# Task E3 / 对应 Test-WorkspaceConsistency
# ---------------------------------------------------------------------------
compare_file_set() {
    local left_dir="$1" right_dir="$2" left_label="$3" right_label="$4"
    [[ -d "$left_dir" ]] || return 0
    if [[ ! -d "$right_dir" ]]; then
        add_error "$right_label is missing while $left_label exists."
        return 0
    fi

    local left_list right_list left_only right_only
    left_list=$(_list_files "$left_dir")
    right_list=$(_list_files "$right_dir")
    left_only=$(comm -23 <(printf '%s\n' "$left_list") <(printf '%s\n' "$right_list"))
    right_only=$(comm -13 <(printf '%s\n' "$left_list") <(printf '%s\n' "$right_list"))

    local name
    while IFS= read -r name; do
        [[ -z "$name" ]] && continue
        add_error "$left_label/$name has no counterpart in $right_label."
    done <<< "$left_only"
    while IFS= read -r name; do
        [[ -z "$name" ]] && continue
        add_error "$right_label/$name has no counterpart in $left_label."
    done <<< "$right_only"
}

test_workspace_consistency() {
    compare_file_set "$ROOT/memory" "$ROOT/assets/workspace/memory" "memory" "assets/workspace/memory"
    compare_file_set "$ROOT/.learnings" "$ROOT/assets/workspace/.learnings" ".learnings" "assets/workspace/.learnings"

    local outline_path="$ROOT/assets/workspace/大纲/细纲.md"
    if [[ ! -f "$outline_path" ]]; then
        add_error "assets/workspace/大纲/细纲.md is missing."
        return 0
    fi
    if ! grep -qF '冻结检查' "$outline_path"; then
        add_error "assets/workspace/大纲/细纲.md missing '冻结检查' marker (Phase 9 freeze checklist)."
    fi
}

# ---------------------------------------------------------------------------
# 主流程
# ---------------------------------------------------------------------------
test_frontmatter
test_version_pins
test_no_secondary_skill_doc
test_agent_metadata
test_markdown_references
test_workspace_consistency

if (( ${#ERRORS[@]} > 0 )); then
    echo "Skill validation failed:"
    for e in "${ERRORS[@]}"; do
        echo " - $e"
    done
    exit 1
fi

echo "Skill validation passed."
