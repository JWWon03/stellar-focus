/* 알림 스몰 아이콘을 안드로이드 프로젝트에 넣는다.
   `npx cap add android` 로 android/ 가 만들어진 뒤에만 할 수 있어서
   웹 복사(sync-web)와 분리해 두었다. 여러 번 돌려도 안전하다. */
import { cp, mkdir, stat, readdir } from 'node:fs/promises';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const HERE = dirname(fileURLToPath(import.meta.url));
const SRC  = join(HERE, 'res-notification');
const DST  = join(HERE, 'android', 'app', 'src', 'main', 'res');

async function exists(p) { try { await stat(p); return true; } catch { return false; } }

if (!(await exists(DST))) {
  console.log('android/ 가 아직 없습니다 — `npx cap add android` 를 먼저 실행하세요. (건너뜀)');
  process.exit(0);
}

for (const dir of await readdir(SRC)) {
  const to = join(DST, dir);
  await mkdir(to, { recursive: true });
  await cp(join(SRC, dir), to, { recursive: true });
}
console.log('알림 아이콘 설치 완료 — ic_stat_stellar');
