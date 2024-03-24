import 'package:flutter/material.dart';

// 最小構成のコンポーネントを作成するファイル
// --------------- Index ---------------
//  1. DropdownCustomComponent
//      Dropdown形式を簡単に表示できるようにするコンポーネント
//  2.
// --------------- Index ---------------

// 1. DropdownCustomComponent
class DropdownCustomComponent extends StatelessWidget {
  final dynamic value;
  final String label;
  final void Function(dynamic)? onChanged;
  final Map<int, String>? itemDict;
  final List<String>? itemList;
  final int? limmit;

  const DropdownCustomComponent({
    Key? key,
    required this.value,
    required this.label,
    required this.onChanged,
    this.itemDict,
    this.itemList,
    this.limmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: DropdownButtonFormField<dynamic>(
        value: value,
        decoration: InputDecoration(labelText: label),
        onChanged: onChanged,
        items: itemDict != null
            ? itemDict!.keys
                .where((int key) => limmit == null || key <= limmit!)
                .map<DropdownMenuItem<dynamic>>((int key) {
                return DropdownMenuItem<dynamic>(
                  value: itemDict![key],
                  child: Text(itemDict![key]!),
                );
              }).toList()
            : itemList != null
                ? itemList!.map<DropdownMenuItem<dynamic>>((String department) {
                    return DropdownMenuItem<dynamic>(
                      value: department,
                      child: Text(department),
                    );
                  }).toList()
                : [], // itemListがnullの場合は空リストを使用
      ),
    );
  }
}

// 2.
