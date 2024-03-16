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

  LessonModel({
    required this.id,
    required this.name,
    required this.timeTableId,
    required this.createdAt,
    required this.day,
    required this.period,
  });

  factory LessonModel.fromMap(Map<String, dynamic> map) {
    return LessonModel(
      id: map['id'],
      name: map['name'],
      timeTableId: map['timeTableId'],
      createdAt: map['createdAt'],
      day: map['dayOfWeek'],
      period: map['period'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'timeTableId': timeTableId,
      'createdAt': createdAt,
      'dayOfWeek': day,
      'period': period,
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
      day: 'Monday', // 例として「Monday」を設定
      period: 1, // 例として「1」を設定
    );
    await db.insert(
      'lessons',
      lessonWithUlid.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LessonModel>> getAllLessons() async {
    final db = await _dbHelper.lessonDatabase;
    final List<Map<String, dynamic>> maps = await db.query('lessons');

    return List.generate(maps.length, (i) {
      return LessonModel.fromMap(maps[i]);
    });
  }
}
