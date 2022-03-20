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
      home: const FlashCardsMenuScaffold(flashcards: [_flashCardsDebug]),
    );
  }
}

const _flashCardsDebug = FlashCards(title: "使い方", body: [
  FlashCard(question: Text("触れてください。"), answer: Text("Good job!\nこちらが裏面です。\n手を離すと次のカードに進みます。")),
  FlashCard(question: Text("こちらは表面です。"), answer: Text("覚えたカードは左右にスワイプしましょう。")),
  FlashCard(question: Text("覚えていないカードは再び出題されるようになっています。"), answer: Text("それでは頑張ってください！")),
]);
