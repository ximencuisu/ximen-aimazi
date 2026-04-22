# ximen-aimazi

一个面向中文网文创作的 Agent Skill。它把“灵感一句话”拆成可执行的写作流程，帮你完成题材定位、世界观、人物、大纲、细纲、正文、一致性审核、润色和评分，并额外支持作家技法参考、半部小说续写、编辑部式审稿，适合原创爽文、长篇连载和同人创作。

[![Agent Skills](https://img.shields.io/badge/Agent%20Skills-compatible-blue)](https://agentskills.io)
[![Version](https://img.shields.io/badge/version-v1.6.0-green)](./CHANGELOG.md)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)

## 这是什么

`ximen-aimazi` 不是单次生成提示词模板，而是一套可持续推进小说项目的写作工作流：

- 从一句话方向扩展成完整创作方案
- 按固定步骤推进大纲、细纲、正文和审校
- 用记忆系统维护角色、伏笔、地点和世界观一致性
- 支持长篇项目的跨会话恢复与章节追踪
- 内置去 AI 味规范、逻辑审核和质量评分

如果你在 Claude Code、Cursor、OpenAI Codex、GitHub Copilot 或其他支持 Agent Skills 的工具里写中文小说，这个仓库就是可以直接挂载使用的技能包。

## 适合什么场景

- 原创网文：都市、修仙、玄幻、重生、系统流、末世、游戏等
- 长篇连载：50 到 500 章的持续创作
- 同人创作：支持补充原著资料，再按设定继续写
- 人机协作：由 AI 负责流程推进，你负责确认方向和关键取舍

## 当前基础能力

当前工作树以 `v1.6.0` 的长篇记忆系统为基线。基础能力的重点不是“多几个模板”，而是把长篇创作真正跑顺：

- 长篇记忆系统升级：新增 `MEMORY.md`、`SESSION.md`、`output/CHAPTERS.md`
- 分类记忆目录：`memory/` 下拆分反馈、项目、用户、参考四类记忆
- 真相档案增强：围绕资源、子剧情、情感线、悬念池补齐跟踪文件
- 分层管理思路：活跃、休眠、归档分层，减少长篇写作时的上下文膨胀
- 会话恢复能力：重新打开项目时，可以从上次进度继续推进

完整版本记录见 [CHANGELOG.md](./CHANGELOG.md)。

## 新增强层

这次迭代吸收了 `Online-writing-skill-main` 里最有价值的三类能力，但没有推翻 `ximen-aimazi` 原有的记忆系统：

- 作家技法参考：不做句子级模仿，而是提炼节奏、世界观、钩子和对话气质
- 半部小说续写：针对卡文、断更、后半程跑偏，先诊断再给多条续写路线
- AI 编辑部流水线：把立项、搭大纲、写稿、审稿、返修拆成角色化流程
- 深度审稿：在基础评分外，再做长篇中后段更需要的 24 维排雷

## 核心能力

- 十步主流程：灵感、世界观、角色、大纲、细纲、逻辑审核、正文、一致性审核、润色、评分
- 参数配置：在正式出稿前询问章节数、女角色数量、擦边等级等关键参数
- 文风控制：5 种预设文风加自定义文风
- 擦边规范：5 种预设风格加自定义规则
- 细纲先行：先做章节级规划，再生成正文
- 逻辑审核：检查时间线、空间线、人物线、设定线、伏笔线
- 去 AI 味：整合 Wikipedia AI 写作识别经验与绝对零度写作原则
- 质量评分：对章节或成稿进行结构化评估
- 作家风格挂载：支持把具体作者技法接入现有文风模板
- 续写救援：支持半部小说诊断、后续路线规划和样章续写
- 角色化协作：支持按“题材参谋 / 架构编辑 / 章节执行 / 毒舌审稿 / 改稿编辑”推进

## 快速开始

### 1. 安装

通过 ClawdHub：

```bash
clawdhub install ximen-aimazi
```

手动安装：

```bash
git clone https://github.com/ximencuisu/ximen-aimazi.git ~/.openclaw/skills/ximen-aimazi
```

如果你在本地项目里直接使用，把 `ximen-aimazi/` 放进项目的 `skills/` 目录即可。

### 2. 初始化新小说

macOS / Linux:

```bash
./scripts/init-novel.sh 我的小说名 --clean
```

Windows:

```bat
.\scripts\init-novel.bat 我的小说名 --clean
```

初始化后，仓库会准备好输出目录和记忆文件，方便从零开始一个新项目。

### 3. 直接开始对话

你可以把它交给支持 Agent Skills 的 AI 工具，然后像这样开题：

```text
帮我用 ximen-aimazi 做一部 100 章都市修仙小说。
主角是被家族放弃的炼丹师，前期隐忍，中期崛起，后期反向收编宗门。
先给我 3 套创意方案，再让我选。
```

同人场景也可以直接说明：

```text
这是斗罗大陆同人。
先整理原著关键设定和人物关系，再给我大纲，不要急着写正文。
```

## 工作方式

主流程仍然是十步，但在正式进入大纲和正文前，会插入参数配置与同人资料整理这两个可选/半可选环节。

1. 灵感生成：把一句话方向扩展成 3 套可选方案
2. 世界观构建：整理力量体系、社会结构、核心规则
3. 角色塑造：主角、对手、盟友、情感线角色
4. 创作参数配置：章节数、角色数量、擦边等级
5. 同人资料整理：搜索或粘贴原著设定，建立约束
6. 大纲生成：确定长线结构和关键转折
7. 细纲规划：决定章节推进节奏
8. 生成细纲：把大纲拆成可执行章节计划
9. 逻辑审核：检查设定、时间、空间、人物、伏笔冲突
10. 正文章节：按通过审核的细纲写正文
11. 一致性审核：回看记忆文件，补齐事实更新
12. 润色与评分：去 AI 味、修句、打分

## 目录结构

```text
ximen-aimazi/
├── SKILL.md                    # 中文主技能文档
├── SKILL.en.md                 # 英文文档
├── README.md
├── CHANGELOG.md
├── LICENSE
├── MEMORY.md                   # 记忆索引
├── SESSION.md                  # 跨会话恢复文件
├── .claude/
│   ├── CLAUDE.md               # 项目级 AI 指令
│   └── settings.local.json     # Stop hook 等本地配置
├── assets/
│   ├── PROMPT-TEMPLATE.md
│   ├── CHAPTER-TEMPLATE.md
│   ├── CHAPTER-TEMPLATE.female.md
│   ├── STYLE-TEMPLATE.md
│   ├── EDGE-TEMPLATE.md
│   └── LEARNINGS-TEMPLATE.md
├── references/
│   ├── anti-ai-detection.md
│   ├── advanced-audit.md
│   ├── author-style-guide.md
│   ├── chapter-outline.md
│   ├── continuation-engine.md
│   ├── editorial-pipeline.md
│   ├── examples.md
│   ├── interactive-prompts.md
│   ├── plot-structures.md
│   ├── prompt-guide.md
│   └── quality-check.md
├── memory/                     # 分类记忆
│   ├── feedback_*.md
│   ├── project_*.md
│   ├── reference_*.md
│   └── user_profile.md
├── .learnings/                 # 小说事实档案
├── output/                     # 大纲、细纲、章节与索引输出
└── scripts/
    ├── init-novel.sh
    ├── init-novel.bat
    ├── word-count.sh
    └── word-count.bat
```

## 关键文件说明

| 文件 | 作用 |
| --- | --- |
| `SKILL.md` | 技能主说明，定义整个创作流程和执行规范 |
| `MEMORY.md` | 记忆入口索引，告诉代理应该去哪里找上下文 |
| `SESSION.md` | 当前小说处在哪个阶段，下次会话从哪里继续 |
| `.claude/CLAUDE.md` | 项目级操作约束，提醒代理先读进度再继续 |
| `.learnings/` | 世界观、角色、地点、伏笔、错误等小说事实档案 |
| `memory/` | 用户偏好、项目参数、参考模板等辅助记忆 |
| `output/CHAPTERS.md` | 章节索引，记录章节状态、字数和推进情况 |
| `references/author-style-guide.md` | 作家技法参考库，用来做风格定调 |
| `references/continuation-engine.md` | 半部小说续写与卡文救援 |
| `references/editorial-pipeline.md` | AI 编辑部式出稿与返修流程 |
| `references/advanced-audit.md` | 关键章节深度审稿清单 |

## 输出约定

这个技能默认把核心产物落到 `output/` 目录：

- `output/提示词.md`
- `output/创作参数.md`
- `output/立项单.md`（可选）
- `output/大纲.md`
- `output/细纲.md`
- `output/续写诊断.md`（可选）
- `output/续写方案.md`（可选）
- `output/审稿报告.md`（可选）
- `output/返修记录.md`（可选）
- `output/第XX章_[章名].md`
- `output/CHAPTERS.md`

这样做的好处是，AI 不是“一次性吐一篇文”，而是把整部小说当成可持续维护的项目来管理。

## 兼容工具

- Claude Code
- Cursor
- OpenAI Codex
- GitHub Copilot
- OpenClaw
- 其他支持 Agent Skills 的工具

## 使用建议

- 先定题材和卖点，再让 AI 生成 3 套方案，不要一上来就直接写正文
- 长篇项目尽量保留 `SESSION.md`、`MEMORY.md` 和 `output/CHAPTERS.md`
- 写同人时先补原著资料，再生成大纲，能显著降低设定穿帮
- 如果你很在意风格稳定，先选定文风模板，再开始细纲和正文
- 如果你想借大神写法，优先选 `1 个主参考 + 1 个辅参考`，不要一口气混 4 种风格
- 如果你已经卡在半部，先跑续写诊断，不要盲目硬写下一章

## 相关文档

- 中文技能文档：[SKILL.md](./SKILL.md)
- 英文说明：[SKILL.en.md](./SKILL.en.md)
- 作家技法参考：[references/author-style-guide.md](./references/author-style-guide.md)
- 续写引擎：[references/continuation-engine.md](./references/continuation-engine.md)
- 编辑部流水线：[references/editorial-pipeline.md](./references/editorial-pipeline.md)
- 深度审稿：[references/advanced-audit.md](./references/advanced-audit.md)
- 更新日志：[CHANGELOG.md](./CHANGELOG.md)

## 许可证

[MIT](./LICENSE)
