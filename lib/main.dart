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
          title: "組織学プレ-英単語",
          csv: rootBundle.loadString('lib/assets/csv/組織学プレ-英単語.csv'),
        )
      ]),
    );
  }
}

final _howToUse = QueueBook(title: "使い方", body: [
  StringCard(
      question: "触れてください。", answer: "Good job!\nこちらが裏面です。\n手を離すと次のカードに進みます。"),
  StringCard(question: "こちらは表面です。", answer: "覚えたカードは左右にスワイプしましょう。"),
  StringCard(
      question: "覚えていないカードは再び出題されるようになっています。\n（チュートリアルは戻りません）",
      answer: "それでは頑張ってください！"),
]);
