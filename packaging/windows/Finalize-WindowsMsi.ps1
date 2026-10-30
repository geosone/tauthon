#Requires -Version 5.1
[CmdletBinding()]
param([Parameter(Mandatory)][string]$MsiPath,[Parameter(Mandatory)][string]$TableDirectory)
$ErrorActionPreference='Stop'
$installer=New-Object -ComObject WindowsInstaller.Installer
$database=$installer.OpenDatabase((Resolve-Path $MsiPath).Path,1)
$database.Import((Resolve-Path $TableDirectory).Path,'RemoveFile.idt')
$database.Commit()
[Runtime.InteropServices.Marshal]::FinalReleaseComObject($database) | Out-Null
[Runtime.InteropServices.Marshal]::FinalReleaseComObject($installer) | Out-Null
(Get-FileHash $MsiPath -Algorithm SHA256).Hash.ToLowerInvariant()
