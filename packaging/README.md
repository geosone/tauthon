# Debian Trixie packaging (experimental)

Upstream: https://github.com/naftaliharris/tauthon
Pinned commit: 8c285035882a2b9843428293675fa7668c0d5b0e

The upstream branch remains unchanged; packaging lives on `debian/trixie`.
`reference/` retains Debian's Python 2.7 packaging, including its copyright
and patch attribution, for adaptation and comparison. Those old rules and
maintainer scripts are NOT executed by this build. The current rules use
Trixie dependencies and debhelper 13; patches need individual review rather
than blindly applying Python 2.7 patches to a diverged Tauthon source tree.

Reference diff SHA-256:
920b54018bc1b807077778be900157cf0a786621f4f7d7f69ec2096ff5d63f8e
Compared with the downloaded DSC; signature verification still pending.

Initial packages: tauthon, libtauthon2.8, libtauthon2.8-dev and optional
tauthon-python2-compat. The optional package supplies command paths, not
arbitrary legacy dependency Provides. No libpython2.7 SONAME alias. Native
third-party modules must be rebuilt. Mystic embedding remains a separate
qualification gate. No claim of complete Python 2 security maintenance.

The build container installs only Trixie packages. No Bullseye or Ubuntu
repositories are mixed into Trixie. Production BBS files are not used.

Build committed sources on the development VM:

    pwsh -NoProfile -File packaging/Build-Debian.ps1

Compilation and binary package assembly run in a disposable container without
network access. Only the initial Docker image build downloads dependencies.
The runtime smoke test is a first gate, not a replacement for the full upstream
test suite, package lifecycle checks or Mystic/MRC integration tests.

## Coexistence with Debian Python upgrades

Tauthon owns no `/usr/bin/python3`, `/usr/lib/python3*` or unversioned
`/usr/bin/python`. There are no Debian 11 repositories, APT holds, pins of
Python 3 versions, or virtual `python3` Provides. Native library dependencies
come from Trixie's shlibs metadata. The exact-version dependency between
Tauthon and its own library keeps those packages consistent; it does not
pin Debian's Python.

The optional aliases conflict only with legacy Python 2 packages owning the
same command paths. Install the native Tauthon runtime alongside an existing
Python 2 installation first; inspect removal plans before replacing legacy
command paths. Do not automatically remove old third-party module packages
to force the compatibility package to install.

Run `packaging/Test-AptUpgrade.ps1` after building. It uses a fresh disposable
Trixie container, installs the packages through APT, checks `full-upgrade`
resolution, verifies no holds and reinstalls Debian's Python 3. This does not
prove compatibility with a future Debian release; each release needs rebuilt
packages and its own qualification. Release upgrades from Debian 11 must be
planned in supported steps rather than mixing repository generations.

The current binaries target Trixie specifically: their generated dependencies
include `libssl3t64 (>= 3.4.0)` and `libc6 (>= 2.38)`. They must not be forced
onto the production Bookworm system. A production migration needs an inventory
of existing Python 2 modules and foreign repositories, tested Mystic embedding,
and a reviewed APT plan. Any Bookworm transition packages need their own build
against Bookworm, not dependency overrides or fake library symlinks.

For published test packages, see `test-results-trixie.md` and the release notes.
`Export-Release.ps1` bundles the six Debian artifacts, build metadata, checksums,
license and qualification notes. A release download is not an APT repository;
a future GitHub Pages repository needs generated and signed APT metadata.
