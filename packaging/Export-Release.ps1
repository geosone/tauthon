[CmdletBinding()]
param(
    [string]$PackageDirectory = (Join-Path $PSScriptRoot '../../tauthon-packages'),
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../../tauthon-release')
)
$ErrorActionPreference = 'Stop'
$PackageDirectory = (Resolve-Path $PackageDirectory).Path
$OutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
$name = 'tauthon-2.8.5-git20260331-trixie-amd64'
$stage = Join-Path $OutputDirectory $name
$archive = Join-Path $OutputDirectory "$name.tar.gz"
if ((Test-Path $stage) -or (Test-Path $archive)) { throw 'Use a fresh release output directory.' }
New-Item -ItemType Directory -Force -Path $stage | Out-Null
$packages = @(Get-ChildItem -LiteralPath $PackageDirectory -Filter '*.deb')
if ($packages.Count -ne 6) { throw 'Expected four runtime/development/compatibility packages and two debug packages.' }
$packages | Copy-Item -Destination $stage
Get-ChildItem -LiteralPath $PackageDirectory -File | Where-Object { $_.Extension -in '.buildinfo', '.changes', '.ini' } | Copy-Item -Destination $stage
foreach ($file in @('README.md', 'debian-patch-review.md', 'test-results-trixie.md')) {
    Copy-Item (Join-Path $PSScriptRoot $file) $stage
}
Copy-Item (Join-Path (Split-Path $PSScriptRoot -Parent) 'LICENSE') $stage
$hashes = @(Get-ChildItem -LiteralPath $stage -File | Sort-Object Name | ForEach-Object {
    "$((Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant())  $($_.Name)"
})
[IO.File]::WriteAllLines((Join-Path $stage 'SHA256SUMS'), $hashes)
& tar -czf $archive -C $OutputDirectory $name
if ($LASTEXITCODE -ne 0) { throw 'Cannot create release archive.' }
$hash = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant()
[IO.File]::WriteAllText("$archive.sha256", "$hash  $name.tar.gz`n")
Write-Output $archive
Write-Output "$archive.sha256"
