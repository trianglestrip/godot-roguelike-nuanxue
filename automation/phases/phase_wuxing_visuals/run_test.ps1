$ErrorActionPreference = "Stop"
$automationPath = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
. (Join-Path $automationPath "config.ps1")
Test-GodotExecutable
$ProjectRoot = Get-ProjectRootFromPhaseScript $PSScriptRoot
& $GodotExe --path $ProjectRoot --headless "res://automation/phases/phase_wuxing_visuals/test_phase_wuxing_visuals.tscn"
exit $LASTEXITCODE
