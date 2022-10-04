import 'package:flutter/material.dart';
import '../modules/flashcardbook.dart';
import './book_player.dart';
import './book_table_viewer.dart';

enum SegmentType {
  flashCardBook,
  directory,
}

abstract class FlashCardBookBrowser {
  Set<String> ls(List<String> dir);
  SegmentType type(List<String> path);
  FlashCardBook getBook(List<String> path);
}

class FlashCardBookBrowseScaffold extends StatefulWidget {
  final FlashCardBookBrowser browser;
  final Text title;
  const FlashCardBookBrowseScaffold(
      {Key? key, required this.browser, required this.title})
      : super(key: key);
  @override
  State<FlashCardBookBrowseScaffold> createState() =>
      _FlashCardBookBrowseScaffoldState();
}

class _FlashCardBookBrowseScaffoldState
    extends State<FlashCardBookBrowseScaffold> {
  List<MaterialPage> pages = [];
  List<String> pwd = [];

  void _pushPwd(List<String> newPwd) {
    setState(() {
      pwd = newPwd;
      pages.add(_flashCardBookBrowsePage(newPwd));
    });
  }

  bool _popPwd() {
    if (pages == []) {
      return false;
    }
    setState(() {
      pages.removeLast();
      pwd.removeLast();
    });
    return true;
  }

  MaterialPage _flashCardBookBrowsePage(List<String> dir) {
    final pwd = dir;
    final browser = widget.browser;
    final ls = widget.browser.ls(pwd);
    return MaterialPage(
      child: ListView.builder(
          itemCount: ls.length,
          itemBuilder: (context, index) {
            final name = ls.elementAt(index);
            final path = pwd + [name];
            switch (browser.type(path)) {
              case SegmentType.flashCardBook:
                // ダイアログの構築
                List<Widget> listItems = [];
                final cards = browser.getBook(path);
                _openBookPlayer() {
                  Navigator.of(context, rootNavigator: true)
                      .push(MaterialPageRoute(builder: (context) {
                    return FlashCardBookPlayerScaffold(
                      book: cards,
                      title: Text(name),
                    );
                  }));
                }

                listItems.add(
                  ListTile(
                    dense: true,
                    onTap: () => Navigator.pop(context, _openBookPlayer),
                    leading: const Icon(Icons.play_circle_outline),
                    title: const Text('開く'),
                  ),
                );

                if (cards is UsersBook) {
                  _openBookTable() {
                    Navigator.of(context, rootNavigator: true)
                        .push(MaterialPageRoute(builder: (context) {
                      return BookTableScaffold(
                        book: cards,
                        title: Text(name),
                      );
                    }));
                  }

                  listItems.add(
                    ListTile(
                      dense: true,
                      onTap: () => Navigator.pop(context, _openBookTable),
                      leading: const Icon(Icons.list),
                      title: const Text('一覧'),
                    ),
                  );
                }

                _openSubMenu() {
                  Future.microtask(() async {
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
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
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
                  });
                }

                return ListTile(
                  title: Text(name),
                  onTap: _openBookPlayer,
                  onLongPress: _openSubMenu,
                  leading: Icon(
                    Icons.play_arrow,
		    color: Theme.of(context).colorScheme.primary,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: _openSubMenu,
                  ),
                );

              case SegmentType.directory:
                return ListTile(
                  title: Text(name),
                  leading: const Icon(Icons.folder),
                  onTap: () => _pushPwd(dir + [name]),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.surfaceVariant,
                  ),
                );
            }
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: pages.isEmpty ? widget.title : Text(pwd.last),
        leading: pages.isEmpty
            ? null
            : IconButton(
                onPressed: _popPwd, icon: const Icon(Icons.keyboard_arrow_up)),
        actions: [
          PopupMenuButton<Function()>(
            onSelected: (Function func) {
              func();
            },
            itemBuilder: (BuildContext c) {
              return [
                PopupMenuItem(
                  child: const Text("このアプリについて"),
                  value: () {
                    showAboutDialog(
                      context: context,
                      applicationIcon: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'lib/assets/icon.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.fill,
                        ),
                      ),
                      applicationLegalese: '©2022 gw31415', // 権利情報
                    );
                  },
                )
              ];
            },
          )
        ],
      ),
      body: Navigator(
          onPopPage: (route, result) {
            return _popPwd();
          },
          pages: [
            _flashCardBookBrowsePage([]),
            ...pages,
          ]),
    );
  }
}
