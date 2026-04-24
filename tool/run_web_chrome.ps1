param(
  [int]$Port = 62225
)

$projectRoot = Split-Path -Parent $PSScriptRoot
$dart = 'C:\Users\Aryan\Downloads\flutter_windows_3.35.2-stable\flutter\bin\cache\dart-sdk\bin\dart.exe'
$launchCommand = "Set-Location '$projectRoot'; flutter build web; & '$dart' run tool/serve_web_build.dart --port $Port"

Start-Process powershell -ArgumentList '-NoExit', '-Command', $launchCommand

$serverReady = $false
for ($i = 0; $i -lt 60; $i++) {
  try {
    Invoke-WebRequest "http://localhost:$Port" -UseBasicParsing | Out-Null
    $serverReady = $true
    break
  } catch {
    Start-Sleep -Seconds 1
  }
}

if (-not $serverReady) {
  Write-Error "The Flutter web server did not become ready on http://localhost:$Port"
  exit 1
}

Start-Process "http://localhost:$Port"
