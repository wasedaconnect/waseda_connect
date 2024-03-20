import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ulid/ulid.dart';
import 'package:waseda_connect/models/ClassModel.dart';
import '../utils/DatabaseHelper.dart';
import 'package:intl/intl.dart';

class LessonModel {
  final String id; // IDはulidで入れる
  final String name; // 授業名
  final String timeTableId; // 割り当てられた時間割ID
  final String createdAt; // 作成日時（ISO 8601形式の文字列を想定）
  final int day1; // 一つ目の時間の曜日
  final int start1; // 時限（1-7）
  final int time1;
  final int day2; //一週間ににこある授業のため。
  final int start2;
  final int time2;
  final String classroom;
  final String classId; //早稲田が提供する授業コード,classと紐づけたい

  LessonModel(
      {required this.id,
      required this.name,
      required this.timeTableId,
      required this.createdAt,
      required this.day1,
      required this.start1,
      required this.time1,
      required this.day2,
      required this.start2,
      required this.time2,
      required this.classroom,
      required this.classId});

  factory LessonModel.fromMap(Map<String, dynamic> map) {
    return LessonModel(
        id: map['id'],
        name: map['name'],
        timeTableId: map['timeTableId'],
        createdAt: map['createdAt'],
        day1: map['day1'],
        start1: map['start1'],
        time1: map['time1'],
        day2: map['day2'],
        start2: map['start2'],
        time2: map['time2'],
        classroom: map['classroom'],
        classId: map['classId']);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'timeTableId': timeTableId,
      'createdAt': createdAt,
      'day1': day1,
      'start1': start1,
      'time1': time1,
      'day2': day2,
      'start2': start2,
      'time2': time2,
      'classroom': classroom,
      'classId': classId
    };
  }
}

//lessonに関するwidgetがある。

class LessonLogic {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // 新しい授業をデータベースに追加するメソッド
  Future<void> insertLesson(String classId) async {
    final db = await _dbHelper.lessonDatabase;
    final ClassLogic instance = ClassLogic();
    final classData = await instance.searchClassesByPKey(classId);
    final prefs = await SharedPreferences.getInstance();
    final String timeTableId = prefs.getString('defaultId') ?? "";

    // ULIDを生成
    var lessonWithUlid = LessonModel(
        id: Ulid().toString(), // ULIDを生成して文字列に変換
        name: classData.courseName,
        timeTableId: timeTableId,
        createdAt: DateFormat('yyyy-MM-ddTHH:mm:ss')
            .format(DateTime.now()), // 現在の日時をISO 8601形式の文字列で生成
        day1: classData.classDay1,
        start1: classData.classStart1,
        time1: classData.classTime1,
        day2: classData.classDay2,
        start2: classData.classStart2,
        time2: classData.classTime2,
        classroom: classData.classroom,
        classId: classId);

    await db.insert(
      'lessons',
      lessonWithUlid.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

//特定の時間割の授業をすべて出力。
  Future<List<LessonModel>> getAllLessons() async {
    final prefs = await SharedPreferences.getInstance();
    final String timeTableId = prefs.getString('defaultId') ?? "";
    final db = await _dbHelper.lessonDatabase;
    final List<Map<String, dynamic>> maps = await db.query(
      'lessons',
      where: 'timeTableId = ?',
      whereArgs: [timeTableId],
    );
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

// 特定の授業を削除する機能
  Future<void> deleteLessonByClassId(String classId) async {
    final db = await _dbHelper.lessonDatabase;
    final prefs = await SharedPreferences.getInstance();
    final String timeTableId = prefs.getString('defaultId') ?? "";
    await db.delete(
      'lessons',
      where: 'classId = ? AND timeTableId = ?',
      whereArgs: [classId, timeTableId]
    );
    print("削除できました");
  }
}
