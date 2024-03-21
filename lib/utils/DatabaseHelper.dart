import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:waseda_connect/constants/DatabaseVersion.dart';

class DatabaseHelper {
  static final DatabaseHelper _databaseHelper =
      DatabaseHelper._createInstance();
  static Database? _lessonDatabase; //ユーザー保持の授業をlesson
  static Database? _timeTableDatabase;
  static Database? _classDatabase; //早稲田公式の授業をclassと呼ぶ

  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    return _databaseHelper;
  }

//<lessonDB>
  //授業データベースの出力、もし存在しなかったら作る。
  Future<Database> get lessonDatabase async {
//現在の番号を取得。
    final int externalVersion = databaseVersion["lesson"]!;

    // データベースが既に初期化されているかどうかをチェック
    if (_lessonDatabase != null) {
      // データベースの現在のバージョンを取得
      final int currentVersion = await _lessonDatabase!.getVersion();
      // 外部バージョンと現在のバージョンを比較
      if (currentVersion < externalVersion) {
        // 必要に応じてデータベースをアップグレード
        _lessonDatabase = await initializeLessonDatabase(externalVersion);
      }
    } else {
      // データベースが初期化されていない場合は、初期化を行う
      _lessonDatabase = await initializeLessonDatabase(externalVersion);
    }

    return _lessonDatabase!;
  }

  ///データベースの初期化
  Future<Database> initializeLessonDatabase(int externalVersion) async {
    var documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'lesson.db');
    var lessonDatabase = await openDatabase(
      path,
      version: externalVersion, // 外部から取得したバージョン番号を使用
      onCreate: _createLessonDb,
      onUpgrade: _onUpgradeLessonDb,
    );

    return lessonDatabase;
  }

  /// データベースの初期化をSQL文で記述
  void _createLessonDb(Database db, int newVersion) async {
    await db.execute('''
  CREATE TABLE lessons (
    id TEXT PRIMARY KEY,
    name TEXT,
    timeTableId TEXT,
    createdAt TEXT,
    day INTEGER,
    period INTEGER,
    classroom TEXT,
    classId TEXT,
    color INTEGER
  )
''');
  } //どっちにも追加しないといけない。

  /// データベースのマイグレーション処理バージョンが変わるごとにこの処理を行いたい。
  void _onUpgradeLessonDb(Database db, int oldVersion, int newVersion) async {
    print(oldVersion);
    print(newVersion);
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE lessons ADD COLUMN color INTEGER'); //どっちにも追加しないといけない
    }
    // 他のバージョンアップの処理をここに追加
  }

  //</lessonDB>
  //<TimeTableDB>
  //授業データベースの出力、もし存在しなかったら作る。
  Future<Database> get timeTableDatabase async {
    _timeTableDatabase ??= await initializeTimeTableDatabase();
    return _timeTableDatabase!;
  }

  ///データベースの初期化
  Future<Database> initializeTimeTableDatabase() async {
    var documentsDirectory =
        await getApplicationDocumentsDirectory(); // アプリの保存場所
    String path = join(documentsDirectory.path, 'TimeTable.db'); // パスの作成

    var TimeTableDatabase = await openDatabase(
      path,
      version: 2, // バージョンを更新した場合はここを変更
      onCreate: _createTimeTableDb,
      onUpgrade: _onUpgrade, // マイグレーション処理を追加
    );
    return TimeTableDatabase;
  }

  /// データベースの初期化をSQL文で記述
  void _createTimeTableDb(Database db, int newVersion) async {
    await db.execute('CREATE TABLE timeTables ('
        'id TEXT PRIMARY KEY, '
        'grade INTEGER, '
        'createdAt TEXT, '
        'semester INTEGER, '
        'year INTEGER'
        ')');
  }

  /// データベースのマイグレーション処理
  void _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // バージョン1から2へのマイグレーション
    if (oldVersion < 2) {
      // await db.execute('ALTER TABLE timeTables ADD COLUMN updatedAt TEXT');
    }
    // さらに新しいバージョンへのマイグレーションが必要な場合は、ここに追加
  }
  //</timeTableDB>

  //<class> 早稲田公式の授業データ

  Future<Database> get classDatabase async {
    var documentsDirectory =
        await getApplicationDocumentsDirectory(); // アプリの保存場所
    String path = join(documentsDirectory.path, 'Class.db');
    _classDatabase = await openDatabase(path, version: 1);
    return _classDatabase!;
  }

  //</class>
}
