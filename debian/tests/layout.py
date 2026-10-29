#!/usr/bin/tauthon2.8
from distutils.dist import Distribution
from distutils.command.install import install
from distutils.errors import DistutilsOptionError
import sysconfig

cmd = install(Distribution({'name': 'layout-probe', 'version': '1.0'}))
cmd.prefix = '/usr'
cmd.install_layout = 'deb'
cmd.finalize_options()
assert cmd.install_purelib == '/usr/lib/tauthon2.8/dist-packages', cmd.install_purelib
assert cmd.install_platlib == cmd.install_purelib
assert cmd.install_headers == '/usr/include/tauthon2.8/layout-probe'
cmd = install(Distribution())
cmd.prefix = '/usr'
cmd.install_layout = 'invalid'
try:
    cmd.finalize_options()
except DistutilsOptionError:
    pass
else:
    raise AssertionError('Unknown layout accepted')
assert 'deb_system' in sysconfig.get_scheme_names()
assert 'posix_local' in sysconfig.get_scheme_names()
assert sysconfig.get_paths('deb_system')['purelib'] == '/usr/lib/tauthon2.8/dist-packages'
print('PASS Debian distutils installation layout and sysconfig schemes')
