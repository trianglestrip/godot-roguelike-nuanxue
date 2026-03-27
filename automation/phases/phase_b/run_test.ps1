$ErrorActionPreference = "Stop"
$automationPath = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
. (Join-Path $automationPath "config.ps1")
Test-GodotExecutable
$ProjectRoot = Get-ProjectRootFromPhaseScript $PSScriptRoot
& $GodotExe --path $ProjectRoot --headless "res://automation/phases/phase_b/test_phase_b.tscn"
exit $LASTEXITCODE
