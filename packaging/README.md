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
