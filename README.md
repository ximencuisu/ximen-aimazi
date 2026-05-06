# ximen-aimazi

中文网文创作 Agent Skill — 从灵感到成稿的结构化创作 + 去 AI 味 + 深度技法。

[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-compatible-blue)](https://agentskills.io)
[![Version](https://img.shields.io/badge/version-v2.0.0-green)](./CHANGELOG.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

## 这是什么

`ximen-aimazi` 是一套可持续推进长篇网络小说项目的写作工作流，不是单次生成提示词模板。

- 一句话方向 → 完整创作方案 → 大纲 → 细纲 → 正文 → 审校 → 评分
- 记忆系统维护角色、伏笔、地点、资源、情感线的一致性
- 跨会话恢复，断点续写不丢上下文
- 内置去 AI 味白描规范 + 三遍法 + 7 维质量评分
- 作家技法参考、卡文救援、编辑部流水线、深度审稿四种增强模式

## 适合什么场景

- **原创网文**：都市、修仙、玄幻、重生、系统流、末世、规则怪谈
- **长篇连载**：50 到 500+ 章的持续创作
- **同人创作**：搜索/粘贴原著设定，再按约束续写
- **人机协作**：AI 推流程，你拍方向和关键取舍

## 核心能力

### 12 步主流程

| Phase | 内容 |
|-------|------|
| 1 | 灵感生成 — 一句话扩展成 3 套可选方案 |
| 2 | 世界观构建 — 力量体系、社会结构、核心规则 |
| 3 | 角色塑造 — 主角 + 配角 + 反派层级 + 三层标签反差 |
| 4 | 创作参数配置 — 章节数 / 女角色数 / 擦边等级 / 文风 |
| 5 | 同人原著资料（如适用）— 搜索或粘贴，建立约束 |
| 6 | 大纲生成 — 三幕式 + 卷级结构 + 关键节点 |
| 7 | 细纲规划 — 批次划分、冻结条件、人工介入点 |
| 8 | 生成细纲 — 当前批次的可执行章节计划 |
| 9 | 逻辑审核与人工介入 — 审核当前批次，给出方案选项 |
| 10 | 正文章节 — 按已冻结细纲写正文 + 去 AI 味规范 |
| 11 | 一致性审核 — 剧情 / 角色 / 设定层面检查 |
| 12 | 润色与评分 — 语言质量层面 + 7 维 10 分制评分 |

### 文风控制

5 种预设文风（A-E）+ 作家技法参考（1 主 1 辅）分层叠加，写入 `memory/project_style.md` 全书生效。

| 文风 | 特点 | 适用题材 |
|------|------|---------|
| A 热血爽文风 | 短句密集、节奏快、打脸干脆 | 玄幻、高武、升级流 |
| B 都市现实风 | 口语化、生活感、细节真实 | 都市、悬疑、规则怪谈 |
| C 古风仙侠风 | 半文半白、意境优先、节奏沉稳 | 仙侠、古言、玄侠 |
| D 悬疑惊悚风 | 氛围压抑、悬念迭起、细节暗示 | 悬疑、规则怪谈、末世 |
| E 轻松日常风 | 吐槽密度高、节奏舒缓、互动有爱 | 种田、御兽、日常 |

### 去 AI 味

- 核心规范：段落不超 4 行 / 动作 + 对话 + 情绪循环 / 短句优先 / Show Don't Tell
- 禁用词表 + 比喻禁令 + 章末禁止总结升华
- 三遍法：去泛化 → 去书面化 → 回人味
- 7 维评分中"去 AI 味"占 7% 权重，独立打分

### 质量评分（7 维 10 分制）

| 维度 | 权重 |
|------|------|
| 爽点设置 | 25% |
| 情节连贯性 | 20% |
| 节奏把控 | 15% |
| 悬念钩子 | 15% |
| 对话质量 | 10% |
| 角色塑造 | 8% |
| 去 AI 味 | 7% |

出稿门槛：日更 ≥ 7.0 / 高潮章 ≥ 8.0 / 卷终章 ≥ 8.2

### 4 种增强模式

| 模式 | 触发条件 | 作用 |
|------|---------|------|
| 作家风格参考 | "像某位作家" | 查阅 `references/author-style-guide.md`，提炼可迁移技法 |
| 半部续写 / 卡文救援 | "卡文了" | 查阅 `references/continuation-engine.md`，诊断 + 3 条路线 |
| AI 编辑部流水线 | "像工作室一样立项" | 查阅 `references/editorial-pipeline.md`，按岗位推进 |
| 深度审稿 | 关键高潮章 / 质量下滑 | 查阅 `references/advanced-audit.md`，排长篇隐患 |

## 快速开始

### 安装

```bash
# 手动安装
git clone https://github.com/ximencuisu/ximen-aimazi.git ~/.openclaw/skills/ximen-aimazi
```

或放入项目的 `skills/` 目录。

### 初始化新小说

```bash
# macOS / Linux
./scripts/init-novel.sh 我的小说名 --clean

# Windows
.\scripts\init-novel.bat 我的小说名 --clean
```

### 开始对话

```text
帮我用 ximen-aimazi 做一部 100 章都市修仙小说。
主角是被家族放弃的炼丹师，前期隐忍，中期崛起，后期反向收编宗门。
先给我 3 套创意方案，再让我选。
```

同人场景：

```text
这是斗罗大陆同人。先整理原著关键设定和人物关系，再给我大纲，不要急着写正文。
```

## 目录结构

```text
ximen-aimazi/
├── SKILL.md                    # 中文主技能文档
├── SKILL.en.md                 # 英文文档
├── README.md
├── CHANGELOG.md
├── LICENSE
├── _meta.json                  # 版本与发布信息
├── MEMORY.md                   # 记忆索引
├── SESSION.md                  # 跨会话恢复文件
├── .claude/
│   ├── CLAUDE.md               # 项目级 AI 指令
│   └── settings.local.json     # Stop hook 等本地配置
├── assets/
│   ├── STYLE-TEMPLATE.md       # 5 种预设文风库
│   ├── EDGE-TEMPLATE.md        # 5 种擦边风格模板
│   ├── CHAPTER-TEMPLATE.md     # 章节模板
│   ├── CHAPTER-TEMPLATE.female.md
│   ├── PROMPT-TEMPLATE.md      # 提示词空白模板
│   ├── LEARNINGS-TEMPLATE.md   # 真相档案模板
│   └── workspace/              # init-novel 使用的项目级模板
├── references/                 # 按需加载的参考资料（26 个文件）
│   ├── anti-ai-writing.md      # 去 AI 味完整指南
│   ├── anti-ai-detection.md    # 去 AI 味检测清单
│   ├── banned-words.md         # 禁用词表
│   ├── quality-check.md        # 7 维 10 分制评分系统
│   ├── quality-checklist.md    # 质量 + 检查清单
│   ├── author-style-guide.md   # 作家技法参考库
│   ├── hook-techniques.md      # 钩子技法大全
│   ├── continuation-engine.md  # 半部续写引擎
│   ├── editorial-pipeline.md   # 编辑部流水线
│   ├── advanced-audit.md       # 深度审稿清单
│   └── ...                     # 更多参考资料
├── memory/                     # 分类记忆
├── .learnings/                 # 小说事实档案（角色/伏笔/地点等）
├── output/                     # 大纲、细纲、章节与索引输出
└── scripts/                    # 初始化与字数统计脚本
```

## v2.0.0 主要变更

- **去 AI 味模块全面重构**：职责分离（detection=识别 / writing=解决），三遍法 + 改写范例库
- **评分体系统一**：从三套互不兼容的评分合并为 7 维 10 分制（`quality-check.md`）
- **文风预设统一**：A-E 五种文风名称与 `STYLE-TEMPLATE.md` 完全对齐
- **Phase 11/12 分工明确**：Phase 11=一致性审核（剧情/角色/设定），Phase 12=语言质量（去 AI 味/润色/评分）
- **内容去重**：SKILL.md 瘦身约 30%，内联内容改为引用 references/ 对应文件
- **作家风格映射表重构**：按文风 A-E 分组，明确分层叠加关系
- **CHARACTERS 写入时机对齐**：从"必写"改为"必检查，有变化则写"
- **17 项冗余/矛盾/边界模糊问题修复**

完整版本记录见 [CHANGELOG.md](./CHANGELOG.md)。

## 使用建议

- 先定题材和卖点，不要一上来就写正文
- 长篇项目保留 `SESSION.md`、`MEMORY.md` 和 `output/CHAPTERS.md`
- 写同人时先补原著资料再生成大纲
- 借大神写法优先选 1 主 + 1 辅，不要混 4 种风格
- 卡文时先跑续写诊断，不要盲目硬写

## 相关文档

| 文档 | 说明 |
|------|------|
| [SKILL.md](./SKILL.md) | 中文技能文档（完整流程与规范） |
| [SKILL.en.md](./SKILL.en.md) | 英文技能文档 |
| [references/author-style-guide.md](./references/author-style-guide.md) | 作家技法参考库 |
| [references/continuation-engine.md](./references/continuation-engine.md) | 续写引擎 |
| [references/editorial-pipeline.md](./references/editorial-pipeline.md) | 编辑部流水线 |
| [references/advanced-audit.md](./references/advanced-audit.md) | 深度审稿 |
| [CHANGELOG.md](./CHANGELOG.md) | 更新日志 |

## 许可证

[MIT](./LICENSE)
