@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ========================================
echo    小说创作助手 - 初始化新小说
echo ========================================
echo.

if "%~1"=="" (
    echo 用法: init-novel.bat 小说名称 [--clean]
    echo.
    echo 示例:
    echo   init-novel.bat 我的修仙小说
    echo   init-novel.bat 我的小说 --clean
    exit /b 1
)

set NOVEL_NAME=%~1
set CLEAN_MODE=%~2

echo 即将创建小说: %NOVEL_NAME%
echo.

if "%CLEAN_MODE%"=="--clean" (
    echo [模式] 清理模式 - 将清空 .learnings/ 中的旧记录
) else (
    echo [模式] 保留模式 - .learnings/ 中的旧记录将被保留
)
echo.

:: 创建 output 目录
if not exist "output" mkdir output
echo [OK] output/ 目录已创建

:: 创建 .learnings 目录
if not exist ".learnings" mkdir .learnings
echo [OK] .learnings/ 目录已创建

:: 保存小说名称到配置文件
echo %NOVEL_NAME% > .novel-name
echo [OK] 小说名称已记录

:: 询问小说方向
echo.
echo ========================================
echo    请描述您的创作方向
echo ========================================
echo 例如: "都市修仙爽文，废柴逆袭"
echo      "重生回高中，成为商业大亨"
echo      "系统流，末世求生"
echo.
set /p USER_DIRECTION=请输入小说方向: 

if not "%USER_DIRECTION%"=="" (
    echo # %NOVEL_NAME% > output/提示词.md
    echo. >> output/提示词.md
    echo **创作方向**: %USER_DIRECTION% >> output/提示词.md
    echo. >> output/提示词.md
    echo **创建时间**: !date! !time! >> output/提示词.md
    echo [OK] 创作方向已保存到 output/提示词.md
)

echo.
echo ========================================
echo    初始化完成！
echo ========================================
echo.
echo 下一步:
echo   1. 编辑 output/提示词.md 完善创作提示词
echo   2. 使用 AI 助手开始创作第一章
echo.
echo 提示词生成命令示例:
echo   "帮我写 %NOVEL_NAME% 的第一章"
echo.

endlocal
