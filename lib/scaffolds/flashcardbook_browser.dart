import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../modules/flashcardbook.dart';
import './book_player.dart';
import './flashcard_list.dart';
import '../modules/preferences.dart';
import 'package:wakelock/wakelock.dart';
import 'package:share_plus/share_plus.dart';

abstract class FlashCardBrowserItem {
  /// FlashCardBookPlayerの初期化時やリプレイ時に発火する。
  /// FlashCardBookのインスタンスを新規に作成しFlashCardBookPlayerに返す。
  Future<FlashCardBook> open();
}

/// 共有ファイルを作成できるもの
abstract class Sharable extends FlashCardBrowserItem {
  /// 共有ファイルを作成する
  Future<XFile> share();
}

/// 一覧表示できるもの
abstract class Listable extends FlashCardBrowserItem {}

enum SegmentType {
  flashCardBook,
  directory,
}

/// 階層構造に単語帳を整理しエクスプロールする構造体
abstract class FlashCardBookBrowser {
  /// 現在のディレクトリにあるセグメントを一覧する
  Future<Set<String>> ls(List<String> dir);

  /// ディレクトリか単語帳かを判別する
  SegmentType type(List<String> path);

  /// パスから辞書データを取得する
  FlashCardBrowserItem get(List<String> path);
}

class FlashCardBookBrowserScaffold extends StatelessWidget {
  final FlashCardBookBrowser browser;
  final Text title;
  final List<String> pwd;
  const FlashCardBookBrowserScaffold(
      {Key? key,
      required this.browser,
      required this.title,
      this.pwd = const []})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: pwd.isEmpty ? title : Text(pwd.last),
      ),
      body: FutureBuilder(
          future: browser.ls(pwd),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              if (snapshot.hasError) {
                return Center(
                  child: Text("${snapshot.error}"),
                );
              }
              return Container(
                decoration: BoxDecoration(color: Theme.of(context).splashColor),
                child: const Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
              );
            }
            final ls = snapshot.data as Set<String>;
            return ListView.builder(
                itemCount: ls.length,
                itemBuilder: (context, index) {
                  final name = ls.elementAt(index);
                  final path = pwd + [name];
                  switch (browser.type(path)) {
                    case SegmentType.flashCardBook:
                      // ダイアログの構築
                      List<Widget> listItems = [];
                      final cards = browser.get(path);
                      openBookPlayer(context) async {
                        final wakelock =
                            await PreferencesManager.wakelock.getter();
                        if (wakelock) {
                          Wakelock.enable();
                        }
                        Navigator.of(context, rootNavigator: true)
                            .push(MaterialPageRoute(builder: (context) {
                          return FlashCardBookPlayerScaffold(
                            player: () async =>
                                RandomBookPlayer(await cards.open()),
                            title: Text(name),
                          );
                        })).then((value) => Wakelock.disable());
                      }

                      listItems.add(
                        ListTile(
                          dense: true,
                          onTap: () => Navigator.pop(
                              context, () => openBookPlayer(context)),
                          leading: const Icon(Icons.play_circle_outline),
                          title: const Text('開く'),
                        ),
                      );

                      if (cards is Listable) {
                        openBookTable() {
                          Navigator.of(context, rootNavigator: true)
                              .push(MaterialPageRoute(builder: (context) {
                            return FlashCardListScaffold(
                              book: cards.open,
                              title: Text(name),
                            );
                          }));
                        }

                        listItems.add(
                          ListTile(
                            dense: true,
                            onTap: () => Navigator.pop(context, openBookTable),
                            leading: const Icon(Icons.list),
                            title: const Text('一覧'),
                          ),
                        );
                      }

                      if (cards is Sharable) {
                        listItems.add(ListTile(
                          dense: true,
                          title: const Text('ファイルを共有'),
                          leading: const Icon(Icons.share),
                          onTap: () async {
                            final XFile file = await cards.share();
                            await Share.shareXFiles([file]);
                          },
                        ));
                      }

                      openSubMenu() async {
                        final hapticService = HapticFeedback.lightImpact();
                        final nextTask = await showModalBottomSheet<Function>(
                            context: context,
                            builder: (BuildContext context) {
                              return ListView(
                                shrinkWrap: true,
                                // title: Text(name),
                                children: [
                                  ListTile(
                                    dense: true,
                                    title: Text(
                                      name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelMedium,
                                    ),
                                  ),
                                  ...listItems,
                                  const Divider(),
                                  ListTile(
                                    dense: true,
                                    title: const Text('閉じる'),
                                    leading: const Icon(Icons.close),
                                    onTap: () => Navigator.of(context).pop(),
                                  )
                                ],
                              );
                            });
                        if (nextTask != null) nextTask();
                        await hapticService;
                      }

                      return ListTile(
                        title: Text(name),
                        onTap: () => openBookPlayer(context),
                        onLongPress: openSubMenu,
                        leading: Icon(
                          Icons.play_arrow,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: openSubMenu,
                        ),
                      );

                    case SegmentType.directory:
                      return ListTile(
                        title: Text(name),
                        leading: const Icon(Icons.folder),
                        onTap: () => Navigator.of(context, rootNavigator: true)
                            .push(MaterialPageRoute(builder: (context) {
                          return FlashCardBookBrowserScaffold(
                            browser: browser,
                            title: title,
                            pwd: pwd + [name],
                          );
                        })),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Theme.of(context).colorScheme.surfaceVariant,
                        ),
                      );
                  }
                });
          }),
    );
  }
}
