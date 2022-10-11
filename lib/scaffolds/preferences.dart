import 'package:settings_ui/settings_ui.dart';
import 'package:flutter/material.dart';
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
    final _futureSubscription = [
      PreferencesManager.wakelock.listener((data) {
        if (!mounted) {
		  dispose();
          return;
        }
        setState(() {
          _wakelock = data;
        });
      })
    ];
    return Scaffold(
      appBar: AppBar(title: const Text("設定")),
      body: FutureBuilder(future: (() async {
        List<ListenerSubscription> res = [];
        for (var element in _futureSubscription) {
          res.add(await element);
        }
        return res;
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
          ],
        );
      }),
    );
  }
}
