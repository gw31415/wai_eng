import 'package:http/http.dart' as http;
import 'package:tekartik_app_flutter_sembast/sembast.dart';

final Future<Database> _urldb =
    getDatabaseFactory(packageName: 'dev.amas.waiEng')
        .openDatabase('http_get_cache.sembast');
final _store = StoreRef<String, String>.main();

// キャッシュしながらHTTP Getリクエストを送ります。
Future<HttpGetCacheResult> httpGetCache(String url) async {
  final record = _store.record(url);
  final db = await _urldb;
  final httpClient = http.Client();
  final res = (await httpClient
      .get(Uri.parse(url))
      .timeout(const Duration(minutes: 1)));
  if (res.statusCode == 200) {
    return HttpGetCacheResult(status: HttpGetCacheStatus.ok, body: res.body);
  }
  try {
    db.transaction((transaction) async {
      await record.put(transaction, res.body);
    });
  } catch (e) {
    final cache = await record.get(db);
    if (cache != null) {
      return HttpGetCacheResult(status: HttpGetCacheStatus.ok, body: cache);
    }
  }
  return HttpGetCacheResult(status: HttpGetCacheStatus.error, body: 'Cannot get data from $url');
}

enum HttpGetCacheStatus {
  ok,
  cache,
  error,
}

class HttpGetCacheResult {
  final String body;
  final HttpGetCacheStatus status;
  const HttpGetCacheResult({required this.body, required this.status});
}
