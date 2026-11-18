"""Checks a genuine Flutter artifact before it can be distributed. Never builds an APK."""
import argparse,hashlib,json,os,re,shutil,subprocess,zipfile
from pathlib import Path
parser=argparse.ArgumentParser();parser.add_argument('apk',type=Path);parser.add_argument('--debug',action='store_true');args=parser.parse_args()
sdk=os.environ.get('ANDROID_HOME') or os.environ.get('ANDROID_SDK_ROOT')
aapt=shutil.which('aapt')
if not aapt and sdk:
    candidates=sorted((Path(sdk)/'build-tools').glob('*/aapt*'))
    aapt=str(candidates[-1]) if candidates else None
if not aapt: raise SystemExit('Android aapt is required to verify identity')
badging=subprocess.check_output([aapt,'dump','badging',str(args.apk)],text=True,encoding='utf8')
if not ("package: name='com.enote.studyflow'" in badging): raise SystemExit('Wrong application ID')
if not ("application-label:'ENote'" in badging): raise SystemExit('Wrong app name')
if not ("targetSdkVersion:'36'" in badging): raise SystemExit('Wrong target SDK')
with zipfile.ZipFile(args.apk) as archive:
    names=archive.namelist()
    if not (any(x.endswith('/libflutter.so') for x in names)): raise SystemExit('Flutter engine missing')
    if not (any(x.startswith('assets/flutter_assets/') for x in names)): raise SystemExit('Flutter assets missing')
if not args.debug:
    apksigner=Path(aapt).with_name('apksigner.bat' if os.name=='nt' else 'apksigner')
    certificates=subprocess.check_output([str(apksigner),'verify','--print-certs',str(args.apk)],text=True)
    if not ('Android Debug' not in certificates): raise SystemExit('Debug-signed artifact cannot be released')
    expected=os.environ.get('ENOTE_RELEASE_CERT_SHA256','').lower()
    if not (re.fullmatch('[a-f0-9]{64}',expected or '')): raise SystemExit('Set the expected release signing certificate fingerprint')
    if not (expected in certificates.lower().replace(':','')): raise SystemExit('Unexpected release signing certificate')
print(json.dumps({'applicationId':'com.enote.studyflow','targetSdk':36,'internalDebug':args.debug,'sha256':hashlib.sha256(args.apk.read_bytes()).hexdigest()}))
