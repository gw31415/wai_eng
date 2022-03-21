import 'package:flutter/material.dart';

class FlashCard {
  final Widget question;
  final Widget answer;
  const FlashCard({required this.question, required this.answer});
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
