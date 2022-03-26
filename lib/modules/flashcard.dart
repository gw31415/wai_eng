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
  late List<int> _buffer;
  var rand = math.Random();
  @override
  init() {
    _rest = _range(body.length);
    _rest.shuffle();
    _log = [];
    if (_rest.length > 10) {
      _buffer = _rest.sublist(0, 10);
      _rest.removeRange(0, 10);
    } else {
	  _buffer = _rest;
	  _rest = [];
	}
  }

  @override
  get(int index) {
    if (index < _log.length) return body[_log[index]];
    if (_buffer.isEmpty) return null;
    _log.add(_buffer.last);
    _buffer.removeLast();
    return get(index);
  }

  @override
  onNext(int index, FlashCardResult res) {
    if (_buffer.length > 2) {
      late final int addedIndex;
      switch (res) {
        case FlashCardResult.ok:
          if (_rest.isEmpty) return;
          addedIndex = _rest.last;
          _rest.removeLast();
          break;
        case FlashCardResult.skipped:
          addedIndex = _log[index];
          break;
      }
      _buffer.insert(rand.nextInt(4), addedIndex);
    }
  }

  RandomBook({required this.title, required body}) : super(body: body);
  RandomBook.fromCsv({required this.title, required csv})
      : super.fromCsv(csv: csv);
}
