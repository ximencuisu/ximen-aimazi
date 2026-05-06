---
name: reference_tools
description: 项目工具脚本和自动化脚本的位置与用途
type: reference
---

# 工具脚本索引

| 脚本 | 位置 | 用途 | 平台 |
|------|------|------|------|
| `init-novel.sh` | `scripts/` | 初始化/重置项目级工作区（提示词、SESSION、CHAPTERS、真相档案） | Linux/macOS |
| `init-novel.ps1` | `scripts/` | Windows 初始化核心逻辑 | Windows PowerShell |
| `init-novel.bat` | `scripts/` | Windows 启动入口（转调 `init-novel.ps1`） | Windows |
| `word-count.sh` | `scripts/` | 统计章节字数并生成 `output/字数统计.md` | Linux/macOS |
| `word-count.ps1` | `scripts/` | Windows 统计核心逻辑并生成报告 | Windows PowerShell |
| `word-count.bat` | `scripts/` | Windows 启动入口（转调 `word-count.ps1`） | Windows |
| `push-to-github.bat` | 根目录 | 推送代码到GitHub | Windows |

---
