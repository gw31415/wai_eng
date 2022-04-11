import 'package:flutter/material.dart';
import 'dart:math' as math;

abstract class FlashCard {
  Widget get question;
  Widget get answer;
  Text get questionAlt {
    return const Text("(表示できません)");
  }

  Text get answerAlt {
    return const Text("(表示できません)");
  }

  const FlashCard();
}

class StringCard extends FlashCard {
  @override
  Widget get question {
    return Padding(padding: const EdgeInsets.all(8), child: questionAlt);
  }

  @override
  Widget get answer {
    return Padding(padding: const EdgeInsets.all(8), child: answerAlt);
  }

  @override
  Text questionAlt;
  @override
  Text answerAlt;

  StringCard({required String question, required String answer})
      : questionAlt = Text(question),
        answerAlt = Text(answer),
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
  Row? get statusRow {
    return null;
  }

  bool get isForceFinished {
    return false;
  }
}

abstract class UsersBook extends FlashCardBook {
  static Future<List<FlashCard>> _convertToBody(
      Future<String> futureCsv) async {
    final csv = await futureCsv;
    List<StringCard> cards = [];
    for (var rowString in csv.split('\n')) {
      final row = rowString.split(',');
      switch (row.length) {
        case 0:
          break;
        case 1:
          if (row[0] != "") {
            cards.add(StringCard(question: row[0], answer: ""));
          }
          break;
        default:
          if (row[0] != "" && row[1] != "") {
            cards.add(StringCard(question: row[0], answer: row[1]));
          }
          break;
      }
    }
    return cards;
  }

  @override
  final String title;
  @override
  final Future<List<FlashCard>> body;

  UsersBook({required this.title, required List<FlashCard> body})
      : body = Future.value(body);
  UsersBook.fromCsv({required this.title, required Future<String> csv})
      : body = _convertToBody(csv);
}

class TutorialBook extends FlashCardBook {
  @override
  final String title;
  final List<FlashCard> _body;
  @override
  init() async {
    return Future.value(QueueBookOperator(body: _body));
  }

  TutorialBook({required this.title, required body})
      : _body = body,
        super();
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

  @override
  final isForceFinished = false;
}

class RandomBook extends UsersBook {
  @override
  init() async {
    return Future.value(RandomBookOperator(body: await body));
  }

  RandomBook({required title, required body}) : super(title: title, body: body);
  RandomBook.fromCsv({required title, required Future<String> csv})
      : super.fromCsv(title: title, csv: csv);
}

class _Record {
  final int index;
  FlashCardResult? res;
  _Record({required this.index, this.res});
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
  late List<_Record> _log;
  late List<int> _buffer;
  int get _okCount {
    return _log.where((r) => (r.res == FlashCardResult.ok)).length;
  }

  var rand = math.Random();

  @override
  get(int index) {
    if (index < _log.length) return body[_log[index].index];
    if (_buffer.isNotEmpty) {
      _log.add(_Record(index: _buffer.last));
      _buffer.removeLast();
    } else {
      _log.add(_Record(index: _log[rand.nextInt(_log.length)].index));
    }
    return get(index);
  }

  @override
  get isForceFinished {
    return _okCount >= body.length;
  }

  @override
  onNext(int index, FlashCardResult res) {
    if (res == FlashCardResult.ok) {
      // 既に記録されたレコードの修正
      final changingRecord = _log[index];
      _log[index] = _Record(
        index: changingRecord.index,
        res: FlashCardResult.ok,
      );
    }

    if (_buffer.length >= 3) {
      late final int addedIndex;
      switch (res) {
        case FlashCardResult.ok:
          if (_rest.isEmpty) return;
          addedIndex = _rest.last;
          _rest.removeLast();
          break;
        case FlashCardResult.skipped:
          addedIndex = _log[index].index;
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

  @override
  get statusRow {
    if (_okCount >= body.length) {
      return Row(children: const [Text("Completed.")]);
    }
    return Row(children: [Text(" $_okCount / ${body.length}")]);
  }
}
