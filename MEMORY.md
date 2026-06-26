# 记忆索引

> 小说创作助手的记忆系统。分为两类：**事实档案**（.learnings/）和**项目元数据**（memory/）。

## 职责边界

| 目录 | 职责 | 内容 | 谁写入 | 谁读取 |
|------|------|------|--------|--------|
| `.learnings/` | **小说世界内的事实** | 角色/地点/情节/伏笔/资源/情感/悬念/错误 | Phase 10 正文生成后自动写入 | Phase 6-10 每章写作前读取 |
| `memory/` | **项目元数据** | 文风/参数/用户偏好/反馈/进度 | Phase 4 参数配置、用户交互后写入 | 全流程按需读取 |

### .learnings/ 真相档案（小说世界内的事实）

| 文件 | 用途 | 写入时机 |
|------|------|---------|
| `CHARACTERS.md` | 角色档案（姓名/身份/等级/状态/关系） | 新角色出场、状态变化时 |
| `LOCATIONS.md` | 地点档案（已出现地点及描述） | 新地点出现时 |
| `PLOT_SUSPENSE.md` | 关键情节+悬念伏笔（活跃/归档分层） | 正文生成后必写 / 大纲/细纲修改后同步 |
| `STORY_BIBLE.md` | 世界观规则（力量体系/社会结构/核心规则） | 新设定补充时 |
| `RESOURCES.md` | 资源账本（物品/金钱/能量） | 资源获得/消耗时 |
| `SUBPLOTS.md` | 子剧情板（活跃/休眠/已回收） | 子剧情状态变化时 |
| `EMOTIONS.md` | 情感弧线（活跃/冷处理/已完结分层） | 情感关系变化时 |
| `ERRORS.md` | 错误记录（穿帮/矛盾/质量差） | 发现问题时 |

### memory/ 项目元数据

| 文件 | 用途 | 写入时机 |
|------|------|---------|
| `project_style.md` | 全书长期文风+作家技法参考 | Phase 4 参数配置后 |
| `project_params.md` | 章节数/女角色数/擦边等级 | Phase 4 用户确认后 |
| `project_status.md` | 当前进度（进行到哪个 Phase） | 每个 Phase 完成后 |
| `project_genres.md` | 已使用题材和爽点模式 | Phase 1 灵感生成后 |
| `feedback_style.md` | 文风/擦边风格选择历史 | 用户选择后 |
| `feedback_interaction.md` | 交互习惯（跳步偏好/模式偏好） | 用户交互后 |
| `user_profile.md` | 用户创作偏好和风格倾向 | 持续学习更新 |
| `reference_tools.md` | 工具脚本索引 | 初始化时 |
| `reference_templates.md` | 模板文件索引 | 初始化时 |

### 分层管理（防止文件膨胀）

| 层级 | 定义 | 何时必读 |
|------|------|---------|
| **活跃** | 近10-20章内出场/发生 | 每次生成前必读 |
| **休眠** | 10-30章未出场/未推进 | 涉及相关角色/情节时查阅 |
| **归档** | 30+章前或已死亡/已回收 | 需要追溯时查阅 |

### 自动归档触发规则

| 触发条件 | 动作 |
|---------|------|
| 角色死亡 | `CHARACTERS.md` 中标记状态为"已死亡/归档" |
| 角色 30+ 章未出场 | 移入休眠区，只保留头部摘要 |
| 伏笔已回收 | `PLOT_SUSPENSE.md` 中标记为"已回收"，30章后移入归档 |
| 子剧情 30+ 章未推进 | `SUBPLOTS.md` 中标记为"休眠" |
| 情感线完结 | `EMOTIONS.md` 中标记为"已完结"，30章后移入归档 |
| 地点 30+ 章未提及 | `LOCATIONS.md` 中标记为"归档" |

---

## 反馈 (Feedback)
- [文风偏好](memory/feedback_style.md) — 用户选择的文风/擦边风格历史，避免重复询问
- [交互习惯](memory/feedback_interaction.md) — 用户交互偏好，参数配置习惯

## 项目 (Project)
- [项目状态](memory/project_status.md) — 当前进行到哪一步，已完成/待完成
- [创作参数](memory/project_params.md) — 章节数/女角色/擦边等级等核心参数
- [文风圣经](memory/project_style.md) — 全书长期文风、作家技法参考、卷级微调规则
- [题材库](memory/project_genres.md) — 已使用过的题材类型和爽点模式

## 用户 (User)
- [用户画像](memory/user_profile.md) — 用户的创作偏好、写作风格倾向

## 参考 (Reference)
- [工具脚本](memory/reference_tools.md) — 初始化脚本、字数统计等工具位置
- [模板索引](memory/reference_templates.md) — 各模板文件用途和调用时机

### v2.6 新增 references 文件

以下文件在 v2.6.0 新增，已同步至 SKILL.md 参考资料表和 AGENTS.md 配置参考清单：

| 文件 | 用途 | 何时加载 |
|------|------|---------|
| `references/faction-design.md` | 势力设计（层级/利益/关系/节奏/互动） | Phase 2/3 涉及多势力冲突时 |
| `references/timeline-and-naming.md` | 时间线格式/时间跳跃/章节命名/卷首尾/字数控制 | Phase 7/8 细纲规划、卷结束检查点 |
| `references/outline-structure.md` | 大纲结构设计 | Phase 6 大纲生成 |
| `references/outline-eight-lines.md` | 八线大纲法 | Phase 6 大纲生成 |
| `references/outline-conflict-design.md` | 大纲冲突设计 | Phase 6 大纲生成 |
| `references/hook-ending.md` | 章末钩子设计 | Phase 8/10 细纲与正文 |
| `references/hook-opening.md` | 章首钩子设计 | Phase 8/10 细纲与正文 |
