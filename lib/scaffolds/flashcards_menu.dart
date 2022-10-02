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

class FlashCardBookBrowseScaffold extends StatelessWidget {
  final FlashCardBookBrowser browser;
  final List<String> pwd;
  const FlashCardBookBrowseScaffold(
      {Key? key, required this.browser, this.pwd = const []})
      : super(key: key);
  @override
  Widget build(context) {
    final ls = browser.ls(pwd);
    final title = pwd.isEmpty ? const Text("WaiEng") : Text(pwd.last);
    return Scaffold(
      appBar: AppBar(
        title: title,
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
      body: ListView.builder(
          itemCount: ls.length,
          itemBuilder: (context, index) {
            final name = ls.elementAt(index);
            final path = pwd + [name];
            switch (browser.type(path)) {
              case SegmentType.flashCardBook:
                // ダイアログの構築
                List<Widget> dialogItems = [];
                final cards = browser.getBook(path);
                _openBookPlayer() {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return FlashCardBookPlayerScaffold(
                      book: cards,
                      title: Text(name),
                    );
                  }));
                }

                dialogItems.add(
                  SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, _openBookPlayer),
                    child: const Text('開く'),
                  ),
                );
                if (cards is UsersBook) {
                  _openBookTable() {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return BookTableScaffold(
                        book: cards,
                        title: Text(name),
                      );
                    }));
                  }

                  dialogItems.add(
                    SimpleDialogOption(
                      onPressed: () => Navigator.pop(context, _openBookTable),
                      child: const Text('一覧'),
                    ),
                  );
                }

                return ListTile(
                  title: Text(name),
                  onTap: _openBookPlayer,
                  trailing: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      Future.microtask(() async {
                        final nextTask = await showDialog<Function>(
                            context: context,
                            builder: (BuildContext context) {
                              return SimpleDialog(
                                title: Text(name),
                                children: dialogItems,
                              );
                            });
                        if (nextTask != null) nextTask();
                      });
                    },
                  ),
                );
              case SegmentType.directory:
                return ListTile(
                  title: Text(name),
                  onTap: () => {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return FlashCardBookBrowseScaffold(browser: browser, pwd: path);
                    }))
                  },
                );
            }
          }),
    );
  }
}
