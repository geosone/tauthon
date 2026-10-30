#Requires -Version 7.0
param([Parameter(Mandatory)][string]$OutputFile)
$ErrorActionPreference='Stop'
$hash='045cf777c6c9109b28ddcf3a413c5ca15e39fc513c13ef87bd9a3132a59d1b51'
if(!(Test-Path $OutputFile)){
    New-Item -ItemType Directory -Force -Path (Split-Path ([IO.Path]::GetFullPath($OutputFile)) -Parent) | Out-Null
    Invoke-WebRequest 'https://raw.githubusercontent.com/python/cpython-source-deps/9c4e58f43af83df1675c98ae7320cd1bae9caf0e/zlib.h' -OutFile $OutputFile
}
if((Get-FileHash $OutputFile -Algorithm SHA256).Hash.ToLowerInvariant() -ne $hash){throw 'Unexpected zlib notice contents.'}
Write-Output $OutputFile
