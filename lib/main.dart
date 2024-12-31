import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart' hide Router;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:wai_eng/modules/preferences.dart';
import 'package:wai_eng/scaffolds/flashcardbook_browser.dart';
import 'modules/browser_reference.dart';
import 'package:flutter/foundation.dart';

import 'scaffolds/favorites_editor.dart';
import 'scaffolds/preferences.dart';

void main() {
  LicenseRegistry.addLicense(() {
    return Stream.fromFuture((() async {
      final licence =
          await rootBundle.loadString('lib/modules/swipable_stack/LICENSE');
      return LicenseEntryWithLineBreaks(['swipable_stack'], licence);
    })());
  });
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WaiEng',
      theme: ThemeData(
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        cupertinoOverrideTheme: const CupertinoThemeData(
          textTheme: CupertinoTextThemeData(),
        ),
      ),
      home: const HomeScaffold(),
    );
  }
}

class HomeScaffold extends StatefulWidget {
  const HomeScaffold({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => HomeScaffoldState();
}

class HomeScaffoldState extends State<HomeScaffold> {
  List<BrowserReference> _favorites = [];
  List<String> _browsers = [];

  dynamic _subscriptions;
  @override
  void dispose() {
    for (var s in _subscriptions) {
      s.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final futureSubscriptionFavorites =
        PreferencesManager.favorites.listener((data) {
      if (!mounted) return;
      setState(() {
        _favorites =
            (jsonDecode(data) as List).map((e) => BrowserReference(e)).toList();
      });
    });
    final futureSubscriptionBrowserReferences =
        PreferencesManager.browserReferences.listener(
      (data) {
        if (!mounted) return;
        setState(() {
          _browsers = data.toList().whereType<String>().toList();
        });
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("WaiEng"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const PreferencesScaffold();
                    },
                  ),
                );
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      body: FutureBuilder(future: (() async {
        _subscriptions = [
          await futureSubscriptionFavorites,
          await futureSubscriptionBrowserReferences
        ];
        final browserRefs = _browsers.map(
          (url) => BrowserReference.dufs(
            url: url,
            displayName: url,
          ),
        );
        if (browserRefs.isEmpty) {
          return const Center(
            child: Text(
              "単語帳の参照先が登録されていません。\n設定から追加してください。",
              style: TextStyle(
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }
        return SettingsList(
          sections: [
            SettingsSection(
              title: const Text('データベース'),
              tiles: await Future.wait(
                  browserRefs.map((item) => item.toSettingsTile())),
            ),
            if (_favorites.isNotEmpty)
              SettingsSection(
                title: Text("お気に入り (${_favorites.length})"),
                tiles: await Future.wait(_favorites
                    .map((item) => item.toSettingsTile(
                          iconSelector: (segmentType, browserType) {
                            switch (segmentType) {
                              case SegmentType.directory:
                                return const Icon(Icons.stars);
                              case SegmentType.flashCardBook:
                                return const Icon(Icons.star);
                            }
                          },
                        ))
                    .toList()),
              ),
            if (_favorites.isNotEmpty)
              SettingsSection(
                tiles: [
                  SettingsTile(
                      title: const Text("お気に入りの編集"),
                      onPressed: (context) async {
                        final manager = PreferencesManager.favorites;
                        final initialList =
                            (jsonDecode(await manager.getter()) as List)
                                .map((e) => BrowserReference(e))
                                .toList();
                        if (!context.mounted) return;
                        Navigator.of(context, rootNavigator: true)
                            .push(MaterialPageRoute(
                          builder: (context) {
                            return ReorderableDismissibleEditorScaffold<
                                BrowserReference>(
                              title: const Text("お気に入りの編集"),
                              initialList: initialList,
                              builder: (dynamic e) => ListTile(
                                title: Text(e.displayName),
                              ),
                              onSave: (dynamic newList) {
                                manager.setter(jsonEncode(
                                    newList.map((e) => e.toJson).toList()));
                              },
                            );
                          },
                          fullscreenDialog: true,
                        ));
                      })
                ],
              ),
          ],
        );
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
        return snapshot.data!;
      }),
    );
  }
}
