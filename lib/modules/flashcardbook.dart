import 'dart:math' as math;
import './flashcard.dart';

/// カードをスワイプしたか、スキップしたか。
enum FlashCardResult {
  ok,
  skipped,
}

/// 全てのフラッシュカードブックの親クラス。
abstract class FlashCardBook {
  const FlashCardBook();

  /// 一覧表示するためのゲッター。一覧表示に対応しない場合はnullを返す
  Future<List<FlashCard>>? intoCardList() {
    return null;
  }

  /// FlashCardBookPlayerの初期化時やリプレイ時に発火する。
  /// FlashCardBookOperatorのインスタンスを新規に作成しFlashCardBookPlayerに返す。
  Future<FlashCardBookOperator> open();
}

/// フラッシュカードを新しく実行する際にFlashCardBookPlayerに渡されるステートの遷移を司るクラス。
abstract class FlashCardBookOperator {
  /// nullを返した場合、最表面カードがnullの番になったタイミングでカード操作が終了されリプレイボタンが表示される。
  FlashCard? get(int index);

  /// カードのスワイプ終了時のコールバック。
  void onSwipeCompleted(int index, FlashCardResult res);

  /// アンドゥボタン押下時に発火するコールバック。
  void onUndo();

  /// 進捗状況:何枚目か
  int? get progress {
    return null;
  }

  /// 全部で何枚あるか
  int? get length {
    return null;
  }

  /// FlashCard? get(int index)が空を返さなかった場合でも中断したい場合にtrueを返すように実装する。
  /// 半永久的にカードを回す際など、終了条件をカードのスワイプ始めではなくスワイプ終わり(onSwipeCompletedのタイミング)で評価したい場合に使う。
  bool get isForceFinished {
    return false;
  }
}

abstract class UsersBook extends FlashCardBook {
  @override
  Future<List<FlashCard>> intoCardList() {
    return _body();
  }

  final Future<List<FlashCard>> Function() _body;

  UsersBook({required Future<List<FlashCard>> Function() body})
      : _body = (() => Future.value(body()));
}

class RandomBook extends UsersBook {
  @override
  open() async {
    return Future.value(RandomBookOperator(body: await intoCardList()));
  }

  RandomBook({required body}) : super(body: body);
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
    length = body.length;
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
  onSwipeCompleted(int index, FlashCardResult res) {
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
  late final int length;

  @override
  int get progress => _okCount;
}
