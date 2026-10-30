#Requires -Version 5.1
[CmdletBinding()]
param([Parameter(Mandatory)][string]$MsiPath,
      [Parameter(Mandatory)][ValidatePattern('^[a-fA-F0-9]{64}$')][string]$ExpectedSHA256,
      [Parameter(Mandatory)][ValidateSet('x86','x64')][string]$Architecture,
      [Parameter(Mandatory)][string]$ResultDirectory)
$ErrorActionPreference='Stop';$ProgressPreference='SilentlyContinue'
if((Get-FileHash $MsiPath -Algorithm SHA256).Hash -ne $ExpectedSHA256){throw 'MSI checksum mismatch.'}
if(Test-Path $ResultDirectory){throw 'Use a fresh result directory.'}
$base=$env:ProgramFiles
if($Architecture -eq 'x86' -and [Environment]::Is64BitOperatingSystem){$base=${env:ProgramFiles(x86)}}
$installedPath=Join-Path $base 'Tauthon28'
if(Test-Path $installedPath){throw 'Refusing to overwrite an existing Tauthon installation.'}
New-Item -ItemType Directory -Path $ResultDirectory | Out-Null
$beforeMachine=[Environment]::GetEnvironmentVariable('PATH','Machine')
$beforeUser=[Environment]::GetEnvironmentVariable('PATH','User')
function PythonRegistration {
    @('HKLM:\SOFTWARE\Python','HKLM:\SOFTWARE\WOW6432Node\Python','HKCU:\SOFTWARE\Python') | ForEach-Object {
        if(Test-Path $_){Get-ChildItem $_ -Recurse | Select-Object -ExpandProperty Name}
    }
}
$beforePython=@(PythonRegistration) -join "`n"
function Installer([string]$Operation,[string]$Log){
    $logPath=Join-Path $ResultDirectory $Log
    $process=Start-Process msiexec.exe -ArgumentList "$Operation `"$MsiPath`" /qn /norestart /L*v `"$logPath`"" -Wait -PassThru
    if($process.ExitCode -ne 0){throw "MSI returned $($process.ExitCode); see $logPath"}
}
$probe=Join-Path $ResultDirectory 'installed-runtime-test.py'
@'
import sys, os, ssl, sqlite3, ctypes, struct, json
assert sys.version_info[:2] == (2,8)
assert struct.calcsize('P') * 8 == int(sys.argv[1])
assert os.path.normcase(sys.prefix) == os.path.normcase(sys.argv[2])
assert sqlite3.connect(':memory:').execute('select 42').fetchone()[0] == 42
assert ssl.create_default_context().verify_mode == ssl.CERT_REQUIRED
sample = u'Gr\u00fc\u00dfe aus \u00d6sterreich'
assert len(sample) == 20 and json.loads(json.dumps(sample)) == sample
print('PASS installed Tauthon runtime, aliases and local prefix')
'@ | Set-Content -Encoding ASCII $probe
$installed=$false
try {
    Installer '/i' 'install.log';$installed=$true
    Push-Location $env:TEMP
    try {
        foreach($name in @('tauthon.exe','python2.exe','python2.7.exe')){
            & (Join-Path $installedPath $name) -B -E $probe $(if($Architecture -eq 'x64'){64}else{32}) $installedPath
            if($LASTEXITCODE -ne 0){throw "Installed runtime test failed: $name"}
        }
        & (Join-Path $installedPath 'embedding-probe.exe')
        if($LASTEXITCODE -ne 0){throw 'Installed DLL embedding failed.'}
    } finally {Pop-Location}
    $alias=Join-Path $installedPath 'python2.exe'
    Copy-Item $alias (Join-Path $ResultDirectory 'python2.exe.before-repair')
    $aliasHash=(Get-FileHash $alias -Algorithm SHA256).Hash
    Remove-Item $alias
    Installer '/fa' 'repair.log'
    if((Get-FileHash $alias -Algorithm SHA256).Hash -ne $aliasHash){throw 'MSI repair did not restore the alias.'}
    'PASS Tauthon MSI runtime, direct embedding and repair'
} finally {
    if($installed){Installer '/x' 'uninstall.log'}
}
if(Test-Path $installedPath){throw 'Uninstall left the installation directory behind.'}
if([Environment]::GetEnvironmentVariable('PATH','Machine') -ne $beforeMachine -or
   [Environment]::GetEnvironmentVariable('PATH','User') -ne $beforeUser){throw 'Global PATH changed unexpectedly.'}
if((@(PythonRegistration) -join "`n") -ne $beforePython){throw 'Global Python registration changed unexpectedly.'}
@('[Result]','Status=Passed',"Architecture=$Architecture",'Runtime=Passed','Embedding=Passed','Repair=Passed','Uninstall=Passed','PathPreserved=true','PythonRegistrationPreserved=true') |
    Set-Content (Join-Path $ResultDirectory 'result.ini')
'PASS Tauthon MSI uninstall, PATH and Python registration preservation'
