'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';
const RESOURCES = {
  "version.json": "b1512fe00929a7f18aa0401428c67c1b",
"splash/img/light-2x.png": "bfc62d007c2a0f0d9467a17c32437b60",
"splash/img/dark-4x.png": "37ec6fc57d33ed7668bdc19493b8ff74",
"splash/img/light-3x.png": "0d00826a0c538cedaa55de25122af03e",
"splash/img/dark-3x.png": "0d00826a0c538cedaa55de25122af03e",
"splash/img/light-4x.png": "37ec6fc57d33ed7668bdc19493b8ff74",
"splash/img/dark-2x.png": "bfc62d007c2a0f0d9467a17c32437b60",
"splash/img/dark-1x.png": "a024262f3508174d6c17f5f1a60d4a82",
"splash/img/light-1x.png": "a024262f3508174d6c17f5f1a60d4a82",
"splash/splash.js": "c6a271349a0cd249bdb6d3c4d12f5dcf",
"splash/style.css": "c8c9d901e6739bae6e89c3c9c044aa46",
"index.html": "05295ce74969e806aa1959c027d5e0a5",
"/": "05295ce74969e806aa1959c027d5e0a5",
"main.dart.js": "0a34f57068932cde590adae264a52af2",
"favicon.png": "5bdb1acfe1c9b2b3ab3f56683e8b0cf2",
"icons/Icon-192.png": "e2fd06b40a3a2b00e88837a78521531f",
"icons/Icon-maskable-192.png": "e2fd06b40a3a2b00e88837a78521531f",
"icons/Icon-maskable-512.png": "ec54fc658b7ac16e9778a66ca816152d",
"icons/Icon-512.png": "ec54fc658b7ac16e9778a66ca816152d",
"manifest.json": "819fc8cfdfd83b1f0f9a4b87b95f1661",
"assets/AssetManifest.json": "1cc150c3c34241782ff41ecb1f74dc7e",
"assets/NOTICES": "1292506b030e32bf86df42b1b402b138",
"assets/FontManifest.json": "dc3d03800ccca4601324923c0b1d6d57",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "6d342eb68f170c97609e9da345464e5e",
"assets/lib/assets/icon.png": "5bdb1acfe1c9b2b3ab3f56683e8b0cf2",
"assets/lib/assets/csv/%25E7%25B5%2584%25E7%25B9%2594%25E5%25AD%25A6%25E3%2583%2597%25E3%2583%25AC/%25E7%25B5%2584%25E7%25B9%2594%25E5%25AD%25A6%25E7%25B7%258F%25E8%25AB%2596_7%25E9%25AA%25A8%25E9%25AB%2584.csv": "c55b6c3e0feec6f7eb6edb1ad4262e1f",
"assets/lib/assets/csv/%25E7%25B5%2584%25E7%25B9%2594%25E5%25AD%25A6%25E3%2583%2597%25E3%2583%25AC/%25E7%25B5%2584%25E7%25B9%2594%25E5%25AD%25A6%25E7%25B7%258F%25E8%25AB%2596_2%25E4%25B8%258A%25E7%259A%25AE.csv": "53d95611f86fc14c34d0fcb7b68cdbee",
"assets/lib/assets/csv/%25E7%25B5%2584%25E7%25B9%2594%25E5%25AD%25A6%25E3%2583%2597%25E3%2583%25AC/%25E7%25B5%2584%25E7%25B9%2594%25E5%25AD%25A6%25E3%2583%2597%25E3%2583%25AC_%25E9%2587%258D%25E8%25A6%2581%25E5%258D%2598%25E8%25AA%259E.csv": "e9dfe23646381aa6e370c5058f9e677c",
"assets/lib/assets/csv/%25E7%25B5%2584%25E7%25B9%2594%25E5%25AD%25A6%25E3%2583%2597%25E3%2583%25AC/%25E7%25B5%2584%25E7%25B9%2594%25E5%25AD%25A6%25E7%25B7%258F%25E8%25AB%2596_6%25E8%25A1%2580%25E6%25B6%25B2.csv": "d07c150eb9177544229fdb0ca7949dd7",
"assets/lib/assets/csv/%25E7%25B5%2584%25E7%25B9%2594%25E5%25AD%25A6%25E3%2583%2597%25E3%2583%25AC/%25E7%25B5%2584%25E7%25B9%2594%25E5%25AD%25A6%25E7%25B7%258F%25E8%25AB%2596_8%25E7%25AD%258B%25E8%2582%2589.csv": "61c21b9d78ec9c8cf444d308e05ee512",
"assets/lib/assets/csv/%25E7%25B5%2584%25E7%25B9%2594%25E5%25AD%25A6%25E3%2583%2597%25E3%2583%25AC/%25E7%25B5%2584%25E7%25B9%2594%25E5%25AD%25A6%25E7%25B7%258F%25E8%25AB%2596_9%25E7%25A5%259E%25E7%25B5%258C%25E7%25B5%2584%25E7%25B9%2594.csv": "3812b403244c124d399972b447d4e2ad",
"assets/lib/assets/csv/%25E7%25B5%2584%25E7%25B9%2594%25E5%25AD%25A6%25E3%2583%2597%25E3%2583%25AC/%25E7%25B5%2584%25E7%25B9%2594%25E5%25AD%25A6%25E7%25B7%258F%25E8%25AB%2596_1%25E6%2596%25B9%25E6%25B3%2595.csv": "2e615d08e669a23e0808dd5c3c768ee3",
"assets/lib/assets/csv/%25E7%25B5%2584%25E7%25B9%2594%25E5%25AD%25A6%25E3%2583%2597%25E3%2583%25AC/%25E7%25B5%2584%25E7%25B9%2594%25E5%25AD%25A6%25E7%25B7%258F%25E8%25AB%2596_4%25E8%25BB%259F%25E9%25AA%25A8.csv": "b0b0593db26069d89b762ccd3b272fb2",
"assets/lib/assets/csv/%25E7%25B5%2584%25E7%25B9%2594%25E5%25AD%25A6%25E3%2583%2597%25E3%2583%25AC/%25E7%25B5%2584%25E7%25B9%2594%25E5%25AD%25A6%25E7%25B7%258F%25E8%25AB%2596_3%25E7%25B5%2590%25E5%2590%2588%25E7%25B5%2584%25E7%25B9%2594.csv": "4fdac561e977886fd1495e2baff86512",
"assets/lib/assets/csv/%25E7%25B5%2584%25E7%25B9%2594%25E5%25AD%25A6%25E3%2583%2597%25E3%2583%25AC/%25E7%25B5%2584%25E7%25B9%2594%25E5%25AD%25A6%25E7%25B7%258F%25E8%25AB%2596_5%25E9%25AA%25A8.csv": "968a187522d9e773b2a1490dfa17b5e2",
"assets/lib/assets/csv/%25E9%25AA%25A8%25E7%25AD%258B_%25E4%25B8%258B%25E8%2582%25A2%25E8%258B%25B1%25E5%258D%2598%25E8%25AA%259E_1%25E8%25B6%25B3.csv": "5a8479a2f5fb6d0b74274fc28eb79c8c",
"assets/lib/assets/csv/%25E9%25AA%25A8%25E7%25AD%258B_%25E4%25B8%258B%25E8%2582%25A2%25E8%258B%25B1%25E5%258D%2598%25E8%25AA%259E_2%25E5%2586%2585%25E8%25BB%25A2%25E7%25AD%258B%25E7%25BE%25A4.csv": "1bfe21322a4d2632162ec505905892b5",
"assets/lib/assets/csv/%25E9%25AA%25A8%25E7%25AD%258B_%25E4%25B8%258B%25E8%2582%25A2%25E8%258B%25B1%25E5%258D%2598%25E8%25AA%259E_4%25E5%259D%2590%25E9%25AA%25A8%25E7%25A5%259E%25E7%25B5%258C%25E6%2594%25AF%25E9%2585%258D.csv": "95d134130d884230c40749341cf0f5ce",
"assets/lib/assets/csv/%25E9%25AA%25A8%25E7%25AD%258B_%25E4%25B8%258B%25E8%2582%25A2%25E8%258B%25B1%25E5%258D%2598%25E8%25AA%259E_3%25E5%25A4%25A7%25E8%2585%25BF%25E7%25A5%259E%25E7%25B5%258C%25E6%2594%25AF%25E9%2585%258D.csv": "531a0f23c5e20e1c5b7a62c001e1f4f9",
"assets/fonts/MaterialIcons-Regular.otf": "7e7a6cccddf6d7b20012a548461d5d81"
};

// The application shell files that are downloaded before a service worker can
// start.
const CORE = [
  "/",
"main.dart.js",
"index.html",
"assets/NOTICES",
"assets/AssetManifest.json",
"assets/FontManifest.json"];
// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});

// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});

// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache.
        return response || fetch(event.request).then((response) => {
          cache.put(event.request, response.clone());
          return response;
        });
      })
    })
  );
});

self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});

// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}

// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
