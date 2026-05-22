#!/usr/bin/env bash
# 字数统计脚本

set -euo pipefail

usage() {
    cat << EOF
用法: $(basename "$0") [--workspace <path>]

统计章节中文字数。
默认统计 ./正文/第*.md，并兼容旧目录 ./output/第*.md。
报告写入 <workspace>/output/字数统计.md。
EOF
}

count_han_chars() {
    perl -CSDA -0ne 'my $count = () = $_ =~ /\p{Han}/g; print $count;' "$1"
}

if ! command -v perl >/dev/null 2>&1; then
    echo "[错误] 未找到 perl，无法统计中文字数。" >&2
    exit 1
fi

WORKSPACE="."

while [[ $# -gt 0 ]]; do
    case "$1" in
        --workspace)
            shift
            if [[ $# -eq 0 ]]; then
                echo "[错误] --workspace 需要一个路径" >&2
                usage
                exit 1
            fi
            WORKSPACE="$1"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            echo "[错误] 未知选项: $1" >&2
            usage
            exit 1
            ;;
        *)
            WORKSPACE="$1"
            shift
            ;;
    esac
done

if [ ! -d "$WORKSPACE" ]; then
    echo "[错误] 工作区不存在: $WORKSPACE" >&2
    exit 1
fi

draft_dir="$WORKSPACE/正文"
legacy_dir="$WORKSPACE/output"
report_dir="$WORKSPACE/output"
report_file="$report_dir/字数统计.md"
detail_file="$(mktemp)"

mkdir -p "$report_dir"

total_chars=0
chapter_count=0

echo "========================================"
echo "  小说字数统计"
echo "========================================"
echo ""
echo "工作区: $WORKSPACE"
echo "主目录: $draft_dir"
echo "兼容目录: $legacy_dir"
echo ""

collect_dir() {
    local label="$1"
    local dir="$2"

    [ -d "$dir" ] || return 0

    for file in "$dir"/第*.md; do
        [ -f "$file" ] || continue

        local filename
        local chars
        filename="$(basename "$file")"
        chars="$(count_han_chars "$file")"

        chapter_count=$((chapter_count + 1))
        total_chars=$((total_chars + chars))

        printf '| %s | `%s` | %s |\n' "$label" "$filename" "$chars" >> "$detail_file"
        echo "[$label] $filename: ${chars} 字"
    done
}

collect_dir "正文" "$draft_dir"
collect_dir "output-legacy" "$legacy_dir"

avg_chars=0
if [ "$chapter_count" -gt 0 ]; then
    avg_chars=$((total_chars / chapter_count))
fi

pct_30=0
pct_50=0
pct_100=0
if [ "$total_chars" -gt 0 ]; then
    pct_30=$((total_chars * 100 / 300000))
    pct_50=$((total_chars * 100 / 500000))
    pct_100=$((total_chars * 100 / 1000000))
fi

{
    echo "# 字数统计"
    echo ""
    echo "> 统计范围：\`正文/第*.md\`；兼容旧目录 \`output/第*.md\`。"
    echo ""
    echo "## 汇总"
    echo ""
    echo "| 指标 | 值 |"
    echo "|------|-----|"
    echo "| 章节数 | $chapter_count |"
    echo "| 总字数 | $total_chars |"
    echo "| 平均每章 | $avg_chars |"
    echo ""
    echo "## 章节详情"
    echo ""
    echo "| 来源 | 章节文件 | 字数 |"
    echo "|------|----------|------|"

    if [ "$chapter_count" -eq 0 ]; then
        echo "| _暂无章节_ | — | 0 |"
    else
        cat "$detail_file"
    fi

    echo ""
    echo "## 进度估算"
    echo ""
    echo "| 目标 | 完成度 |"
    echo "|------|--------|"
    echo "| 30万字 | ${pct_30}% |"
    echo "| 50万字 | ${pct_50}% |"
    echo "| 100万字 | ${pct_100}% |"
} > "$report_file"

rm -f "$detail_file"

echo ""
echo "========================================"
echo "  统计结果"
echo "========================================"
echo "章节数: $chapter_count"
echo "总字数: $total_chars"
echo "平均每章: ${avg_chars} 字"
echo ""
echo "========================================"
echo "  进度估算"
echo "========================================"
echo "30万字目标: ${pct_30}%"
echo "50万字目标: ${pct_50}%"
echo "100万字目标: ${pct_100}%"
echo ""
echo "详细统计已写入 $report_file"
