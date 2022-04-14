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

  /// null以外を返したときのみ一覧表示に対応
  Future<List<FlashCard>>? get body {
    return null;
  }

  /// FlashCardBookPlayerの初期化時やリプレイ時に発火する。
  /// FlashCardBookOperatorのインスタンスを新規に作成しFlashCardBookPlayerに返す。
  Future<FlashCardBookOperator> init();
}

abstract class FlashCardBookOperator {
  /// nullを返した場合、最表面カードがnullの番になったタイミングでカード操作が終了されリプレイボタンが表示される。
  FlashCard? get(int index);

  void onNext(int index, FlashCardResult res);
  void onUndo();

  /// 下部に表示されるFlashCardBook実行中ステータス
  Widget? get statusBar {
    return null;
  }

  /// FlashCard? get(int index)が空を返さなかった場合でも中断したい場合にtrueを返すように実装する。
  /// onNextで発火
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
  static const _bufferMaximumSize = 10;
  static const _bufferMinimumSize = 4; // 4以上
  static const _flowRange = 4; // _bufferMinimumSize以下
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
    if (_rest.length > _bufferMaximumSize) {
      _buffer = _rest.sublist(0, _bufferMaximumSize);
      _rest.removeRange(0, _bufferMaximumSize);
    } else {
      _buffer = _rest;
      _rest = [];
    }
  }

  /// 一度も出題されていないカードのIdリスト
  late List<int> _rest;

  /// 呼びだされたカードと結果を順番に記録。
  /// カードがUIによって呼ばれると一旦結果をnullにして登録しておき、後でスワイプされた時に結果を登録しなおす
  late List<_Record> _log;

  /// カードを呼びだす前にプールしておくところ。
  /// スキップされたカードは再び_bufferの後ろのほうに無作為に戻される。
  late List<int> _buffer;

  int get _okCount {
    int okcount = 0;
    for (var cardId = 0; cardId < body.length; cardId++) {
      for (var logI = _log.length - 1; logI >= 0; logI--) {
        final record = _log[logI];
        if (record.index == cardId && record.res != null) {
          if (record.res == FlashCardResult.ok) okcount++;
          break;
        }
      }
    }
    return okcount;
  }

  var rand = math.Random();

  @override
  get(int index) {
    if (index < _log.length) return body[_log[index].index];
    _log.add(_Record(index: _buffer.last));
    _buffer.removeLast();
    return get(index);
  }

  @override
  get isForceFinished {
    return _okCount >= body.length;
  }

  @override
  onNext(int index, FlashCardResult res) {
    // 既に記録されたレコードの修正
    final changingRecord = _log[index];
    if (changingRecord.res == null) {
      _log[index] = _Record(
        index: changingRecord.index,
        res: res,
      );
    }

    // getして減った_bufferリストを補填する
    late final int addedIndex;
    switch (res) {
      case FlashCardResult.skipped:
        // skipped -> _log[index].index
        addedIndex = _log[index].index;
        break;
      case FlashCardResult.ok:
        if (_buffer.length >= _bufferMinimumSize) {
          // ok -> _rest.last?
          if (_rest.isEmpty) return;
          addedIndex = _rest.last;
          _rest.removeLast();
        } else {
          // ok -> _log[rand.nextInt(_log.length)].index
          addedIndex = _log[rand.nextInt(_log.length)].index;
        }
        break;
    }

    // _bufferへの挿入箇所。
    // _bufferの前方(後に取りだされる方)に入りやすいよう重みをつけている。
    final position = rand.nextInt(_flowRange ^ 2) ~/ _flowRange;
    _buffer.insert(position, addedIndex);
  }

  @override
  onUndo() {
    // _log: 一枚追加され待機状態になっている & 結果が一枚余計に登録されている。

    // 待機状態に入ったレコードを削除。
    if (_log.isNotEmpty && _log.last.res == null) _log.removeLast();

    // 最後に結果を登録したレコードを待機状態に戻す
    for (var logI = _log.length - 1; logI >= 0; logI--) {
      final record = _log[logI];
      if (record.res != null) {
        // 結果が出た最後のレコードを修正
        _log[logI] = _Record(index: record.index, res: null);
        break;
      }
    }

    // _buffer: Undoの後一枚余計に追加してしまうので、このままだと枚数が多くなってしまうので補正する。
    // onUndoする前最後にどこに追加したか分からないので、影響の少ないとみなせる最初の要素を_restの最後尾に移動。
    if (_buffer.isNotEmpty) {
      _rest.add(_buffer.first);
      _buffer.remove(0);
    }
  }

  @override
  get statusBar {
    if (_okCount < body.length) {
      return Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text(" $_okCount / ${body.length}")]));
    }
    return null;
  }
}
