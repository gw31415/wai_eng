import 'package:flutter/material.dart';
import 'scaffolds/flashcards_menu.dart';
import 'modules/flashcard.dart';
import 'package:flutter/services.dart';

void main() {
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
        RandomBook.fromCsv(
          title: "組織学プレ 重要単語",
          csv: rootBundle.loadString('lib/assets/csv/組織学プレ/組織学プレ_重要単語.csv'),
        ),
        RandomBook.fromCsv(
          title: "組織学総論 1:方法",
          csv: rootBundle.loadString('lib/assets/csv/組織学プレ/組織学総論_1方法.csv'),
        ),
        RandomBook.fromCsv(
          title: "組織学総論 2:上皮",
          csv: rootBundle.loadString('lib/assets/csv/組織学プレ/組織学総論_2上皮.csv'),
        ),
        RandomBook.fromCsv(
          title: "組織学総論 3:結合組織",
          csv: rootBundle.loadString('lib/assets/csv/組織学プレ/組織学総論_3結合組織.csv'),
        ),
        RandomBook.fromCsv(
          title: "組織学総論 4:軟骨",
          csv: rootBundle.loadString('lib/assets/csv/組織学プレ/組織学総論_4軟骨.csv'),
        ),
        RandomBook.fromCsv(
          title: "組織学総論 5:骨",
          csv: rootBundle.loadString('lib/assets/csv/組織学プレ/組織学総論_5骨.csv'),
        ),
        RandomBook.fromCsv(
          title: "組織学総論 6:血液",
          csv: rootBundle.loadString('lib/assets/csv/組織学プレ/組織学総論_6血液.csv'),
        ),
        RandomBook.fromCsv(
          title: "組織学総論 7:骨髄",
          csv: rootBundle.loadString('lib/assets/csv/組織学プレ/組織学総論_7骨髄.csv'),
        ),
        RandomBook.fromCsv(
          title: "組織学総論 8:筋肉",
          csv: rootBundle.loadString('lib/assets/csv/組織学プレ/組織学総論_8筋肉.csv'),
        ),
        RandomBook.fromCsv(
          title: "組織学総論 9:神経組織",
          csv: rootBundle.loadString('lib/assets/csv/組織学プレ/組織学総論_9神経組織.csv'),
        ),
      ]),
    );
  }
}

final _howToUse = TutorialBook(title: "使い方", body: [
  StringCard(
      question: "触れてください。", answer: "Good job!\nこちらが裏面です。\n手を離すと次のカードに進みます。"),
  StringCard(question: "こちらは表面です。", answer: "覚えたカードは左右にスワイプしましょう。"),
  StringCard(
      question: "覚えていないカードは再び出題されるようになっています。\n（チュートリアルは戻りません）",
      answer: "それでは頑張ってください！"),
]);
