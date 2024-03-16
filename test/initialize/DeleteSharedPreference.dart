import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() {
  group('Database Tests', () {
    // テスト前に実行されるセットアップ関数
    setUp(() async {
      // テスト用のデータベースファイルパスを取得
      final String dbPath = join(await getDatabasesPath(), 'test.db');
      // データベースが存在する場合は削除
      await deleteDatabase(dbPath);
    });

    test('Delete Database', () async {
      // データベースファイルパスを取得
      final String dbPath = join(await getDatabasesPath(), 'test.db');
      // データベースを開く（存在しない場合は作成される）
      final Database db = await openDatabase(dbPath);
      // データベースを閉じる
      await db.close();

      // データベースを消去
      await deleteDatabase(dbPath);

      // データベースファイルが実際に消去されたかを確認するロジックをここに記述
      // この例では、単純にデータベースを開こうとして、エラーが発生するかどうかをチェックします
      bool dbExists = true;
      try {
        await openDatabase(dbPath);
      } catch (e) {
        dbExists = false;
      }

      // データベースが存在しないことを確認
      expect(dbExists, false);
    });
  });
}
