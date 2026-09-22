# ============================================================
# apply-skin.ps1 — 把 Miku 皮肤补丁应用到 ZCode 桌面版
# 用法:  .\apply-skin.ps1 [-ZCodeDir "D:\ZCode"]
# 原理:  解包 app.asar → 在打包 CSS 末尾追加 miku-skin.css（带标记）
#        → 重打包（原生二进制保持 unpacked）→ 换回
# 说明:  ZCode 自动更新会覆盖 app.asar，更新后重新运行本脚本即可。
#        首次运行会生成 app.asar.miku-backup 备份，可用 restore-skin.ps1 还原。
# ============================================================
param([string]$ZCodeDir = "D:\ZCode")

$ErrorActionPreference = "Stop"
$resources  = Join-Path $ZCodeDir "resources"
$asar       = Join-Path $resources "app.asar"
$backup     = "$asar.miku-backup"
$skinFile   = Join-Path $PSScriptRoot "miku-skin.css"
$mkBegin    = "/* === MIKU-SKIN BEGIN === */"
$mkEnd      = "/* === MIKU-SKIN END === */"

if (-not (Test-Path $asar))      { throw "找不到 $asar，请用 -ZCodeDir 指定 ZCode 安装目录" }
if (-not (Test-Path $skinFile))  { throw "找不到皮肤文件 $skinFile" }
if (Get-Process ZCode -ErrorAction SilentlyContinue) { throw "ZCode 正在运行，请先完全退出再应用皮肤" }
if (-not (Get-Command node -ErrorAction SilentlyContinue)) { throw "需要 Node.js（npx）来重打包 asar" }

# 1. 首次备份
if (-not (Test-Path $backup)) {
    Copy-Item $asar $backup
    Write-Host "已备份原版: $backup"
} else {
    Write-Host "备份已存在，跳过: $backup"
}

# 2. 解包到临时目录
$tmp = Join-Path $env:TEMP "zcode-skin-$(Get-Random)"
New-Item -ItemType Directory -Path $tmp -Force | Out-Null
try {
    Write-Host "解包 app.asar ..."
    npx --yes @electron/asar extract $asar (Join-Path $tmp "app")
    if ($LASTEXITCODE -ne 0) { throw "asar 解包失败" }

    # 3. 定位 index.html 引用的主样式文件
    $indexPath = Join-Path $tmp "app\out\renderer\index.html"
    $html = [IO.File]::ReadAllText($indexPath)
    $cssName = [regex]::Match($html, 'assets/(styles-[\w-]+\.css)').Groups[1].Value
    if (-not $cssName) { throw "未能在 index.html 中定位主样式文件，ZCode 版本可能已变更结构" }
    $cssPath = Join-Path $tmp "app\out\renderer\assets\$cssName"
    Write-Host "目标样式文件: $cssName"

    # 4. 清除旧补丁块（幂等），追加新皮肤
    $css = [IO.File]::ReadAllText($cssPath)
    $css = [regex]::Replace($css, [regex]::Escape($mkBegin) + "(?s).*?" + [regex]::Escape($mkEnd), "")
    $css = $css.TrimEnd() + "`n`n" + $mkBegin + "`n" + [IO.File]::ReadAllText($skinFile) + "`n" + $mkEnd + "`n"
    [IO.File]::WriteAllText($cssPath, $css, [Text.UTF8Encoding]::new($false))

    # 5. 重打包（保持原生二进制 unpacked，与原版一致）
    Write-Host "重打包 app.asar（约 1-2 分钟）..."
    $newAsar = Join-Path $tmp "app-new.asar"
    npx --yes @electron/asar pack (Join-Path $tmp "app") $newAsar --unpack "{*.node,*.dll,*.exe}"
    if ($LASTEXITCODE -ne 0) { throw "asar 重打包失败" }

    # 6. 校验 unpacked 二进制数量与原版一致
    $origCount = (Get-ChildItem "$resources\app.asar.unpacked" -Recurse -File).Count
    $newCount  = (Get-ChildItem "$newAsar.unpacked" -Recurse -File).Count
    if ($newCount -lt $origCount) { throw "重打包后 unpacked 文件数($newCount)少于原版($origCount)，中止" }
    Write-Host "unpacked 校验通过: 原版 $origCount / 新版 $newCount"

    # 7. 换入新版 asar 与 unpacked 目录
    Copy-Item $newAsar $asar -Force
    Remove-Item "$resources\app.asar.unpacked" -Recurse -Force
    Copy-Item "$newAsar.unpacked" "$resources\app.asar.unpacked" -Recurse -Force

    Write-Host ""
    Write-Host "✔ Miku 皮肤应用成功！启动 ZCode 即可看到 Snow Miku（亮）/ Cyber Diva（暗）。" -ForegroundColor Green
    Write-Host "  皮肤跟随 ZCode 设置里的主题切换自动亮暗。" -ForegroundColor Gray
}
finally {
    Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
}
