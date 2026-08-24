/* 저장소 루트의 웹 앱을 www/ 로 복사한다.
   앱을 루트에 그대로 둬야 GitHub Pages 배포가 유지되므로, 래퍼는
   빌드할 때만 필요한 것을 긁어 간다. 원본은 절대 건드리지 않는다.

   서비스워커는 일부러 빼놓는다. 네이티브 WebView 는 파일을 로컬에서
   읽으므로 오프라인 캐시가 필요 없고, sw 가 끼면 앱을 새로 깔아도
   낡은 화면이 남는 사고가 난다. */
import { cp, mkdir, rm, readFile, writeFile, stat } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const ROOT = join(HERE, '..');
const WWW  = join(HERE, 'www');

const FILES = ['index.html', 'manifest.webmanifest'];
const DIRS  = ['textures', 'icons'];

async function exists(p) { try { await stat(p); return true; } catch { return false; } }

await rm(WWW, { recursive: true, force: true });
await mkdir(WWW, { recursive: true });

for (const f of FILES) {
  if (await exists(join(ROOT, f))) await cp(join(ROOT, f), join(WWW, f));
}
for (const d of DIRS) {
  if (await exists(join(ROOT, d))) await cp(join(ROOT, d), join(WWW, d), { recursive: true });
}

// 서비스워커 등록을 끈다. 위 주석의 이유.
const idx = join(WWW, 'index.html');
let html = await readFile(idx, 'utf8');

/* **함수 본문이 아니라 여는 줄만 붙잡는다.** 예전에는 첫 두 줄을 통째로
   맞췄는데, index.html 쪽에 진단용 한 줄이 늘자 조용히 어긋났다. 경고만
   찍고 넘어가는 바람에 서비스워커가 살아 있는 APK 가 나올 뻔했다.
   못 찾으면 빌드를 세운다 — 조용히 잘못된 앱을 뽑는 것보다 낫다. */
const OPEN = 'function registerSW(){';
if (!html.includes(OPEN)) {
  console.error('! ' + OPEN + ' 를 찾지 못했습니다. index.html 에서 이름이 바뀌었는지 확인하세요.');
  console.error('  그대로 두면 네이티브 WebView 에 서비스워커가 등록되어,');
  console.error('  앱을 새로 깔아도 낡은 화면이 남습니다. sync-web.mjs 의 OPEN 을 맞춰 주세요.');
  process.exit(1);
}
html = html.replace(OPEN, `${OPEN}
  return;   // 네이티브 래퍼에서는 서비스워커를 쓰지 않는다`);
await writeFile(idx, html, 'utf8');

console.log('www/ 준비 완료 —', FILES.concat(DIRS).join(', '));
