# ximen-aimazi 优化计划：打造优秀长篇网文写作 Skill

## 一、总结

将 ximen-aimazi 从一个功能完整但结构臃肿的 v1.9.0 skill，优化为内容精炼、结构清晰、工程化程度高、兼容多平台的优秀长篇网文写作 Agent Skill。

**目标**：成为中文网文创作领域最专业、最实用的 Agent Skill。

**核心原则**：内容优先、深度技法保持、结构瘦身、工程化补全。

---

## 二、现状分析

### 2.1 项目结构

```
ximen-aimazi/
├── SKILL.md                    # 根目录技能文档（~800行，详细）
├── .trae/skills/ximen-aimazi/
│   ├── SKILL.md                # 实际加载的技能文档（与根目录版本不同步）
│   └── references/             # 与根目录 references/ 重复
├── references/                 # 25个参考文件
│   ├── style-modules.md        # ⚠️ 2500+行超级文件
│   ├── chapter-outline.md      # ⚠️ 仅33行，太薄
│   ├── interactive-prompts.md  # ⚠️ 过时，仍引用旧8步流程
│   └── ...                     # 其余质量尚可
├── assets/                     # 模板文件
├── memory/                     # 记忆文件
├── .learnings/                 # 真相档案
├── scripts/                    # 初始化脚本
├── .claude/                    # Claude Code 配置
└── _meta.json                  # 版本信息
```

### 2.2 已识别问题

| # | 问题 | 严重度 | 影响 |
|---|------|--------|------|
| P1 | SKILL.md 双版本不同步 | 高 | .trae 版本是实际加载的，但根目录版本内容更全 |
| P2 | style-modules.md 2500+行 | 高 | 无法有效加载，token 浪费严重 |
| P3 | 参考文件质量参差 | 中 | chapter-outline.md 仅33行，interactive-prompts.md 过时 |
| P4 | 文件路径不一致 | 中 | SKILL.md 用 `大纲/正文/设定/`，CLAUDE.md 用 `output/` |
| P5 | 缺少女频专项 | 中 | 仅一个模板文件，无方法论 |
| P6 | 缺少 skill 打包配置 | 中 | 无 plugin.json / marketplace.json |
| P7 | examples.md 示例单薄 | 低 | 仅1个玄幻示例 |
| P8 | references/ 目录重复 | 低 | 根目录和 .trae/skills/ 下各一份 |

---

## 三、优化方案

### Phase 1：结构重构与瘦身（最高优先级）

#### 1.1 同步 SKILL.md 双版本

**问题**：根目录 SKILL.md 和 `.trae/skills/ximen-aimazi/SKILL.md` 内容不同步。

**方案**：
- 以根目录 SKILL.md 为权威版本（内容更全）
- 将根目录版本同步到 `.trae/skills/ximen-aimazi/SKILL.md`
- 同步更新 SKILL.en.md
- 后续只维护根目录版本，.trae 版本通过脚本或手动同步

**涉及文件**：
- `SKILL.md` — 权威版本，保持不变
- `.trae/skills/ximen-aimazi/SKILL.md` — 同步更新
- `SKILL.en.md` — 同步更新

#### 1.2 拆分 style-modules.md

**问题**：2500+行超级文件，无法有效加载。

**方案**：拆分为 15+ 个独立参考文件 + 1个索引文件

| 新文件 | 来源章节 | 预估行数 |
|--------|---------|---------|
| `references/style-index.md` | 总索引，指向各子文件 | ~80 |
| `references/style-humor.md` | 幽默 | ~80 |
| `references/style-suspense.md` | 悬疑+推理+恐怖 | ~120 |
| `references/style-romance.md` | 言情+后宫+爱情线 | ~150 |
| `references/style-combat.md` | 打斗+智斗+战斗三板斧 | ~200 |
| `references/style-cinematic.md` | 镜头式写作+三机位法+分镜 | ~150 |
| `references/style-upgrade.md` | 升级流+爽文+装逼打脸 | ~200 |
| `references/style-fantasy.md` | 奇幻/玄幻+金手指设计 | ~100 |
| `references/style-reality.md` | 现实/世情+新媒体+战神赘婿 | ~150 |
| `references/style-niche.md` | 轻小说+沙雕+赛博朋克+盘点+模拟+直播 | ~200 |
| `references/style-platform.md` | 各网站风格差异+市场定位 | ~150 |
| `references/writing-basics.md` | 核心心法+白描+视角+代入感 | ~200 |
| `references/writing-craft.md` | 文笔+水分控制+环境交互+一笔多用 | ~200 |
| `references/market-methodology.md` | 商业网文六大模块+卖点论+情绪缺口+需求驱动 | ~300 |
| `references/creative-strategy.md` | 创作思路+节奏法+反套路+跟风创新+题材拼接 | ~250 |

**操作步骤**：
1. 读取 style-modules.md 全文
2. 按上述分类拆分内容
3. 每个文件添加标准头部（标题、用途、何时加载）
4. 创建 style-index.md 索引文件
5. 删除原 style-modules.md
6. 更新 SKILL.md 中的引用路径

**涉及文件**：
- `references/style-modules.md` — 删除
- 15个新文件 — 创建
- `SKILL.md` — 更新引用
- `.trae/skills/ximen-aimazi/references/` — 同步

#### 1.3 修复文件路径不一致

**问题**：SKILL.md 中项目文件结构使用 `大纲/` `正文/` `设定/`，但 CLAUDE.md 和实际输出用 `output/`。

**方案**：
- 统一为 SKILL.md 中定义的逻辑路径（`大纲/` `正文/` `设定/` 等）
- 更新 CLAUDE.md 中的输出规范，与 SKILL.md 对齐
- 更新 init-novel 脚本，创建统一的目录结构
- 在 SKILL.md 中增加明确的目录结构说明

**涉及文件**：
- `SKILL.md` — 保持逻辑路径定义
- `.claude/CLAUDE.md` — 更新输出规范
- `scripts/init-novel.sh` / `.bat` / `.ps1` — 更新目录创建逻辑

#### 1.4 清理重复文件

**问题**：根目录和 `.trae/skills/ximen-aimazi/references/` 下有重复的参考文件。

**方案**：
- 根目录 `references/` 为权威版本
- `.trae/skills/ximen-aimazi/references/` 通过同步保持一致
- 在 README.md 中说明同步机制

---

### Phase 2：内容增强与补全

#### 2.1 补强 chapter-outline.md

**问题**：仅33行，内容太薄。

**方案**：扩充为完整的细纲批次化规范，包含：
- 批次规划详细规则
- 冻结条件完整定义
- 返修触发条件
- 批次细纲模板
- 迭代记录模板
- 人工介入决策模板

**预估行数**：~200行

**涉及文件**：
- `references/chapter-outline.md` — 重写扩充

#### 2.2 更新 interactive-prompts.md

**问题**：仍引用旧的8步流程，与当前12步不匹配。

**方案**：
- 按12步流程重写所有交互提示词
- 每步增加 AskUserQuestion 格式的提示词
- 增加续写/卡文救援模式的交互提示词
- 增加编辑部流水线模式的交互提示词

**涉及文件**：
- `references/interactive-prompts.md` — 重写

#### 2.3 新增女频专项模块

**方案**：新增3个参考文件

| 文件 | 内容 |
|------|------|
| `references/female-genre-guide.md` | 女频创作方法论：甜宠/虐恋/宫斗/宅斗/种田/重生/快穿/穿书等题材框架、女频核心情绪（安全感/被偏爱/逆袭/独立）、女频爽点设计（打脸绿茶/宠妻/护短/独宠）、女频节奏特征 |
| `references/female-character-design.md` | 女频角色设计：女主类型（白莲花/黑莲花/女强/甜软/清冷）、男主类型（霸总/暖男/病娇/腹黑/高岭之花）、CP模式（甜宠/虐恋/双向奔赴/追妻火葬场）、配角设计（绿茶/白月光/闺蜜/婆婆） |
| `references/female-opening-design.md` | 女频开头设计：穿书开局/重生开局/替嫁开局/退婚开局/和亲开局等模板，黄金一章在女频的适配 |

**涉及文件**：
- 3个新文件 — 创建
- `SKILL.md` — 更新引用
- `assets/CHAPTER-TEMPLATE.female.md` — 可能需要扩充

#### 2.4 扩充 examples.md

**问题**：仅1个玄幻示例。

**方案**：增加以下示例：
- 都市重生文示例（提示词+章节片段）
- 女频甜宠文示例（提示词+章节片段）
- 规则怪谈文示例（提示词+章节片段）
- 同人创作示例（原著资料整理+大纲片段）
- 卡文救援示例（诊断+三条路线）
- 去AI味改写示例（改写前后对比）

**涉及文件**：
- `references/examples.md` — 扩充

#### 2.5 新增平台适配指南

**方案**：将 style-platform.md 中的网站差异内容扩展为独立参考文件

| 文件 | 内容 |
|------|------|
| `references/platform-guide.md` | 起点主站/番茄/刺猬猫/飞卢/晋江/七猫等平台的读者画像、节奏要求、题材偏好、开篇策略、更新策略 |

**涉及文件**：
- `references/platform-guide.md` — 新建（从 style-platform.md 扩展）

---

### Phase 3：Skill 工程化

#### 3.1 优化 Skill 触发描述

**问题**：当前 description 较长但关键词覆盖不够精准。

**方案**：
- 精简 description，突出核心价值
- 扩展触发关键词列表
- 增加英文触发词支持
- 确保 description 在 200 字以内

**涉及文件**：
- `SKILL.md` 的 frontmatter — 更新 description
- `.trae/skills/ximen-aimazi/SKILL.md` — 同步

#### 3.2 新增 plugin.json

**方案**：创建标准 skill 打包配置

```json
{
  "name": "ximen-aimazi",
  "version": "2.1.0",
  "description": "中文网文创作全流程助手",
  "author": "ximencuisu",
  "license": "MIT",
  "keywords": ["网文", "小说", "写作", "创作", "去AI味", "爽文"],
  "main": "SKILL.md",
  "references": "references/",
  "assets": "assets/"
}
```

**涉及文件**：
- `plugin.json` — 新建

#### 3.3 优化 Skill 加载效率

**问题**：SKILL.md 过长导致初始加载消耗大量 token。

**方案**：
- SKILL.md 只保留核心流程和规则（目标 <500行）
- 详细内容全部引用 references/ 文件
- 增加"按需加载"指引，明确标注何时加载哪个参考文件
- 在 SKILL.md 头部增加快速索引表

**涉及文件**：
- `SKILL.md` — 精简重构
- `.trae/skills/ximen-aimazi/SKILL.md` — 同步

#### 3.4 更新 _meta.json 和版本号

**方案**：
- 版本号升级为 2.1.0
- 更新 changelog 描述

**涉及文件**：
- `_meta.json` — 更新版本号和 changelog
- `CHANGELOG.md` — 新增 v2.1.0 条目

#### 3.5 更新 .claude/CLAUDE.md

**方案**：
- 同步路径规范
- 更新参考文件列表
- 增加新参考文件的加载指引

**涉及文件**：
- `.claude/CLAUDE.md` — 更新

---

### Phase 4：质量保障

#### 4.1 全局一致性检查

**方案**：
- 检查所有文件间的交叉引用是否正确
- 检查 SKILL.md 中引用的参考文件是否都存在
- 检查评分权重是否一致（SKILL.md vs quality-check.md vs interactive-prompts.md）
- 检查 Phase 编号是否一致

#### 4.2 同步 .trae/skills/ 目录

**方案**：
- 将所有变更同步到 `.trae/skills/ximen-aimazi/` 目录
- 确保 references/ 目录完全一致
- 确保 SKILL.md 完全一致

---

## 四、执行顺序

| 步骤 | 内容 | 预估工作量 |
|------|------|-----------|
| 1 | 拆分 style-modules.md（Phase 1.2） | 最大，需仔细拆分 |
| 2 | 精简重构 SKILL.md（Phase 3.3） | 大，需平衡完整性和精简 |
| 3 | 同步双版本 SKILL.md（Phase 1.1） | 中 |
| 4 | 修复路径不一致（Phase 1.3） | 中 |
| 5 | 补强 chapter-outline.md（Phase 2.1） | 中 |
| 6 | 更新 interactive-prompts.md（Phase 2.2） | 中 |
| 7 | 新增女频专项模块（Phase 2.3） | 大 |
| 8 | 扩充 examples.md（Phase 2.4） | 中 |
| 9 | 新增平台适配指南（Phase 2.5） | 中 |
| 10 | 优化触发描述（Phase 3.1） | 小 |
| 11 | 新增 plugin.json（Phase 3.2） | 小 |
| 12 | 更新 _meta.json 和版本号（Phase 3.4） | 小 |
| 13 | 更新 .claude/CLAUDE.md（Phase 3.5） | 小 |
| 14 | 清理重复文件（Phase 1.4） | 小 |
| 15 | 全局一致性检查（Phase 4.1） | 中 |
| 16 | 同步 .trae/skills/ 目录（Phase 4.2） | 小 |

---

## 五、假设与决策

| 决策项 | 选择 | 理由 |
|--------|------|------|
| style-modules.md 处理方式 | 拆分+保留索引 | 最优解：既减少单次加载 token，又保持可发现性 |
| 女频支持 | 新增独立模块 | 女频方法论差异大，融入现有模块会稀释内容 |
| 平台兼容 | 内容优先 | skill 内容质量是核心，平台适配由用户处理 |
| SKILL.md 精简目标 | <500行核心内容 | 详细内容移入 references/，减少初始加载消耗 |
| 权威版本 | 根目录 SKILL.md | 内容更全，作为 single source of truth |
| 路径规范 | 统一用逻辑路径 | `大纲/` `正文/` `设定/` 比 `output/` 更直观 |

---

## 六、验证步骤

1. **结构验证**：确认所有新文件已创建，所有引用路径正确
2. **内容验证**：确认 style-modules.md 拆分后无内容丢失
3. **同步验证**：确认 .trae/skills/ 与根目录完全一致
4. **功能验证**：用 Trae 加载 skill，确认触发正常、参考文件可加载
5. **一致性验证**：确认评分权重、Phase 编号、路径引用全局一致
