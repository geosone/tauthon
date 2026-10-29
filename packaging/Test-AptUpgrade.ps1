[CmdletBinding()]
param([string]$PackageDirectory = (Join-Path $PSScriptRoot '../../tauthon-packages'))
$ErrorActionPreference = 'Stop'
$PackageDirectory = (Resolve-Path $PackageDirectory).Path
if (-not (Get-ChildItem -LiteralPath $PackageDirectory -Filter '*.deb')) { throw 'No packages found.' }
$test = @'
set -eu
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y --no-install-recommends python3 ca-certificates
python3 -c 'import sys; assert sys.version_info.major == 3'
apt-get install -y --no-install-recommends /packages/*.deb
[ -z "$(apt-mark showhold)" ]
[ -z "$(dpkg --audit)" ]
apt-get -s full-upgrade > /tmp/upgrade-plan
cat /tmp/upgrade-plan
if grep -E '^Remv (python3([ :.-]|$)|tauthon([ :.-]|$)|libtauthon)' /tmp/upgrade-plan; then
    printf '%s\n' 'FAIL upgrade would remove Python 3 or Tauthon' >&2
    exit 1
fi
apt-get install -y --reinstall python3
python3 -c 'import sys, sysconfig; assert sys.version_info.major == 3; print(sys.version)'
python2.7 -c 'import sys; assert sys.version_info[:2] == (2, 8); print(sys.version)'
printf '%s\n' 'PASS clean Trixie APT installation, full-upgrade resolution and Python 3 reinstallation'
'@
& docker run --rm --mount "type=bind,src=$PackageDirectory,dst=/packages,readonly" debian:trixie-slim sh -ec $test
if ($LASTEXITCODE -ne 0) { throw "APT acceptance failed with exit code $LASTEXITCODE" }
