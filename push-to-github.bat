@echo off
chcp 65001 >nul
echo ========================================
echo    push-to-github.bat is deprecated
echo ========================================
echo.
echo This repository should be reviewed before publishing.
echo Please run these commands manually after checking changes:
echo.
echo   git status
echo   git diff
echo   git add ^<files^>
echo   git commit -m "chore: update ximen-aimazi skill package"
echo   git push
echo.
echo The old script used "git add ." and a stale commit message.
echo It has been disabled to avoid accidental publishing of local workspaces.
echo.
pause
