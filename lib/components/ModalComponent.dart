import 'package:flutter/material.dart';

class ModalComponent extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String yesText;

  const ModalComponent({
    Key? key,
    required this.title,
    required this.content,
    required this.onConfirm,
    required this.onCancel,
    required this.yesText,
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
            // ダイアログを閉じる
          },
          child: Text('キャンセル'),
        ),
        TextButton(
          onPressed: () {
            onConfirm(); // ダイアログを閉じる
          },
          child: Text(yesText),
        ),
      ],
    );
  }
}
