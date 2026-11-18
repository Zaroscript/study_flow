/* Pre-deploy gate for the landing's Android download.
 *   node scripts/check-release.cjs            offline: public/release.json is well-formed
 *   node scripts/check-release.cjs --remote   also downloads apkUrl and compares size + SHA-256
 * Run --remote AFTER uploading the APK to the GitHub release and BEFORE deploying the landing,
 * so the Download button can never point at a missing or different file.
 * The URL pattern must stay identical to RELEASE_URL in Landing.tsx. */
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');

const RELEASE_URL = /^https:\/\/github\.com\/Zaroscript\/study_flow\/releases\/(?:latest\/download|download\/[A-Za-z0-9._-]+)\/ENote[A-Za-z0-9._-]*\.apk$/;
const file = path.resolve(__dirname, '..', 'public', 'release.json');
const fail = (message) => { console.error(`FAIL ${message}`); process.exit(1); };

if (!fs.existsSync(file)) {
  console.log('OK no public/release.json: the landing will show "Android release in preparation".');
  process.exit(0);
}
let manifest;
try { manifest = JSON.parse(fs.readFileSync(file, 'utf8')); } catch (e) { fail(`release.json is not valid JSON: ${e.message}`); }
if (manifest.available !== true) fail('available must be true');
if (!/^\d+\.\d+\.\d+$/.test(manifest.version || '')) fail('version must be x.y.z');
if (!RELEASE_URL.test(manifest.apkUrl || '')) fail('apkUrl must be an ENote*.apk on github.com/Zaroscript/study_flow/releases');
if (!/^[a-f0-9]{64}$/.test(manifest.sha256 || '')) fail('sha256 must be 64 lowercase hex characters');
if (!(Number.isInteger(manifest.sizeBytes) && manifest.sizeBytes > 0)) fail('sizeBytes must be a positive integer');
if (!manifest.apkUrl.includes(`/v${manifest.version}/`) && !manifest.apkUrl.includes('/latest/download/')) fail('apkUrl tag does not match version');
console.log(`OK release.json is well-formed (v${manifest.version}, ${manifest.sizeBytes} bytes)`);

if (process.argv.includes('--remote')) {
  (async () => {
    const response = await fetch(manifest.apkUrl, { redirect: 'follow' });
    if (!response.ok) fail(`apkUrl returned HTTP ${response.status}: the release asset is not published yet`);
    const bytes = Buffer.from(await response.arrayBuffer());
    if (bytes.length !== manifest.sizeBytes) fail(`size mismatch: published ${bytes.length}, manifest ${manifest.sizeBytes}`);
    const digest = crypto.createHash('sha256').update(bytes).digest('hex');
    if (digest !== manifest.sha256) fail(`sha256 mismatch: published ${digest}, manifest ${manifest.sha256}`);
    console.log('OK published asset matches the manifest (size + SHA-256)');
  })().catch((e) => fail(`could not download apkUrl: ${e.message}`));
}
