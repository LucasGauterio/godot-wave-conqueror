if (-not $env:GODOT_PATH) {
    Write-Host "Error: GODOT_PATH environment variable is not set." -ForegroundColor Red
    Write-Host "Please set it to your Godot executable path." -ForegroundColor Yellow
    exit 1
}

if (!(Test-Path $env:GODOT_PATH)) {
    Write-Host "Godot executable not found at $env:GODOT_PATH" -ForegroundColor Red
    exit 1
}

Write-Host "Opening Wave Conqueror in Editor..." -ForegroundColor Cyan
& $env:GODOT_PATH -e
