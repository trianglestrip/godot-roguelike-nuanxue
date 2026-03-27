$ErrorActionPreference = "Stop"
. "$PSScriptRoot\config.ps1"
Test-GodotExecutable

$phases = @(
    "phase_a",
    "phase_b",
    "phase_c",
    "phase_d",
    "phase_e",
    "phase_wuxing_visuals",
    "phase_wuxing_combat",
    "phase_integration"
)

foreach ($p in $phases) {
    $runner = Join-Path $PSScriptRoot "phases\$p\run_test.ps1"
    if (-not (Test-Path -LiteralPath $runner)) {
        Write-Error "Missing: $runner"
    }
    Write-Host "==== Running $p ====" -ForegroundColor Cyan
    & $runner
    if ($LASTEXITCODE -ne 0) {
        Write-Host "FAILED: $p (exit $LASTEXITCODE)" -ForegroundColor Red
        exit $LASTEXITCODE
    }
}

Write-Host "All phases passed." -ForegroundColor Green
exit 0
