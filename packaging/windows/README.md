# Windows native builds and MSI test installers

The `windows/build-msvc` branch builds x86 and x64 with the existing PCbuild
projects and MSVC v143. GitHub Actions run 41041170384 built both native
bundles successfully. The DLL retains its name **tauthon28.dll**; renaming it
to python27.dll does not establish ABI compatibility with Mystic.

## MSI packaging

`New-WindowsMsi.ps1` runs with PowerShell 7 on Linux and uses `wixl` from
msitools. Obtain the pinned zlib license with `Get-MsiNotices.ps1`, then pass
`-BundleDirectory`, `-Architecture x86|x64`, `-ZlibNotice` and a fresh
`-OutputDirectory`. Bundle hashes and the PE architecture are verified.

Finalize each candidate on Windows with Windows PowerShell 5.1 or later:

```powershell
./Finalize-WindowsMsi.ps1 -MsiPath ./tauthon-2.8.5-windows-x64-test1.msi -TableDirectory .
```

The table directory must contain the generated `RemoveFile.idt`. Finalization
imports it through Microsoft's Windows Installer API and prints the final
SHA256. Linux msibuild import produced a package rejected by Windows FileCost
(error 2211) in our first trial; do not distribute an unfinalized candidate.
RemoveFile entries remove only the exact .pyc/.pyo names corresponding to
shipped standard-library modules during uninstall. See Microsoft's
[RemoveFile documentation](https://learn.microsoft.com/en-us/windows/win32/msi/removefile-table).

## Installation for sysops

Install Microsoft's official **Visual C++ v14 Redistributable 14.44 or newer**
for the matching x86/x64 architecture first. It is a separate prerequisite:
https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist

The MSI defaults to `Program Files\Tauthon28` (x86 under Program Files (x86)
on a 64-bit host). It includes local `tauthon.exe`, `python2.exe` and
`python2.7.exe` commands. Global PATH, Python registrations and .py associations
are untouched. A custom directory can be supplied to Windows Installer:

```powershell
msiexec.exe /i tauthon-2.8.5-windows-x64-test1.msi INSTALLFOLDER="D:\BBS\Tauthon28"
```

Remove an older test MSI before installing another build. Automatic upgrades
and downgrades have not been qualified. Uninstall through Apps & Features or
`msiexec /x <package.msi>`. MSI version 2.8.501 denotes source 2.8.5, test 1.
The package is unsigned and deliberately labelled as a test version.

## Verification and remaining work

`Test-WindowsMsi.ps1` exercises installation, matching bitness, all three
executables, SQLite, SSL context verification, ctypes, Unicode JSON, native
DLL embedding, repair after an alias is removed, uninstall, and preservation
of PATH/Python registrations. Use a fresh result directory and supply the
SHA256 of the finalized MSI. It refuses to overwrite an existing installation.

The targets are Windows 10 x86/x64. Windows 7 and actual Mystic A49 embedding
remain unqualified. Tcl/Tk, Berkeley DB, IDLE and stdlib tests are omitted.
Upstream dependencies include old OpenSSL 1.1.1n, SQLite 3.35.5 and zlib 1.2.12.
These are functional compatibility test packages, not security-maintained
production runtimes. Dependency updates need separate compatibility tests.
Licenses and exact dependency-source references are included with the MSI.

On 2026-10-30 both finalized packages passed this full lifecycle on the
supplied Windows 10 Pro 22H2 x86/x64 VMs, with VC runtime 14.44.35211.0.
Repair was slow (approximately a minute); it restored the deleted alias.
Uninstall removed generated stdlib bytecode and the installation directory.
Public test downloads: https://bbs.disconnected-by-peer.at/windows/
