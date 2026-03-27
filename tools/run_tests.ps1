#Requires -Version 5.1
<#
.SYNOPSIS
  无界面运行自动化测试（阶段 0 / A / B）。
.PARAMETER Phase
  all | 0 | a | b
.PARAMETER GodotExe
  默认：D:\project\godot\Godot_v4.6.1-stable_win64_console.exe，也可用环境变量 $env:GODOT
#>
param(
    [ValidateSet("all", "0", "a", "b")]
    [string] $Phase = "all",
    [string] $GodotExe = ""
)

$ErrorActionPreference = "Stop"
if ([string]::IsNullOrWhiteSpace($GodotExe)) {
    if (-not [string]::IsNullOrWhiteSpace($env:GODOT)) {
        $GodotExe = $env:GODOT
    } else {
        $GodotExe = "D:\project\godot\Godot_v4.6.1-stable_win64_console.exe"
    }
}

if (-not (Test-Path -LiteralPath $GodotExe)) {
    Write-Error "Godot 可执行文件不存在: $GodotExe"
}

$ProjectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $ProjectRoot

$extra = @()
if ($Phase -ne "all") {
    $extra = @("--", "--test-phase=$Phase")
}

& $GodotExe --headless --path $ProjectRoot -s "res://tests/automation/run_all.gd" @extra
exit $LASTEXITCODE
