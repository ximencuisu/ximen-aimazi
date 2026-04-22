# 西门爱码子 — 项目指令

## 项目概述

这是 **ximen-aimazi** 小说创作助手项目（v1.6.x 增强版），一个 Agent Skills 兼容的中文网络小说生成工具。
核心价值：从灵感到正文的结构化创作流程，内置去AI味（绝对零度写作）、质量评分、作家技法参考、续写救援和编辑部式审稿。

## 会话恢复

**每次会话开始第一件事**：读取 `SESSION.md` 和 `output/CHAPTERS.md`，了解当前进度。
如果 `SESSION.md` 显示已有项目在进行中，从记录的"当前步骤"继续。

## 关键工作流

1. **灵感** → 用户一句话方向，生成3套创意方案
2. **世界观** → 力量体系、社会结构、核心规则
3. **角色** → 主角+配角设定
4. **参数** → 交互式询问：章节数/女角色数/擦边等级
5. **大纲** → 三幕式结构
6. **细纲** → 逐章详细规划
7. **逻辑审核** → 时间/空间/人物/设定/伏笔一致性
8. **正文** → 交互式文风选择 + 擦边规范载入
9. **一致性审核** → 对照 .learnings/ 真相档案
10. **润色** → 绝对零度写作（禁止比喻、直白心理描写）
11. **评分** → 8维度加权评分（S/A/B/C/D）

## 可选增强模式

1. **作家技法参考** → 用户指定作者风格时，读取 `references/author-style-guide.md`
2. **半部小说续写** → 用户卡文或已有半部稿时，读取 `references/continuation-engine.md`
3. **编辑部流水线** → 用户想像工作室一样推进时，读取 `references/editorial-pipeline.md`
4. **深度审稿** → 关键章节或精修场景，读取 `references/advanced-audit.md`

## 记忆文件（真相档案）

每次生成章节前后必须读写 `.learnings/` 目录：

| 文件 | 用途 | 写入时机 |
|------|------|----------|
| `STORY_BIBLE.md` | 世界观核心设定 | 新设定时 |
| `CHARACTERS.md` | 角色档案+状态（活跃/休眠/归档分层） | 新角色出场/状态变化 |
| `LOCATIONS.md` | 地点档案（当前/历史分层） | 新地点出现/变化 |
| `PLOT_POINTS.md` | 关键情节+伏笔（活跃/归档分层） | 每章生成后 |
| `RESOURCES.md` | 资源账本（持有/已消耗分层） | 物品/金钱变化 |
| `SUBPLOTS.md` | 子剧情板（活跃/休眠/归档分层） | 子剧情激活/休眠 |
| `EMOTIONS.md` | 情感弧线（活跃/冷处理分层） | 角色情感发展 |
| `SUSPENSE.md` | 悬念池（活跃/已回收分层） | 伏笔埋设/回收 |
| `ERRORS.md` | 错误日志 | 生成失败/质量问题 |
| `output/CHAPTERS.md` | 章节索引 | 每章生成后追加 |

**写章节前必读**：以上所有文件的活跃部分，确保生存/地理/伏笔/去重检查通过。
**长篇分层策略**：活跃（近10-20章）必读，休眠/归档按需查阅。

## 去AI味核心禁令

- **禁止比喻词**：像/就像/好像/如同/仿佛/宛如/犹如/好似（风格C擦边情节除外）
- **禁止直白心理描写**：他很紧张/她感到愤怒 → 改为微动作展示
- **禁止禁语表高频词**：冷笑/颤抖/泛白/勾起弧度/空气凝固
- **禁止欧化表达**：他很高/作出决定/被激怒
- **段落不超过4行**

## 配置参考

- 文风配置：`assets/STYLE-TEMPLATE.md`（5种预设+自定义）
- 擦边配置：`assets/EDGE-TEMPLATE.md`（5种风格+自定义）
- 章节模板：`assets/CHAPTER-TEMPLATE.md` + `assets/CHAPTER-TEMPLATE.female.md`
- 作家技法参考：`references/author-style-guide.md`
- 卡文救援：`references/continuation-engine.md`
- 编辑部流水线：`references/editorial-pipeline.md`
- 去AI味详细：`references/anti-ai-detection.md`
- 质量评分：`references/quality-check.md`
- 深度审稿：`references/advanced-audit.md`
- 情节结构：`references/plot-structures.md`（10种经典套路）

## 输出规范

- 大纲 → `output/大纲.md`
- 细纲 → `output/细纲.md`
- 章节 → `output/第XX章_[章名].md`
- 创作参数 → `output/创作参数.md`
- 立项分析 → `output/立项单.md`（可选）
- 续写诊断 → `output/续写诊断.md`（可选）
- 续写方案 → `output/续写方案.md`（可选）
- 深度审稿 → `output/审稿报告.md`（可选）
- 返修说明 → `output/返修记录.md`（可选）
- 章节索引 → `output/CHAPTERS.md`（每章生成后更新）
- 会话状态 → `SESSION.md`（Stop 钩子自动更新）
