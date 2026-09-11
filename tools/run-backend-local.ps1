[CmdletBinding()]
param(
    [switch]$SkipBuild,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ApplicationArgs
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$backendRoot = Join-Path $projectRoot 'maring-backend'
$jarPath = Join-Path $backendRoot 'target\maring-api-0.0.1-SNAPSHOT.jar'

Push-Location $projectRoot
try {
    if (-not $SkipBuild) {
        mvn -B -pl maring-backend package '-DskipTests'
        if ($LASTEXITCODE -ne 0) {
            throw "Backend package failed with exit code $LASTEXITCODE"
        }
    }

} finally {
    Pop-Location
}

if (-not (Test-Path -LiteralPath $jarPath)) {
    throw "Executable JAR not found: $jarPath"
}

Push-Location $backendRoot
try {
    java -jar $jarPath '--spring.profiles.active=local' @ApplicationArgs
    $javaExit = $LASTEXITCODE
} finally {
    Pop-Location
}

exit $javaExit
