# 更新日志

## v2.6.0 (2026-06-26)

### 系统性审查完善

**核心改动**：基于 spec 驱动的系统性完整性审查，覆盖 6 大主题（模板一致性、引用清理、覆盖盲区、测试覆盖、脚本工具、文档一致性），完善 33 项验证点，消除模板漂移、断链残留、覆盖盲区和文档不一致问题。

**主题 A：模板与初始化一致性**
- 女频章节模板补齐四层读取确认块（项目约束/真相档案/上下文/参考库）+ 硬门控标注
- workspace/memory 补齐至 10 个文件，与根级 memory/ 一致
- LEARNINGS-TEMPLATE.md 补齐 8 个模板段落
- CHAPTERS.md 补分页机制 + 历史摘要区
- 细纲模板补 Phase 9 冻结检查表（5 项条件）
- workspace/设定/ 补 5 个续写专用文件骨架
- ERRORS.md 补 `<!-- 插入格式 -->` 注释块
- STYLE-TEMPLATE.md 补"作家技法参考使用规则"小节

**主题 B：references 引用清理与拆分**
- 拆分 outline-arrangement.md → outline-structure.md + outline-eight-lines.md + outline-conflict-design.md
- 拆分 hook-techniques.md → hook-ending.md + hook-opening.md
- 清理 anti-ai-writing.md 对 banned-words.md / anti-ai-detection.md 的循环引用
- continuation-engine.md / continuation-interaction.md 去重，统一指向 continuation-overview.md
- 10 个 references 文件补 `> 何时加载：` 头部声明
- style-fantasy.md / style-suspense.md 补速查卡声明

**主题 C：覆盖盲区补齐**
- 新增 faction-design.md（势力层级/利益矩阵/关系网/节奏/主角互动 5 章）
- 新增 timeline-and-naming.md（时间线格式/时间跳跃/章节命名/卷首尾/字数控制 5 章）
- writing-craft.md 补"第一人称视角管理"章节
- genre-frameworks-unified.md 补"治愈系/ASMR"题材条目
- market-methodology.md 补"发布后反馈整合"章节

**主题 D：测试覆盖度**
- evals.json 从 6 个用例扩展至 20 个（+14），覆盖 DP6/7/8 读取确认门控、改稿流水线、编辑部模式、作家技法、同人、卷检查点、铺垫链、去AI味频率、跳步负向
- trigger-evals.json 正向用例从 4 个扩展至 10 个（+6），覆盖改稿/续写接力/编辑部/深度审稿/去AI味专项

**主题 E：脚本工具与跨平台**
- 新增 validate-skill.sh（bash 版，与 PowerShell 版输出一致）
- validate-skill.ps1 移除 `[^\x00-\x7F]` 中文过滤，改用 codepoint 构建中文路径
- 两脚本补跨目录一致性检查（memory/ vs workspace/memory/、.learnings/ vs workspace/.learnings/、细纲冻结检查表）
- 新增 foreshadow-audit.{sh,ps1}（伏笔回收审计）
- 新增 pave-chain-check.{sh,ps1}（铺垫链三阶校验）

**主题 F：文档一致性**
- AGENTS.md 删除 EMOTIONS.md 重复条目
- 三处 EMOTIONS.md 描述统一为"活跃/冷处理/已完结"三层
- LOCATIONS.md 归档阈值统一为"30+ 章未提及"
- MEMORY.md 补"情感线完结 30 章后移入归档"规则
- AGENTS.md "去AI味核心禁令"末尾补索引提示
- AGENTS.md "配置参考"补完整清单索引
- SKILL.md Phase 6/8/10/12 补 OUTPUT-EXAMPLES.md 引用
- SKILL.md Phase 1/4/交互模式/启动说明补 memory/ 新文件引用

**新增文件**：
- references/faction-design.md, references/timeline-and-naming.md
- references/outline-structure.md, references/outline-eight-lines.md, references/outline-conflict-design.md
- references/hook-ending.md, references/hook-opening.md
- scripts/validate-skill.sh, scripts/foreshadow-audit.sh, scripts/foreshadow-audit.ps1, scripts/pave-chain-check.sh, scripts/pave-chain-check.ps1
- assets/workspace/memory/ 下 6 个新文件（project_genres, project_params, feedback_style, feedback_interaction, user_profile, reference_tools, reference_templates）
- assets/workspace/设定/ 下 5 个续写专用文件（作品DNA, 风格指纹, 不可改动清单, 续写诊断, 续写方案）

**删除文件**：
- references/outline-arrangement.md（拆分为 3 个新文件）
- references/hook-techniques.md（拆分为 2 个新文件）

**修改文件**：
- SKILL.md, AGENTS.md, MEMORY.md, CHANGELOG.md, _meta.json, plugin.json, README.md
- assets/CHAPTER-TEMPLATE.female.md, assets/LEARNINGS-TEMPLATE.md, assets/STYLE-TEMPLATE.md, assets/OUTPUT-EXAMPLES.md
- scripts/validate-skill.ps1, scripts/init-novel.ps1, scripts/init-novel.sh
- evals/evals.json, evals/trigger-evals.json
- .learnings/ERRORS.md, .learnings/EMOTIONS.md, .learnings/LOCATIONS.md
- references/anti-ai-writing.md, references/writing-craft.md, references/genre-frameworks-unified.md, references/market-methodology.md
- references/continuation-engine.md, references/continuation-interaction.md, references/continuation-overview.md
- references/quality-check.md, references/interactive-prompts.md, references/workflow-interaction.md, references/style-fingerprint-guide.md
- references/style-fantasy.md, references/style-suspense.md

---

## v2.5.0 (2026-06-11)

### 架构瘦身与审核清单内嵌

**核心改动**：针对上下文窗口瓶颈做结构性优化——减少正文写作的强制加载量、为审核环节内嵌保底清单、拆分非续写场景的冗余内容、合并高频更新的记忆文件，并新增输出范例文件。

**Phase 10 必读参考降级**：
- `writing-basics.md` 和 `writing-craft.md` 从正文必读降级为按需加读
- 核心写作技法已在上轮改造中内嵌至 SKILL.md 速查卡片，内嵌规则作为保底基线始终生效
- 仅在需要深入讨论环境交互、核心梗迭代等扩展技法时才加载原文件
- 预期减少约 2000 行强制上下文开销

**Phase 9/11 审核清单内嵌**：
- Phase 9 新增「核心审核清单（逻辑审核必遵）」：时间线/空间线/人物线/设定线/伏笔线/读感线 6 维 + 技法调用完整性
- Phase 11 新增「核心审核清单（一致性审核必遵）」：核心一致性/格式一致性/逻辑连贯/技法调用完整性 4 维
- 审核环节不再完全依赖外部参考文件，内嵌清单作为保底规则始终执行

**续写流程拆出**：
- SKILL.md 中续写详情（CP1-CP3 表格、5 种场景、文风F激活、12 个决策点）拆至 `references/continuation-overview.md`
- SKILL.md 保留简短索引（~14行），续写模式激活时按需加载完整规范
- 非续写场景节省约 40 行常驻上下文

**记忆系统合并**：
- `PLOT_POINTS.md`（关键情节）+ `SUSPENSE.md`（悬念池）合并为 `PLOT_SUSPENSE.md`
- 统一更新 SKILL.md、AGENTS.md、CLAUDE.md、MEMORY.md、init 脚本、validate 脚本等 12 个文件
- 每章生成后少维护一个文件，降低长篇创作的记忆系统负担

**新增输出范例**：
- `assets/OUTPUT-EXAMPLES.md`：覆盖 Phase 6 大纲摘要、Phase 8 细纲条目、Phase 10 正文开头（合格 vs 不合格对比）、Phase 12 评分报告、调用痕迹 5 个关键输出
- 为 Agent 提供"好的输出长什么样"的具体参照

**修改文件**：SKILL.md、AGENTS.md、CLAUDE.md、MEMORY.md、README.md、CHANGELOG.md、_meta.json、plugin.json、assets/CHAPTER-TEMPLATE.md、assets/LEARNINGS-TEMPLATE.md、scripts/init-novel.sh、scripts/init-novel.ps1、scripts/validate-skill.ps1、references/advanced-audit.md、references/continuation-engine.md、references/plot-structures.md

**新增文件**：references/continuation-overview.md、assets/OUTPUT-EXAMPLES.md

**删除文件**：.learnings/PLOT_POINTS.md、.learnings/SUSPENSE.md（含 workspace 模板）

---

## v2.4.0 (2026-06-06)

### 文风对比学习功能

**核心改动**：新增文风F（对比学习文风），用户贴入 AI 原文 + 修改文即可自动提取可执行的写作规则，替代"描述你想要的文风"这种模糊方式。

**新文件**：
- `assets/STYLE-CONTRAST-TEMPLATE.md` — 用户自助贴入样本的对比学习模板
- `references/style-contrast-analysis.md` — 10 维对比分析指南（开篇方式/句式/段落/对话密度/情绪表达/描写风格/金手指揭示/节奏/禁用词/人称距离）
- `memory/style_contrast_guide.md` — 12 条预置去 AI 味写作规则（开箱即用，含反例→正例对照）

**功能特性**：
- **文风F预设**：`assets/STYLE-TEMPLATE.md` 新增文风F，Phase 4 参数4 扩展为 A-F
- **三种对比样本提供方式**：Phase 4 创作参数阶段 / CP 续写准备阶段（CP-⑦½） / Phase 10/12 中途激活
- **12 条预置规则**：基于用户提供的玄幻网文样本提取，涵盖冲突开篇、禁止穿越过渡、金手指平淡化、短句式、动作替心理、描写功能化、对话驱动、设定嵌入式、禁用词替换表、段落节奏、穿越者视角克制、留白信息密度
- **续写全程覆盖**：续写模式跳过 Phase 4 不影响文风F使用，CP-⑦½ 决策点、Phase 10/12 中段均可激活
- **优先级规则**：对比文风规则 > 泛化去AI味规则 > 题材风格模块，冲突时以对比规则为准

**修改文件**：
- `SKILL.md` — Phase 4 参数扩展为 A-F、Phase 10/12 串入对比规则强制读取、续写流程增加文风F激活路径（三种调用方式 + CP-⑦½ 决策点 + 中段中断激活机制）
- `assets/STYLE-TEMPLATE.md` — 新增文风F预设
- `memory/project_style.md` — 新增对比文风激活配置字段

---

## v2.3.4 (2026-06-01)

### 分发可靠性维护

**核心改动**：收敛为单中文入口，补齐客户端展示元数据，并加强本地校验，降低安装、发布和按需加载时的漂移风险。

- 删除英文辅助技能文档，`SKILL.md` 作为唯一技能入口
- 新增 `agents/openai.yaml`，提供客户端展示名、短描述和默认调用提示
- 新增 `references/anti-ai-detection.md` 与 `references/banned-words.md` 兼容入口，避免旧引用断链
- 修复女频模板和文档中指向不存在女频参考文件的调用
- 新增 `scripts/validate-skill.ps1`，校验版本、单入口、客户端元数据和 Markdown 引用
- 修正 README 目录统计和 `.claude/CLAUDE.md` 版本口径

---

## v2.3.3 (2026-05-22)

### 通用技能包整改

**核心改动**：按通用 Agent Skill 分发方式重新梳理技能资源与小说工作区边界，修复初始化、模板、路径口径、字数统计和分发卫生问题。

- `init-novel` 默认创建独立小说工作区，支持 `--workspace <path>` 显式指定位置，不再把用户小说项目直接写入技能安装目录
- 统一 v2.3 工作流路径：章节正文使用 `正文/`，章节索引使用 `追踪/CHAPTERS.md`，`output/` 保留为报告目录并兼容旧章节统计
- 补齐流程前置模板：`大纲/大纲.md`、`大纲/细纲.md`、`追踪/伏笔.md`、`追踪/时间线.md`
- 修复 `word-count`：默认扫描 `正文/第*.md`，兼容旧 `output/第*.md`，报告统一写入 `output/字数统计.md`
- 文档同步为平台中立表述：将 `AskUserQuestion` 改为结构化提问能力，修正快速模式与主流程门控说明
- 清理通用分发问题：移除 `.trae` 镜像副本、删除本机 `settings.local.json`、重写过期 `push-to-github.bat`

---

## v2.3.0 (2026-05-21)

### 全流程交互决策点

**核心改动**：将续写流程已有的"交互决策点"模型扩展到整个创作流程（Phase 1-12），实现每一步都有用户介入决策的可能性。

**主流程21个交互决策点（DP前缀）**：

| 编号 | Phase | 决策点名称 | 讨论模式 | 快速模式 |
|------|-------|-----------|---------|---------|
| DP1-1 | Phase 1 | 创作方向确认 | 停 | 跳过 |
| DP1-2 | Phase 1 | 创意方案选择 | 停 | 必停 |
| DP2-1 | Phase 2 | 世界观方向选择 | 停 | 跳过 |
| DP2-2 | Phase 2 | 世界观细节审核 | 停 | 跳过 |
| DP3-1 | Phase 3 | 主角方向选择 | 停 | 跳过 |
| DP3-2 | Phase 3 | 角色阵容审核 | 停 | 跳过 |
| DP4-1 | Phase 4 | 创作参数配置 | 停 | 必停 |
| DP5-1 | Phase 5 | 同人判断与资料确认 | 停 | 跳过 |
| DP6-1 | Phase 6 | 大纲方向选择 | 停 | 跳过 |
| DP6-2 | Phase 6 | 大纲审核 | 停 | 跳过 |
| DP7-1 | Phase 7 | 批次规划确认 | 停 | 跳过 |
| DP8-1 | Phase 8 | 细纲生成确认 | 停 | 跳过 |
| DP8-2 | Phase 8 | 细纲审核 | 停 | 跳过 |
| DP9-1 | Phase 9 | 审核结果与方案选择 | 停 | 必停 |
| DP10-1 | Phase 10 | 章节生成前确认 | 停 | 跳过 |
| DP10-2 | Phase 10 | 章节生成后审核 | 停 | 必停(首章) |
| DP11-1 | Phase 11 | 一致性审核讨论 | 停 | 跳过(低于门槛停) |
| DP12-1 | Phase 12 | 润色方向确认 | 停 | 跳过 |
| DP12-2 | Phase 12 | 评分结果处理 | 停 | 跳过(低于门槛停) |
| DP12-3 | Phase 12 | 章节完成与下一步 | 停 | 跳过 |

**续写决策点编号对齐**：续写流程12个决策点改用 CP- 前缀（CP-①~CP-⑫），与主流程 DP 前缀区分

**统一交互模式**：讨论模式（默认）/ 快速模式，覆盖主流程+续写流程

**全流程进度检测**：扩展为通用检测表，无论从哪里切入都能恢复并走完剩余流程

**新增文件**：
- `references/workflow-interaction.md`：全流程交互决策点指南

**重写文件**：
- `references/interactive-prompts.md`：改造为结构化决策点模板

**更新文件**：
- `SKILL.md`：增加交互模式章节、决策点引用、进度检测扩展、前置依赖矩阵增加入口决策点列
- `references/continuation-interaction.md`：决策点编号改为CP-前缀、增加与主流程统一说明
- `references/continuation-engine.md`：交互模式统一、决策点引用更新为CP-前缀

---

## v2.2.1 (2026-05-17)

### 续写交互增强

**12 个交互决策点**：续写流程全程嵌入交互决策点，让用户和 AI 一起讨论、掌控方向

| # | 决策点 | 阶段 | 快速模式 |
|---|--------|------|---------|
| ① | 提取结果审核 | CP1 | 跳过 |
| ② | 关键设定修正 | CP1 | 跳过 |
| ③ | 卡点诊断讨论 | CP2 | 跳过 |
| ④ | 路线选择与调整 | CP2 | 必停 |
| ⑤ | 节拍审核 | CP2 | 跳过 |
| ⑥ | 锁定理由展示 | CP3 | 必停 |
| ⑦ | 补充遗漏条目 | CP3 | 跳过 |
| ⑧ | 衔接点确认 | Phase 7 | 跳过 |
| ⑨ | 首章方向选择 | Phase 8 | 跳过 |
| ⑩ | Sample Chapter 讨论 | Phase 10 | 必停 |
| ⑪ | 每章关键情节点确认 | Phase 10 | 首章必停 |
| ⑫ | 审核结果讨论 | Phase 11-12 | 低于门槛时停 |

**两种交互模式**：
- 🗨️ 讨论模式（默认）：每个决策点都展示选项+讨论
- ⚡ 快速模式：只在4个关键决策点暂停，其余自动推进
- 随时说"切换到快速模式"/"切换到讨论模式"即可切换

**新增参考文件**：
| 文件 | 说明 |
|------|------|
| `references/continuation-interaction.md` | 12个决策点完整交互模板（新增） |

**continuation-engine.md 更新**：
- CP1 完成条件增加决策点①②（提取结果审核+关键设定修正）
- CP2 完成条件增加决策点③④⑤（卡点诊断讨论+路线选择+节拍审核）
- CP3 门控规则增加决策点⑥⑦（锁定理由展示+补充遗漏条目）
- Phase 7-10 衔接增加决策点增加决策点⑧⑨（衔接点确认+首章方向选择）
- Phase 10 增加决策点⑩⑪（Sample Chapter讨论+每章情节点确认）
- Phase 11 增加决策点⑫（审核结果讨论）
- 新增"交互模式"章节

**SKILL.md 更新**：
- 按需加载参考文件表增加 `continuation-interaction.md`
- Continuation Preparation Phase 小节增加交互模式说明
- 参考资料表增加交互模块

---

## v2.2.0 (2026-05-17)

### 续写功能全面增强

**新增 CP1-CP3 续写准备阶段**：
- **CP1 反向解析** — 从已有正文系统化提取作品DNA、风格指纹（9项可量化指标）、人物状态、伏笔状态、世界观规则
- **CP2 卡点诊断与续写方案** — 5类卡点归类（结构/人物/资源/信息/情绪），三条续写路线（稳妥/提速/爆点）+ 3-10章节拍
- **CP3 不可改动清单确认（强门控）** — Frozen_Canon 机制，未确认完毕拒绝进入 Phase 7，续写过程中冲突自动中断

**5种续写场景识别**：
- A 卡文诊断 / B 外稿续写 / C 风格漂移修正 / D 旧坑回填 / E 跨作者接力
- 4种补充子场景：单章续写、跨卷续写、断更后续写、修改后续写

**风格指纹比对与漂移控制**：
- 9项可量化指标：平均句长、句长分布、平均段长、对话占比、高频意象/动词、句式偏好、动作-对话-情绪比例、回避表达倾向
- 每项指标设定漂移阈值，3项以上超阈值自动阻断润色
- Phase 12 额外执行风格指纹回拉规则

**产出物 Metadata 与来源追溯**：
- 每个续写流程文件标注来源（原作提取/AI生成/AI续写/用户修改）
- 变更历史记录 + 续写产物索引

**续写中断、回退与异常处理**：
- 任意阶段可安全中断恢复
- 重大产出物写入前自动备份
- 异常输入检测与报告

**新增参考文件**：
| 文件 | 说明 |
|------|------|
| `references/continuation-engine.md` | 续写引擎完整规范（162行→407行，14章） |
| `references/continuation-engine.md` | CP1 反向解析操作指南（已整合） |
| `references/style-fingerprint-guide.md` | 风格指纹比对与漂移控制指南（新增） |

**SKILL.md 更新**：
- 新增 Continuation Preparation Phase 小节
- 增强模式表格扩充续写内容
- 项目进度检测表增加续写分支
- 前置依赖矩阵增加 Continuation_Mode 条件
- Phase 10/11/12 增加 Continuation_Mode 额外规则
- 项目文件结构补充续写相关文件
- Artifact映射表补充续写产出物
- 出稿门槛增加续写章节 ≥ 7.5
- 记忆写入总则增加续写流程
- 触发词扩充（续写/卡文/接力等）

---

## v2.1.1 (2026-05-15)

### 全面优化与修复

**断裂引用修复**：
- 修复 SKILL.md 中 30+ 个指向不存在文件的引用，全部重定向到已有文件
- 移除 `interactive-prompts.md` 等未使用引用
- 统一文件路径：`追踪/伏笔.md` → `.learnings/SUSPENSE.md`

**去AI味规则优化**：
- 绝对禁止 → 按题材分级（热血限制/古风放宽/都市严格）
- 禁语表 → 频率限制版（每章/每卷次数控制）
- 新增文风例外说明章节
- 新增擦边描写与去AI味规则优先级表

**记忆系统增强**：
- MEMORY.md 增加 `.learnings/` vs `memory/` 职责边界清晰表格
- 增加 9 个真相档案详细说明
- 增加自动归档触发规则（角色死亡/30章未出场/伏笔回收等）

**交互体验提升**：
- Phase 4 新增三种创作模式（快速/标准/深度）
- 参数配置改为渐进式询问 + 智能推荐
- 新增用户偏好学习机制

**其他**：
- output/CHAPTERS.md 增加分页/摘要机制（50章以上自动归档）
- 新增 Troubleshooting 章节（8 个常见问题）
- 修正 CHANGELOG v1.4.0/v1.5.0 日期冲突
- anti-ai-detection.md 编号一致性修复

---

## v1.9.0 (2026-04-22)

### 吸收 Online-writing-skill 的增强层

在保留 `v1.6.0` 长篇记忆系统基线的前提下，新增以下能力：

- **作家技法参考库** — 新增 `references/author-style-guide.md`，支持将具体作者的节奏、氛围、钩子、人物处理方式挂载到现有文风系统
- **半部小说续写与卡文救援** — 新增 `references/continuation-engine.md`，支持对已有稿件做 DNA 拆解、卡点诊断和多路线续写
- **AI 编辑部流水线** — 新增 `references/editorial-pipeline.md`，把立项、架构、出稿、审稿、返修拆成角色化流程
- **深度审稿清单** — 新增 `references/advanced-audit.md`，补上长篇中后段常见的人设、资源、伏笔、追读风险排查
- **文风挂载增强** — `assets/STYLE-TEMPLATE.md` 新增 `ACTIVE_AUTHOR_STYLE`，支持“基础文风 + 作者技法参考”的混合模式
- **主技能文档增强** — `SKILL.md`、`README.md`、`.claude/CLAUDE.md` 同步接入新模式与新输出约定

---

## v1.6.0 (2026-04-12)

### 记忆系统增强与长篇优化

面向长篇创作（200-500章）的记忆系统全面升级：

**新增文件：**
- **`MEMORY.md`** — 记忆索引，按反馈/项目/用户/参考四类索引所有记忆文件
- **`.claude/CLAUDE.md`** — 项目级AI指令，每次会话自动加载
- **`SESSION.md`** — 跨session恢复文件，记录当前进度和下一步
- **`output/CHAPTERS.md`** — 章节索引，追踪所有章节的状态/字数/爽点/伏笔
- **8个分类记忆文件** — `memory/` 目录下按类型分类的结构化记忆

**新增真相档案（4个）：**
- `RESOURCES.md` — 资源账本
- `SUBPLOTS.md` — 子剧情板
- `EMOTIONS.md` — 情感弧线
- `SUSPENSE.md` — 悬念池

**分层管理机制：**
- `.learnings/` 文件全部增加活跃/休眠/归档分层
- 防止长篇创作中单文件无限膨胀
- 上下文分层检索策略：最近3章全文 + 关键情节索引

**Hook 配置：**
- `.claude/settings.local.json` Stop 钩子，会话结束时自动更新 SESSION.md

---

## v1.5.0 (2026-03-26)

### 联网选材与题材分类

新增联网检索番茄小说热榜功能，支持19种题材分类选择：

**新增功能：**
- **联网选材** - 抓取番茄小说排行榜获取热门趋势
- **题材分类** - 19种预设题材 + 自定义选项
- **热榜展示** - 展示 Top10 热门作品及趋势分析

**题材列表：**
西方奇幻、东方仙侠、科幻末世、都市日常、都市修真、都市高武、历史古代、战神赘婿、都市种田、传统玄幻、历史脑洞、悬疑脑洞、都市脑洞、玄幻脑洞、悬疑灵异、抗战谍战、游戏体育、动漫衍生、男频衍生

**流程变化：**
- 新增"第零步：选材参考"作为创作起点
- 十步流程扩展为十一步流程

---

## v1.4.0 (2026-03-25)

### 文风配置与创作参数

新增交互式文风选择、创作参数配置、擦边描写规范：

**新增功能：**
- **交互式文风选择** - 5种预设文风 + 自定义粘贴
- **创作参数配置** - 章节数量/女角色数量/擦边等级
- **擦边描写规范** - 5种风格预设 + 自定义配置

**文风预设：**
A热血爽文 / B都市现实 / C古风仙侠 / D悬疑惊悚 / E轻松日常

**擦边风格：**
A含蓄暗示 / B直白热烈 / C文艺唯美 / D暴力美学 / E纯情青涩

**新增文件：**
| 文件 | 说明 |
|------|------|
| `assets/STYLE-TEMPLATE.md` | 文风提示词配置（5种预设+自定义） |
| `assets/EDGE-TEMPLATE.md` | 擦边描写规范（5种风格+自定义） |

---

## v1.3.0 (2026-03-23)

### 细纲生成与逻辑审核

新增细纲生成和逻辑审核流程，从大纲到正文之间增加审核环节：

**新增功能：**
- **细纲规划** - 规划全本细纲的生成策略
- **细纲生成** - 生成每章详细细纲
- **逻辑审核** - 检查细纲中的逻辑矛盾
- **十步创作流程** - 从八步扩展到十步

**新增文件：**
| 文件 | 说明 |
|------|------|
| `references/chapter-outline.md` | 章节细纲生成与逻辑审核完整指南 |

**审核维度：**
- 时间线审核（章节衔接、时间跳跃）
- 空间线审核（地点转移、距离合理）
- 人物线审核（存活状态、等级匹配、关系变化）
- 设定线审核（力量体系、社会规则、物品来源）
- 伏笔线审核（伏笔呼应、回收时机）

---

## v1.2.0 (2026-03-23)

### 去AI味指南重大升级

整合Wikipedia AI写作识别标准与绝对零度写作原则：

**新增内容：**
- **AI高频词汇表** - 此外、关键、展现、强调、vibrant等50+词
- **Copula Avoidance** - 禁止用"serves as/boasts"代替"is/has"
- **否定排比禁令** - 禁止"Not only...but..."
- **三项并列禁令** - 禁止强行凑成三项
- **同意词替换禁令** - 禁止过度使用同义词
- **虚假范围禁令** - 禁止"从X到Y"无意义列举
- **Em Dash滥用** - 禁止过度使用破折号
- **粗体滥用** - 禁止机械性强调
- **语气词禁令** - 禁止"希望这有帮助"等
- **冗余短语** - 50+简化对照

---

## v1.1.0 (2026-03-23)

### 新增功能
- **八步创作流程整合** - 从用户提供的参考整合完整的创作流程
- **一致性审核** - 人设/设定/逻辑/伏笔四维度检查
- **润色优化** - 语言精炼、对话优化、氛围强化
- **质量评分系统** - 8维度评分（S/A/B/C/D等级）
- **去AI味指南** - 消除AI生成痕迹，语言自然流畅

### 新增文件
| 文件 | 说明 |
|------|------|
| `references/quality-check.md` | 详细质量评分标准（8维度） |
| `references/anti-ai-detection.md` | 去AI味指南 |
| `references/interactive-prompts.md` | 各步骤标准交互提示词 |
| `assets/CHAPTER-TEMPLATE.female.md` | 女频小说章节模板 |
| `scripts/init-novel.bat` | Windows批处理版初始化脚本 |
| `scripts/word-count.sh` | Linux/Mac字数统计脚本 |
| `scripts/word-count.bat` | Windows字数统计脚本 |
| `CHANGELOG.md` | 版本更新日志 |

---

## v1.0.0 (2025-03-09)

### 初始版本
- 智能提示词生成（8维度完善）
- 分章节生成（2000-3000字/章）
- 记忆系统（.learnings/）
- 关键情节图解（Mermaid）
- 失败记录（ERRORS.md）
- 多题材支持（都市/修仙/玄幻/重生/系统流/末世）

---

## 版本对照

| 版本 | 主要功能 |
|------|---------|
| v1.0.0 | 基础创作流程 |
| v1.1.0 | 八步流程 + 审核 + 评分 + 去AI味 + 女频 + 多语言 |
| v1.2.0 | 去AI味重大升级 + 绝对零度写作 |
| v1.3.0 | 十步流程 + 细纲生成 + 逻辑审核 |
| v1.4.0 | 文风配置 + 创作参数 + 擦边规范 |
| v1.5.0 | 联网选材 + 19种题材分类 |
| v1.6.0 | 记忆系统增强 + 长篇分层管理 + 真相档案扩展 |
| v1.9.0 | 作家技法参考 + 续写引擎 + 编辑部流水线 + 深度审稿 |
| v2.1.1 | 断裂引用修复 + 去AI味分级 + 记忆归档增强 |
| v2.2.0 | 续写全面增强 — CP1-CP3 准备阶段 + 风格指纹比对 + Frozen_Canon |
| v2.2.1 | 续写交互增强 — 12 个决策点 + 讨论/快速双模式 |
| v2.3.0 | 全流程交互决策点 — 主流程 21 个 DP + 续写 12 个 CP |
| v2.3.3 | 通用技能包整改 — 独立工作区 + 模板补齐 + 路径统一 |
| v2.3.4 | 分发可靠性 — 单入口 + 客户端元数据 + 校验脚本 |
| v2.4.0 | 文风对比学习 — 6种文风(含F) + 用户样本自动提取规则 |
| v2.5.0 | 架构瘦身 — Phase 9/11 审核内嵌 + 必读降级 + 续写拆出 + 记忆合并 + 输出范例 |
| v2.6.0 | 系统性审查完善 — 模板一致性 + 引用清理 + 覆盖盲区 + 测试覆盖 + 脚本工具 + 文档一致性 |
