import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../modules/swipable_stack/swipable_stack.dart';
import '../modules/flashcardbook.dart';

class FlashCardBookPlayerScaffold extends StatefulWidget {
  const FlashCardBookPlayerScaffold(
      {Key? key, required this.operator, required this.title})
      : super(key: key);
  final Future<FlashCardBookOperator> Function() operator;
  final Text title;
  @override
  State<FlashCardBookPlayerScaffold> createState() =>
      _FlashCardBookPlayerScaffoldState();
}

class _FlashCardBookPlayerScaffoldState
    extends State<FlashCardBookPlayerScaffold> {
  late SwipableStackController _controller;
  late Future<FlashCardBookOperator> _opFuture;
  late bool nextCardAvailable;
  var getProgress = () => .0;

  void _listenController() {
    setState(() {});
  }

  // Cardの初期化処理: initStateやリプレイボタンを押下したら発火
  void _initCards() {
    setState(() {
      _controller = SwipableStackController()..addListener(_listenController);
      _opFuture = widget.operator();
      nextCardAvailable = true;
    });
  }

  // Stateの初期化
  @override
  void initState() {
    super.initState();
    _initCards();
  }

  @override
  void dispose() {
    super.dispose();
    _controller
      ..removeListener(_listenController)
      ..dispose();
  }

  // bookopの直前の状態
  String? beforeState;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: widget.title,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(8),
            child: LinearProgressIndicator(value: getProgress()),
          ),
        ),
        body: SafeArea(
          child: FutureBuilder(
              // カードを読みこむ
              future: _opFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("${snapshot.error}"),
                    );
                  }
                  return Container(
                    decoration:
                        BoxDecoration(color: Theme.of(context).splashColor),
                    child: const Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  );
                }
                final bookop = snapshot.data as FlashCardBookOperator;
                Text? progressIndicateText;
                if (bookop is ProgressableOperator) {
                  getProgress =
                      () => bookop.done.toDouble() / bookop.length.toDouble();
                  // 進捗のテキストラベル
                  progressIndicateText =
                      Text("${bookop.done} / ${bookop.length}");
                }

                /// リプレイボタン
                final replayButton = IconButton(
                  iconSize: 50,
                  tooltip: "Replay",
                  icon: const Icon(Icons.replay),
                  onPressed: () {
                    _initCards();
                  },
                );

                /// アンドゥボタン
                final undoButton = IconButton(
                  icon: const Icon(Icons.undo),
                  onPressed: _controller.canRewind && beforeState != null
                      ? () {
                          bookop.state = beforeState!;
                          _controller.rewind();
                        }
                      : null,
                  tooltip: "Undo",
                );

                /// カードのレイアウト
                final flashcard = SwipableStack(
                  controller: _controller,
                  swipeAnchor: SwipeAnchor.top,
                  swipeAssistDuration: const Duration(milliseconds: 300),
                  detectableSwipeDirections: const {
                    SwipeDirection.right,
                    SwipeDirection.left,
                  },
                  onPanStart: (_) {
                    HapticFeedback.lightImpact();
                  },
                  swipeNextOnSwipeCanceled: const SwipeNextArgs(
                    swipeDirection: SwipeDirection.down,
                    shouldCallCompletionCallback: true,
                    ignoreOnWillMoveNext: false,
                    duration: Duration(milliseconds: 250),
                  ),
                  onWillMoveNext: (_, __) {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    return true;
                  },
                  overlayBuilder: (_, properties) {
                    final card = bookop.get(properties.index);
                    if (card == null) {
                      return Container();
                    }
                    return Card(child: Center(child: card.answer));
                  },
                  stackClipBehaviour: Clip.none,
                  builder: (context, properties) {
                    final card = bookop.get(properties.index);
                    if (card == null) {
                      return Container();
                    }
                    return Card(child: Center(child: card.question));
                  },
                  onSwipeCompleted: (index, direction) {
                    beforeState = bookop.state;
                    switch (direction) {
                      case SwipeDirection.down:
                        bookop.onSwipeCompleted(index, FlashCardResult.skipped);
                        _showSnackBar(context, "SKIPPED");
                        break;
                      default:
                        bookop.onSwipeCompleted(index, FlashCardResult.ok);
                        _showSnackBar(context, "OK", primary: true);
                    }
                    nextCardAvailable = bookop.get(index + 1) != null;
                  },
                );
                return Stack(
                  children: [
                    Align(
                      // StatusRow
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: progressIndicateText,
                      ),
                    ),
                    AnimatedSwitcher(
                      // リプレイボタンとの切りかえ
                      duration: const Duration(milliseconds: 150),
                      child: bookop.isForceFinished || !nextCardAvailable
                          ? Center(child: replayButton)
                          : Column(
                              // FlashCard & アンドゥボタン表示部
                              children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: undoButton,
                                  ),
                                  Expanded(
                                    child: Padding(
                                      // progressIndicateTextのためのスペース
                                      padding:
                                          const EdgeInsets.only(bottom: 24),
                                      child: LayoutBuilder(
                                          builder: (context, constraints) {
                                        double padWidth = 240;
                                        if (constraints.maxWidth < 600) {
                                          padWidth = 8;
                                        } else if (constraints.maxWidth < 764) {
                                          padWidth = 100;
                                        } else if (constraints.maxWidth <
                                            1024) {
                                          padWidth = 160;
                                        }
                                        double padHeight = 8;
                                        if (constraints.maxHeight > 600) {
                                          padHeight = 20;
                                        } else if (constraints.maxHeight >
                                            400) {
                                          padHeight = 16;
                                        }
                                        return Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: padWidth,
                                            vertical: padHeight,
                                          ),
                                          child: flashcard,
                                        );
                                      }),
                                    ),
                                  ),
                                ]),
                    ),
                  ],
                );
              }),
        ));
  }
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _showSnackBar(
    BuildContext context, String msg,
    {bool primary = false}) {
  final colorScheme = Theme.of(context).colorScheme;
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: const Duration(milliseconds: 500),
      backgroundColor:
          primary ? colorScheme.primaryContainer : colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      content: SizedBox(
        height: 48,
        child: Center(
          child: Text(
            msg,
            style: TextStyle(
              color: primary
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      )));
}
