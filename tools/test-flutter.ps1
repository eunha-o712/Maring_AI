$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$testTemp = Join-Path $projectRoot '.local-temp'
New-Item -ItemType Directory -Path $testTemp -Force | Out-Null
$previousTemp = $env:TEMP
$previousTmp = $env:TMP
Push-Location (Join-Path $projectRoot 'maring-frontend')
try {
    # Flutter's Windows test engine can terminate when its listener path contains
    # non-ASCII characters. Keep this workaround local to this process.
    $env:TEMP = $testTemp
    $env:TMP = $testTemp
    flutter test --no-pub --concurrency=1 @args
    $testExit = $LASTEXITCODE
} finally {
    $env:TEMP = $previousTemp
    $env:TMP = $previousTmp
    Pop-Location
}
exit $testExit
