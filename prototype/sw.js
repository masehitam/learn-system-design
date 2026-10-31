// Network-first: selalu ambil versi terbaru saat online, pakai salinan cache saat offline.
const CACHE = 'alur-v1';
const SHELL = ['./', 'index.html', 'config.js', 'manifest.webmanifest', 'icon.svg', 'icon-192.png'];
// Aset luar yang ikut di-cache: font dan library Supabase. API Supabase sengaja tidak di-cache.
const EXTERNAL = /^https:\/\/(fonts\.googleapis\.com|fonts\.gstatic\.com|cdn\.jsdelivr\.net)\//;

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(SHELL)).then(() => self.skipWaiting()));
});
self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(ks => Promise.all(ks.filter(k => k !== CACHE).map(k => caches.delete(k)))).then(() => self.clients.claim()));
});
self.addEventListener('fetch', e => {
  const r = e.request;
  if (r.method !== 'GET' || !(r.url.startsWith(self.location.origin) || EXTERNAL.test(r.url))) return;
  e.respondWith(fetch(r).then(res => {
    // Redirect login membawa ?code=... sekali pakai; jangan menumpuk salinannya di cache.
    if ((res.ok || res.type === 'opaque') && !(r.mode === 'navigate' && new URL(r.url).search)) { const copy = res.clone(); caches.open(CACHE).then(c => c.put(r, copy)); }
    return res;
  }).catch(() => caches.match(r, {ignoreSearch: true}).then(hit => hit || (r.mode === 'navigate' ? caches.match('index.html') : Response.error()))));
});
