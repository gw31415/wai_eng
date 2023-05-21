import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:wai_eng/modules/preferences.dart';
import 'modules/browser_reference.dart';
import 'package:flutter/foundation.dart';

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
        primarySwatch: Colors.teal,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.teal,
        brightness: Brightness.dark,
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
    final futureSubscription = PreferencesManager.favorites.listener((data) {
      if (!mounted) return;
      setState(() {
        _favorites =
            (jsonDecode(data) as List).map((e) => BrowserReference(e)).toList();
      });
    });
    final browsers = [
      BrowserReference.dufs(
        url: "https://dufs.amas.dev",
        displayName: "dufs.amas.dev",
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text("WaiEng"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true)
                    .push(MaterialPageRoute(builder: (context) {
                  return const PreferencesScaffold();
                }));
              },
              icon: const Icon(Icons.settings))
        ],
      ),
      body: FutureBuilder(future: (() async {
        _subscriptions = await futureSubscription;
        return SettingsList(
          sections: [
            SettingsSection(
              title: const Text('データベース'),
              tiles: await Future.wait(
                  browsers.map((item) => item.toSettingsTile())),
            ),
            if (_favorites.isNotEmpty)
              SettingsSection(
                title: Text("お気に入り (${_favorites.length})"),
                tiles: await Future.wait(
                    _favorites.map((item) => item.toSettingsTile()).toList()),
              ),
            if (_favorites.isNotEmpty)
              SettingsSection(
                tiles: [
                  SettingsTile(
                    title: const Text("お気に入りの削除"),
                    onPressed: (context) =>
                        PreferencesManager.favorites.setter("[]"),
                  )
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
