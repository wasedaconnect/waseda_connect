import 'package:flutter/material.dart';

class FormModalComponent extends StatelessWidget {
  final String title;
  final Widget content;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  final String yesText;

  const FormModalComponent({
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
      content: content,
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
