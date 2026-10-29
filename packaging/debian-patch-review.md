# Debian Python 2.7 patch review

Reference: Debian python2.7 2.7.18-8+deb11u1. Tauthon base:
8c285035882a2b9843428293675fa7668c0d5b0e. This is an initial targeted review,
not completion of the security-patch audit.

| Debian patch | Finding / adaptation |
| --- | --- |
| `site-locations.diff` | Ported to native Tauthon `dist-packages`; `.pth` in the optional compatibility package adds the old Python 2.7 local and distro addon directories. |
| `distutils-install-layout.diff` | Ported `--install-layout=deb`, separate local/distro schemes, egg metadata and relevant upstream tests. Tauthon stdlib and headers keep their real namespace. Documentation hunks are replaced by this packaging documentation. |
| `distutils-sysconfig.diff` | Partly relevant: use actual `LIBPL` for Makefile discovery. Compiler flag hunks require reconciliation with Tauthon's newer C++ compiler support; not blindly applied. |
| `multiarch.diff` | Configure already discovers `MULTIARCH`. Ported extension suffix loading and `sys._multiarch`. Shared/static libraries are placed in Debian's architecture directory by packaging rules. Multiarch co-installation of interpreters and headers is not claimed. |
| `deb-locations.diff` | Mostly demo scripts and documentation paths, not interpreter import compatibility. No wholesale port needed for the current runtime package. |
| `ext-no-libpython-link.diff` | Deferred pending embedding tests: globally removing linkage is not automatically appropriate for Tauthon loaded by Mystic. |
| `distutils-link.diff` | Filtering standard library rpaths is a candidate; no blanket change until rebuilt extension tests establish expected link flags. |
| `build-libpython.diff` | Static archive object de-duplication; assess against current Tauthon Makefile before enabling. |
| `add-python-config-sh.diff` | Cross-build helper and extra config queries; native Tauthon config works independently. Cross-building is not yet qualified. |
| `ensurepip-disabled.diff` / `ensurepip-wheels.diff` | Package build disables automatic ensurepip bootstrap. Explicit ensurepip policy and replacement wheels remain separate work. No old wheels are installed as a compatibility shortcut. |
| `multiarch-libc.diff` | Header regeneration helper (`h2py`), not a runtime library search patch; check if Debian platform-header regeneration will be adopted. |
| `CVE-*.diff` | Security audit still open. Each fix needs comparison with Tauthon changes and regression tests; successful compilation is not evidence these fixes are included. |

The native standard library remains `/usr/lib/tauthon2.8`. The optional command
compatibility package adds `/usr/bin/python2`, `/usr/bin/python2.7`, and search
paths `/usr/local/lib/python2.7/dist-packages` and
`/usr/lib/python2.7/dist-packages`. That allows pure modules and explicitly
rebuilt extensions to use legacy addon locations without falsifying the
interpreter version or the shared-library ABI.

`setup.py install --install-layout=deb` installs newly built modules into
`/usr/lib/tauthon2.8/dist-packages`. For a rebuilt legacy Debian package whose
file lists require the old directory, pass
`--install-lib=/usr/lib/python2.7/dist-packages` explicitly. Its build dependencies,
maintainer scripts and extension ABI still need review. No `python2.7` virtual
package is advertised solely because these command aliases exist.
