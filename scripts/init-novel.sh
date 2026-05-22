#!/usr/bin/env bash
# 小说初始化脚本
# 为一部新小说创建独立工作区，不直接污染 skill 安装目录。

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATE_DIR="$SKILL_DIR/assets/workspace"

usage() {
    cat << EOF
用法: $(basename "$0") <小说名称> [选项]

为一部新小说初始化独立工作区。

参数:
  小说名称              小说的名称

选项:
  --workspace <path>    目标工作区目录，默认创建在本 skill 目录的同级目录
  --clean               覆盖目标工作区内的项目级脚手架文件
  -h, --help            显示此帮助信息

示例:
  $(basename "$0") 逆天丹帝
  $(basename "$0") 都市之王 --workspace ../novels/都市之王 --clean

EOF
}

log_info() { echo -e "${GREEN}[信息]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[警告]${NC} $1"; }
log_step() { echo -e "${CYAN}[步骤]${NC} $1"; }
log_error() { echo -e "${RED}[错误]${NC} $1" >&2; }

resolve_workspace() {
    local input="$1"
    if [[ "$input" = /* ]] || [[ "$input" =~ ^[A-Za-z]:[\\/].* ]]; then
        printf '%s\n' "$input"
    else
        printf '%s\n' "$(pwd)/$input"
    fi
}

copy_template() {
    local rel_path="$1"
    local src="$TEMPLATE_DIR/$rel_path"
    local dest="$WORKSPACE_DIR/$rel_path"
    local dest_dir

    if [ ! -f "$src" ]; then
        log_error "模板不存在: $src"
        exit 1
    fi

    dest_dir="$(dirname "$dest")"
    mkdir -p "$dest_dir"

    if [ "$CLEAN" = true ] || [ ! -f "$dest" ]; then
        cp "$src" "$dest"
    fi
}

write_template_file() {
    local template_rel="$1"
    local dest="$2"
    local src="$TEMPLATE_DIR/$template_rel"
    local dest_dir

    if [ "$CLEAN" != true ] && [ -f "$dest" ]; then
        return
    fi

    if [ ! -f "$src" ]; then
        log_error "模板不存在: $src"
        exit 1
    fi

    dest_dir="$(dirname "$dest")"
    mkdir -p "$dest_dir"

    sed "s/__NOVEL_NAME__/$NOVEL_NAME/g" "$src" > "$dest"
}

NOVEL_NAME=""
WORKSPACE_ARG=""
CLEAN=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --clean)
            CLEAN=true
            shift
            ;;
        --workspace)
            shift
            if [[ $# -eq 0 ]]; then
                log_error "--workspace 需要一个路径"
                usage
                exit 1
            fi
            WORKSPACE_ARG="$1"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        -*)
            log_error "未知选项: $1"
            usage
            exit 1
            ;;
        *)
            if [ -z "$NOVEL_NAME" ]; then
                NOVEL_NAME="$1"
            else
                log_error "意外参数: $1"
                usage
                exit 1
            fi
            shift
            ;;
    esac
done

if [ -z "$NOVEL_NAME" ]; then
    log_error "请提供小说名称"
    usage
    exit 1
fi

if [ -n "$WORKSPACE_ARG" ]; then
    WORKSPACE_DIR="$(resolve_workspace "$WORKSPACE_ARG")"
else
    WORKSPACE_DIR="$(cd "$(dirname "$SKILL_DIR")" && pwd)/$NOVEL_NAME"
fi
OUTPUT_DIR="$WORKSPACE_DIR/output"
DRAFT_DIR="$WORKSPACE_DIR/正文"
LEARNINGS_DIR="$WORKSPACE_DIR/.learnings"
MEMORY_DIR="$WORKSPACE_DIR/memory"
TRACKING_DIR="$WORKSPACE_DIR/追踪"
OUTLINE_DIR="$WORKSPACE_DIR/大纲"
BATCH_OUTLINE_DIR="$OUTLINE_DIR/批次细纲"
SETTINGS_DIR="$WORKSPACE_DIR/设定"
WORLD_DIR="$SETTINGS_DIR/世界观"
CHARACTER_DIR="$SETTINGS_DIR/角色"
SESSION_FILE="$WORKSPACE_DIR/SESSION.md"
NOVEL_NAME_FILE="$WORKSPACE_DIR/.novel-name"
PROMPT_FILE="$SETTINGS_DIR/提示词.md"
PROJECT_STATUS_FILE="$MEMORY_DIR/project_status.md"

EXISTING_NOVEL_NAME=""
if [ -f "$NOVEL_NAME_FILE" ]; then
    EXISTING_NOVEL_NAME="$(head -n 1 "$NOVEL_NAME_FILE")"
fi

if [ "$CLEAN" != true ] && [ -n "$EXISTING_NOVEL_NAME" ] && [ "$EXISTING_NOVEL_NAME" != "$NOVEL_NAME" ]; then
    log_error "当前工作区已记录小说《$EXISTING_NOVEL_NAME》。如要切换到《$NOVEL_NAME》，请追加 --clean 或换一个 --workspace 路径。"
    exit 1
fi

echo ""
echo -e "${CYAN}=======================================${NC}"
echo -e "${CYAN}  ximen-aimazi workspace init${NC}"
echo -e "${CYAN}=======================================${NC}"
echo ""
echo -e "  小说名称: ${GREEN}《${NOVEL_NAME}》${NC}"
echo -e "  工作区: ${GREEN}${WORKSPACE_DIR}${NC}"
echo -e "  覆盖脚手架: $([ "$CLEAN" = true ] && echo "是" || echo "否")"
echo ""

mkdir -p "$WORKSPACE_DIR" "$OUTPUT_DIR" "$DRAFT_DIR" "$LEARNINGS_DIR" "$MEMORY_DIR" "$TRACKING_DIR" "$OUTLINE_DIR" "$BATCH_OUTLINE_DIR" "$SETTINGS_DIR" "$WORLD_DIR" "$CHARACTER_DIR"

log_step "同步项目级模板"
copy_template ".learnings/CHARACTERS.md"
copy_template ".learnings/LOCATIONS.md"
copy_template ".learnings/PLOT_POINTS.md"
copy_template ".learnings/STORY_BIBLE.md"
copy_template ".learnings/ERRORS.md"
copy_template ".learnings/RESOURCES.md"
copy_template ".learnings/SUBPLOTS.md"
copy_template ".learnings/EMOTIONS.md"
copy_template ".learnings/SUSPENSE.md"
copy_template "memory/project_params.md"
copy_template "memory/project_style.md"
copy_template "追踪/CHAPTERS.md"
copy_template "追踪/伏笔.md"
copy_template "追踪/时间线.md"
copy_template "大纲/大纲.md"
copy_template "大纲/细纲.md"
copy_template "大纲/细纲迭代记录.md"
copy_template "大纲/细纲干预决策.md"
copy_template "大纲/细纲冻结清单.md"

log_step "写入会话与提示词入口"
write_template_file "SESSION.md" "$SESSION_FILE"
write_template_file "memory/project_status.md" "$PROJECT_STATUS_FILE"
write_template_file "设定/提示词.md" "$PROMPT_FILE"
printf '%s\n' "$NOVEL_NAME" > "$NOVEL_NAME_FILE"

for gitkeep_dir in "$OUTPUT_DIR" "$DRAFT_DIR" "$BATCH_OUTLINE_DIR" "$WORLD_DIR" "$CHARACTER_DIR"; do
    if [ ! -f "$gitkeep_dir/.gitkeep" ]; then
        : > "$gitkeep_dir/.gitkeep"
    fi
done

echo ""
log_info "《${NOVEL_NAME}》工作区初始化完成"
echo ""
echo "后续步骤:"
echo "  1. 完善 $PROMPT_FILE"
echo "  2. 让 AI 先生成 3 套创意方案"
echo "  3. 确认方案后进入世界观、角色和创作参数配置"
echo "  4. 再推进大纲、细纲、审核和正文"
echo ""

if [ "$CLEAN" != true ] && [ -n "$EXISTING_NOVEL_NAME" ]; then
    log_warn "未使用 --clean，因此保留了当前项目已有内容，只补齐了缺失的脚手架文件。"
fi
