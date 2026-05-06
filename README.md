# ximen-aimazi

中文网文创作 Agent Skill — 从灵感到成稿的结构化创作 + 去 AI 味 + 深度技法。

[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-compatible-blue)](https://agentskills.io)
[![Version](https://img.shields.io/badge/version-v2.1.0-green)](./CHANGELOG.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

## 这是什么

`ximen-aimazi` 是一套可持续推进长篇网络小说项目的写作工作流，不是单次生成提示词模板。

- 一句话方向 → 完整创作方案 → 大纲 → 细纲 → 正文 → 审校 → 评分
- 记忆系统维护角色、伏笔、地点、资源、情感线的一致性
- 跨会话恢复，断点续写不丢上下文
- 内置去 AI 味 6 门禁 + 三遍法 + 7 维质量评分
- 作家技法参考、卡文救援、编辑部流水线、深度审稿四种增强模式
- **v2.1.0 新增**：女频专项模块、平台适配指南、按需加载参考文件

## 适合什么场景

- **男频网文**：都市、修仙、玄幻、重生、系统流、末世、规则怪谈
- **女频网文**：甜宠、虐恋、宫斗宅斗、种田经商、重生、快穿穿书
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
| A 热血燃向 | 短句密集、节奏快、情绪高亢 | 玄幻、高武、升级流 |
| B 冷峻硬核 | 白描为主、克制内敛、细节精准 | 悬疑、规则怪谈、末世 |
| C 轻松日常 | 口语化、生活感、节奏舒缓 | 都市、种田、御兽 |
| D 古韵仙侠 | 半文半白、意境优先、节奏沉稳 | 仙侠、古言、玄侠 |
| E 幽默反套路 | 反差感、吐槽密度高、节奏跳跃 | 搞笑修仙、法治修仙、脑洞文 |

### 去 AI 味

- 6 门禁：禁用词替换 → 句式去套路 → 心理描写外化 → 节奏打碎 → 对话去腔调 → 结尾去升华
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
git clone https://github.com/ximencuisu/ximen-aimazi.git
```

放入项目的 `skills/` 目录，或按你的 Agent 平台要求放置。

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

女频场景：

```text
帮我写一部 80 章甜宠文，替嫁新娘+冷面霸总，要宠妻护短打脸绿茶。
```

同人场景：

```text
这是斗罗大陆同人。先整理原著关键设定和人物关系，再给我大纲，不要急着写正文。
```

## 参考文件体系

v2.1.0 将原 `style-modules.md`（2500+ 行）拆分为按需加载的独立模块，大幅降低单次 token 消耗。

### 题材风格模块

| 文件 | 内容 | 何时加载 |
|------|------|---------|
| `style-index.md` | 题材风格总索引 | 查找所需风格模块 |
| `style-humor.md` | 幽默风格 | 轻松/幽默/沙雕 |
| `style-suspense.md` | 悬疑/推理/恐怖 | 悬疑/惊悚/推理/恐怖 |
| `style-romance.md` | 言情/爱情线/后宫 | 言情/甜宠/后宫/虐恋 |
| `style-combat.md` | 打斗/智斗 | 玄幻/修仙/武侠/高武 |
| `style-cinematic.md` | 镜头式写作 | 提升画面感/场景切换 |
| `style-upgrade.md` | 升级流/爽文/装逼打脸 | 升级流/爽文/无敌流 |
| `style-fantasy.md` | 奇幻/玄幻/金手指 | 奇幻/玄幻/仙侠 |
| `style-reality.md` | 现实/世情/新媒体 | 都市/现实/新媒体 |
| `style-niche.md` | 小众题材 | 轻小说/沙雕/赛博朋克/盘点/模拟/直播 |
| `style-platform.md` | 平台风格差异 | 了解平台差异 |

### 写作技法模块

| 文件 | 内容 |
|------|------|
| `writing-basics.md` | 核心心法、白描、视角、代入感 |
| `writing-craft.md` | 文笔、水分控制、环境交互 |

### 商业化模块

| 文件 | 内容 |
|------|------|
| `market-methodology.md` | 商业网文六大模块、卖点论、情绪缺口 |
| `creative-strategy.md` | 创作策略、节奏法、反套路、题材拼接 |
| `platform-guide.md` | 起点/番茄/刺猬猫/飞卢/晋江/七猫平台适配 |

### 女频专项模块

| 文件 | 内容 |
|------|------|
| `female-genre-guide.md` | 女频题材框架、核心情绪、爽点设计 |
| `female-character-design.md` | 女频角色设计、CP 模式、关系网 |
| `female-opening-design.md` | 女频开头设计、开局模板、钩子设计 |

### 其他核心参考

| 文件 | 内容 |
|------|------|
| `anti-ai-writing.md` | 去 AI 味完整指南（6 门禁 + 三遍法） |
| `anti-ai-detection.md` | 去 AI 味检测清单 |
| `banned-words.md` | 禁用词表 |
| `quality-check.md` | 7 维 10 分制评分系统 |
| `hook-techniques.md` | 钩子技法大全（章尾 13 式 + 章首 7 式） |
| `continuation-engine.md` | 半部续写引擎 |
| `editorial-pipeline.md` | 编辑部流水线 |
| `advanced-audit.md` | 深度审稿清单 |
| `advanced-plot-techniques.md` | 60+ 高级剧情技法 |
| `author-style-guide.md` | 作家技法参考库 |
| `character-design.md` | 角色设计完整指南 |
| `dialogue-mastery.md` | 对话写作技法 |
| `emotional-arc-design.md` | 情绪弧线设计 |
| `genre-frameworks-unified.md` | 题材框架统一指南 |
| `opening-design.md` | 开头设计 |
| `outline-arrangement.md` | 大纲编排法 |
| `plot-structures.md` | 剧情结构 |
| `reversal-toolkit.md` | 反转工具箱 |
| `narrative-units.md` | 叙事单元设计 |
| `chapter-outline.md` | 细纲批次化规范 |
| `artifact-protocols.md` | 文件模板与创建指引 |
| `examples.md` | 多题材创作示例 |
| `interactive-prompts.md` | 12 步流程交互提示词 |
| `prompt-guide.md` | 提示词编写指南 |

## 目录结构

```text
ximen-aimazi/
├── SKILL.md                    # 中文主技能文档（精简版，详细内容在 references/）
├── SKILL.en.md                 # 英文文档
├── plugin.json                 # Skill 打包配置
├── README.md
├── CHANGELOG.md
├── LICENSE
├── _meta.json                  # 版本与发布信息
├── MEMORY.md                   # 记忆索引
├── SESSION.md                  # 跨会话恢复文件
├── .claude/
│   ├── CLAUDE.md               # 项目级 AI 指令
│   └── settings.local.json     # Stop hook 等本地配置
├── .trae/skills/ximen-aimazi/  # Trae 平台 skill 镜像
├── assets/
│   ├── STYLE-TEMPLATE.md       # 5 种预设文风库
│   ├── EDGE-TEMPLATE.md        # 5 种擦边风格模板
│   ├── CHAPTER-TEMPLATE.md     # 章节模板
│   ├── CHAPTER-TEMPLATE.female.md
│   ├── PROMPT-TEMPLATE.md      # 提示词空白模板
│   ├── LEARNINGS-TEMPLATE.md   # 真相档案模板
│   └── workspace/              # init-novel 使用的项目级模板
├── references/                 # 按需加载的参考资料（44 个文件）
│   ├── style-*.md              # 题材风格模块（11 个）
│   ├── writing-*.md            # 写作技法模块（2 个）
│   ├── market-*.md             # 商业化模块
│   ├── creative-*.md           # 创作策略模块
│   ├── female-*.md             # 女频专项模块（3 个）
│   ├── platform-guide.md       # 平台适配指南
│   ├── anti-ai-*.md            # 去 AI 味模块（2 个）
│   └── ...                     # 更多参考资料
├── memory/                     # 分类记忆
├── .learnings/                 # 小说事实档案（角色/伏笔/地点等）
└── scripts/                    # 初始化与字数统计脚本
```

## v2.1.0 主要变更

**结构重构：**
- 拆分 `style-modules.md`（2500+ 行）为 15 个独立参考文件 + 1 个索引文件
- 精简 `SKILL.md` 从 1069 行至 406 行（减少 62%），详细内容改为引用 `references/`
- 修复文件路径不一致（统一使用逻辑路径：大纲/正文/设定/追踪/）
- 清理根目录与 `.trae/skills/` 间的文件重复

**内容增强：**
- 新增女频专项模块：题材指南、角色设计、开头设计
- 新增平台适配指南：起点/番茄/刺猬猫/飞卢/晋江/七猫
- 补强 `chapter-outline.md`（33 行 → 200+ 行完整批次化规范）
- 更新 `interactive-prompts.md` 为 12 步流程 + 增强模式提示词
- 扩充 `examples.md`（新增都市重生/女频甜宠/规则怪谈/去 AI 味改写/卡文救援示例）

**工程化：**
- 新增 `plugin.json` 标准打包配置
- 优化 Skill 触发描述
- 新增"按需加载参考文件"指引（15 个场景映射）
- 更新 `.claude/CLAUDE.md` 路径规范和参考文件列表

完整版本记录见 [CHANGELOG.md](./CHANGELOG.md)。

## 使用建议

- 先定题材和卖点，不要一上来就写正文
- 长篇项目保留 `SESSION.md`、`MEMORY.md` 和 `追踪/CHAPTERS.md`
- 写同人时先补原著资料再生成大纲
- 借大神写法优先选 1 主 + 1 辅，不要混 4 种风格
- 卡文时先跑续写诊断，不要盲目硬写
- 女频创作优先加载 `female-genre-guide.md` 等女频专项模块

## 许可证

[MIT](./LICENSE)
