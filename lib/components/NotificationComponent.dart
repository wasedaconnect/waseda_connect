import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waseda_connect/provider/provider.dart';
// ステップ1で作成したファイルをインポート

class NotificationWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationMessage = ref.watch(notificationProvider);

    if (notificationMessage.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(notificationMessage)),
        );
        // 通知メッセージを表示した後は、状態をクリアする
        ref.read(notificationProvider.notifier).state = '';
      });
    }

    return Container(); // このウィジェットはUIに影響を与えないため、Containerを返す
  }
}
