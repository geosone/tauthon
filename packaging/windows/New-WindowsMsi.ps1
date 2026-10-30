#Requires -Version 7.0
[CmdletBinding()]
param([Parameter(Mandatory)][string]$BundleDirectory,
      [Parameter(Mandatory)][ValidateSet('x86','x64')][string]$Architecture,
      [Parameter(Mandatory)][string]$ZlibNotice,
      [Parameter(Mandatory)][string]$OutputDirectory)
$ErrorActionPreference='Stop'
$source=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
if((Get-FileHash $ZlibNotice -Algorithm SHA256).Hash.ToLowerInvariant() -ne '045cf777c6c9109b28ddcf3a413c5ca15e39fc513c13ef87bd9a3132a59d1b51'){
    throw 'Use Get-MsiNotices.ps1 to obtain the matching zlib license notice.'
}
$bundle=(Resolve-Path $BundleDirectory).Path
$output=[IO.Path]::GetFullPath($OutputDirectory)
if(Test-Path $output){throw 'Use a fresh output directory.'}
foreach($required in @('tauthon.exe','tauthon28.dll','python2.exe','python2.7.exe','LICENSE','SHA256SUMS','embedding-probe.exe')){
    if(!(Test-Path (Join-Path $bundle $required))){throw "Incomplete bundle: $required"}
}
foreach($line in Get-Content (Join-Path $bundle 'SHA256SUMS')){
    if($line -notmatch '^([0-9a-fA-F]{64})  (.+)$'){throw 'Invalid bundle hash manifest.'}
    $expected=$Matches[1];$relative=$Matches[2].Replace([char]92,[char]47)
    $path=[IO.Path]::GetFullPath((Join-Path $bundle $relative))
    if(!$path.StartsWith($bundle+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)){throw 'Manifest path escapes bundle.'}
    if((Get-FileHash $path -Algorithm SHA256).Hash -ne $expected){throw "Bundle integrity failure: $relative"}
}
$pe=[IO.File]::ReadAllBytes((Join-Path $bundle 'tauthon.exe'))
$offset=[BitConverter]::ToInt32($pe,60)
$machine=[BitConverter]::ToUInt16($pe,$offset+4)
if($machine -ne $(if($Architecture -eq 'x64'){34404}else{332})){throw 'Bundle architecture differs from MSI target.'}
$payload=Join-Path $output 'payload'
New-Item -ItemType Directory -Path $payload | Out-Null
foreach($file in Get-ChildItem $bundle -Recurse -File){
    $relative=[IO.Path]::GetRelativePath($bundle,$file.FullName).Replace([char]92,[char]47)
    # Microsoft CRT is installed from Microsoft's signed redistributable;
    # do not independently repackage its DLLs. Omit build/test-only files.
    if($relative -match '^(Lib/test/|Lib/idlelib/|third-party-notices/pythonx86/)' -or
       $relative -match '\.(pyc|pyo|pdb)$' -or
       $relative -match '^(vcruntime[^/]*\.dll|_testcapi\.pyd|_ctypes_test\.pyd|SHA256SUMS|README\.txt)$'){continue}
    $target=Join-Path $payload $relative
    New-Item -ItemType Directory -Force -Path (Split-Path $target -Parent) | Out-Null
    Copy-Item $file.FullName $target
}
$notices=Join-Path $payload 'third-party-notices'
Copy-Item $ZlibNotice (Join-Path $notices 'zlib-1.2.12.h')
Copy-Item (Join-Path $source 'Modules/expat/COPYING') (Join-Path $notices 'expat-COPYING')
Copy-Item (Join-Path $source 'Modules/_ctypes/libffi_msvc/LICENSE') (Join-Path $notices 'libffi-msvc-LICENSE')
@'
Windows dependencies are selected by PCbuild/python.props and get_externals.bat.
Source repositories and tags:
https://github.com/python/cpython-source-deps/tree/zlib-1.2.12
https://github.com/python/cpython-source-deps/tree/bzip2-1.0.8
https://github.com/python/cpython-source-deps/tree/sqlite-3.35.5.0
https://github.com/python/cpython-source-deps/tree/openssl-1.1.1n
Prebuilt OpenSSL provenance:
https://github.com/python/cpython-bin-deps/tree/openssl-bin-1.1.1n
Expat and the MSVC libffi port are in the accompanying Tauthon source tree.
The pinned zlib notice is from source-deps commit 9c4e58f43af83df1675c98ae7320cd1bae9caf0e.
Microsoft's VC runtime is a separately installed prerequisite and not included.
'@ | Set-Content (Join-Path $notices 'SOURCES.txt')
@'
Tauthon 2.8.5 — Windows test MSI, build 1 (MSI version 2.8.501).
Requires the matching Microsoft Visual C++ 2015–2022 runtime, v14.44 or later.
Official runtime downloads: https://learn.microsoft.com/cpp/windows/latest-supported-vc-redist

Install normally using Windows Installer, or:
msiexec /i tauthon-2.8.5-windows-ARCH-test1.msi INSTALLFOLDER="C:\Tauthon28" /qn /norestart
Default: Program Files\Tauthon28 (Program Files (x86) for x86 on x64 Windows).
Local executables: tauthon.exe, python2.exe, python2.7.exe.
Native library: tauthon28.dll. Do not rename it to python27.dll.
No global Python registration, PATH changes or .py file associations are made.
Uninstall through Apps & Features or msiexec /x with this MSI.
This first test package requires uninstalling an older test MSI before replacement;
automatic major upgrades/downgrades are not yet qualified.

Windows 10 x86/x64 is the test target. Windows 7 and Mystic A49 embedding are
not qualified. Tcl/Tk, Berkeley DB and the full stdlib test suite are omitted.
Upstream Windows dependencies include old OpenSSL 1.1.1n. This is a functional
test build, not a current security-supported runtime release.
Licenses are in LICENSE and third-party-notices. Source, build scripts and
dependency provenance: https://github.com/geosone/tauthon/tree/windows/build-msvc
A matching source archive is provided beside the public MSI downloads.
'@.Replace('windows-ARCH-',"windows-$Architecture-") | Set-Content (Join-Path $payload 'README-MSI.txt')
$xml=[Xml.XmlDocument]::new();$ns='http://schemas.microsoft.com/wix/2006/wi'
function Element($Parent,[string]$Name,[hashtable]$Attributes){
    $node=$xml.CreateElement($Name,$ns)
    foreach($key in $Attributes.Keys){$node.SetAttribute($key,[string]$Attributes[$key])}
    $null=$Parent.AppendChild($node)
    return ,$node
}
function Hash([string]$Value){
    $algorithm=[Security.Cryptography.SHA256]::Create()
    try {return ([BitConverter]::ToString($algorithm.ComputeHash([Text.Encoding]::UTF8.GetBytes($Value)))).Replace('-','').ToLowerInvariant()}
    finally {$algorithm.Dispose()}
}
function GuidFor([string]$Value){
    $h=Hash $Value
    return ([guid]($h.Substring(0,8)+'-'+$h.Substring(8,4)+'-5'+$h.Substring(13,3)+'-8'+$h.Substring(17,3)+'-'+$h.Substring(20,12))).ToString().ToUpperInvariant()
}
$wix=Element $xml 'Wix' @{}
$product=Element $wix 'Product' @{Id=(GuidFor "tauthon-test1/$Architecture");Name="Tauthon 2.8.5 test build 1 ($Architecture)";Language='1033';Version='2.8.501';Manufacturer='Tauthon contributors';UpgradeCode=(GuidFor "tauthon-upgrade/$Architecture")}
$null=Element $product 'Package' @{InstallerVersion='500';Compressed='yes';InstallScope='perMachine'}
$null=Element $product 'Media' @{Id='1';Cabinet='tauthon.cab';EmbedCab='yes'}
$null=Element $product 'Property' @{Id='ARPURLINFOABOUT';Value='https://github.com/geosone/tauthon'}
$crt=Element $product 'Property' @{Id='VC_CRT_VERSION'}
$searchAttributes=@{Id='RuntimeVersion';Root='HKLM';Key="SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\$Architecture";Name='Version';Type='raw'}
if($Architecture -eq 'x64'){$searchAttributes.Win64='yes'}
$null=Element $crt 'RegistrySearch' $searchAttributes
$condition=Element $product 'Condition' @{Message='Install the matching Microsoft Visual C++ 2015-2022 Redistributable (v14.44 or newer) first. See README-MSI.txt / download notes.'}
$condition.InnerText='Installed OR (VC_CRT_VERSION AND VC_CRT_VERSION >= "v14.44.0.0")'
$root=Element $product 'Directory' @{Id='TARGETDIR';Name='SourceDir'}
$programFiles=Element $root 'Directory' @{Id=$(if($Architecture -eq 'x64'){'ProgramFiles64Folder'}else{'ProgramFilesFolder'})}
$install=Element $programFiles 'Directory' @{Id='INSTALLFOLDER';Name='Tauthon28'}
$feature=Element $product 'Feature' @{Id='Runtime';Title='Tauthon runtime and local Python 2 aliases';Level='1'}
$directories=@{''=$install}
$removeRows=[Collections.Generic.List[string]]::new()
foreach($file in Get-ChildItem $payload -Recurse -File | Sort-Object FullName){
    $relative=[IO.Path]::GetRelativePath($payload,$file.FullName).Replace([char]92,[char]47)
    $parts=$relative.Split('/');$key=''
    for($i=0;$i -lt $parts.Length-1;$i++){
        $parent=$key;$key=($key+'/'+$parts[$i]).TrimStart('/')
        if(!$directories.ContainsKey($key)){$directories[$key]=Element $directories[$parent] 'Directory' @{Id=('D'+(Hash $key).Substring(0,24));Name=$parts[$i]}}
    }
    $id=(Hash $relative).Substring(0,24)
    $attributes=@{Id=('C'+$id);Guid=(GuidFor "$Architecture/$relative")}
    if($Architecture -eq 'x64'){$attributes.Win64='yes'}
    $component=Element $directories[$key] 'Component' $attributes
    $null=Element $component 'File' @{Id=('F'+$id);Source=$file.FullName;KeyPath='yes'}
    if($file.Extension -eq '.py'){
        foreach($extension in @('pyc','pyo')){
            $name='P'+$id.Substring(0,7)+'.'+$extension+'|'+$file.BaseName+'.'+$extension
            $removeRows.Add(('R'+$extension+$id)+"`tC$id`t$name`t"+$directories[$key].GetAttribute('Id')+"`t2")
        }
    }
    $null=Element $feature 'ComponentRef' @{Id=('C'+$id)}
}
$wxs=Join-Path $output 'tauthon.wxs';$xml.Save($wxs)
$msi=Join-Path $output "tauthon-2.8.5-windows-$Architecture-test1.msi"
& wixl -a $Architecture -o $msi $wxs
if($LASTEXITCODE -ne 0){throw 'WiX MSI compilation failed.'}
# wixl 0.106 does not implement the WiX RemoveFile element. Import the native
# Windows Installer table through Finalize-WindowsMsi.ps1 on Windows.
# RemoveFiles is already in the standard sequence. Linux msibuild import
# produced error 2211 on the real Windows Installer engine.
$removeTable=Join-Path $output 'RemoveFile.idt'
@("FileKey`tComponent_`tFileName`tDirProperty`tInstallMode","s72`ts72`tL255`ts72`ti2","RemoveFile`tFileKey") + @($removeRows) |
    Set-Content -Encoding UTF8 $removeTable
Write-Warning 'Finalize with Finalize-WindowsMsi.ps1 on Windows before distributing this MSI.'
[IO.File]::WriteAllText("$msi.sha256",(Get-FileHash $msi -Algorithm SHA256).Hash.ToLowerInvariant()+"  $([IO.Path]::GetFileName($msi))`n")
Write-Output $msi
