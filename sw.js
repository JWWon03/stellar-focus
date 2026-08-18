/* Stellar Focus 서비스워커
   ------------------------------------------------------------------
   두 가지 일을 한다.
   1) 앱 껍데기를 캐시해 오프라인에서도 켜지게 한다.
   2) 알림을 띄운다. 홈 화면에 추가한 PWA(특히 iOS)에서는 페이지의
      new Notification() 이 동작하지 않고 서비스워커만 알림을 띄울 수 있다.

   갱신 규칙이 자산 종류마다 다르다.
   - index.html: 네트워크 우선. 캐시 우선으로 하면 배포해도 사용자가
     낡은 앱을 계속 쓰게 된다.
   - 텍스처·아이콘: 캐시 우선. 내용이 바뀌지 않고 용량이 크다.
*/
const VER   = 'sf-v2';
const SHELL = VER + '-shell';
const ASSET = VER + '-asset';

/* 미리 받아둘 최소 집합. 텍스처는 무겁고 없어도 앱이 돌아가므로
   미리 받지 않고 처음 쓰일 때 캐시한다. */
const PRECACHE = [
  './',
  './index.html',
  './manifest.webmanifest',
  './icons/icon-192.png',
  './icons/icon-512.png'
];

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(SHELL)
      .then(c => c.addAll(PRECACHE))
      // 한 개라도 실패하면 설치 전체가 실패한다. 오프라인 캐시는
      // 있으면 좋은 것이지 앱의 전제가 아니므로 조용히 넘어간다.
      .catch(() => {})
      .then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys()
      .then(ks => Promise.all(ks.filter(k => k !== SHELL && k !== ASSET)
                                .map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  const req = e.request;
  if (req.method !== 'GET') return;

  const url = new URL(req.url);
  if (url.origin !== self.location.origin) return;   // Supabase 등 외부는 건드리지 않는다

  const isDoc = req.mode === 'navigate' || url.pathname.endsWith('/index.html');

  if (isDoc) {
    // 네트워크 우선 — 새로 배포한 앱을 받되, 오프라인이면 캐시로 버틴다
    e.respondWith(
      fetch(req)
        .then(res => {
          const copy = res.clone();
          caches.open(SHELL).then(c => c.put('./index.html', copy)).catch(() => {});
          return res;
        })
        .catch(() => caches.match('./index.html').then(r => r || caches.match('./')))
    );
    return;
  }

  // 그 밖(텍스처·아이콘·매니페스트)은 캐시 우선
  e.respondWith(
    caches.match(req).then(hit => hit || fetch(req).then(res => {
      if (res && res.status === 200 && res.type === 'basic') {
        const copy = res.clone();
        caches.open(ASSET).then(c => c.put(req, copy)).catch(() => {});
      }
      return res;
    }).catch(() => hit))
  );
});

/* 페이지가 살아 있지 않아도 알림을 띄울 수 있게 통로를 열어 둔다 */
self.addEventListener('message', e => {
  const d = e.data || {};
  if (d.type === 'notify') {
    self.registration.showNotification(d.title, d.options || {});
  } else if (d.type === 'skipWaiting') {
    self.skipWaiting();
  }
});

/* 알림을 누르면 이미 열린 창으로 가고, 없으면 새로 연다 */
self.addEventListener('notificationclick', e => {
  e.notification.close();
  e.waitUntil(
    self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then(list => {
      for (const c of list) {
        if ('focus' in c) return c.focus();
      }
      if (self.clients.openWindow) return self.clients.openWindow('./');
    })
  );
});
