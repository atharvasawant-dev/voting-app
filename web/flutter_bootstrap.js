{{flutter_js}}
{{flutter_build_config}}

(function () {
  const offlineCacheName = 'civicvote-offline-cache-v1';
  const offlineAssets = [
    'offline.html',
    'manifest.json',
    'icons/Icon-192.png',
    'icons/Icon-512.png',
    'favicon.png'
  ];

  async function warmOfflineCache() {
    if (!('caches' in window)) {
      return;
    }

    try {
      const cache = await caches.open(offlineCacheName);
      await cache.addAll(offlineAssets);
    } catch (error) {
      console.warn('Offline cache warmup failed.', error);
    }
  }

  window.addEventListener('load', async function () {
    await warmOfflineCache();

    _flutter.loader.load({
      serviceWorker: {
        serviceWorkerVersion: {{flutter_service_worker_version}}
      },
      onEntrypointLoaded: async function (engineInitializer) {
        const appRunner = await engineInitializer.initializeEngine();
        await appRunner.runApp();
      }
    });
  });
})();
