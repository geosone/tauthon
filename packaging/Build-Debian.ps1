[CmdletBinding()]
param(
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../../tauthon-packages'),
    [ValidateRange(1, 32)][int]$Jobs = 2,
    [ValidateSet("bookworm", "trixie")][string]$Suite = "bookworm"
)
$ErrorActionPreference = 'Stop'
$repository = Split-Path $PSScriptRoot -Parent
if (-not $IsLinux) { throw 'This builder currently requires a Linux Docker host.' }
function Invoke-Checked {
    param([string]$Program, [string[]]$Arguments)
    & $Program @Arguments
    if ($LASTEXITCODE -ne 0) { throw "$Program failed with exit code $LASTEXITCODE" }
}
$status = & git -C $repository status --porcelain
if ($LASTEXITCODE -ne 0 -or $status) { throw 'Commit packaging changes before building a traceable source snapshot.' }
$commit = & git -C $repository rev-parse HEAD
if ($LASTEXITCODE -ne 0) { throw 'Cannot determine source commit.' }
$OutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$temporary = Join-Path ([IO.Path]::GetTempPath()) ('tauthon-build-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $temporary | Out-Null
try {
    $archive = Join-Path $temporary 'source.tar'
    $source = Join-Path $temporary 'source'
    New-Item -ItemType Directory -Path $source | Out-Null
    Invoke-Checked git @('-C', $repository, 'archive', '--format=tar', "--output=$archive", $commit)
    Invoke-Checked tar @('-xf', $archive, '-C', $source)
    Invoke-Checked docker @('build', '-f', (Join-Path $source "packaging/$Suite.Dockerfile"), '-t', "tauthon-build:$Suite", (Join-Path $source 'packaging'))
    Invoke-Checked docker @('run', '--rm', '--network=none', '--mount', "type=bind,src=$source,dst=/source,readonly", '--mount', "type=bind,src=$OutputDirectory,dst=/out", '-e', "DEB_BUILD_OPTIONS=parallel=$Jobs", "tauthon-build:$Suite", 'sh', '-ec', 'mkdir /work; cp -a /source /work/tauthon; cd /work/tauthon; dpkg-buildpackage -b -us -uc; cp /work/*.deb /work/*.buildinfo /work/*.changes /out/')
    $image = & docker image inspect "tauthon-build:$Suite" --format '{{.Id}}'
    if ($LASTEXITCODE -ne 0) { throw 'Cannot determine build image.' }
    $archiveHash = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant()
    [IO.File]::WriteAllLines((Join-Path $OutputDirectory 'build.ini'), @(
        '[Build]', 'Status=Built', "SourceCommit=$commit", "SourceArchiveSHA256=$archiveHash",
        "ContainerImage=$image", "Utc=$([DateTime]::UtcNow.ToString('o'))"
    ))
    Write-Output "Packages: $OutputDirectory"
}
finally {
    Remove-Item -LiteralPath $temporary -Recurse -Force
}
