#!/usr/bin/env bash
# 铺垫链三阶校验脚本
# 扫描批次细纲文件，识别新概念首次登场，检查三阶铺垫链完整性。

set -euo pipefail

usage() {
    cat << EOF
用法: $(basename "$0") [--workspace <path>] [--batch-file <path>]

扫描批次细纲文件，校验新概念的三阶铺垫链完整性。
三阶：①微伏笔 ②逻辑桥梁 ③体感落地（顺序不可乱，全程 ≤3 章）。

参数:
  --workspace <path>    小说工作区路径（默认当前目录）
  --batch-file <path>   批次细纲文件路径（默认扫描 <workspace>/大纲/批次细纲/ 下最新文件）

退出码: 0 = 全部完整；1 = 存在缺失/违规；2 = 用法错误。
EOF
}

WORKSPACE="."
BATCH_FILE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --workspace)
            shift
            [[ $# -eq 0 ]] && { echo "[错误] --workspace 需要一个路径" >&2; usage; exit 2; }
            WORKSPACE="$1"
            shift
            ;;
        --batch-file)
            shift
            [[ $# -eq 0 ]] && { echo "[错误] --batch-file 需要一个路径" >&2; usage; exit 2; }
            BATCH_FILE="$1"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "[错误] 未知选项: $1" >&2
            usage
            exit 2
            ;;
    esac
done

if [ ! -d "$WORKSPACE" ]; then
    echo "[错误] 工作区不存在: $WORKSPACE" >&2
    exit 2
fi

# Resolve batch file.
BATCH_DIR="$WORKSPACE/大纲/批次细纲"
if [ -z "$BATCH_FILE" ]; then
    if [ ! -d "$BATCH_DIR" ]; then
        echo "[错误] 批次细纲目录不存在: $BATCH_DIR" >&2
        echo "       请用 --batch-file 指定批次细纲文件路径。" >&2
        exit 2
    fi
    BATCH_FILE=$(ls -t "$BATCH_DIR"/*.md 2>/dev/null | head -1 || true)
    if [ -z "$BATCH_FILE" ]; then
        echo "[错误] $BATCH_DIR 下无 .md 文件" >&2
        exit 2
    fi
fi

if [ ! -f "$BATCH_FILE" ]; then
    echo "[错误] 批次细纲文件不存在: $BATCH_FILE" >&2
    exit 2
fi

echo "========================================"
echo "  铺垫链三阶校验 (Pave Chain Check)"
echo "========================================"
echo "工作区:   $WORKSPACE"
echo "批次文件: $BATCH_FILE"
echo ""

if ! command -v perl >/dev/null 2>&1; then
    echo "[错误] 未找到 perl，无法解析批次细纲。" >&2
    exit 2
fi

# Parse the batch file and extract concept/stage annotations.
# Output TSV: type<TAB>chapter_num<TAB>concept_name<TAB>stage
TMP_RAW=$(mktemp)
TMP_CONCEPTS=$(mktemp)
TMP_STAGES=$(mktemp)
trap 'rm -f "$TMP_RAW" "$TMP_CONCEPTS" "$TMP_STAGES"' EXIT

perl -CSDA -0777 -ne '
    use utf8;
    binmode(STDOUT, ":utf8");
    my $cur_chapter = 0;
    my $last_concept = "";
    for my $line (split /\r?\n/) {
        if ($line =~ /第\s*(\d+)\s*章/) {
            $cur_chapter = $1;
        }
        next unless $cur_chapter > 0;

        # Helper: extract concept name from brackets on this line.
        # Matches [concept] or 【concept】.
        my $concept = "";
        if ($line =~ /[\x{3010}\x{5B}]([^\x{3011}\x{5D}]+)[\x{3011}\x{5D}]/) {
            $concept = $1;
            $concept =~ s/^\s+|\s+$//g;
        }

        # Detect pave-chain annotation: line contains 铺垫链.
        if ($line =~ /铺垫链/) {
            if ($concept ne "") {
                $last_concept = $concept;
                if ($line =~ /铺垫链完成/) {
                    print "concept\t$cur_chapter\t$concept\t完成记录\n";
                } else {
                    print "concept\t$cur_chapter\t$concept\t标注\n";
                }
            }
            # Extract stages from completion record: 微伏笔(L##) → 逻辑桥梁(L##) → 体感落地(L##).
            while ($line =~ /微伏笔\s*[\x{FF08}(]L?(\d+)[\x{FF09})]/g) {
                print "stage\t$1\t$concept\t微伏笔\n";
            }
            while ($line =~ /逻辑桥梁\s*[\x{FF08}(]L?(\d+)[\x{FF09})]/g) {
                print "stage\t$1\t$concept\t逻辑桥梁\n";
            }
            while ($line =~ /体感落地\s*[\x{FF08}(]L?(\d+)[\x{FF09})]/g) {
                print "stage\t$1\t$concept\t体感落地\n";
            }
        }

        # Detect individual stage lines.
        # Only match lines that look like annotations (bullet points or containing 阶).
        # Use last_concept if no bracket concept found on this line.
        my $effective_concept = $concept ne "" ? $concept : $last_concept;
        if ($line =~ /^\s*[-*]\s/ || $line =~ /阶/) {
            if ($line =~ /微伏笔/) {
                print "stage\t$cur_chapter\t$effective_concept\t微伏笔\n";
            }
            if ($line =~ /逻辑桥梁/) {
                print "stage\t$cur_chapter\t$effective_concept\t逻辑桥梁\n";
            }
            if ($line =~ /体感落地/) {
                print "stage\t$cur_chapter\t$effective_concept\t体感落地\n";
            }
        }

        # Detect new concept markers.
        if ($line =~ /新概念|首次登场/) {
            if ($concept ne "") {
                $last_concept = $concept;
                print "concept\t$cur_chapter\t$concept\t新概念标注\n";
            }
        }
    }
' "$BATCH_FILE" > "$TMP_RAW"

# Collect unique concepts and their stages.
awk -F'\t' '$1 == "concept" && $3 != "" { print $3 }' "$TMP_RAW" | sort -u > "$TMP_CONCEPTS"
awk -F'\t' '
    $1 == "stage" && $3 != "" { print $3 "\t" $4 "\t" $2 }
    $1 == "stage" && $3 == "" { print "UNKNOWN\t" $4 "\t" $2 }
' "$TMP_RAW" | sort -u > "$TMP_STAGES"

concept_count=$(wc -l < "$TMP_CONCEPTS" | tr -d ' ')

echo "========================================"
echo "  新概念清单 (Concepts Found)"
echo "========================================"
if [ "$concept_count" -eq 0 ] || [ "$(cat "$TMP_CONCEPTS")" = "" ]; then
    echo "  (本批次未发现新概念标注)"
    echo ""
    echo "结果: 无新概念 -> exit 0"
    exit 0
else
    while IFS= read -r concept; do
        [ -z "$concept" ] && continue
        first_chap=$(awk -F'\t' -v c="$concept" '$1 == "concept" && $3 == c { print $2; exit }' "$TMP_RAW")
        echo "  [第${first_chap}章] $concept"
    done < "$TMP_CONCEPTS"
fi
echo ""

echo "========================================"
echo "  三阶完整性报告 (Three-Stage Completeness)"
echo "========================================"

issues=0
violations=""

while IFS= read -r concept; do
    [ -z "$concept" ] && continue
    first_chap=$(awk -F'\t' -v c="$concept" '$1 == "concept" && $3 == c { print $2; exit }' "$TMP_RAW")

    micro_chap=$(awk -F'\t' -v c="$concept" '$1 == c && $2 == "微伏笔" { print $3; exit }' "$TMP_STAGES")
    logic_chap=$(awk -F'\t' -v c="$concept" '$1 == c && $2 == "逻辑桥梁" { print $3; exit }' "$TMP_STAGES")
    somatic_chap=$(awk -F'\t' -v c="$concept" '$1 == c && $2 == "体感落地" { print $3; exit }' "$TMP_STAGES")

    echo "  $concept (首次登场: 第${first_chap}章):"

    has_micro="no"; has_logic="no"; has_somatic="no"
    if [ -n "$micro_chap" ]; then echo "    ✓ 微伏笔 (L${micro_chap})"; has_micro="yes"; else echo "    ✗ 微伏笔 (缺失)"; fi
    if [ -n "$logic_chap" ]; then echo "    ✓ 逻辑桥梁 (L${logic_chap})"; has_logic="yes"; else echo "    ✗ 逻辑桥梁 (缺失)"; fi
    if [ -n "$somatic_chap" ]; then echo "    ✓ 体感落地 (L${somatic_chap})"; has_somatic="yes"; else echo "    ✗ 体感落地 (缺失)"; fi

    # Check spacing.
    if [ -n "$micro_chap" ] && [ -n "$somatic_chap" ]; then
        span=$((somatic_chap - micro_chap))
        if [ "$span" -gt 3 ]; then
            echo "    ✗ 间距: ${span}章 (>3章，超期)"
            violations="${violations}  $concept: 间距 ${span}章超期（微伏笔 L${micro_chap} → 体感落地 L${somatic_chap}）\n"
            issues=$((issues + 1))
        else
            echo "    ✓ 间距: ${span}章 (≤3章)"
        fi
    fi

    # Check order.
    if [ -n "$micro_chap" ] && [ -n "$logic_chap" ] && [ -n "$somatic_chap" ]; then
        if [ "$micro_chap" -gt "$logic_chap" ] || [ "$logic_chap" -gt "$somatic_chap" ]; then
            violations="${violations}  $concept: 三阶乱序（微伏笔 L${micro_chap} → 逻辑桥梁 L${logic_chap} → 体感落地 L${somatic_chap}）\n"
            issues=$((issues + 1))
            echo "    ✗ 三阶乱序"
        fi
    fi

    # Check missing stages.
    missing=""
    [ "$has_micro" = "no" ] && missing="${missing}微伏笔、"
    [ "$has_logic" = "no" ] && missing="${missing}逻辑桥梁、"
    [ "$has_somatic" = "no" ] && missing="${missing}体感落地、"
    if [ -n "$missing" ]; then
        missing="${missing%、}"
        violations="${violations}  $concept: 缺失 ${missing}\n"
        issues=$((issues + 1))
    fi

    echo ""
done < "$TMP_CONCEPTS"

echo "========================================"
echo "  违规模式 (Violations)"
echo "========================================"
if [ -z "$violations" ]; then
    echo "  (无违规)"
else
    printf "%b" "$violations"
fi
echo ""

if [ "$issues" -gt 0 ]; then
    echo "结果: $concept_count 个概念, $issues 个问题 -> exit 1"
    exit 1
fi
echo "结果: $concept_count 个概念, 全部三阶完整 -> exit 0"
exit 0
