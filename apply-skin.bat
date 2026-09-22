@echo off
title ZCode Miku Skin - Apply
echo.
echo  Applying Miku skin to ZCode (takes 1-2 minutes)...
echo  Make sure ZCode is FULLY closed (check the system tray!).
echo.
pause
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0apply-skin.ps1" %*
echo.
echo  Done. If you see errors above, take a screenshot and report.
pause
