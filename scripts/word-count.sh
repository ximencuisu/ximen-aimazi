#!/bin/bash
# 字数统计脚本
# 用法: ./word-count.sh [小说名]

chinese_char_count() {
    # 统计中文字符数（忽略标点和空格）
    grep -oP '[\x{4e00}-\x{9fff}]' "$1" 2>/dev/null | wc -l
}

total_chars=0
chapter_count=0

echo "========================================"
echo "  小说字数统计"
echo "========================================"
echo ""

if [ ! -d "output" ]; then
    echo "[错误] 未找到 output/ 目录"
    echo "请在小说项目根目录运行此脚本"
    exit 1
fi

# 统计章节文件
for file in output/第*.md; do
    if [ -f "$file" ]; then
        chapter_count=$((chapter_count + 1))
        filename=$(basename "$file")
        
        # 提取正文（去掉元信息和空行）
        content=$(sed -n '/^---$/,$p' "$file" | grep -v '^>' | grep -v '^---' | tr -d '\n')
        
        # 统计中文字符
        chars=$(echo "$content" | grep -oP '[\x{4e00}-\x{9fff}]' | wc -l)
        total_chars=$((total_chars + chars))
        
        echo "$filename: ${chars} 字"
    fi
done

echo ""
echo "========================================"
echo "  统计结果"
echo "========================================"
echo "章节数: $chapter_count"
echo "总字数: $total_chars"
echo "平均每章: $((total_chars > 0 && chapter_count > 0 ? total_chars / chapter_count : 0)) 字"

if [ $total_chars -gt 0 ]; then
    echo ""
    echo "========================================"
    echo "  进度估算"
    echo "========================================"
    
    target_30=300000
    target_50=500000
    target_100=1000000
    
    pct_30=$((total_chars * 100 / target_30))
    pct_50=$((total_chars * 100 / target_50))
    pct_100=$((total_chars * 100 / target_100))
    
    echo "30万字目标: $pct_30%%"
    echo "50万字目标: $pct_50%%"
    echo "100万字目标: $pct_100%%"
fi

echo ""
echo "详细统计已保存到 output/字数统计.md"
echo "$chapter_count|$total_chars|$(date)" >> output/字数统计.md
