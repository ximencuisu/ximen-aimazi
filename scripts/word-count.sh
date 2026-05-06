#!/bin/bash
# 字数统计脚本
# 用法: ./word-count.sh

set -euo pipefail

count_han_chars() {
    perl -CSDA -0ne 'my $count = () = $_ =~ /\p{Han}/g; print $count;' "$1"
}

if ! command -v perl >/dev/null 2>&1; then
    echo "[错误] 未找到 perl，无法统计中文字数。" >&2
    exit 1
fi

if [ ! -d "output" ]; then
    echo "[错误] 未找到 output/ 目录"
    echo "请在小说项目根目录运行此脚本"
    exit 1
fi

report_file="output/字数统计.md"
detail_file="$(mktemp)"

total_chars=0
chapter_count=0

echo "========================================"
echo "  小说字数统计"
echo "========================================"
echo ""

for file in output/第*.md; do
    [ -f "$file" ] || continue

    filename="$(basename "$file")"
    chars="$(count_han_chars "$file")"

    chapter_count=$((chapter_count + 1))
    total_chars=$((total_chars + chars))

    printf '| `%s` | %s |\n' "$filename" "$chars" >> "$detail_file"
    echo "$filename: ${chars} 字"
done

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
    echo "> 统计范围：\`output/\` 目录下所有 \`第*.md\` 章节文件。"
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
    echo "| 章节文件 | 字数 |"
    echo "|----------|------|"

    if [ "$chapter_count" -eq 0 ]; then
        echo "| _暂无章节_ | 0 |"
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
