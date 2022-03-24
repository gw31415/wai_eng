import 'package:flutter/material.dart';

class FlashCard {
  final Widget question;
  final Widget answer;
  const FlashCard({required this.question, required this.answer});
  FlashCard.fromString({required String question, required String answer})
      : question =
            Padding(padding: const EdgeInsets.all(8), child: Text(question)),
        answer = Padding(padding: const EdgeInsets.all(8), child: Text(answer));
}

enum FlashCardResult {
  ok,
  skipped,
}

abstract class FlashCardBook {
  const FlashCardBook();
  String get title;
  FlashCard? get(int index);
  void onNext(int index, FlashCardResult direction) {}
  void onUndo() {}
}

class QueueBook extends FlashCardBook {
  @override
  final String title;
  final List<FlashCard> body;
  @override
  FlashCard? get(int index) {
    if (index < body.length) return body[index];
    return null;
  }

  const QueueBook({required this.title, required this.body});
}
