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
  try {
    final res = (await httpClient
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 30)));
    if (res.statusCode == 200) {
      db.transaction((transaction) async {
        await record.put(transaction, res.body);
      });
      return HttpGetCacheResult(status: HttpGetCacheStatus.ok, body: res.body);
    }
    throw res.statusCode;
  } catch (e) {
    final cache = await record.get(db);
    if (cache != null) {
      return HttpGetCacheResult(status: HttpGetCacheStatus.ok, body: cache);
    }
    return HttpGetCacheResult(
      status: HttpGetCacheStatus.error,
      body: '$e',
    );
  }
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
