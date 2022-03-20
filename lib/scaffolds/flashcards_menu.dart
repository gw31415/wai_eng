import 'package:flutter/material.dart';
import '../modules/flashcard.dart';

class _FlashCardsListView extends StatelessWidget {
  final List<FlashCards> flashcards;
  const _FlashCardsListView({Key? key, required this.flashcards})
      : super(key: key);
  @override
  Widget build(context) {
    return ListView.builder(
        itemCount: flashcards.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(flashcards[index].title),
          );
        });
  }
}

class FlashCardsMenuScaffold extends StatelessWidget {
  final List<FlashCards> flashcards;
  const FlashCardsMenuScaffold({Key? key, required this.flashcards})
      : super(key: key);
  @override
  Widget build(context) {
    return Scaffold(body: _FlashCardsListView(flashcards: flashcards));
  }
}
