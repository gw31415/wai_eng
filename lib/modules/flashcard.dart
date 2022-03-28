import 'package:flutter/material.dart';
import 'dart:math' as math;

abstract class FlashCard {
  Widget get question;
  Widget get answer;
  const FlashCard();
}

class StringCard extends FlashCard {
  @override
  Widget question;
  @override
  Widget answer;
  StringCard({required String question, required String answer})
      : question =
            Padding(padding: const EdgeInsets.all(8), child: Text(question)),
        answer = Padding(padding: const EdgeInsets.all(8), child: Text(answer)),
        super();
}

enum FlashCardResult {
  ok,
  skipped,
}

abstract class FlashCardBook {
  const FlashCardBook();
  String get title;
  Future<List<FlashCard>>? get body {
    return null;
  }

  Future<FlashCardBookOperator> init();
}

abstract class FlashCardBookOperator {
  FlashCard? get(int index);
  void onNext(int index, FlashCardResult res);
  void onUndo();
}

abstract class FlashCardBookWithBody extends FlashCardBook {
  static Future<List<FlashCard>> _convertToBody(
      Future<String> futureCsv) async {
    final csv = await futureCsv;
    return csv.split('\n').map((rowString) {
      final row = rowString.split(',');
      switch (row.length) {
        case 0:
          return StringCard(question: "", answer: "");
        case 1:
          return StringCard(question: row[0], answer: "");
        default:
          return StringCard(question: row[0], answer: row[1]);
      }
    }).toList();
  }

  @override
  final String title;
  @override
  final Future<List<FlashCard>> body;

  FlashCardBookWithBody({required this.title, required List<FlashCard> body})
      : body = Future.value(body);
  FlashCardBookWithBody.fromCsv(
      {required this.title, required Future<String> csv})
      : body = _convertToBody(csv);
}

class QueueBook extends FlashCardBookWithBody {
  @override
  init() async {
    return Future.value(QueueBookOperator(body: await body));
  }

  QueueBook({required title, required body}) : super(title: title, body: body);
  QueueBook.fromCsv({required title, required Future<String> csv})
      : super.fromCsv(title: title, csv: csv);
}

class QueueBookOperator extends FlashCardBookOperator {
  final List<FlashCard> body;
  QueueBookOperator({required this.body});
  @override
  FlashCard? get(int index) {
    if (index < body.length) return body[index];
    return null;
  }

  @override
  onNext(index, res) {}
  @override
  onUndo() {}
}

class RandomBook extends FlashCardBookWithBody {
  @override
  init() async {
    return Future.value(RandomBookOperator(body: await body));
  }

  RandomBook({required title, required body}) : super(title: title, body: body);
  RandomBook.fromCsv({required title, required Future<String> csv})
      : super.fromCsv(title: title, csv: csv);
}

class RandomBookOperator extends FlashCardBookOperator {
  static const _bufferSize = 10;
  static List<int> _range(int i) {
    List<int> res = [];
    for (var j = 0; j < i; j++) {
      res.add(j);
    }
    return res;
  }

  final List<FlashCard> body;
  RandomBookOperator({required this.body}) {
    _rest = _range(body.length);
    _rest.shuffle();
    _log = [];
    if (_rest.length > _bufferSize) {
      _buffer = _rest.sublist(0, _bufferSize);
      _rest.removeRange(0, _bufferSize);
    } else {
      _buffer = _rest;
      _rest = [];
    }
  }

  late List<int> _rest;
  late List<int> _log;
  late List<int> _buffer;
  var rand = math.Random();

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
    if (_buffer.length >= 3) {
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

  @override
  onUndo() {
    if (_log.isNotEmpty) _log.removeLast();
    while (_buffer.length > _bufferSize - 3) {
      _rest.add(_buffer.first);
      _buffer.remove(0);
    }
  }
}
