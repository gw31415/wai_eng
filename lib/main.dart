import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'modules/flashcard.dart';
import 'scaffolds/flashcards_menu.dart';
import 'modules/flashcardbook.dart';
import 'modules/convert.dart' as convert;
import 'package:flutter/foundation.dart';
import 'modules/httpgetcache.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

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

/// Dufsサーバーに公開されたファイルを閲覧する。
class DufsBrowser extends FlashCardBookBrowser {
  /// ベースとなるURL
  /// 最後にスラッシュあり
  final String _baseUrl;

  /// ファイル一覧
  final Set<String> _files = {};

  DufsBrowser({
    /// DufsサーバーのURL
    required String dufsUrl,
  }) : _baseUrl = dufsUrl[dufsUrl.length - 1] == "/" ? dufsUrl : "$dufsUrl/";

  // PATHをHTTP GetするURLに変換する関数
  String _converter(List<String> path,
      {bool simple = false, bool encoded = true}) {
    return "$_baseUrl${encoded ? Uri.encodeFull(path.join("/")) : path.join("/")}${simple ? "?simple" : ""}";
  }

  @override
  Future<Set<String>> ls(List<String> dir) async {
    final res = await httpGetCache(_converter(dir, simple: true));
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
    return RandomBook(
      body: () async {
        final res = await httpGetCache(uri);
        if (res.status != HttpGetCacheStatus.error) {
          return convert.cardFromCsv(res.body);
        }
        throw Exception(res.body);
      },
      fileName: path.last,
      uri: uri,
    );
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
          browser: DufsBrowser(dufsUrl: "https://dufs.amas.dev")),
    );
  }
}

class RandomBook implements ListableBook, SharableBook {
  final Future<List<FlashCard>> Function() _body;

  /// 元ファイルあるURI
  final String uri;

  /// 共有時のファイル名
  final String fileName;

  @override
  open() => _body();

  @override
  share() async {
    final res = await httpGetCache(uri);
    if (res.status != HttpGetCacheStatus.error) {
      final Uint8List unit8List = Uint8List.fromList([
        0xEF,
        0xBB,
        0xBF,
        ...utf8.encode(res.body),
      ]);
      getTemporaryDirectory();
      final xfile = XFile.fromData(
        unit8List,
        mimeType: "text/csv",
        name: fileName,
      );
      return xfile;
    }
    throw Exception(res.body);
  }

  RandomBook({required body, required this.uri, required this.fileName})
      : _body = body;
}
