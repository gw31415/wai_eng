import 'package:settings_ui/settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:wai_eng/modules/flashcard.dart';
import 'package:wai_eng/scaffolds/book_player.dart';
import '../modules/flashcardbook.dart';
import '../modules/preferences.dart';

class PreferencesScaffold extends StatefulWidget {
  const PreferencesScaffold({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _PreferencesScaffoldState();
}

class _PreferencesScaffoldState extends State<PreferencesScaffold> {
  bool _wakelock = true;
  List<ListenerSubscription> _subscriptions = [];
  @override
  void dispose() {
    for (var s in _subscriptions) {
      s.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final futureSubscription = [
      PreferencesManager.wakelock.listener((data) {
        if (!mounted) return;
        setState(() {
          _wakelock = data;
        });
      })
    ];
    return Scaffold(
      appBar: AppBar(title: const Text("設定")),
      body: FutureBuilder(
        future: (() async {
          List<ListenerSubscription> res = [];
          for (var element in futureSubscription) {
            res.add(await element);
          }
          return res;
        })(),
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
          _subscriptions = snapshot.data as List<ListenerSubscription>;
          return SettingsList(
            sections: [
              SettingsSection(
                title: const Text('フラッシュカード プレイ画面'),
                tiles: [
                  SettingsTile.switchTile(
                      initialValue: _wakelock,
                      onToggle: PreferencesManager.wakelock.setter,
                      title: const Text('画面消灯を抑制する'))
                ],
              ),
              SettingsSection(
                title: const Text('情報'),
                tiles: [
                  SettingsTile.navigation(
                    title: const Text('使い方'),
                    onPressed: (context) {
                      Navigator.of(context, rootNavigator: true)
                          .push(MaterialPageRoute(builder: (context) {
                        return FlashCardBookPlayerScaffold(
                          player: () async => SimplePlayer([
                            StringCard(
                              question: "触れてください。",
                              answer: "Good job!\nこちらが裏面です。\n手を離すと次のカードに進みます。",
                            ),
                            StringCard(
                              question: "こちらは表面です。",
                              answer:
                                  "覚えたカードは左右にスワイプしましょう。\n覚えられなかったカードは指を離してスキップしましょう。",
                            ),
                            StringCard(
                              question: "覚えていないカードは記録されます。",
                              answer: "それでは頑張ってください！",
                            ),
                          ]),
                          title: const Text("使い方"),
                        );
                      }));
                    },
                  ),
                  SettingsTile.navigation(
                    title: const Text('ライセンス情報'),
                    onPressed: (context) {
                      showLicensePage(
                        context: context,
                        applicationIcon: Image.asset(
                          'assets/icon.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.fill,
                        ),
                        applicationLegalese: '©2022 gw31415', // 権利情報
                      );
                    },
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }
}
