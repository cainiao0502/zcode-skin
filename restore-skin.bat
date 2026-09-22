@echo off
chcp 65001 >nul
title ZCode Miku Skin - 还原原版
echo.
echo  即将从备份还原 ZCode 原版 app.asar...
echo  请确保已完全退出 ZCode（含托盘）。
echo.
pause
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0restore-skin.ps1" %*
echo.
pause
