/* Service worker for Boring game site.
   Caches only the site shell (page, font, icons, covers) so the app opens fast.
   Game files are NOT cached here — they load straight from the network,
   so they never go stale. Bump VERSION whenever you change game/index.html. */
const VERSION = "bgs-v2";
const SHELL = [
  "game/",
  "images/found-me.png",
  "vrc%20font.ttf",
  "favicon.png",
  "manifest.webmanifest",
  "icons/icon-192.png",
  "icons/icon-512.png"
];

self.addEventListener("install", e => {
  e.waitUntil(caches.open(VERSION).then(c => c.addAll(SHELL)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k.startsWith("bgs-") && k !== VERSION).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", e => {
  const req = e.request;
  if (req.method !== "GET") return;
  const url = new URL(req.url);
  if (url.origin !== location.origin) return;

  const base = new URL("./", self.registration.scope).pathname;
  const rel = decodeURIComponent(url.pathname.slice(base.length));

  // The game page: try the network first (so updates show up), fall back to cache offline.
  if (req.mode === "navigate" && (rel === "game/" || rel === "game/index.html")) {
    e.respondWith(
      fetch(req).then(res => {
        const copy = res.clone();
        caches.open(VERSION).then(c => c.put("game/", copy));
        return res;
      }).catch(() => caches.match("game/"))
    );
    return;
  }

  if (req.mode === "navigate") return; // other pages: normal network

  // Cover images + shell files: cache first, then network.
  const isCover = rel.startsWith("Games/") && /\/cover\.(png|jpe?g|webp|gif)$/i.test(rel);
  const isShell = !rel.startsWith("Games/");
  if (isCover || isShell) {
    e.respondWith(
      caches.match(req).then(hit => hit || fetch(req).then(res => {
        if (res.ok) { const copy = res.clone(); caches.open(VERSION).then(c => c.put(req, copy)); }
        return res;
      }))
    );
  }
  // Everything else (game files) goes straight to the network untouched.
});
