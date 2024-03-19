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
        'day1 INTEGER, '
        'start INTEGER,'
        'time1 INTEGER,'
        'day2 INTEGER,'
        'start2 INTEGER,'
        'time2 INTEGER,'
        'classId TEXT'
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
    await db.execute('CREATE TABLE timeTables ('
        'id TEXT PRIMARY KEY, '
        'grade INTEGER, '
        'createdAt TEXT, '
        'semester TEXT, '
        'year INTEGER'
        ')');
  }
  //</timeTableDB>

  //<class> 早稲田公式の授業データ
  //DBがすでに存在するとき、それを消して新しいものを作るようにしたい。
  Future<Database> get classDatabase async {
    _classDatabase ??= await initializeclassDatabase();
    return _classDatabase!;
  }

  ///データベースの初期化
  Future<Database> initializeclassDatabase() async {
    var documentsDirectory =
        await getApplicationDocumentsDirectory(); //アプリの保存する場所
    String path = join(documentsDirectory.path, 'Class.db'); //パスの作成
    var classDatabase =
        await openDatabase(path, version: 1, onCreate: _createClassDb);
    return classDatabase;
  }

  ///データベースの初期化をSQL文で記述
  void _createClassDb(Database db, int newVersion) async {
    await db.execute('CREATE TABLE classes ('
        'id TEXT PRIMARY KEY,'
        'academicYear TEXT,'
        'department TEXT,'
        'courseName TEXT,'
        'instructor TEXT,'
        'semester TEXT,'
        'classTime TEXT,'
        'courseCategory TEXT,'
        'assignedYear TEXT,'
        'credits TEXT,'
        'classroom TEXT,'
        'campus TEXT,'
        'courseKey TEXT,'
        'classCode TEXT,'
        'languageUsed TEXT,'
        'teachingMethod TEXT,'
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
        'classTime2 INTEGER'
        ');');

    //</class>
  }
}
