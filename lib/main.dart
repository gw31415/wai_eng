import 'package:flutter/material.dart';
import 'scaffolds/flashcards_menu.dart';
import 'modules/flashcard.dart';
import 'modules/flashcardbook.dart';
import 'modules/convert.dart' as convert;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

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

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '和医大 英単語',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: FlashCardsMenuScaffold(flashcards: [
        _howToUse,
        ...const [
          "骨筋_下肢英単語_1足",
          "骨筋_下肢英単語_2内転筋群",
          "骨筋_下肢英単語_3大腿神経支配",
          "骨筋_下肢英単語_4坐骨神経支配",
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
        ].map((name) => RandomBook(
            title: name,
            body: () async {
              final csv =
                  await rootBundle.loadString('lib/assets/csv/$name.csv');
              return convert.cardFromCsv(csv);
            })),
      ]),
    );
  }
}

// チュートリアルのカードを記述
final _howToUse = TutorialBook(title: "使い方", body: [
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
  @override
  final String title;
  final List<FlashCard> _body;
  @override
  init() async {
    return Future.value(TutorialOperator(body: _body));
  }

  TutorialBook({required this.title, required body})
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
