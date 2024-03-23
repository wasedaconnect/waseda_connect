import 'dart:ffi';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'remote_config_provider.dart';
import 'package:package_info/package_info.dart';
import 'package:version/version.dart';

// remote configのprovider
final updateRequesterProvider = FutureProvider<bool>((ref) async {
  final remoteConfig = await ref.watch(remoteConfigProvider.future);
  await remoteConfig.fetchAndActivate();
  // Firebase の RemoteConfigコンソールで指定したキーを使って値を取得
  final requiredVersion = remoteConfig.getString('requiredVersion');
  if (requiredVersion.isEmpty) { 
    return false;
  }
  // JSON to Map

  // 現在のアプリケーションを取得
  final appPackageInfo = await PackageInfo.fromPlatform();
  final appVersion = appPackageInfo.version;



  // 現在のバージョンより新しいバージョンが指定されているか
  final hasNewVersion = Version.parse(requiredVersion) > Version.parse(appVersion);

  if (!hasNewVersion) {
    return false;
  }
  return true;
});