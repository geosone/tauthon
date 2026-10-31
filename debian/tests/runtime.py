#!/usr/bin/tauthon2.8
import sys, ssl, sqlite3, ctypes, bz2, zlib, readline, hashlib, json, socket
assert sys.version_info[:2] == (2, 8), sys.version
assert bz2.decompress(bz2.compress('legacy')) == 'legacy'
assert zlib.decompress(zlib.compress('legacy')) == 'legacy'
assert sqlite3.connect(':memory:').execute('select 42').fetchone() == (42,)
assert hashlib.sha256('test').hexdigest() == '9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08'
assert json.loads(json.dumps({'text': u'Gr\u00fc\u00dfe'}))['text'] == u'Gr\u00fc\u00dfe'
ctx = ssl.create_default_context()
assert ctx.verify_mode == ssl.CERT_REQUIRED
assert ctx.check_hostname
print('PASS Tauthon runtime imports, codecs, SQLite and verified TLS defaults')
import os, tempfile
if hasattr(os, 'futimesat'):
    handle, path = tempfile.mkstemp()
    directory = os.open(os.path.dirname(path), os.O_RDONLY)
    try:
        stamp = 4102444800.25
        os.futimesat(directory, os.path.basename(path), (stamp, stamp))
        assert abs(os.stat(path).st_mtime - stamp) < 0.001
    finally:
        os.close(directory)
        os.close(handle)
        os.unlink(path)
    print('PASS futimesat fractional post-2038 timestamp roundtrip')
