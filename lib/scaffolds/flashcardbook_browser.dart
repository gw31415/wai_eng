import 'dart:convert';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../modules/browser_reference.dart';
import '../modules/flashcardbook.dart';
import './book_player.dart';
import './flashcard_list.dart';
import '../modules/preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
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
  Future<SegmentType> type(List<String> path);

  /// パスから辞書データを取得する
  FlashCardBrowserItem get(List<String> path);

  /// 選択項目のショートカットを作成する
  BrowserReference reference(List<String> path);
}

class FlashCardBookBrowserScaffold extends StatelessWidget {
  final FlashCardBookBrowser browser;
  final Text title;
  final List<String> pwd;
  const FlashCardBookBrowserScaffold(
      {super.key,
      required this.browser,
      required this.title,
      this.pwd = const []})
      : super();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: pwd.isEmpty ? title : Text(pwd.last),
      ),
      body: FutureBuilder(future: (() async {
        final ls = await browser.ls(pwd);
        final listitems = await Future.wait(ls.map((name) async {
          final path = pwd + [name];
          switch (await browser.type(path)) {
            case SegmentType.flashCardBook:
              // ダイアログの構築
              List<Widget> listItems = [];
              final cards = browser.get(path);
              openBookPlayer(context) async {
                final wakelock = await PreferencesManager.wakelock.getter();
                if (wakelock) {
                  WakelockPlus.enable();
                }
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (context) {
                  return FlashCardBookPlayerScaffold(
                    player: () async => RandomBookPlayer(await cards.open()),
                    title: Text(name),
                  );
                })).then((value) => WakelockPlus.disable());
              }

              listItems.add(
                ListTile(
                  dense: true,
                  onTap: () =>
                      Navigator.pop(context, () => openBookPlayer(context)),
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

              listItems.add(ListTile(
                dense: true,
                title: const Text('お気に入りに追加'),
                leading: const Icon(Icons.star),
                onTap: () async {
                  Navigator.of(context).pop();
                  final input = await showTextInputDialog(
                      context: context,
                      textFields: [
                        DialogTextField(initialText: path.last),
                      ],
                      title: "お気に入りに追加",
                      message: "お気に入りの名称を設定してください。");
                  if (input == null) return;
                  final displayName = input.last;
                  final reference = browser.reference(path);
                  reference.displayName = displayName;
                  final before = jsonDecode(
                    await PreferencesManager.favorites.getter(),
                  );
                  PreferencesManager.favorites
                      .setter(jsonEncode(before + [reference.toJson]));
                },
              ));

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
                              style: Theme.of(context).textTheme.labelMedium,
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
                onLongPress: () async {
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
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ),
                            ListTile(
                              dense: true,
                              title: const Text('お気に入りに追加'),
                              leading: const Icon(Icons.stars),
                              onTap: () async {
                                Navigator.of(context).pop();
                                final input = await showTextInputDialog(
                                    context: context,
                                    textFields: [
                                      DialogTextField(initialText: path.last),
                                    ],
                                    title: "お気に入りに追加",
                                    message: "お気に入りの名称を設定してください。");
                                if (input == null) return;
                                final displayName = input.last;
                                final reference = browser.reference(path);
                                reference.displayName = displayName;
                                final before = jsonDecode(
                                  await PreferencesManager.favorites.getter(),
                                );
                                PreferencesManager.favorites.setter(
                                    jsonEncode(before + [reference.toJson]));
                              },
                            ),
                            const Divider(),
                            ListTile(
                              dense: true,
                              title: const Text('閉じる'),
                              leading: const Icon(Icons.close),
                              onTap: () => Navigator.of(context).pop(),
                            ),
                          ],
                        );
                      });
                  if (nextTask != null) nextTask();
                  await hapticService;
                },
                trailing: Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              );
          }
        }));
        return ListView(children: listitems);
      })(), builder: (context, snapshot) {
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
        final listview = snapshot.data as ListView;
        return listview;
      }),
    );
  }
}
