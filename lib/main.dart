import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'scaffolds/flashcards_menu.dart';
import 'modules/flashcardbook.dart';
import 'modules/convert.dart' as convert;
import 'package:flutter/foundation.dart';
import 'modules/httpgetcache.dart';

void main() {
  LicenseRegistry.addLicense(() {
    return Stream.fromFuture((() async {
      final licence =
          await rootBundle.loadString('lib/modules/swipable_stack/LICENSE');
      return LicenseEntryWithLineBreaks(['swipable_stack'], licence);
    })());
  });
  runApp(const MainApp());
}

class DufsBrowser extends FlashCardBookBrowser {
  /// ベースとなるURL
  /// 最後にスラッシュあり
  final String baseUrl;

  /// ファイル一覧
  final Set<String> _files = {};

  DufsBrowser({required String baseUrl})
      : baseUrl = baseUrl[baseUrl.length - 1] == "/" ? baseUrl : "$baseUrl/";

  // PATHをHTTP GetするURLに変換する関数
  String _converter(List<String> path, {bool json = false}) {
    return "$baseUrl${Uri.encodeFull(path.join("/"))}?${json ? "json" : "simple"}";
  }

  @override
  Future<Set<String>> ls(List<String> dir) async {
    final res = await httpGetCache(_converter(dir));
    if (res.status != HttpGetCacheStatus.error) {
      return res.body.trim().split('\n').map((line) {
        if (line[line.length - 1] == '/') {
          return line.substring(0, line.length - 1);
        } else {
          _files.add(dir.isEmpty ? line : "${dir.join("/")}/$line");
          return line;
        }
      }).toSet();
    }
    throw Exception(res.body);
  }

  @override
  FlashCardBook getBook(List<String> path) {
    final uri = _converter(path);
    return RandomBook(body: () async {
      final res = await httpGetCache(uri);
      if (res.status != HttpGetCacheStatus.error) {
        return convert.cardFromCsv(res.body);
      }
      throw Exception(res.body);
    });
  }

  @override
  SegmentType type(List<String> path) {
    if (_files.contains(path.join("/"))) {
      return SegmentType.flashCardBook;
    }
    return SegmentType.directory;
  }
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WaiEng',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.teal,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.teal,
        brightness: Brightness.dark,
      ),
      home: FlashCardBookBrowseScaffold(
          title: const Text('WaiEng'),
          browser: DufsBrowser(baseUrl: "https://dufs.amas.dev")),
    );
  }
}
