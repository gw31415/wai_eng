import 'package:flutter/material.dart';
import 'dart:math' as math;

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
  void init() {}
  void onNext(int index, FlashCardResult res) {}
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

class RandomBook extends FlashCardBook {
  static List<int> _range(int i) {
    List<int> res = [];
    for (var j = 0; j < i; j++) {
      res.add(j);
    }
    return res;
  }

  @override
  final String title;
  final List<FlashCard> body;
  late List<int> _rest;
  late List<int> _log;
  var rand = math.Random();
  @override
  init() {
    _rest = _range(body.length);
    _log = [];
  }

  @override
  get(int index) {
    if (index < _log.length) return body[_log[index]];
    if (_rest.isEmpty) return null;
    if (_rest.length != 1) {
      do {
        _rest.shuffle();
      } while (_log.isNotEmpty && _log.last == _rest.last);
    }
    _log.add(_rest.last);
    return get(index);
  }

  @override
  onNext(int index, FlashCardResult res) {
    if (res == FlashCardResult.ok) _rest.remove(_log[index]);
  }

  RandomBook({required this.title, required this.body});
}
