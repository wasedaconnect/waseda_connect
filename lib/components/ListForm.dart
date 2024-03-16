import 'package:flutter/material.dart';

class ListForm extends StatefulWidget {
  //動的ウィジェットを作成。
  final List<String>? items;
  final String? selectedItem;
  //この中では変数に入力することができない
  final Function(String?)? onSelected; // コールバック関数を追加

  const ListForm(
      {Key? key,
      required this.items,
      required this.selectedItem,
      this.onSelected})
      : super(key: key); //ここに引数を入力

  @override
  _ListFormState createState() => _ListFormState();
}

class _ListFormState extends State<ListForm> {
  String? _selectedItem; //変更しうる変数のみインスタンス内で定義

  @override //initSateの動作を行いつつ、新しく初期化メソッドを追加。
  void initState() {
    super.initState();
    // 初期選択アイテムを設定
    _selectedItem = widget.selectedItem;
  }

  @override

  ///親ウィジェットの変更を同期。
  void didUpdateWidget(covariant ListForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 外部からselectedItemが更新された場合、内部状態も更新する
    if (widget.selectedItem != oldWidget.selectedItem) {
      setState(() {
        _selectedItem = widget.selectedItem;
      });
    }
  }

  @override //プルダウン付きフォーム。可変にしてもいい。
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedItem,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? newValue) {
        setState(() {
          _selectedItem = newValue;
        });
        if (widget.onSelected != null) {
          widget.onSelected!(newValue); // コールバック関数を呼び出す
        }
      },
      items: widget.items?.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
