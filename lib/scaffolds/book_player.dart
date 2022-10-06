import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../modules/swipable_stack/swipable_stack.dart';
import '../modules/flashcardbook.dart';

class FlashCardBookPlayerScaffold extends StatefulWidget {
  const FlashCardBookPlayerScaffold(
      {Key? key, required this.book, required this.title})
      : super(key: key);
  final FlashCardBook book;
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
      _opFuture = widget.book.init();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: widget.title,
          bottom: PreferredSize(
              child: LinearProgressIndicator(value: getProgress()),
              preferredSize: const Size.fromHeight(8)),
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
                getProgress = () {
                  if (bookop.length == null || bookop.progress == null) {
                    return 0;
                  }
                  return bookop.progress!.toDouble() /
                      bookop.length!.toDouble();
                };

                // 進捗のテキストラベル
                final progressIndicateText =
                    Text("${bookop.progress} / ${bookop.length}");

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
                  onPressed: _controller.canRewind
                      ? () {
                          bookop.onUndo();
                          _controller.rewind();
                        }
                      : null,
                  tooltip: "Undo",
                );

                /// カードのレイアウト
                final bookView = SwipableStack(
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
                    switch (direction) {
                      case SwipeDirection.down:
                        bookop.onNext(index, FlashCardResult.skipped);
                        _showSnackBar(context, "SKIPPED");
                        break;
                      default:
                        bookop.onNext(index, FlashCardResult.ok);
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
                      duration: const Duration(milliseconds: 100),
                      child: bookop.isForceFinished || !nextCardAvailable
                          ? Center(child: replayButton)
                          : Column(
                              // FlashCard & アンドゥボタン表示部
                              children: [
                                  Padding(
                                      // FlashCard
                                      padding: const EdgeInsets.all(8),
                                      child: undoButton),
                                  Expanded(
                                    child: Padding(
									  // progressIndicateTextのためのスペース
                                      padding: const EdgeInsets.only(bottom: 24),
                                      child: LayoutBuilder(
                                          builder: (context, constraints) {
                                        return Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: bookView);
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
