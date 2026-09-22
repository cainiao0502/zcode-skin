# ============================================================
# restore-skin.ps1 — 从备份还原 ZCode 原版 app.asar
# 用法:  .\restore-skin.ps1 [-ZCodeDir "D:\ZCode"]
# ============================================================
param([string]$ZCodeDir = "D:\ZCode")

$ErrorActionPreference = "Stop"
$backup = Join-Path $ZCodeDir "resources\app.asar.miku-backup"
$asar   = Join-Path $ZCodeDir "resources\app.asar"

if (-not (Test-Path $backup)) { throw "未找到备份 $backup，无需还原" }
if (Get-Process ZCode -ErrorAction SilentlyContinue) { throw "ZCode 正在运行，请先完全退出" }

Copy-Item $backup $asar -Force
Remove-Item $backup
Write-Host "✔ 已还原 ZCode 原版 app.asar（备份已清除）。" -ForegroundColor Green
