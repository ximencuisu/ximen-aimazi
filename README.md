# ximen-aimazi

**小说创作助手** — 一个 [Agent Skill](https://agentskills.io)，支持从灵感到正文的十步创作流程，自动生成章节制爽文小说。去AI味整合Wikipedia AI写作识别标准与绝对零度写作原则。

[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-compatible-blue)](https://agentskills.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 功能特性

- **十步创作流程** — 灵感→世界观→人物→大纲→细纲→审核→正文→审核→润色→评分
- **细纲生成** — 生成每章详细细纲，确保逻辑连贯
- **逻辑审核** — 检查细纲中的时间/空间/人物/设定/伏笔矛盾
- **智能提示词生成** — 用户只需一句话方向，自动补全完整创作提示词
- **分章节生成** — 逐章创作，每章 2500-3000 字，章章有爽点
- **记忆系统** — `.learnings/` 记录角色、地点、情节，确保前后一致
- **质量评分** — 9维度量化评分（S/A/B/C/D等级）
- **去AI味指南** — 消除AI痕迹，语言自然流畅

## 十步创作流程

```
1. 灵感生成    → 确定方向，生成3套创意方案
2. 世界观构建  → 力量体系、势力分布、社会规则
3. 人物塑造    → 主角人设、配角阵容
4. 大纲生成    → 三幕式结构、关键节点规划
5. 细纲规划    → 规划全本细纲的生成策略
6. 生成细纲    → 逐章生成详细细纲
7. 逻辑审核    → 检查细纲中的逻辑矛盾
8. 正文章节    → 按审核通过的细纲写正文
9. 润色优化    → 去AI味、语言精炼
10. 质量评分   → 9维度评分，不合格则重写
```

## 快速开始

### 安装

**通过 ClawdHub（推荐）：**

```bash
clawdhub install ximen-aimazi
```

**手动安装：**

```bash
git clone https://github.com/ximencuisu/ximen-aimazi.git ~/.openclaw/skills/ximen-aimazi
```

**Cursor / Claude Code：**

将 `ximen-aimazi/` 目录放入项目根目录的 `skills/` 文件夹中即可。

### 使用

1. 告诉 AI 你想写什么类型的小说：

   > "帮我写一个废柴少年获得炼丹系统后逆袭的修仙爽文"

2. AI 自动完善提示词，生成大纲，请你确认

3. 确认后逐章生成，每章输出为独立 md 文件

4. 角色、地点、情节自动记录，确保故事连贯

### 初始化新小说

```bash
./scripts/init-novel.sh 我的小说名 --clean
```

## 目录结构

```
ximen-aimazi/
├── SKILL.md                    # 主文件：完整工作流和创作规范
├── assets/
│   ├── PROMPT-TEMPLATE.md      # 提示词生成模板
│   ├── CHAPTER-TEMPLATE.md     # 章节生成模板
│   └── LEARNINGS-TEMPLATE.md   # 记忆文件模板
├── .learnings/
│   ├── CHARACTERS.md           # 角色档案
│   ├── LOCATIONS.md            # 地点档案
│   ├── PLOT_POINTS.md          # 关键情节档案
│   ├── STORY_BIBLE.md          # 世界观设定
│   └── ERRORS.md               # 生成错误日志
├── references/
│   ├── quality-check.md        # 质量评分系统
│   ├── anti-ai-detection.md    # 去AI味指南
│   ├── prompt-guide.md         # 提示词完善指南
│   ├── plot-structures.md      # 爽文情节结构参考
│   └── examples.md             # 完整示例集
├── scripts/
│   └── init-novel.sh           # 初始化脚本
└── output/                     # 生成的章节输出目录
```

## 工作流

```
用户方向 → 灵感生成 → 世界观构建 → 人物塑造 → 大纲生成
                                                          ↓
输出章节 ← 质量检查 ← 润色优化 ← 一致性审核 ← 正文章节
              ↑                              ↓
         记忆系统 ←←←←←←←←←←←←←←←←←←←←←
```

## 记忆系统

每次生成新章节前，AI 代理会自动读取记忆文件：

| 文件 | 作用 |
|------|------|
| `CHARACTERS.md` | 防止角色穿帮（已死复活、等级倒退） |
| `LOCATIONS.md` | 保持空间描写一致 |
| `PLOT_POINTS.md` | 管理伏笔的埋设与回收 |
| `STORY_BIBLE.md` | 守护世界观设定不自相矛盾 |
| `ERRORS.md` | 记录问题，避免重蹈覆辙 |

## 支持的题材

| 题材 | 典型元素 |
|------|---------|
| 都市 | 重生/系统/赘婿/装逼打脸 |
| 修仙 | 废柴逆袭/炼丹/宗门/越级挑战 |
| 玄幻 | 血脉觉醒/远古传承/神器 |
| 科幻 | 星际/机甲/基因改造 |
| 末世 | 丧尸/变异/生存/随身空间 |
| 游戏 | 网游/全息/副本/排行榜 |

## 兼容性

本技能遵循 [Agent Skills 规范](https://agentskills.io/specification)，兼容以下工具：

- Claude Code
- Cursor
- OpenAI Codex
- GitHub Copilot
- OpenClaw
- 其他支持 Agent Skills 的工具

## 灵感来源

记忆系统设计参考了 [self-improving-agent](https://github.com/peterskoett/self-improving-agent) 的 `.learnings/` 模式。

## 许可证

[MIT](LICENSE)
