import 'dart:convert';
import 'dart:math' as math;
import 'package:share_plus/share_plus.dart';

import './flashcard.dart';

/// カードをスワイプしたか、スキップしたか。
enum FlashCardResult {
  /// 左右にスワイプした場合
  ok,

  /// 指を離してスキップした場合
  skipped,
}

/// 全てのフラッシュカードブックの親クラス。
abstract class FlashCardBook {
  /// FlashCardBookPlayerの初期化時やリプレイ時に発火する。
  /// List<FlashCard>のインスタンスを新規に作成しFlashCardBookPlayerに返す。
  Future<List<FlashCard>> open();
}

/// 共有ファイルを作成できるもの
abstract class SharableBook extends FlashCardBook {
  /// 共有ファイルを作成する
  Future<XFile> share();
}

/// 一覧表示できるもの
abstract class ListableBook extends FlashCardBook {}

/// フラッシュカードを新しく実行する際にFlashCardBookPlayerに渡されるステートの遷移を司るクラス。
abstract class FlashCardBookOperator {
  /// nullを返した場合、最表面カードがnullの番になったタイミングでカード操作が終了されリプレイボタンが表示される。
  FlashCard? get(int index);

  /// カードのスワイプ終了時のコールバック。
  void onSwipeCompleted(int index, FlashCardResult res);

  /// 状態を表す文字列。アンドゥに利用。
  String get state;
  set state(String state);

  /// FlashCard? get(int index)が空を返さなかった場合でも中断したい場合にtrueを返すように実装する。
  /// 半永久的にカードを回す際など、終了条件をカードのスワイプ始めではなくスワイプ終わり(onSwipeCompletedのタイミング)で評価したい場合に使う。
  bool get isForceFinished {
    return false;
  }
}

abstract class ProgressableOperator extends FlashCardBookOperator {
  /// 進捗が何枚分か。何枚覚えたかなどを表わす。
  /// .lengthとの比でプログレスバーが表示され、下部のラベルが設定される。
  int get done;

  /// 全部で何枚あるか
  int get length;
}

class _Record {
  late final int index;
  FlashCardResult? res;
  _Record({required this.index, this.res});
  _Record.fromJson(String json) {
    final obj = jsonDecode(json);
    assert(obj is Map);
    // assert(obj['index'] is int);
    // assert(obj['ok'] is bool?);

    index = obj['index'] as int;
    final objOk = obj['ok'] as bool?;
    if (objOk == null) {
      res = null;
    } else {
      res = objOk ? FlashCardResult.ok : FlashCardResult.skipped;
    }
  }
  get _asJson {
    return jsonEncode({
      'index': index,
      'ok': res == null ? null : res == FlashCardResult.ok,
    });
  }
}

class RandomBookOperator extends FlashCardBookOperator
    implements ProgressableOperator {
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
  RandomBookOperator(this.body) {
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

  @override
  set state(state) {
    final obj = jsonDecode(state);
    assert(obj is Map);
    assert(obj['rest'] is List<dynamic>);
    _rest = obj['rest'].cast<int>();
    assert(obj['log'] is List<dynamic>);
    _log = (obj['log'].cast<String>() as List<String>)
        .map((e) => _Record.fromJson(e))
        .toList();
    assert(obj['buffer'] is List<dynamic>);
    _buffer = obj['buffer'].cast<int>();
    rand.nextDouble();
  }

  @override
  get state {
    return jsonEncode({
      'rest': _rest,
      'log': _log.map((e) => e._asJson).toList(),
      'buffer': _buffer,
    });
  }

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
  late final int length;

  @override
  int get done => _okCount;
}
