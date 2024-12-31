import 'package:flutter/material.dart';
import 'package:wai_eng/modules/preferences.dart';
import 'package:adaptive_dialog/adaptive_dialog.dart';

List<String> filterUrls(List<Object?> urls) {
  List<String> res = [];
  for (var element in urls.whereType<String>()) {
    var url = Uri.tryParse(element);
    if (url != null && url.scheme == "") {
      url = Uri.tryParse("https://$element");
    }
    if (url == null || (url.scheme != "http" && url.scheme != "https")) {
      continue;
    }
    res.add(url.toString());
  }
  return res;
}

class BrowsersListEditor extends StatefulWidget {
  const BrowsersListEditor({Key? key}) : super(key: key);

  @override
  State<BrowsersListEditor> createState() => _BrowsersListEditorState();
}

String? urlVaridator(String? value) {
  if (value == null || value.isEmpty) {
    return 'URLを入力してください';
  }
  var url = Uri.tryParse(value);
  if (url != null && url.scheme == "") {
    url = Uri.tryParse("http://$value");
  }
  if (url == null) {
    return 'URLが不正です';
  }
  if (url.scheme != "http" && url.scheme != "https") {
    return 'HTTPまたはHTTPSスキームを指定してください';
  }
  return null;
}

class _BrowsersListEditorState extends State<BrowsersListEditor> {
  List<String> browsers = [];

  @override
  Widget build(BuildContext context) {
    final manager = PreferencesManager.browserReferences;
    return Scaffold(
        appBar: AppBar(
          title: const Text('単語帳参照先'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final inputs = await showTextInputDialog(
              context: context,
              title: '追加',
              message: 'URLを入力してください',
              textFields: [
                const DialogTextField(
                  hintText: 'https://example.com',
                  validator: urlVaridator,
                ),
              ],
            );

            if (inputs == null) return;
            final url = inputs[0];
            if (urlVaridator(url) != null) {
              return;
            }
            final newBrowsers = [...(await manager.getter()), url];
            await manager.setter(newBrowsers);
            setState(() {
              browsers = filterUrls(newBrowsers);
            });
          },
          child: const Icon(Icons.add),
        ),
        body: FutureBuilder(
            future: manager.getter(),
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
              browsers = filterUrls(snapshot.data!);
              return ListView.builder(
                itemCount: browsers.length,
                itemBuilder: (context, index) {
                  final browser = browsers.elementAt(index);
                  return ListTile(
                    title: Text(browser),
                    onLongPress: () async {
                      final res = await showOkCancelAlertDialog(
                        context: context,
                        okLabel: "削除",
                        defaultType: OkCancelAlertDefaultType.cancel,
                        title: "削除",
                        message: "$browser を削除しますか？",
                      );
                      if (res == OkCancelResult.ok) {
                        final newBrowsers = (browsers..removeAt(index));
                        await PreferencesManager.browserReferences.setter(
                            newBrowsers.map((e) => e as Object?).toList());
                        setState(() {
                          browsers = newBrowsers;
                        });
                      }
                    },
                  );
                },
              );
            }));
  }
}
