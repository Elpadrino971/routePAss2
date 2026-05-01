/* ROUTEPASS service worker — Web Push */

self.addEventListener('install', (event) => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(self.clients.claim());
});

self.addEventListener('push', (event) => {
  let payload = { title: 'ROUTEPASS', body: '' };
  try {
    if (event.data) payload = event.data.json();
  } catch {
    // texte brut
    payload.body = event.data ? event.data.text() : '';
  }
  event.waitUntil(
    self.registration.showNotification(payload.title || 'ROUTEPASS', {
      body: payload.body || '',
      icon: '/logo-r.svg',
      badge: '/logo-r.svg',
      tag: payload.tag,
      data: payload.url ? { url: payload.url } : undefined,
    })
  );
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const url = event.notification.data?.url || '/home';
  event.waitUntil(
    self.clients.matchAll({ type: 'window' }).then((clients) => {
      for (const client of clients) {
        if (client.url.endsWith(url) && 'focus' in client) return client.focus();
      }
      if (self.clients.openWindow) return self.clients.openWindow(url);
      return undefined;
    })
  );
});
