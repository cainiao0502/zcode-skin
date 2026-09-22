@echo off
title ZCode Miku Skin - Restore
echo.
echo  Restoring original ZCode app.asar from backup...
echo  Make sure ZCode is FULLY closed (check the system tray!).
echo.
pause
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0restore-skin.ps1" %*
echo.
echo  Done. If you see errors above, take a screenshot and report.
pause
