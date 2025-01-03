import 'package:flutter/gestures.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:wai_eng/modules/flashcard.dart';
import 'package:wai_eng/modules/httpgetcache.dart';
import 'package:wai_eng/scaffolds/book_player.dart';
import 'package:wai_eng/scaffolds/browsers_list_editor.dart';
import 'package:url_launcher/url_launcher.dart';
import '../modules/flashcardbook.dart';
import '../modules/preferences.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';

class PreferencesScaffold extends StatefulWidget {
  const PreferencesScaffold({super.key}) : super();
  @override
  State<StatefulWidget> createState() => _PreferencesScaffoldState();
}

class _PreferencesScaffoldState extends State<PreferencesScaffold> {
  bool _wakelock = true;
  bool _autoCache = true;
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
      }),
      PreferencesManager.autoCache.listener((data) {
        if (!mounted) return;
        setState(() {
          _autoCache = data;
        });
      }),
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
              SettingsSection(title: const Text("単語帳の参照先"), tiles: [
                SettingsTile.navigation(
                  title: const Text('編集'),
                  onPressed: (context) {
                    Navigator.of(context, rootNavigator: true)
                        .push(MaterialPageRoute(builder: (context) {
                      return const BrowsersListEditor();
                    }));
                  },
                  description: RichText(
                      text: TextSpan(children: [
                    TextSpan(
                      text: 'CSVファイルを配信する',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    TextSpan(
                      text: ' dufs ',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Colors.blue,
                          ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          if (!await launchUrl(
                              Uri.parse("https://github.com/sigoden/dufs"))) {
                            throw Exception('Could not launch');
                          }
                        },
                    ),
                    TextSpan(
                      text: 'Webサーバーを立て、そのURLを入力してください。',
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  ])),
                ),
              ]),
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
                title: const Text('オフラインモード'),
                tiles: [
                  SettingsTile.switchTile(
                      initialValue: _autoCache,
                      onToggle: PreferencesManager.autoCache.setter,
                      title: const Text('オンライン時に自動で一時保存する')),
                  SettingsTile(
                    title: const Text("一時保存の削除"),
                    onPressed: (context) async {
                      final res = await showOkCancelAlertDialog(
                        context: context,
                        okLabel: "続行",
                        defaultType: OkCancelAlertDefaultType.cancel,
                        title: "一時保存の削除",
                        message: "削除してもよろしいですか？",
                      );
                      if (res == OkCancelResult.ok) deleteCache();
                    },
                  )
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
                    title: const Text('プライバシーポリシー'),
                    onPressed: (context) {
                      launchUrlString(
                        "https://github.com/gw31415/wai_eng/blob/main/PRIVACY_POLICY.md",
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    title: const Text('利用規約'),
                    onPressed: (context) {
                      launchUrlString(
                        "https://github.com/gw31415/wai_eng/blob/main/LICENSE",
                      );
                    },
                  ),
                  SettingsTile.navigation(
                    title: const Text('ライセンス情報'),
                    onPressed: (context) {
                      showLicensePage(
                        context: context,
                        applicationIcon: Image.asset(
                          'assets/logo_rounded.png',
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
