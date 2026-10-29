-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA512

Format: 1.0
Source: python2.7
Binary: python2.7, libpython2.7-stdlib, python2.7-minimal, libpython2.7-minimal, libpython2.7, python2.7-examples, python2.7-dev, libpython2.7-dev, libpython2.7-testsuite, idle-python2.7, python2.7-doc, python2.7-dbg, libpython2.7-dbg
Architecture: any all
Version: 2.7.18-8+deb11u1
Maintainer: Matthias Klose <doko@debian.org>
Standards-Version: 4.5.0
Vcs-Browser: https://salsa.debian.org/cpython-team/python2
Vcs-Git: https://salsa.debian.org/cpython-team/python2.git
Testsuite: autopkgtest
Build-Depends: debhelper (>= 9), dpkg-dev (>= 1.17.11), quilt, autoconf, autotools-dev, lsb-release, sharutils, libreadline-dev, libtinfo-dev, libncursesw5-dev (>= 5.3), tk-dev, blt-dev (>= 2.4z), libssl-dev (>= 1.1.1), zlib1g-dev, libbz2-dev, libexpat1-dev, libbluetooth-dev [linux-any] <!profile.nobluetooth>, locales [!armel !avr32 !hppa !ia64 !mipsel], libsqlite3-dev, libffi-dev (>= 3.0.5) [!or1k !avr32], libgpm2 [linux-any], mime-support, netbase, net-tools, bzip2, time, libdb-dev (<< 1:6.0), libgdbm-dev, help2man, xvfb <!nocheck>, xauth <!nocheck>, python2.7:any <cross>
Build-Depends-Indep: python3-sphinx
Build-Conflicts: autoconf2.13, hardening-wrapper, python-cxx-dev, python-xml, python2.7-xml, tcl8.4-dev, tk8.4-dev
Package-List:
 idle-python2.7 deb python optional arch=all
 libpython2.7 deb libs optional arch=any
 libpython2.7-dbg deb debug optional arch=any
 libpython2.7-dev deb libdevel optional arch=any
 libpython2.7-minimal deb python optional arch=any
 libpython2.7-stdlib deb python optional arch=any
 libpython2.7-testsuite deb libdevel optional arch=all
 python2.7 deb python optional arch=any
 python2.7-dbg deb debug optional arch=any
 python2.7-dev deb python optional arch=any
 python2.7-doc deb doc optional arch=all
 python2.7-examples deb python optional arch=all
 python2.7-minimal deb python optional arch=any
Checksums-Sha1:
 1a84bcb4aef49a08f39dbf9219d8b3190ebfd84d 17539408 python2.7_2.7.18.orig.tar.gz
 24ff67cc0a790d852dc8f060c84be27d0321492d 317001 python2.7_2.7.18-8+deb11u1.diff.gz
Checksums-Sha256:
 da3080e3b488f648a3d7a4560ddee895284c3380b11d6de75edb986526b9a814 17539408 python2.7_2.7.18.orig.tar.gz
 920b54018bc1b807077778be900157cf0a786621f4f7d7f69ec2096ff5d63f8e 317001 python2.7_2.7.18-8+deb11u1.diff.gz
Files:
 38c84292658ed4456157195f1c9bcbe1 17539408 python2.7_2.7.18.orig.tar.gz
 45d42026c10acf93dd944e7dfc5a6e01 317001 python2.7_2.7.18-8+deb11u1.diff.gz

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCgAdFiEETMLS2QqNFlTb+HOqLRqqzyREREIFAmUQll8ACgkQLRqqzyRE
REIeCg/+JH5fPXwITf+qOGC7mQItFcs+JoFxSy/d8B5X1NxE/xgjWOOqcJkBtuDl
2PIXFiH7bcMQMobBswYt/xym4znEHGOWUk7/v3FC+An1O4XbDaaIHV/QCvhkwb/D
MTWW4qL0qpynJyfbAillTiUmQKE2rIQJelJIQYDxUdssxBCSmuLPTzf+prOBNB+U
/INuBJSE6wZrelefgLw7xUec2PY3e6e97XbBilczKa7BqjwNUreLHlQNE4sJrB9x
V/XrM27GSLT/95A+F7YO+pi66P3n9gK41YuWL/ZewVbrwF2nCI+6toBMv+rshtyA
d8/R7K66ktqpHjXXSqqk7N0RyLgukv9JI8wL2aDncpjzkHK/1pZnRai28iDMKn3e
a11EGM4QLLGt4P6SJEeq/MH4YzQ/UjmD5P+fX1Ns3LtNrAz+APszdLx2N2BGgqNq
o1hkqzkiOITUsaTzekaI8v547JwoPyFT8T5XuDP6ldJyf2GiL2YgyVPl0Gy8yrQL
sSqa5rZr0MPzZxds8zCPh0HvAGyKPbCH27WgDCEts+XWUDhz7vZdPH9G91Jmy3N3
YOAd0SzWcuvC2fRfkb4QDSTcBEDOTFBL3lMaHCIr5IIKiilP6rcusZWa7l4/FpC2
45Q6pht1HIq0+tOVH9lzDOewBDbJ4XvpRdTvkgmnmh3/1BJ0Xw4=
=9VaW
-----END PGP SIGNATURE-----
