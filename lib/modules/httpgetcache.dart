import 'package:http/http.dart' as http;
import 'package:tekartik_app_flutter_sembast/sembast.dart';

import 'preferences.dart';

const packageName = 'dev.amas.waiEng';
const dbName = 'http_get_cache.sembast';

final _store = StoreRef<String, String>.main();

// キャッシュの削除
Future<void> deleteCache() =>
    getDatabaseFactory(packageName: packageName).deleteDatabase(dbName);

// キャッシュしながらHTTP Getリクエストを送ります。
Future<HttpGetCacheResult> httpGetCache(String url,
    {bool offline = false}) async {
  final db = getDatabaseFactory(packageName: packageName).openDatabase(dbName);
  final record = _store.record(url);
  final httpClient = http.Client();
  try {
    if (offline) throw "offline mode";
    final res = (await httpClient
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 30)));
    if (res.statusCode == 200) {
      if (await PreferencesManager.autoCache.getter()) {
        // キャッシュモードがオンの場合
        (await db).transaction((transaction) async {
          await record.put(transaction, res.body);
        });
      }
      return HttpGetCacheResult(status: HttpGetCacheStatus.ok, body: res.body);
    }
    throw res.statusCode;
  } catch (e) {
    final cache = await record.get(await db);
    if (cache != null) {
      return HttpGetCacheResult(status: HttpGetCacheStatus.ok, body: cache);
    }
    rethrow;
  }
}

enum HttpGetCacheStatus {
  ok,
  cache,
}

class HttpGetCacheResult {
  final String body;
  final HttpGetCacheStatus status;
  const HttpGetCacheResult({required this.body, required this.status});
}
