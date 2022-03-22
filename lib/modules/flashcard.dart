import 'package:flutter/material.dart';

class FlashCard {
  final Widget question;
  final Widget answer;
  const FlashCard({required this.question, required this.answer});
  FlashCard.fromString({required String question, required String answer}) :
    question = Padding(padding: const EdgeInsets.all(8), child: Text(question)),
    answer = Padding(padding: const EdgeInsets.all(8), child: Text(answer));
}

class FlashCards {
  final List<FlashCard> body;
  final String title;
  const FlashCards({required this.title, required this.body});
  int length() {
    return body.length;
  }

  FlashCard? get(int i) {
    if (length() - 1 < i) {
      return null;
    }
    return body[i];
  }
}

