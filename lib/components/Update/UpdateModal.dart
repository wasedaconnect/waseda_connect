import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../main.dart';
import '../../hooks/VersionCheck.dart';
import 'package:waseda_connect/hooks/UrlLaunchWithUri.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateModal extends ConsumerWidget {
  const UpdateModal({
    super.key,
  });

  static const WEB_SITE_URL = "https://www.waseda-connect.com/";
  static const APP_STORE_URL =
      'https://apps.apple.com/jp/app/id[アプリのApple ID]?mt=8';

  // FIXME ストアにアプリを登録したらurlが入れられる
  static const PLAY_STORE_URL =
      'https://play.google.com/store/apps/details?id=[アプリのパッケージ名]';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _urlLaunchWithUri = UrlLaunchWithUri();
    return Platform.isIOS
      ? PopScope(
        // AndroidのBackボタンで閉じられないようにする
        canPop: false,
        child: CupertinoAlertDialog(
          title: const Text('アプリが更新されました。\n\n最新バージョンのダウンロードをお願いします。'),
          actions: [
            TextButton(
              onPressed: () {
                // App Store or Google Play に飛ばす処理
                _urlLaunchWithUri.launchUrlWithUri(context, WEB_SITE_URL);
              },
              child: const Text('アップデートする'),
            ),
          ],
        ),
      )
      : PopScope(
        // AndroidのBackボタンで閉じられないようにする
        canPop: false,
        child: CupertinoAlertDialog(
          title: const Text('アプリが更新されました。\n\n最新バージョンのダウンロードをお願いします。'),
          actions: [
            TextButton(
              onPressed: () {
                // App Store or Google Play に飛ばす処理
                _urlLaunchWithUri.launchUrlWithUri(context, WEB_SITE_URL);
              },
              child: const Text('アップデートする'),
            ),
          ],
        ),
      );
  }
}