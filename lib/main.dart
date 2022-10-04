import 'package:flutter/material.dart';
import 'scaffolds/flashcards_menu.dart';
import 'modules/flashcard.dart';
import 'modules/flashcardbook.dart';
import 'modules/convert.dart' as convert;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  LicenseRegistry.addLicense(() {
    return Stream<LicenseEntry>.fromIterable(<LicenseEntry>[
      const LicenseEntryWithLineBreaks(<String>['swipable_stack'], '''
        MIT License

        Copyright (c) 2021 Ryunosuke Watanabe

        Permission is hereby granted, free of charge, to any person obtaining a copy
        of this software and associated documentation files (the "Software"), to deal
        in the Software without restriction, including without limitation the rights
        to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
        copies of the Software, and to permit persons to whom the Software is
        furnished to do so, subject to the following conditions:

        The above copyright notice and this permission notice shall be included in all
        copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
        IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
        FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
        AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
        OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
        SOFTWARE.
		'''),
    ]);
  });
  runApp(const MainApp());
}

const _dbName = 'flash_card_book.sqlite';
const _tableName = 'urlbrowser';

class UrlBrowser extends FlashCardBookBrowser {
  final Set<List<String>> urls;
  final Future<Database> urldb;
  UrlBrowser({required Set<String> urls})
      : urls = urls.map((url) => url.split('/')).toSet(),
        urldb = (() async {
          final path =
              join((await getApplicationSupportDirectory()).path, _dbName);
          return openDatabase(
            path,
            version: 1,
          );
        })();
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
    final uri =
        "https://gw31415.github.io/wai_eng/sources/${Uri.encodeFull(path.join("/"))}.csv";
    return RandomBook(body: () async {
      final db = await urldb;
      try {
        final httpClient = http.Client();
        final res = (await httpClient
            .get(Uri.parse(uri))
            .timeout(const Duration(minutes: 1)));
        if (res.statusCode != 200) {
          throw Exception('Cannot get data.');
        }
        await db.execute('''
          CREATE TABLE IF NOT EXISTS $_tableName (
            url TEXT PRIMARY KEY,
            data TEXT
          )
	    ''');
        await db.insert(
          _tableName,
          {
            'url': uri,
            'data': res.body,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        return convert.cardFromCsv(res.body);
      } catch (e) {
        final res = await db.query(
          _tableName,
          where: 'url=?',
          whereArgs: [uri],
        );
        if (res.isNotEmpty) {
          if (res.first['data'] != null) {
            final String csv = res.first['data']!.toString();
            return convert.cardFromCsv(csv);
          }
        }
      }
      throw Exception('Cannot get data from $uri');
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
          browser: UrlBrowser(urls: const {
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
            "ハングル14-17単語",
          })),
    );
  }
}

// チュートリアルのカードを記述
final _howToUse = TutorialBook(body: [
  StringCard(
    question: "触れてください。",
    answer: "Good job!\nこちらが裏面です。\n手を離すと次のカードに進みます。",
  ),
  StringCard(
    question: "こちらは表面です。",
    answer: "覚えたカードは左右にスワイプしましょう。\n覚えられなかったカードは指を離してスキップしましょう。",
  ),
  StringCard(
    question: "覚えていないカードは記録されます。",
    answer: "それでは頑張ってください！",
  ),
]);

class TutorialBook extends FlashCardBook {
  final List<FlashCard> _body;
  @override
  init() async {
    return Future.value(TutorialOperator(body: _body));
  }

  TutorialBook({required body})
      : _body = body,
        super();
}

class TutorialOperator extends FlashCardBookOperator {
  final List<FlashCard> body;
  TutorialOperator({required this.body});
  @override
  FlashCard? get(int index) {
    if (index < body.length) return body[index];
    return null;
  }

  @override
  onNext(index, res) {}
  @override
  onUndo() {}

  @override
  final isForceFinished = false;
}
