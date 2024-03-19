import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConfirmDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            onCancel();
            Navigator.of(context).pop(); // ダイアログを閉じる
          },
          child: Text('キャンセル'),
        ),
        TextButton(
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop(); // ダイアログを閉じる
          },
          child: Text('削除'),
        ),
      ],
    );
  }
}
