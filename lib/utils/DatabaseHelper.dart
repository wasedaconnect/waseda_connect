import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

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
    _lessonDatabase ??= await initializeLessonDatabase();
    return _lessonDatabase!;
  }

  ///データベースの初期化
  Future<Database> initializeLessonDatabase() async {
    var documentsDirectory =
        await getApplicationDocumentsDirectory(); // アプリの保存場所
    String path = join(documentsDirectory.path, 'lesson.db'); // パスの作成
    var lessonDatabase = await openDatabase(
      path,
      version: 2, // データベースのバージョンを更新
      onCreate: _createLessonDb,
      onUpgrade: _onUpgradeLessonDb, // マイグレーション処理を追加
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
    color INTEGER,
    FOREIGN KEY (timeTableId) REFERENCES timeTables(id),
    FOREIGN KEY (classId) REFERENCES classes(pKey)
  )
''');
  }

  /// データベースのマイグレーション処理
  void _onUpgradeLessonDb(Database db, int oldVersion, int newVersion) async {
    print(oldVersion);
    if (oldVersion < 2) {
      // 例: バージョン1から2へのマイグレーションで新しいカラムを追加
      // await db.execute('ALTER TABLE lessons ADD COLUMN color INTEGER');
    }
    // さらに新しいバージョンへのマイグレーションが必要な場合は、ここに追加
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
    _classDatabase ??= await initializeclassDatabase();
    return _classDatabase!;
  }

  /// データベースの初期化
  Future<Database> initializeclassDatabase() async {
    var documentsDirectory =
        await getApplicationDocumentsDirectory(); // アプリの保存場所
    String path = join(documentsDirectory.path, 'Class.db'); // パスの作成

    // データベースファイルが存在する場合、削除する

    // 新しいデータベースを作成
    return openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // テーブルを作成するSQLコマンド
      await _createClassDb(db, version);
    });
  }

  /// データベースの初期化をSQL文で記述
  Future<void> _createClassDb(Database db, int newVersion) async {
    await db.execute('CREATE TABLE classes ('
        'pKey TEXT PRIMARY KEY,'
        'department INTEGER,'
        'courseName TEXT,'
        'instructor TEXT,'
        'semester INTEGER,'
        'courseCategory TEXT,'
        'assignedYear INTEGER,'
        'credits INTEGER,'
        'classroom TEXT,'
        'campus TEXT,'
        'languageUsed TEXT,'
        'teachingMethod INTEGER,'
        'courseCode TEXT,'
        'majorField TEXT,'
        'subField TEXT,'
        'minorField TEXT,'
        'level TEXT,'
        'classFormat TEXT,'
        'classDay1 INTEGER,'
        'classStart1 INTEGER,'
        'classTime1 INTEGER,'
        'classDay2 INTEGER,'
        'classStart2 INTEGER,'
        'classTime2 INTEGER,'
        'isOpened INTEGER'
        ');');
  }

  //</class>
}
