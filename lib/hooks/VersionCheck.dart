import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info/package_info.dart';

class VersionCheck {

  /// バージョンチェック関数
  Future<bool> versionCheck() async {
    // versionCode(buildNumber)取得
    final PackageInfo info = await PackageInfo.fromPlatform();
    int currentVersion = int.parse(info.buildNumber);
    // releaseビルドかどうかで取得するconfig名を変更
    final configName = "requiredVersion";

    // remote config
    final FirebaseRemoteConfig remoteConfig = await FirebaseRemoteConfig.instance;

    try {
      // 常にサーバーから取得するようにするため期限を最小限にセット
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: Duration.zero,
        ),
    );
      int newVersion = remoteConfig.getInt(configName);
      if (newVersion > currentVersion) {
        return true;
      }

    } catch (exception) {
      print('Unable to fetch remote config. Cached or default values will be '
          'used');
    }
    return false;
  }
}
