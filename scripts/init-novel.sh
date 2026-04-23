#!/bin/bash
# 小说初始化脚本
# 为一部新小说创建工作区：初始化 output 目录、项目级记忆文件和会话入口
# 用法: ./init-novel.sh <小说名称> [--clean]

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATE_DIR="$SKILL_DIR/assets/workspace"
OUTPUT_DIR="$SKILL_DIR/output"
LEARNINGS_DIR="$SKILL_DIR/.learnings"
MEMORY_DIR="$SKILL_DIR/memory"
SESSION_FILE="$SKILL_DIR/SESSION.md"
NOVEL_NAME_FILE="$SKILL_DIR/.novel-name"
PROMPT_FILE="$OUTPUT_DIR/提示词.md"
PROJECT_STATUS_FILE="$MEMORY_DIR/project_status.md"

usage() {
    cat << EOF
用法: $(basename "$0") <小说名称> [选项]

为一部新小说初始化工作区。

参数:
  小说名称     小说的名称

选项:
  --clean      清除当前项目级文件并重新初始化
  -h, --help   显示此帮助信息

示例:
  $(basename "$0") 逆天丹帝
  $(basename "$0") 都市之王 --clean

EOF
}

log_info() { echo -e "${GREEN}[信息]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[警告]${NC} $1"; }
log_step() { echo -e "${CYAN}[步骤]${NC} $1"; }
log_error() { echo -e "${RED}[错误]${NC} $1" >&2; }

copy_template() {
    local rel_path="$1"
    local src="$TEMPLATE_DIR/$rel_path"
    local dest="$SKILL_DIR/$rel_path"
    local dest_dir

    dest_dir="$(dirname "$dest")"
    mkdir -p "$dest_dir"

    if [ "$CLEAN" = true ] || [ ! -f "$dest" ]; then
        cp "$src" "$dest"
    fi
}

write_session_file() {
    if [ "$CLEAN" != true ] && [ -f "$SESSION_FILE" ]; then
        return
    fi

    cat > "$SESSION_FILE" << EOF
# 会话恢复

> 此文件用于跨 session 恢复。每次会话结束时更新此文件。
> 下次打开 Claude 时，读取此文件即可知道从哪里继续。

## 当前状态

- **小说名称**: $NOVEL_NAME
- **题材**: —
- **创作流程阶段**: 未开始（1灵感 → 2世界观 → 3角色 → 4参数 → 5同人资料(如适用) → 6大纲 → 7细纲规划（分批） → 8生成细纲（当前批次） → 9逻辑审核 / 人工介入 / 冻结 → 10正文 → 11一致性审核 → 12润色与评分）
- **已生成章节**: 0
- **当前章节**: —
- **下一步操作**: 完善 output/提示词.md，并让 AI 先给出 3 套创意方案

## 文风/擦边激活状态

- **文风**: 未选择
- **擦边等级**: 未设置
- **擦边风格**: 未选择

## 待办清单

- [ ] 完善 output/提示词.md
- [ ] 执行灵感生成（3套方案）
- [ ] 用户选择方案
- [ ] 构建世界观
- [ ] 角色设定
- [ ] 交互式参数配置
- [ ] 建立文风圣经（memory/project_style.md）
- [ ] 同人资料整理（如适用）
- [ ] 生成大纲
- [ ] 细纲规划（分批）
- [ ] 生成当前批次细纲
- [ ] 审核当前批次
- [ ] 人工介入决策
- [ ] 冻结当前批次
- [ ] 生成正文
- [ ] 一致性审核
- [ ] 润色与评分

## 最近更新

| 时间 | 操作 | 结果 | 变更文件 |
|------|------|------|---------|
| 初始化 | 创建新项目工作区 | 完成 | SESSION.md, output/提示词.md, output/CHAPTERS.md, output/细纲迭代记录.md, output/细纲干预决策.md, output/细纲冻结清单.md |
EOF
}

write_project_status_file() {
    if [ "$CLEAN" != true ] && [ -f "$PROJECT_STATUS_FILE" ]; then
        return
    fi

    cat > "$PROJECT_STATUS_FILE" << EOF
---
name: project_status
description: 当前项目的创作进度状态，记录进行到哪一步
type: project
---

# 项目状态

记录当前/最近的创作项目进度，避免重新开始或迷失流程。

---

## 当前项目

- **项目名称**：$NOVEL_NAME
- **当前步骤**：未开始（灵感）
- **已完成章节**：0
- **最后操作**：初始化工作区
- **下一步**：完善 output/提示词.md，并生成 3 套创意方案

## 历史项目

_（暂无记录）_

| 项目名 | 题材 | 总章节 | 完成章节 | 状态 | 最后日期 |
|--------|------|--------|---------|------|----------|

## 待办事项

- [ ] 完善 output/提示词.md
- [ ] 生成 3 套创意方案
- [ ] 继续世界观与角色设计

---
EOF
}

write_prompt_file() {
    if [ "$CLEAN" != true ] && [ -f "$PROMPT_FILE" ]; then
        return
    fi

    cat > "$PROMPT_FILE" << EOF
# 《$NOVEL_NAME》创作提示词

> 本文件由初始化脚本生成，建议先补充创作方向，再交给 AI 生成 3 套创意方案。

## 小说名称

$NOVEL_NAME

## 创作方向

（待填写：例如 都市修仙爽文，废柴逆袭）

## 核心信息草稿

- 题材：
- 主角初始困境：
- 金手指/核心外挂：
- 主要爽点：
- 目标读者：

## 使用建议

- 先确认题材、主角困境和核心爽点。
- 再进入世界观、角色和创作参数配置。
- 最后让 AI 先生成 3 套创意方案供选择。
EOF
}

NOVEL_NAME=""
CLEAN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --clean) CLEAN=true; shift ;;
        -h|--help) usage; exit 0 ;;
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

EXISTING_NOVEL_NAME=""
if [ -f "$NOVEL_NAME_FILE" ]; then
    EXISTING_NOVEL_NAME="$(head -n 1 "$NOVEL_NAME_FILE")"
fi

if [ "$CLEAN" != true ] && [ -n "$EXISTING_NOVEL_NAME" ] && [ "$EXISTING_NOVEL_NAME" != "$NOVEL_NAME" ]; then
    log_error "当前工作区已记录小说《$EXISTING_NOVEL_NAME》。如要切换到《$NOVEL_NAME》，请追加 --clean 重新初始化。"
    exit 1
fi

echo ""
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo -e "${CYAN}  ximen-aimazi - 初始化工作区${NC}"
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo ""
echo -e "  小说名称: ${GREEN}《${NOVEL_NAME}》${NC}"
echo -e "  清除旧数据: $([ "$CLEAN" = true ] && echo "是" || echo "否")"
echo ""

mkdir -p "$OUTPUT_DIR" "$LEARNINGS_DIR" "$MEMORY_DIR"

if [ "$CLEAN" = true ]; then
    log_step "清除旧的输出文件"
    find "$OUTPUT_DIR" -maxdepth 1 -type f -name '*.md' -delete 2>/dev/null || true
fi

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
copy_template "output/CHAPTERS.md"
copy_template "output/细纲迭代记录.md"
copy_template "output/细纲干预决策.md"
copy_template "output/细纲冻结清单.md"

log_step "写入会话与提示词入口"
write_session_file
write_project_status_file
write_prompt_file
printf '%s\n' "$NOVEL_NAME" > "$NOVEL_NAME_FILE"
touch "$OUTPUT_DIR/.gitkeep"

echo ""
log_info "《${NOVEL_NAME}》工作区初始化完成"
echo ""
echo "后续步骤:"
echo "  1. 完善 output/提示词.md"
echo "  2. 让 AI 先生成 3 套创意方案"
echo "  3. 确认方案后进入世界观、角色和创作参数配置"
echo "  4. 再推进大纲、细纲、审核和正文"
echo ""

if [ "$CLEAN" != true ] && [ -n "$EXISTING_NOVEL_NAME" ]; then
    log_warn "未使用 --clean，因此保留了当前项目已有内容，只补齐了缺失的脚手架文件。"
fi
