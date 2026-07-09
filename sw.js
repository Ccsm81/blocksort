// Block Sort service worker — network-first HTML (fresh on reload), cache-first assets (offline OK)
const CACHE = 'blocksort-v15';
const ASSETS = ['./','./index.html','./manifest.json'];
self.addEventListener('install', e => { e.waitUntil(caches.open(CACHE).then(c=>c.addAll(ASSETS)).catch(()=>{})); self.skipWaiting(); });
self.addEventListener('activate', e => { e.waitUntil(caches.keys().then(ks=>Promise.all(ks.filter(k=>k!==CACHE).map(k=>caches.delete(k))))); self.clients.claim(); });
self.addEventListener('fetch', e => {
  if (e.request.method !== 'GET') return;
  const u = new URL(e.request.url);
  const isHTML = e.request.mode === 'navigate' || u.pathname.endsWith('/') || u.pathname.endsWith('index.html');
  if (isHTML) e.respondWith(fetch(e.request).then(r=>{ const cp=r.clone(); caches.open(CACHE).then(c=>c.put('./index.html',cp)); return r; }).catch(()=>caches.match('./index.html').then(r=>r||caches.match('./'))));
  else e.respondWith(caches.match(e.request).then(r=>r||fetch(e.request)));
});
