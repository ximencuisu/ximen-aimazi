@echo off
chcp 65001 >nul
echo ========================================
echo    推送到 GitHub
echo ========================================
echo.
echo 请先在 GitHub 创建仓库：
echo https://github.com/new
echo   - Repository name: ximen-aimazi
echo   - 不要勾选 "Add a README file"
echo.
pause
echo.
cd /d "%~dp0"
git remote set-url origin https://github.com/ximencuisu/ximen-aimazi.git
git add .
git commit -m "feat: v1.2.0 - 小说创作助手，去AI味重大升级"
git push -u origin main
echo.
echo ========================================
echo    推送完成！
echo ========================================
echo.
echo 访问你的仓库：
echo https://github.com/ximencuisu/ximen-aimazi
echo.
pause
