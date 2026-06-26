---
name: reference_tools
description: 项目工具脚本和自动化脚本的位置与用途
type: reference
---

# 工具脚本索引

| 脚本 | 位置 | 用途 | 平台 |
|------|------|------|------|
| `init-novel.sh` | `scripts/` | 初始化/重置独立小说工作区（提示词、SESSION、CHAPTERS、真相档案、大纲、追踪文件） | Linux/macOS |
| `init-novel.ps1` | `scripts/` | Windows 初始化核心逻辑 | Windows PowerShell |
| `init-novel.bat` | `scripts/` | Windows 启动入口（转调 `init-novel.ps1`） | Windows |
| `word-count.sh` | `scripts/` | 统计 `正文/第*.md`，兼容旧 `output/第*.md`，并生成 `output/字数统计.md` | Linux/macOS |
| `word-count.ps1` | `scripts/` | Windows 统计核心逻辑并生成报告 | Windows PowerShell |
| `word-count.bat` | `scripts/` | Windows 启动入口（转调 `word-count.ps1`） | Windows |
| `validate-skill.ps1` | `scripts/` | 校验 frontmatter / 版本号 / 单入口 / agents 元数据 / Markdown 引用断链 / 跨目录一致性 | Windows PowerShell |
| `validate-skill.sh` | `scripts/` | 同 `validate-skill.ps1` 的 bash 移植版（macOS/Linux），首次运行前执行 `chmod +x` | Linux/macOS |
| `push-to-github.bat` | 根目录 | 已废弃的发布提示脚本；提交与推送请手动执行 | Windows |

---
