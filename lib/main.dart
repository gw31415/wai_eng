import 'package:flutter/material.dart';
import 'scaffolds/flashcards_menu.dart';
import 'modules/flashcard.dart';

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
      home: FlashCardsMenuScaffold(flashcards: [_flashCardsDebug]),
    );
  }
}

final _flashCardsDebug = FlashCards(title: "使い方", body: [
  FlashCard.fromString(
      question: "触れてください。", answer: "Good job!\nこちらが裏面です。\n手を離すと次のカードに進みます。"),
  FlashCard.fromString(question: "こちらは表面です。", answer: "覚えたカードは左右にスワイプしましょう。"),
  FlashCard.fromString(
      question: "覚えていないカードは再び出題されるようになっています。", answer: "それでは頑張ってください！"),
]);
