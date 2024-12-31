import 'dart:async';
import 'package:tekartik_app_flutter_sembast/sembast.dart';

final Future<Database> _db = getDatabaseFactory(packageName: 'dev.amas.waiEng')
    .openDatabase('preferences.sembast');

Future _setPreference<T>(String label, T value) async {
  final db = await _db;
  final store = StoreRef<String, T>.main();
  final preferences = store.record(label);
  await db.transaction((transaction) async {
    await preferences.put(transaction, value);
  });
}

Future<StreamSubscription<RecordSnapshot<String, T>?>>
    _setupPreferenceListener<T>(
  String label,
  void Function(RecordSnapshot<String, T>?)? onData, {
  Function? onError,
  void Function()? onDone,
  bool? cancelOnError,
}) async {
  final db = await _db;
  final store = StoreRef<String, T>.main();
  return store.record(label).onSnapshot(db).listen(onData,
      onError: onError, onDone: onDone, cancelOnError: cancelOnError);
}

typedef PreferenceSetter<T> = Future Function(T);

typedef PreferenceListener<T>
    = Future<StreamSubscription<RecordSnapshot<String, T>?>> Function(
  void Function(T)? onData, {
  Function? onError,
  void Function()? onDone,
  bool? cancelOnError,
});

typedef ListenerSubscription
    = StreamSubscription<RecordSnapshot<String, bool>?>;

class PreferencesManager<T> {
  final PreferenceSetter<T> setter;
  final PreferenceListener<T> listener;
  final Future<T> Function() getter;
  final T defaultValue;
  PreferencesManager._(String label, this.defaultValue)
      : setter = ((value) => _setPreference(label, value)),
        listener = ((
          void Function(T)? onData, {
          Function? onError,
          void Function()? onDone,
          bool? cancelOnError,
        }) =>
            _setupPreferenceListener(label, (snapshot) {
              if (snapshot == null) {
                _setPreference(label, defaultValue);
              } else {
                if (onData != null) {
                  onData(snapshot.value);
                }
              }
            }, onDone: onDone, onError: onError, cancelOnError: cancelOnError)),
        getter = (() async {
          final db = await _db;
          final record = StoreRef<String, T>.main().record(label);
          return await record.get(db) ?? defaultValue;
        });

  static PreferencesManager<bool> get wakelock =>
      PreferencesManager._('wakelock', false);
  static PreferencesManager<bool> get autoCache =>
      PreferencesManager._('autoCache', true);
  static PreferencesManager<String> get favorites =>
      PreferencesManager._('favorites', "[]");
  static PreferencesManager<List<Object?>> get browserReferences =>
      PreferencesManager._('browserReferences', []);
}
