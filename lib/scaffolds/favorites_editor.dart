import 'package:flutter/material.dart';

class ReorderableDismissibleEditorScaffold<T> extends StatefulWidget {
  const ReorderableDismissibleEditorScaffold({
    super.key,
    required this.initialList,
    this.onSave,
    this.title,
    required this.builder,
  }) : super();
  final List<T> initialList;
  final Function(List<T>)? onSave;
  final ListTile Function(T) builder;
  final Widget? title;

  @override
  ReorderableDismissibleEditorScaffoldState<T> createState() =>
      ReorderableDismissibleEditorScaffoldState<T>();
}

class ReorderableDismissibleEditorScaffoldState<T>
    extends State<ReorderableDismissibleEditorScaffold> {
  List<int> dataList = [];
  bool saveable = false;

  // リスト項目となる削除可能なウィジェットを作成
  Widget buildItem(int originIndex) {
    final listtile = widget.builder(widget.initialList[originIndex]);
    return Dismissible(
      key: Key(originIndex.toString()), // 項目が特定できるよう固有の文字列をキーとする
      background: Container(color: Colors.red), // スワイプしているアイテムの背景色
      onDismissed: (direction) {
        // 削除時の処理
        setState(() {
          dataList.remove(originIndex);
          saveable = true;
        });
      },
      // 各項目のレイアウト
      child: listtile,
    );
  }

  @override
  void initState() {
    dataList = List.generate(widget.initialList.length, (index) => index);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: widget.title,
          actions: [
            IconButton(
              onPressed: widget.onSave == null || !saveable
                  ? null
                  : () {
                      widget.onSave!.call(
                        dataList.map((e) => widget.initialList[e]).toList(),
                      );
                      setState(() {
                        saveable = false;
                      });
                    },
              icon: const Icon(Icons.save),
            ),
          ],
        ),
        body: ReorderableListView(
          onReorder: (int oldIndex, int newIndex) {
            if (newIndex > oldIndex) {
              // 元々下にあった要素が上にずれるため一つ分後退させる
              newIndex -= 1;
            }

            // 並び替え処理
            final data = dataList[oldIndex];
            setState(() {
              dataList.removeAt(oldIndex);
              dataList.insert(newIndex, data);
              saveable = true;
            });
          },
          children: dataList.map(buildItem).toList(),
        ));
  }
}
