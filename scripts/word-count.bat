@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo    小说字数统计
echo ========================================
echo.

set "output_dir=output"
if not exist "%output_dir%" (
    echo [错误] 未找到 %output_dir%/ 目录
    echo 请在小说项目根目录运行此脚本
    exit /b 1
)

set total_chars=0
set chapter_count=0

echo 正在统计章节文件...
echo.

for %%f in ("%output_dir%/第*.md") do (
    set "file=%%f"
    set "filename=%%~nxf"
    
    :: 提取正文字数（简化版，统计文件总字符）
    for %%c in ("!file!") do (
        :: 使用 PowerShell 统计中文字符
        for /f "delims=" %%x in ('powershell -NoProfile -Command "(Get-Content '!file!' -Raw) -replace '[^一-龥]', '' | Measure-Object -Character).Characters"') do (
            set "chars=%%x"
        )
    )
    
    set /a chapter_count+=1
    set /a total_chars+=!chars!
    
    echo !filename!: !chars! 字
)

echo.
echo ========================================
echo    统计结果
echo ========================================
echo 章节数: !chapter_count!
echo 总字数: !total_chars!

if !chapter_count! gtr 0 (
    set /a avg=total_chars / chapter_count
    echo 平均每章: !avg! 字
)

echo.
echo ========================================
echo    进度估算
echo ========================================

if !total_chars! gtr 0 (
    set /a pct_30=total_chars * 100 / 300000
    set /a pct_50=total_chars * 100 / 500000
    set /a pct_100=total_chars * 100 / 1000000
    
    echo 30万字目标: !pct_30!%%
    echo 50万字目标: !pct_50!%%
    echo 100万字目标: !pct_100!%%
)

echo.
endlocal
