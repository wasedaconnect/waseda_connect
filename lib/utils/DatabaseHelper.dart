import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _databaseHelper =
      DatabaseHelper._createInstance();
  static Database? _lessonDatabase;

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
        await openDatabase(path, version: 1, onCreate: _createDb);
    return lessonDatabase;
  }

  ///データベースの初期化をSQL文で記述
  void _createDb(Database db, int newVersion) async {
    await db.execute('CREATE TABLE lessons ('
        'id TEXT PRIMARY KEY , '
        'name TEXT, '
        'timeTableId TEXT'
        ')');
  }
  //</lessonDB>
}
