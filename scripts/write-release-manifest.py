"""Writes public/release.json for the landing page from a VERIFIED release APK.

Refuses to run unless scripts/verify-apk.py passes in release mode (correct
package/name/target SDK, Flutter engine present, not debug-signed, expected
signing certificate). The landing page shows its Download button only when this
manifest exists, so a missing/failed build can never produce a dead or wrong link.

Usage:
  ENOTE_RELEASE_CERT_SHA256=<sha256 of release cert> \
  python scripts/write-release-manifest.py path/to/app-release.apk 1.0.0
Output: public/release.json and <apk dir>/ENote-<version>.apk (the file to upload to the
GitHub release tagged v<version>).
"""
import hashlib
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

if len(sys.argv) != 3 or not re.fullmatch(r'\d+\.\d+\.\d+', sys.argv[2]):
    raise SystemExit(__doc__)

apk = Path(sys.argv[1])
version = sys.argv[2]
root = Path(__file__).resolve().parent.parent

subprocess.run([sys.executable, str(root / 'scripts' / 'verify-apk.py'), str(apk)], check=True)

release_apk = apk.with_name(f'ENote-{version}.apk')
if apk.resolve() != release_apk.resolve():
    shutil.copyfile(apk, release_apk)
data = release_apk.read_bytes()
manifest = {
    'available': True,
    'version': version,
    'apkUrl': f'https://github.com/Zaroscript/study_flow/releases/download/v{version}/ENote-{version}.apk',
    'sha256': hashlib.sha256(data).hexdigest(),
    'sizeBytes': len(data),
    'minAndroid': '7.0',
}
(root / 'public' / 'release.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf8')
print(json.dumps(manifest, indent=2))
print(f'Upload this file to the GitHub release v{version}: {release_apk}')
