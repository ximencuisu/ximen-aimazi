#!/usr/bin/env bash
# 伏笔审计脚本

set -euo pipefail

usage() {
    cat << EOF
用法: $(basename "$0") [--workspace <path>] [--current-chapter <int>]

扫描伏笔追踪文件，报告未回收的伏笔条目。
读取: <workspace>/追踪/伏笔.md 和 <workspace>/.learnings/PLOT_SUSPENSE.md
当前章节默认从 <workspace>/追踪/CHAPTERS.md 自动推断，可用 --current-chapter 指定。
退出码: 0 = 无超期/未回收伏笔；1 = 存在问题。
EOF
}

WORKSPACE="."
CURRENT_CHAPTER=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --workspace)
            shift
            [[ $# -eq 0 ]] && { echo "[错误] --workspace 需要一个路径" >&2; usage; exit 2; }
            WORKSPACE="$1"
            shift
            ;;
        --current-chapter)
            shift
            [[ $# -eq 0 ]] && { echo "[错误] --current-chapter 需要一个整数" >&2; usage; exit 2; }
            CURRENT_CHAPTER="$1"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            WORKSPACE="$1"
            shift
            ;;
    esac
done

if [ ! -d "$WORKSPACE" ]; then
    echo "[错误] 工作区不存在: $WORKSPACE" >&2
    exit 2
fi

FORESHADOW_FILE="$WORKSPACE/追踪/伏笔.md"
PLOT_SUSPENSE_FILE="$WORKSPACE/.learnings/PLOT_SUSPENSE.md"
CHAPTERS_FILE="$WORKSPACE/追踪/CHAPTERS.md"

# Resolve current chapter from CHAPTERS.md if not specified.
if [ -z "$CURRENT_CHAPTER" ]; then
    if [ -f "$CHAPTERS_FILE" ]; then
        CURRENT_CHAPTER=$(grep -E '最新章节' "$CHAPTERS_FILE" 2>/dev/null \
            | grep -oE '[0-9]+' | head -1 || true)
        if [ -z "$CURRENT_CHAPTER" ]; then
            CURRENT_CHAPTER=$(grep -oE '第\s*[0-9]+\s*章' "$CHAPTERS_FILE" 2>/dev/null \
                | grep -oE '[0-9]+' | sort -n | tail -1 || true)
        fi
    fi
fi

echo "========================================"
echo "  伏笔审计 (Foreshadow Audit)"
echo "========================================"
echo "工作区: $WORKSPACE"
echo "伏笔文件: $FORESHADOW_FILE"
echo "悬念档案: $PLOT_SUSPENSE_FILE"
echo "章节索引: $CHAPTERS_FILE"
if [ -n "$CURRENT_CHAPTER" ]; then
    echo "当前章节: $CURRENT_CHAPTER"
else
    echo "当前章节: 未知 (用 --current-chapter 指定)"
fi
echo ""

TMP_F=$(mktemp)
TMP_S=$(mktemp)
TMP_ALL=$(mktemp)
TMP_UNRESOLVED=$(mktemp)
TMP_OVERDUE=$(mktemp)
trap 'rm -f "$TMP_F" "$TMP_S" "$TMP_ALL" "$TMP_UNRESOLVED" "$TMP_OVERDUE"' EXIT

# Parse 追踪/伏笔.md "活跃伏笔" table.
# Output TSV: source<TAB>id<TAB>status<TAB>planted_num<TAB>planned_num
parse_foreshadow_file() {
    local file="$1"
    [ -f "$file" ] || return 0
    awk -F'|' '
        /^\s*##\s*活跃伏笔/ { in_active = 1; next }
        /^\s*##\s/ { in_active = 0; next }
        !in_active { next }
        !/^\s*\|/ { next }
        /^\s*\|[\s\-:|]+\|\s*$/ { next }
        {
            if (NF < 7) next
            id = $2; planted = $4; planned = $5; status = $7
            gsub(/^[ \t]+|[ \t]+$/, "", id)
            gsub(/^[ \t]+|[ \t]+$/, "", planted)
            gsub(/^[ \t]+|[ \t]+$/, "", planned)
            gsub(/^[ \t]+|[ \t]+$/, "", status)
            if (id == "" || id ~ /^(ID|伏笔内容|埋设章节)/) next
            planted_num = ""; if (planted ~ /[0-9]+/) { match(planted, /[0-9]+/); planted_num = substr(planted, RSTART, RLENGTH) }
            planned_num = ""; if (planned ~ /[0-9]+/) { match(planned, /[0-9]+/); planned_num = substr(planned, RSTART, RLENGTH) }
            printf "伏笔.md\t%s\t%s\t%s\t%s\n", id, status, planted_num, planned_num
        }
    ' "$file" > "$TMP_F"
}

# Parse .learnings/PLOT_SUSPENSE.md blocks (### [ID] ...).
parse_plot_suspense_file() {
    local file="$1"
    [ -f "$file" ] || return 0
    if ! command -v perl >/dev/null 2>&1; then
        echo "[错误] 未找到 perl，无法解析 PLOT_SUSPENSE.md" >&2
        return 0
    fi
    perl -CSDA -0777 -ne '
        use utf8;
        while (/^###\s+\[([^\]]+)\][^\n]*\r?\n(.*?)(?=^###\s+\[|\z)/gms) {
            my $id = $1;
            my $body = $2;
            my ($planted, $status, $planned) = ("", "", "");
            if ($body =~ /\*\*埋设章节\*\*\s*[:：]\s*([^|\r\n]+)/) { $planted = $1; }
            if ($body =~ /\*\*状态\*\*\s*[:：]\s*([^|\r\n]+)/) { $status = $1; }
            if ($body =~ /\*\*预期回收\*\*\s*[:：]\s*([^\r\n]+)/) { $planned = $1; }
            $status =~ s/^\s+|\s+$//g;
            my $planted_num = ($planted =~ /(\d+)/) ? $1 : "";
            my $planned_num = ($planned =~ /(\d+)/) ? $1 : "";
            print "PLOT_SUSPENSE.md\t$id\t$status\t$planted_num\t$planned_num\n";
        }
    ' "$file" > "$TMP_S"
}

parse_foreshadow_file "$FORESHADOW_FILE"
parse_plot_suspense_file "$PLOT_SUSPENSE_FILE"

count_f=$(wc -l < "$TMP_F" | tr -d ' ')
count_s=$(wc -l < "$TMP_S" | tr -d ' ')

echo "从 伏笔.md 解析:           $count_f 条"
echo "从 PLOT_SUSPENSE.md 解析:   $count_s 条"
echo ""

cat "$TMP_F" "$TMP_S" > "$TMP_ALL"

# Unresolved: status not matching resolved/未埋 patterns.
awk -F'\t' '
    {
        s = $3
        if (s == "") next
        if (s ~ /已回收|已完结|已废弃|已暂缓|已弃|废弃|暂缓|归档/) next
        if (s ~ /未埋|未设/) next
        print
    }
' "$TMP_ALL" > "$TMP_UNRESOLVED"

# Overdue: unresolved + planned chapter exists + current > planned.
if [ -n "$CURRENT_CHAPTER" ]; then
    awk -F'\t' -v cur="$CURRENT_CHAPTER" '
        { if ($5 != "" && cur + 0 > $5 + 0) print }
    ' "$TMP_UNRESOLVED" > "$TMP_OVERDUE"
fi

count_unresolved=$(wc -l < "$TMP_UNRESOLVED" | tr -d ' ')
count_overdue=$(wc -l < "$TMP_OVERDUE" | tr -d ' ')

echo "========================================"
echo "  未回收伏笔 (Unresolved)"
echo "========================================"
if [ "$count_unresolved" -eq 0 ]; then
    echo "  (无)"
else
    while IFS=$'\t' read -r src id status planted planned; do
        echo "  [$src] $id | status=$status | planted=${planted:-?} | planned=${planned:-?}"
    done < "$TMP_UNRESOLVED"
fi
echo ""

echo "========================================"
echo "  超期未回收 (Overdue)"
echo "========================================"
if [ "$count_overdue" -eq 0 ]; then
    echo "  (无)"
else
    while IFS=$'\t' read -r src id status planted planned; do
        echo "  [$src] $id | planned=$planned | current=$CURRENT_CHAPTER | status=$status"
    done < "$TMP_OVERDUE"
fi
echo ""

# Cross-file inconsistency: same ID appearing with different statuses.
echo "========================================"
echo "  跨文件状态不一致 (Inconsistency)"
echo "========================================"
inconsistent_count=0
# Collect unique (id, status) pairs, then find IDs with more than one distinct status.
inconsistent_ids=$(awk -F'\t' '{print $2 "\t" $3}' "$TMP_ALL" \
    | sort -u \
    | awk -F'\t' '{cnt[$1]++; if (st[$1]=="") st[$1]=$2; else if (st[$1]!=$2) diff[$1]=st[$1]" / "$2} END {for (k in diff) print k"\t"diff[k]}')
if [ -z "$inconsistent_ids" ]; then
    echo "  (无)"
else
    echo "$inconsistent_ids" | while IFS=$'\t' read -r id statuses; do
        echo "  $id | statuses: $statuses"
    done
    inconsistent_count=$(echo "$inconsistent_ids" | wc -l | tr -d ' ')
fi
echo ""

# Single-file-only IDs (informational).
echo "========================================"
echo "  单文件独有 ID (Informational)"
echo "========================================"
ids_f=$(awk -F'\t' '{print $2}' "$TMP_F" | sort -u)
ids_s=$(awk -F'\t' '{print $2}' "$TMP_S" | sort -u)
only_f=$(comm -23 <(echo "$ids_f") <(echo "$ids_s"))
only_s=$(comm -13 <(echo "$ids_f") <(echo "$ids_s"))
if [ -z "$only_f" ] && [ -z "$only_s" ]; then
    echo "  (完全匹配)"
else
    [ -n "$only_f" ] && echo "  仅在 伏笔.md:           $(echo "$only_f" | tr '\n' ' ')"
    [ -n "$only_s" ] && echo "  仅在 PLOT_SUSPENSE.md: $(echo "$only_s" | tr '\n' ' ')"
fi
echo ""

# Exit code: 1 if any overdue or unresolved items exist.
if [ "$count_overdue" -gt 0 ] || [ "$count_unresolved" -gt 0 ]; then
    echo "结果: $count_overdue 条超期, $count_unresolved 条未回收 -> exit 1"
    exit 1
fi
echo "结果: 无超期/未回收伏笔 -> exit 0"
exit 0
