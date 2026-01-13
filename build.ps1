if (-not $env:GODOT_PATH) {
    Write-Host "Error: GODOT_PATH environment variable is not set." -ForegroundColor Red
    Write-Host "Please set it to your Godot executable path." -ForegroundColor Yellow
    exit 1
}

if (!(Test-Path $env:GODOT_PATH)) {
    Write-Host "Godot executable not found at $env:GODOT_PATH" -ForegroundColor Red
    exit 1
}

$buildDir = "build"
if (!(Test-Path $buildDir)) {
    New-Item -ItemType Directory -Path $buildDir | Out-Null
}

Write-Host "Compiling (Exporting) Wave Conqueror for Windows..." -ForegroundColor Cyan
# Note: This requires an export preset named "Windows Desktop" to be defined in export_presets.cfg
& $env:GODOT_PATH --export-release "Windows Desktop" "$buildDir/WaveConqueror.exe"
