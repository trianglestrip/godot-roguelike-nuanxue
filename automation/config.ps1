# Dot-source from automation/run_all.ps1 or phases/*/run_test.ps1
$ErrorActionPreference = "Stop"

if ($env:GODOT_BIN) {
    $GodotExe = $env:GODOT_BIN
} else {
    $GodotExe = "D:\project\godot\Godot_v4.6.1-stable_win64_console.exe"
}

function Test-GodotExecutable {
    if (-not (Test-Path -LiteralPath $GodotExe)) {
        Write-Error "Godot not found: $GodotExe`nSet GODOT_BIN to your Godot_v4.x-stable_win64_console.exe"
    }
}

# automation/phases/<phase>/run_test.ps1 -> project root (parent of automation)
function Get-ProjectRootFromPhaseScript {
    param([string]$PhaseScriptRoot)
    $automation = Resolve-Path (Join-Path $PhaseScriptRoot "..\..")
    return (Split-Path $automation.Path)
}
