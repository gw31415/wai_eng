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

class HttpGetBrowser extends FlashCardBookBrowser {
  // セグメントをスラッシュで区切って表現したパスのセット
  final Set<List<String>> urls;
  // PATHをHTTP GetするURLに変換する関数
  final String Function(List<String>) converter;
  HttpGetBrowser({required Set<String> paths, required this.converter})
      : urls = paths.map((url) => url.split('/')).toSet();
  @override
  Set<String> ls(List<String> dir) {
    return urls
        .where((url) => url.length >= dir.length)
        .where((url) {
          for (var i = 0; i < dir.length; i++) {
            if (url[i] != dir[i]) {
              return false;
            }
          }
          return true;
        })
        .map((url) => url[dir.length])
        .toSet();
  }

  @override
  FlashCardBook getBook(List<String> path) {
    final uri = converter(path);
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
    main:
    for (var url in urls.where((element) => path.length == element.length)) {
      for (var i = 0; i < url.length; i++) {
        if (url[i] != path[i]) {
          continue main;
        }
      }
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
          browser: HttpGetBrowser(
              converter: (path) =>
                  "https://raw.githubusercontent.com/gw31415/wai_eng/main/sources/${Uri.encodeFull(path.join("/"))}.csv",
              paths: const {
                "骨筋/下肢英単語/1足",
                "骨筋/下肢英単語/2内転筋群",
                "骨筋/下肢英単語/3大腿神経支配",
                "骨筋/下肢英単語/4坐骨神経支配",
                "骨筋/頭部/脳神経通路",
                "骨筋/頭部/分離骨英語と個数",
                "組織学プレ/組織学プレ_重要単語",
                "組織学プレ/組織学総論_1方法",
                "組織学プレ/組織学総論_2上皮",
                "組織学プレ/組織学総論_3結合組織",
                "組織学プレ/組織学総論_4軟骨",
                "組織学プレ/組織学総論_5骨",
                "組織学プレ/組織学総論_6血液",
                "組織学プレ/組織学総論_7骨髄",
                "組織学プレ/組織学総論_8筋肉",
                "組織学プレ/組織学総論_9神経組織",
                "系統解剖/大腿断面",
                "系統解剖/下腿断面",
                "系統解剖/L1(下面)",
                "系統解剖/Th5(下面)",
                "神経解剖/久岡/眼球",
                "神経解剖/久岡/視覚系",
                "神経解剖/久岡/聴覚",
                "神経解剖/久岡/視覚対応性地図",
                "内蔵/金井/呼吸器",
                "内蔵/金井/内分泌",
                "ハングル14-17単語",
                "薬理学総論/GPCRの分類",
                "薬理学総論/シトクロムP450と相互作用する薬剤",
              })),
    );
  }
}
