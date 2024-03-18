import 'package:sqflite/sqflite.dart';
import 'package:ulid/ulid.dart';
import '../utils/DatabaseHelper.dart';
import 'package:intl/intl.dart';

class LessonModel {
  final String id; // IDはulidで入れる
  final String name; // 授業名
  final String timeTableId; // 割り当てられた時間割ID
  final String createdAt; // 作成日時（ISO 8601形式の文字列を想定）
  final String day; // 曜日
  final int period; // 時限（1-7）
  final String code; //早稲田が提供する授業コード

  LessonModel(
      {required this.id,
      required this.name,
      required this.timeTableId,
      required this.createdAt,
      required this.day,
      required this.period,
      required this.code});

  factory LessonModel.fromMap(Map<String, dynamic> map) {
    return LessonModel(
        id: map['id'],
        name: map['name'],
        timeTableId: map['timeTableId'],
        createdAt: map['createdAt'],
        day: map['day'],
        period: map['period'],
        code: map['code']);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'timeTableId': timeTableId,
      'createdAt': createdAt,
      'day': day,
      'period': period,
      'code': code
    };
  }
}

//lessonに関するwidgetがある。

class LessonLogic {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // 新しい授業をデータベースに追加するメソッド
  Future<void> insertLesson(LessonModel lesson) async {
    final db = await _dbHelper.lessonDatabase;
    // ULIDを生成
    var lessonWithUlid = LessonModel(
        id: Ulid().toString(), // ULIDを生成して文字列に変換
        name: lesson.name,
        timeTableId: lesson.timeTableId,
        createdAt: DateFormat('yyyy-MM-ddTHH:mm:ss')
            .format(DateTime.now()), // 現在の日時をISO 8601形式の文字列で生成
        day: lesson.day,
        period: lesson.period,
        code: lesson.code);
    await db.insert(
      'lessons',
      lessonWithUlid.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

//授業をすべて出力。
  Future<List<LessonModel>> getAllLessons() async {
    final db = await _dbHelper.lessonDatabase;
    final List<Map<String, dynamic>> maps = await db.query('lessons');
    return List.generate(maps.length, (i) {
      return LessonModel.fromMap(maps[i]);
    });
  }

  // 授業をIDから取得するメソッド
  Future<LessonModel?> getLessonById(String id) async {
    final db = await _dbHelper.lessonDatabase;
    final List<Map<String, dynamic>> maps = await db.query(
      'lessons',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return LessonModel.fromMap(maps.first);
    }
    return null; // 該当する授業が見つからない場合はnullを返す
  }

// 特定の授業のdayとperiodを更新するメソッド
  Future<void> updateLessonDayAndPeriod(
      String id, String newDay, int newPeriod) async {
    final db = await _dbHelper.lessonDatabase;
    await db.update(
      'lessons',
      {
        'dayOfWeek': newDay,
        'period': newPeriod,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
