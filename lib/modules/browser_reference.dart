import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:wai_eng/scaffolds/book_player.dart';

import 'convert.dart' as convert;
import '../scaffolds/flashcardbook_browser.dart';
import 'flashcardbook.dart';
import 'httpgetcache.dart';

import 'dart:convert';

/// データベースの形式を表す文字列
enum BrowserType {
  /// Dufsで建てたサーバー
  dufs,
}

class BrowserReference {
  /// ブラウザのタイプ
  final BrowserType type;

  /// 引数
  final Map args;

  /// 位置
  final List<String> path;

  /// 表示名
  String displayName;

  BrowserReference(String json)
      : type = BrowserType.values.byName(jsonDecode(json)['type'] as String),
        args = jsonDecode(json)['args'] as Map,
        path = (jsonDecode(json)['path'] as List)
            .map((e) => e.toString())
            .toList(),
        displayName = jsonDecode(json)['displayName'];

  /// Dufsで建てたサーバー
  BrowserReference.dufs({
    required String url,
    this.path = const [],
    required this.displayName,
  })  : type = BrowserType.dufs,
        args = {'url': url};

  /// JSONにシリアライズする
  String get toJson => jsonEncode({
        'type': type.name,
        'args': args,
        'path': path,
        'displayName': displayName,
      });

  /// FlashCardBookBrowserに変換する
  FlashCardBookBrowser get toBrowser {
    switch (type) {
      case BrowserType.dufs:
        final url = args['url'] as String;
        return DufsBrowser(dufsUrl: url);
    }
  }

  /// メニューのアイテムに変換する
  Future<SettingsTile> toSettingsTile({
    Icon Function(
      SegmentType segment,
      BrowserType browser,
    )? iconSelector,
  }) async {
    Icon defaultSelector(SegmentType segment, BrowserType browser) {
      if (segment == SegmentType.flashCardBook) {
        return const Icon(Icons.play_arrow);
      }
      return const Icon(Icons.cloud);
    }

    final browser = toBrowser;
    final segmentType = await browser.type(path);
    final icon = iconSelector != null
        ? iconSelector.call(segmentType, type)
        : defaultSelector(segmentType, type);

    switch (type) {
      case BrowserType.dufs:
        return SettingsTile.navigation(
          leading: icon,
          title: Text(displayName),
          onPressed: (context) async {
            switch (segmentType) {
              case SegmentType.flashCardBook:
                // カードのショートカット
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (context) {
                  return FlashCardBookPlayerScaffold(
                    player: () async =>
                        RandomBookPlayer(await browser.get(path).open()),
                    title: Text(path.last),
                  );
                }));
                break;
              case SegmentType.directory:
                // パスのショートカット
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (context) {
                  return FlashCardBookBrowserScaffold(
                    title: Text(displayName),
                    browser: browser,
                    pwd: path,
                  );
                }));
            }
          },
        );
    }
  }
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
    return res.body.trim().split('\n').map((line) {
      if (line[line.length - 1] == '/') {
        return line.substring(0, line.length - 1);
      } else {
        _files.add(dir.isEmpty ? line : "${dir.join("/")}/$line");
        return line;
      }
    }).toSet();
  }

  @override
  FlashCardBrowserItem get(List<String> path) {
    final uri = _converter(path);
    return DufsBook(
      url: uri,
      fileName: path.last,
    );
  }

  @override
  Future<SegmentType> type(List<String> path) async {
    if (_files.isNotEmpty) {
      if (_files.contains(path.join("/"))) {
        return SegmentType.flashCardBook;
      }
      return SegmentType.directory;
    }
    if (path.isEmpty) {
      return SegmentType.directory;
    }
    final uri = _converter(path.sublist(0, path.length - 1), simple: true);
    HttpGetCacheResult res;
    try {
      res = await httpGetCache(uri, offline: true);
    } catch (e) {
      res = await httpGetCache(uri);
    }
    final sig = res.body.trim().split('\n');
    if (sig.contains(path.last)) {
      return SegmentType.flashCardBook;
    }
    return SegmentType.directory;
  }

  @override
  BrowserReference reference(List<String> path) {
    return BrowserReference.dufs(
        url: _baseUrl, displayName: path.last, path: path);
  }
}

class DufsBook implements Listable, Sharable {
  /// 元ファイルあるURI
  final String url;

  /// 共有時のファイル名
  final String fileName;

  @override
  Future<FlashCardBook> open() async {
    final res = await httpGetCache(url);
    return convert.cardFromCsv(res.body);
  }

  @override
  share() async {
    final res = await httpGetCache(url);
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

  DufsBook({required this.url, required this.fileName});
}
