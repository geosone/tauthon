# Windows compatibility build

This branch uses the existing upstream PCbuild projects with MSVC, rather
than assuming that a MinGW build has the same ABI as the Windows ports.
`Build-Windows.ps1` builds x64 and checks the interpreter and essential
modules. `Export-WindowsTestBundle.ps1` creates a separate portable test
directory and local `python2.exe` / `python2.7.exe` executable aliases.

The DLL keeps its native **tauthon28.dll** name. It must not be copied or
renamed to python27.dll as a claimed ABI replacement. Native extensions and
Mystic embedding require separate tests. Registry entries, Python 3, global
PATH and file associations are not modified by these tools.

The GitHub workflow runs on Windows Server 2022 and uploads only a temporary
test artifact. This does not establish Windows 7 support. The supplied test
VM runs Windows 7 SP1 x64 with PowerShell 2.0; updates are still being applied.
Build tools require PowerShell 7 on the build runner, not on that target VM.
SSH and RDP/VNC are available for later runtime and installation tests.

Upstream PCbuild currently selects old dependencies, including OpenSSL
1.1.1n, SQLite 3.35.5 and zlib 1.2.12. The first native build is a diagnostic
step, not a security-supported release. Dependency sources, versions,
licenses and the redistributable runtime must be reviewed before publishing
an installer. Tkinter and Berkeley DB are omitted from this initial profile.

Still required: successful native build, relocation/alias tests, direct
embedding probe, compatible dependency updates, MSI packaging and lifecycle
tests, Windows 7 runtime qualification and actual Mystic A49 embedding.
