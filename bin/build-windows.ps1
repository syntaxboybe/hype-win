param(
    [string]$QtBin = $env:HYPE_QT_BIN
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

$msysBin = 'C:\msys64\ucrt64\bin'
if ((Test-Path $msysBin) -and ($env:PATH -notlike "*$msysBin*")) {
    $env:PATH = "$msysBin;$env:PATH"
}
$build = Join-Path $root 'build'

function Find-Executable([string[]]$Names) {
    foreach ($name in $Names) {
        $command = Get-Command $name -ErrorAction SilentlyContinue
        if ($command) { return $command.Source }
    }
    return $null
}

if (-not $QtBin) {
    $qmake = Find-Executable @('qmake6.exe', 'qmake.exe')
} else {
    $qmake = Join-Path $QtBin 'qmake6.exe'
    if (-not (Test-Path $qmake)) { $qmake = Join-Path $QtBin 'qmake.exe' }
}
if (-not $qmake -or -not (Test-Path $qmake)) {
    throw 'Qt 6.9+ qmake was not found. Set HYPE_QT_BIN to the Qt bin directory.'
}

$qtVersion = (& $qmake -query QT_VERSION).Trim()
$version = [Version]$qtVersion
if ($version -lt [Version]'6.9') {
    throw "Qt 6.9+ is required; $qmake reports Qt $qtVersion."
}

$make = Find-Executable @('mingw32-make.exe', 'nmake.exe')
if (-not $make) {
    throw 'No mingw32-make.exe or nmake.exe was found on PATH.'
}

New-Item -ItemType Directory -Force $build | Out-Null
Push-Location $build
try {
    & $qmake (Join-Path $root 'hype.pro')
    if ($LASTEXITCODE) { throw "qmake failed with exit code $LASTEXITCODE." }
    if ((Split-Path $make -Leaf) -ieq 'mingw32-make.exe') {
        & $make "-j$([Environment]::ProcessorCount)"
    } else {
        & $make
    }
    if ($LASTEXITCODE) { throw "Build failed with exit code $LASTEXITCODE." }
} finally {
    Pop-Location
}

$binary = Join-Path $build 'release/hype.exe'
if (-not (Test-Path $binary)) {
    $binary = Join-Path $build 'hype.exe'
}
if (-not (Test-Path $binary)) {
    throw 'The build completed without producing hype.exe.'
}


$deploy = Join-Path (Split-Path $qmake) 'windeployqt.exe'
if (Test-Path $deploy) {
    & $deploy '--qmldir' (Join-Path $root 'src') $binary
    if ($LASTEXITCODE) { throw "windeployqt failed with exit code $LASTEXITCODE." }
}
$runtimeBins = @($msysBin, (Split-Path $qmake)) | Select-Object -Unique
$msysRoot = Split-Path (Split-Path $msysBin)
$ldd = Join-Path $msysRoot 'usr/bin/ldd.exe'
$runtimeQueue = [System.Collections.Generic.Queue[string]]::new()
$runtimeSeen = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
$runtimeQueue.Enqueue($binary)
Get-ChildItem (Split-Path $binary) -Filter '*.dll' -Recurse |
    ForEach-Object { $runtimeQueue.Enqueue($_.FullName) }
while ($runtimeQueue.Count -gt 0) {
    $current = $runtimeQueue.Dequeue()
    if (-not (Test-Path $ldd)) { continue }
    $dependencies = & $ldd $current 2>$null
    foreach ($line in $dependencies) {
        if ($line -notmatch '=>\s+/((?:ucrt64|mingw64)/bin)/([^\s]+\.dll)') { continue }
        $runtimeFile = $matches[2]
        if (-not $runtimeSeen.Add($runtimeFile)) { continue }
        $runtimeSource = $runtimeBins |
            ForEach-Object { Join-Path $_ $runtimeFile } |
            Where-Object { Test-Path $_ } |
            Select-Object -First 1
        if (-not $runtimeSource) { continue }
        $runtimeDestination = Join-Path (Split-Path $binary) $runtimeFile
        Copy-Item $runtimeSource $runtimeDestination -Force
        $runtimeQueue.Enqueue($runtimeDestination)
    }
}

$qtPlugins = (& $qmake -query QT_INSTALL_PLUGINS).Trim()
$offscreen = Join-Path $qtPlugins 'platforms/qoffscreen.dll'
if (Test-Path $offscreen) {
    $platforms = Join-Path (Split-Path $binary) 'platforms'
    New-Item -ItemType Directory -Force $platforms | Out-Null
    Copy-Item $offscreen (Join-Path $platforms 'qoffscreen.dll') -Force
}


$qtQml = (& $qmake -query QT_INSTALL_QML).Trim()
$controlsPlugin = Join-Path $qtQml 'QtQuick/Controls/qtquickcontrols2plugin.dll'
if (Test-Path $controlsPlugin) {
    $controls = Join-Path (Split-Path $binary) 'qml/QtQuick/Controls'
    New-Item -ItemType Directory -Force $controls | Out-Null
    Copy-Item $controlsPlugin (Join-Path $controls 'qtquickcontrols2plugin.dll') -Force
}

$qtConf = Join-Path (Split-Path $binary) 'qt.conf'
@'
[Paths]
Prefix=.
Plugins=.
Qml2Imports=qml
'@ | Set-Content -Path $qtConf -Encoding ascii -NoNewline
Write-Host "Built $binary"
Write-Host "Run it with: $binary open $((Join-Path $root 'examples/welcome.md'))"
