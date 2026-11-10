param(
    [string]$QtBin = $env:HYPE_QT_BIN,
    [string]$InnoPath = $env:HYPE_INNO_PATH,
    [switch]$SkipBuild
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

if (-not $SkipBuild) {
    $buildScript = Join-Path $PSScriptRoot 'build-windows.ps1'
    if ($QtBin) {
        & $buildScript -QtBin $QtBin
    } else {
        & $buildScript
    }
    if ($LASTEXITCODE) { throw "Windows build failed with exit code $LASTEXITCODE." }
}

$compilerCandidates = @()
if ($InnoPath) { $compilerCandidates += $InnoPath }
$compilerCandidates += @(
    (Get-Command iscc.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -First 1),
    (Join-Path $env:LOCALAPPDATA 'Programs\Inno Setup 6\ISCC.exe'),
    (Join-Path ${env:ProgramFiles(x86)} 'Inno Setup 6\ISCC.exe'),
    (Join-Path $env:ProgramFiles 'Inno Setup 6\ISCC.exe')
)
$compiler = $compilerCandidates |
    Where-Object { $_ -and (Test-Path $_) } |
    Select-Object -First 1
if (-not $compiler) {
    throw 'Inno Setup 6 was not found. Install JRSoftware.InnoSetup or set HYPE_INNO_PATH to ISCC.exe.'
}

$installerScript = Join-Path $root 'installer/hype.iss'
$dist = Join-Path $root 'dist'
New-Item -ItemType Directory -Force $dist | Out-Null
& $compiler $installerScript
if ($LASTEXITCODE) { throw "Inno Setup failed with exit code $LASTEXITCODE." }

$installer = Join-Path $dist 'hype-setup.exe'
if (-not (Test-Path $installer)) {
    throw "Inno Setup completed without producing $installer."
}
Write-Host "Created $installer"
