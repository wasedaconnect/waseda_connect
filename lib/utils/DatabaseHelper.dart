import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _databaseHelper =
      DatabaseHelper._createInstance();
  static Database? _lessonDatabase;
  static Database? _timeTableDatabase;

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
        await getApplicationDocumentsDirectory(); //アプリの保存する場所
    String path = join(documentsDirectory.path, 'lesson.db'); //パスの作成
    var lessonDatabase =
        await openDatabase(path, version: 1, onCreate: _createLessonDb);
    return lessonDatabase;
  }

  ///データベースの初期化をSQL文で記述
  void _createLessonDb(Database db, int newVersion) async {
    await db.execute('CREATE TABLE lessons ('
        'id TEXT PRIMARY KEY, '
        'name TEXT, '
        'timeTableId TEXT, '
        'createdAt TEXT, '
        'day TEXT, '
        'period INTEGER'
        ')');
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
        await getApplicationDocumentsDirectory(); //アプリの保存する場所
    String path = join(documentsDirectory.path, 'TimeTable.db'); //パスの作成
    var TimeTableDatabase =
        await openDatabase(path, version: 1, onCreate: _createTimeTableDb);
    return TimeTableDatabase;
  }

  ///データベースの初期化をSQL文で記述
  void _createTimeTableDb(Database db, int newVersion) async {
    await db.execute('CREATE TABLE lessons ('
        'id TEXT PRIMARY KEY, '
        'name TEXT, '
        'timeTableId TEXT, '
        'createdAt TEXT, '
        'day TEXT, '
        'period INTEGER'
        ')');
  }
  //</lessonDB>
}
