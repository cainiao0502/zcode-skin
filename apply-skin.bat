@echo off
chcp 65001 >nul
title ZCode Miku Skin - 应用皮肤
echo.
echo  即将为 ZCode 应用 Miku 皮肤（约 1-2 分钟）...
echo  请确保已完全退出 ZCode（含托盘）。
echo.
pause
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0apply-skin.ps1" %*
echo.
pause
