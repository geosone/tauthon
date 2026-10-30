#Requires -Version 7.0
[CmdletBinding()]
param([Parameter(Mandatory)][string]$OutputDirectory,
      [Parameter(Mandatory)][string]$EmbeddingProbe,
      [ValidateSet('x64','Win32')][string]$Architecture='x64')
$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$output=[IO.Path]::GetFullPath($OutputDirectory)
if(Test-Path $output){throw 'Use a new output directory.'}
New-Item -ItemType Directory -Path $output | Out-Null
$directory=if($Architecture -eq 'x64'){'amd64'}else{'win32'}
$build=Join-Path $root "PCbuild/$directory"
foreach($name in @('tauthon.exe','tauthonw.exe','tauthon28.dll')){
    Copy-Item (Join-Path $build $name) $output
}
Get-ChildItem $build -File | Where-Object {$_.Extension -in '.pyd','.dll'} | Copy-Item -Destination $output
Copy-Item (Join-Path $root 'Lib') (Join-Path $output 'Lib') -Recurse
Copy-Item (Join-Path $root 'LICENSE') $output
Copy-Item $EmbeddingProbe (Join-Path $output 'embedding-probe.exe')
$externals=Join-Path $root 'externals'
Get-ChildItem $externals -Recurse -File | Where-Object {$_.Name -match 'LICENSE|COPYING|NOTICE'} | ForEach-Object {
    $destination=Join-Path $output ('third-party-notices/'+[IO.Path]::GetRelativePath($externals,$_.FullName))
    New-Item -ItemType Directory -Force -Path (Split-Path $destination -Parent) | Out-Null
    Copy-Item $_.FullName $destination
}
# Local executable aliases only: never impersonate python27.dll or register
# this interpreter as Python 3/the global default.
Copy-Item (Join-Path $output 'tauthon.exe') (Join-Path $output 'python2.exe')
Copy-Item (Join-Path $output 'tauthon.exe') (Join-Path $output 'python2.7.exe')
@'
Experimental Windows Tauthon test bundle (see build.ini for architecture).
MSVC build; real Mystic integration and Windows 7 compatibility are not qualified.
Upstream PCbuild currently selects old third-party dependencies, including
OpenSSL 1.1.1n. This is not a supported security release or public installer.
The native DLL is tauthon28.dll, not python27.dll. Existing binary extensions
require explicit compatibility tests or rebuilding. No registry or PATH change.
'@ | Set-Content (Join-Path $output 'README.txt')
@('[Build]',"Architecture=$Architecture",'TargetOS=Windows10','LegacyWindows7=NotQualified') | Set-Content (Join-Path $output 'build.ini')
if($IsWindows){
    Push-Location $env:TEMP
    try {
        foreach($name in @('tauthon.exe','python2.exe','python2.7.exe')){
            & (Join-Path $output $name) -B -E -c 'import os,sys,json,sqlite3,ssl,ctypes; assert sys.version_info[:2] == (2,8); assert os.path.normcase(sys.prefix) == os.path.normcase(sys.argv[1]); print("PASS relocated executable and local prefix")' $output
            if($LASTEXITCODE -ne 0){throw "Relocation test failed for $name."}
        }
        & (Join-Path $output 'embedding-probe.exe')
        if($LASTEXITCODE -ne 0){throw 'Direct DLL embedding test failed.'}
    } finally {Pop-Location}
}
$hashes=Get-ChildItem $output -Recurse -File | Sort-Object FullName | ForEach-Object {
    (Get-FileHash $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()+'  '+[IO.Path]::GetRelativePath($output,$_.FullName)
}
$hashes | Set-Content (Join-Path $output 'SHA256SUMS')
