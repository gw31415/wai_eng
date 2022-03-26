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

abstract class FlashCardBookWithBody extends FlashCardBook {
  static List<FlashCard> _convertToBody(String csv) {
    return csv.split('\n').map((rowString) {
      final row = rowString.split(',');
      switch (row.length) {
        case 0:
          return FlashCard.fromString(question: "", answer: "");
        case 1:
          return FlashCard.fromString(question: row[0], answer: "");
        default:
          return FlashCard.fromString(question: row[0], answer: row[1]);
      }
    }).toList();
  }

  final List<FlashCard> body;
  const FlashCardBookWithBody({required this.body}) : super();

  FlashCardBookWithBody.fromCsv({required String csv})
      : body = _convertToBody(csv),
        super();
}

class QueueBook extends FlashCardBookWithBody {
  @override
  final String title;
  @override
  FlashCard? get(int index) {
    if (index < body.length) return body[index];
    return null;
  }

  const QueueBook({required this.title, required body}) : super(body: body);
  QueueBook.fromCsv({required this.title, required csv})
      : super.fromCsv(csv: csv);
}

class RandomBook extends FlashCardBookWithBody {
  static List<int> _range(int i) {
    List<int> res = [];
    for (var j = 0; j < i; j++) {
      res.add(j);
    }
    return res;
  }

  @override
  final String title;
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

  RandomBook({required this.title, required body}) : super(body: body);
  RandomBook.fromCsv({required this.title, required csv})
      : super.fromCsv(csv: csv);
}
