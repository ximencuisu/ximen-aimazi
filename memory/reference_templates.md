---
name: reference_templates
description: 各模板文件的用途、位置和调用时机
type: reference
---

# 模板索引

| 模板文件 | 位置 | 用途 | 调用时机 |
|----------|------|------|----------|
| `STYLE-TEMPLATE.md` | `assets/` | 文风预设库（5种预设+自定义） | 建立 `memory/project_style.md` 时引用 |
| `EDGE-TEMPLATE.md` | `assets/` | 擦边描写规范（5种风格+自定义） | 擦边等级非"无"时载入 |
| `CHAPTER-TEMPLATE.md` | `assets/` | 男频章节模板 | 生成正文时套用 |
| `CHAPTER-TEMPLATE.female.md` | `assets/` | 女频（言情）章节模板 | 女频小说时使用 |
| `PROMPT-TEMPLATE.md` | `assets/` | 提示词模板（完整版+快速版） | 生成创作提示词时 |
| `LEARNINGS-TEMPLATE.md` | `assets/` | 记忆文件模板 | 初始化新.learnings文件时 |
| `workspace/` | `assets/` | 项目级工作区模板（`.learnings` / `SESSION.md` / `memory/project_*.md` / `output/*.md`，含细纲迭代记录、干预决策与冻结清单） | `init-novel` 初始化或 `--clean` 重置时 |

## 参考文档

| 文档 | 位置 | 用途 |
|------|------|------|
| `anti-ai-detection.md` | `references/` | 去AI味详细指南（绝对零度写作） |
| `quality-check.md` | `references/` | 8维度质量评分标准 |
| `chapter-outline.md` | `references/` | 章节细纲的分批生成、迭代返修、人工介入与逻辑审核 |
| `interactive-prompts.md` | `references/` | 交互式提示模板 |
| `plot-structures.md` | `references/` | 10种经典情节结构 |
| `prompt-guide.md` | `references/` | 提示词完善指南 |
| `examples.md` | `references/` | 完整示例集 |

---
