#Requires -Version 5.1
<#
.SYNOPSIS
  方案三（Full Rework）：备份并移除旧游戏代码目录，写入最小可运行桩（EventBus + 空主场景）。
.DESCRIPTION
  默认会移动以下目录到 _plan3_archive/<时间戳>/：
    - src, scenes, automation
  可选：-IncludeArtGenerators 同时归档 art 下的 .gd/.py 生成脚本。
  执行前请提交或 stash 未保存改动；建议先使用 -WhatIf 预览。
.PARAMETER WhatIf
  仅打印将执行的操作，不修改磁盘。
.PARAMETER IncludeArtGenerators
  将 art 目录内 *.gd、*.py 移入同一归档（不删除 art 下其他资源若有）。
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [switch] $IncludeArtGenerators
)

$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

$stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$Archive = Join-Path $Root "_plan3_archive" $stamp
$DirsToMove = @("src", "scenes", "automation")

function Write-Step($msg) { Write-Host "[plan3-clean] $msg" -ForegroundColor Cyan }

if (-not (Test-Path (Join-Path $Root "project.godot"))) {
    Write-Error "未在仓库根目录找到 project.godot：$Root"
}

New-Item -ItemType Directory -Path $Archive -Force | Out-Null
Write-Step "归档目录：$Archive"

# 备份 project.godot
$pg = Join-Path $Root "project.godot"
Copy-Item -LiteralPath $pg -Destination (Join-Path $Archive "project.godot.bak") -Force

foreach ($d in $DirsToMove) {
    $p = Join-Path $Root $d
    if (Test-Path $p) {
        if ($PSCmdlet.ShouldProcess($p, "移动到归档")) {
            Move-Item -LiteralPath $p -Destination (Join-Path $Archive $d)
            Write-Step "已移动：$d"
        }
    } else {
        Write-Step "跳过（不存在）：$d"
    }
}

if ($IncludeArtGenerators) {
    $art = Join-Path $Root "art"
    if (Test-Path $art) {
        $artDest = Join-Path $Archive "art_generators"
        New-Item -ItemType Directory -Path $artDest -Force | Out-Null
        Get-ChildItem -Path $art -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Extension -in ".gd", ".py" } | ForEach-Object {
            if ($PSCmdlet.ShouldProcess($_.FullName, "移动到 art_generators")) {
                Move-Item -LiteralPath $_.FullName -Destination $artDest
                Write-Step "已移动生成脚本：$($_.Name)"
            }
        }
    }
}

# 写入最小桩
$bootstrapSrc = Join-Path $Root "scripts\plan3\bootstrap"
$core = Join-Path $Root "src\core"
$scenesBoot = Join-Path $Root "scenes\bootstrap"

if ($PSCmdlet.ShouldProcess($Root, "写入最小桩 src/core、scenes/bootstrap")) {
    New-Item -ItemType Directory -Path $core -Force | Out-Null
    New-Item -ItemType Directory -Path $scenesBoot -Force | Out-Null
    Copy-Item -Force (Join-Path $bootstrapSrc "event_bus.gd") (Join-Path $core "event_bus.gd")
    Copy-Item -Force (Join-Path $bootstrapSrc "main.tscn") (Join-Path $scenesBoot "main.tscn")
    Write-Step "已写入：src/core/event_bus.gd、scenes/bootstrap/main.tscn"
}

# 覆盖 project.godot 中 application 与 autoload（保留其余段落）
$minimalPg = Join-Path $bootstrapSrc "project.godot.snippet"
if (-not (Test-Path $minimalPg)) {
    Write-Error "缺少模板：$minimalPg"
}

if ($PSCmdlet.ShouldProcess($pg, "合并 project.godot 片段")) {
    $original = Get-Content -LiteralPath $pg -Raw -Encoding UTF8
    $snippet = Get-Content -LiteralPath $minimalPg -Raw -Encoding UTF8

    # 从 [application] 到 [debug] 之前（含原 autoload），保留 [debug] 及后续段落
    $pattern = '(?s)\[application\].*?(?=\n\[debug\])'
    if ($original -notmatch '\[application\]') {
        Write-Error "project.godot 中未找到 [application] 段，请手动合并 scripts/plan3/bootstrap/project.godot.snippet"
    }
    $merged = [regex]::Replace($original, $pattern, $snippet.TrimEnd() + "`n`n", 1)
    $utf8 = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($pg, $merged, $utf8)
    Write-Step "已更新 project.godot（application + autoload）"
}

Write-Step "完成。请用 Godot 打开工程验证主场景：scenes/bootstrap/main.tscn"
Write-Host "备份与归档位置：$Archive" -ForegroundColor Green
