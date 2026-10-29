#Requires -Version 7.0
[CmdletBinding()]
param([ValidateSet('x64','Win32')][string]$Architecture='x64',
      [ValidateSet('v142','v143')][string]$Toolset='v143')
$ErrorActionPreference='Stop'
if(-not $IsWindows){throw 'This build uses native MSVC on Windows.'}
$root=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$previousToolset=$env:PlatformToolset
Push-Location $root
try {
    # MSBuild imports environment properties. This avoids build.bat splitting
    # an equals-containing property argument through its legacy CMD parser.
    $env:PlatformToolset=$Toolset
    & (Join-Path $root 'PCbuild/build.bat') -e -p $Architecture --no-tkinter --no-bsddb
    if($LASTEXITCODE -ne 0){throw "MSVC build failed ($LASTEXITCODE)."}
    $directory=if($Architecture -eq 'x64'){'amd64'}else{'win32'}
    $exe=Join-Path $root "PCbuild/$directory/tauthon.exe"
    & $exe -E -c 'import sys, json, sqlite3, ssl, hashlib, zlib, bz2, ctypes, socket; assert sys.version_info[:2] == (2, 8); assert sqlite3.connect(":memory:").execute("select 42").fetchone()[0] == 42; assert ssl.create_default_context().verify_mode == ssl.CERT_REQUIRED; print("PASS Windows interpreter, modules, SQLite and SSL context"); print(sys.version); print(ssl.OPENSSL_VERSION)'
    if($LASTEXITCODE -ne 0){throw 'Windows runtime smoke test failed.'}
} finally {$env:PlatformToolset=$previousToolset; Pop-Location}
