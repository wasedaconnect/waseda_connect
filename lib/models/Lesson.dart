import 'package:sqflite/sqflite.dart';
import 'package:ulid/ulid.dart';
import '../utils/DatabaseHelper.dart';

class Lesson {
  //ユーザーが持っている授業
  final String id; //IDはulidで入れるつもり。
  final String name; //授業名
  final String timeTableId; //割り当てられた時間割ID

  Lesson({required this.id, required this.name, required this.timeTableId});

  factory Lesson.fromMap(Map<String, dynamic> map) {
    return Lesson(
      id: map['id'],
      name: map['name'],
      timeTableId: map['timeTableId'],
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'timeTableId': timeTableId,
    };
  }
}
//lessonに関するwidgetがある。

class LessonLogic {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // 新しい授業をデータベースに追加するメソッド
  Future<void> insertLesson(Lesson lesson) async {
    final db = await _dbHelper.lessonDatabase;
    var ulid = Ulid().toString(); // ULIDを生成
    var lessonWithUlid = Lesson(
      id: ulid,
      name: lesson.name,
      timeTableId: lesson.timeTableId,
    );
    await db.insert(
      'lessons',
      lessonWithUlid.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Lesson>> getAllLessons() async {
    final db = await _dbHelper.lessonDatabase;
    final List<Map<String, dynamic>> maps = await db.query('lessons');

    return List.generate(maps.length, (i) {
      return Lesson.fromMap(maps[i]);
    });
  }
}
