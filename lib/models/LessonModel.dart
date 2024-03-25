import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ulid/ulid.dart';
import 'package:waseda_connect/Screen/TimeTable/TimeTable.dart';
import 'package:waseda_connect/constants/Dict.dart';
import 'package:waseda_connect/models/ClassModel.dart';
import 'package:waseda_connect/models/TimeTableModel.dart';
import '../utils/DatabaseHelper.dart';
import 'package:intl/intl.dart';

class LessonModel {
  final String id; // IDはulidで入れる
  final String name; // 授業名
  final String timeTableId; // 割り当てられた時間割ID
  final String createdAt; // 作成日時（ISO 8601形式の文字列を想定）
  final int day; // 一つ目の時間の曜日
  final int period; // 時限（1-7）

  final String classroom;
  final String classId; //早稲田が提供する授業コード,classと紐づけたい
  final int color;

  LessonModel(
      {required this.id,
      required this.name,
      required this.timeTableId,
      required this.createdAt,
      required this.day,
      required this.period,
      required this.classroom,
      required this.classId,
      required this.color});

  factory LessonModel.fromMap(Map<String, dynamic> map) {
    return LessonModel(
        id: map['id'],
        name: map['name'],
        timeTableId: map['timeTableId'],
        createdAt: map['createdAt'],
        day: map['day'],
        period: map['period'],
        classroom: map['classroom'],
        classId: map['classId'],
        color: map['color']);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'timeTableId': timeTableId,
      'createdAt': createdAt,
      'day': day,
      'period': period,
      'classroom': classroom,
      'classId': classId,
      'color': color
    };
  }
}

//lessonに関するwidgetがある。

class LessonLogic {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // 新しい授業をデータベースに追加するメソッド 結構複雑
  Future<bool> insertLesson(String classId) async {
    if (await validateLessonData(classId) == false) {
      return false;
    }
    final db = await _dbHelper.lessonDatabase;
    final ClassLogic instance = ClassLogic();
    final classData = await instance.searchClassesByPKey(classId);
    final prefs = await SharedPreferences.getInstance();
    final int defaultYear = prefs.getInt('defaultYear')!;
    final TimeTableLogic timeTableInstance = TimeTableLogic();
    final timeTableData =
        await timeTableInstance.getTimeTablesByYear(defaultYear);
    for (var semesterData in termToSemester[classData.semester]!) {
      //timetableごとにデータベースに入れる。
      // ULIDを生成
      print(semesterData);
      for (int i = 0; i < classData.classTime1; i++) {
        var lessonWithUlid = LessonModel(
            id: Ulid().toString(), // ULIDを生成して文字列に変換
            name: classData.courseName,
            timeTableId: timeTableData[semesterData - 1].id,
            createdAt: DateFormat('yyyy-MM-ddTHH:mm:ss')
                .format(DateTime.now()), // 現在の日時をISO 8601形式の文字列で生成
            day: classData.classDay1,
            period: classData.classStart1 + i,
            classroom: classData.classroom,
            classId: classId,
            color: 1);
        await db.insert(
          'lessons',
          lessonWithUlid.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      if (classData.classTime2 > 0) {
        //週に二個以上ある科目かどうか
        for (int i = 0; i < classData.classTime2; i++) {
          var lessonWithUlid = LessonModel(
              id: Ulid().toString(), // ULIDを生成して文字列に変換
              name: classData.courseName,
              timeTableId: timeTableData[semesterData - 1].id,
              createdAt: DateFormat('yyyy-MM-ddTHH:mm:ss')
                  .format(DateTime.now()), // 現在の日時をISO 8601形式の文字列で生成
              day: classData.classDay2,
              period: classData.classStart2 + i,
              classroom: classData.classroom,
              classId: classId,
              color: 1);
          await db.insert(
            'lessons',
            lessonWithUlid.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    }
    return true;
  }

  // ダミーデータを登録
  Future<void> insertDummyLesson(String name, String classRoom, int day,
      int period, TimeTableModel? timeTableData) async {
    final db = await _dbHelper.lessonDatabase;
    final dbClass = await _dbHelper.classDatabase;
    final TimeTableLogic timeTableInstance = TimeTableLogic();
    final prefs = await SharedPreferences.getInstance();
    final int defaultYear = prefs.getInt('defaultYear')!;
    var newTimeTablesData =
        await timeTableInstance.getTimeTablesByYear(defaultYear);
    print("timetableid");
    print(newTimeTablesData);
    // final timeTable = await timeTableInstance.getTimeTable(timeTableId);
    // final int semester = timeTable!.semester;

    // ULIDを生成
    var lessonWithUlid = LessonModel(
        id: Ulid().toString(), // ULIDを生成して文字列に変換
        name: name,
        timeTableId: timeTableData!.id,
        createdAt: DateFormat('yyyy-MM-ddTHH:mm:ss')
            .format(DateTime.now()), // 現在の日時をISO 8601形式の文字列で生成
        day: day,
        period: period,
        color: 1,
        classroom: classRoom,
        classId: "dummy");

    // var dummyClass = ClassModel(
    //     pKey: "dummydata-${name}",
    //     department: 0,
    //     courseName: name,
    //     instructor: "",
    //     semester: timeTableData!.semester,
    //     courseCategory: "",
    //     assignedYear: 0,
    //     credits: 0,
    //     classroom: "",
    //     campus: "",
    //     languageUsed: "",
    //     teachingMethod: 0,
    //     courseCode: "",
    //     majorField: "",
    //     subField: "",
    //     minorField: "",
    //     level: "",
    //     classFormat: "",
    //     classDay1: day,
    //     classStart1: period,
    //     classTime1: 1,
    //     classDay2: 0,
    //     classStart2: 0,
    //     classTime2: 0,
    //     isOpened: 0);

    await db.insert(
      'lessons',
      lessonWithUlid.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    // await dbClass.insert(
    //   'classes',
    //   dummyClass.toMap(),
    //   conflictAlgorithm: ConflictAlgorithm.replace,
    // );
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

  //
  Future<List<LessonModel>> getLessonsByTimeTableId(String timeTableId) async {
    final db = await _dbHelper.lessonDatabase;
    final List<Map<String, dynamic>> maps = await db.query(
      'lessons',
      where: 'timeTableId = ?',
      whereArgs: [timeTableId],
    );

    // 結果が空の場合はnullを返す

    return List.generate(maps.length, (i) {
      return LessonModel.fromMap(maps[i]);
    });
  }

  // 授業をIDから取得するメソッド
  Future<LessonModel?> getLessonById(String id) async {
    print('getLessonById');
    print(id);

    final db = await _dbHelper.lessonDatabase;

    final List<Map<String, dynamic>> maps = await db.query(
      'lessons',
      where: 'id = ?',
      whereArgs: [id],
    );
    print(maps);

    if (maps.isNotEmpty) {
      return LessonModel.fromMap(maps.first);
    }
    return null; // 該当する授業が見つからない場合はnullを返す
  }

  // 授業をIDから取得するメソッド
  Future<LessonModel?> getLessonByPKey(String pKey) async {
    print('getLessonById');
    print(pKey);

    final db = await _dbHelper.lessonDatabase;

    final List<Map<String, dynamic>> maps = await db.query(
      'lessons',
      where: 'classId = ?',
      whereArgs: [pKey],
    );
    print(maps);

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

    await db.delete('lessons', where: 'classId = ? ', whereArgs: [classId]);
    print("削除できました");
  }

  Future<bool> validateLessonData(String classId) async {
    final db = await _dbHelper.lessonDatabase;
    final ClassLogic instance = ClassLogic();
    final classData = await instance.searchClassesByPKey(classId);
    final prefs = await SharedPreferences.getInstance();
    final int defaultYear = prefs.getInt('defaultYear') ?? 2024;
    final TimeTableLogic timeTableInstance = TimeTableLogic();
    final timeTableData =
        await timeTableInstance.getTimeTablesByYear(defaultYear);
    for (var semesterData in termToSemester[classData.semester]!) {
      for (int i = 0; i < classData.classTime1; i++) {
        var period1 = classData.classStart1 + i;
        var day1 = classData.classDay1;

        if (!(period1 == 10 || period1 == 11) || day1 != 7) {
          //オンデマンドを除く
          final List<Map<String, dynamic>> result = await db.query(
            'lessons', // ここには検索するテーブル名を指定
            where: 'period = ? AND day = ? AND timeTableId = ?',
            whereArgs: [period1, day1, timeTableData[semesterData - 1].id],
          );
          if (result.isEmpty == false) {
            return false;
          }
        }
      }
      if (classData.classTime2 > 0) {
        //週に二個以上ある科目かどうか
        for (int i = 0; i < classData.classTime2; i++) {
          var period2 = classData.classStart2 + i;
          var day2 = classData.classDay2;
          if (!(period2 == 10 || period2 == 11) || day2 != 7) {
            //オンデマンドを除く
            //オンデマンドを除く
            final List<Map<String, dynamic>> result = await db.query(
              'lessons', // ここには検索するテーブル名を指定
              where: 'period = ? AND day = ? AND timeTableId = ?',
              whereArgs: [period2, day2, timeTableData[semesterData - 1].id],
            );
            if (result.isEmpty == false) {
              return false;
            }
          }
        }
      }
      if(classData.classDay1 == 7){ //オンデマ科目
        final List<Map<String, dynamic>> result = await db.query(
          'lessons', // ここには検索するテーブル名を指定
          where: 'classId = ? AND timeTableId = ?',
          whereArgs: [classData.pKey, timeTableData[semesterData - 1].id],
        );
        if(result.isNotEmpty){ //すでに存在している
          return false;
        }

      }
    }
    return true;
  }

  Future<void> deleteDummyLesson(
      int day, int period, TimeTableModel? timeTableData) async {
    final db = await _dbHelper.lessonDatabase;

    await db.delete('lessons',
        where: 'classId = ? AND day = ? AND period = ? AND timeTableId = ?',
        whereArgs: ["dummy", day, period, timeTableData!.id]);

    print("削除できました");
  }

  // 授業の背景色の変更するメソッド
  Future<void> changeLessonColor(String id, int colorId) async {
    // LessonModelのcolorに数字を当てる感じ
    print('授業の背景色の変更');
    final db = await _dbHelper.lessonDatabase;

    await db.update(
      'lessons',
      {'color': colorId}, // 更新するフィールドと値
      where: 'classId = ?', // 更新する条件
      whereArgs: [id], // 条件に対応する値
    );
  }

  Future<void> changeLessonName(String id, String value) async {
    print('授業の表示名の変更');
    print(id);
    print(value);
    final db = await _dbHelper.lessonDatabase;

    final a = await db.update(
      'lessons',
      {'name': value}, // 更新するフィールドと値
      where: 'classId = ?', // 更新する条件
      whereArgs: [id], // 条件に対応する値
    );
    print(a);
  }

  Future<void> changeLessonClassroom(String id, String value) async {
    print('教室の表示名の変更');
    final db = await _dbHelper.lessonDatabase;
    await db.update(
      'lessons',
      {'classroom': value}, // 更新するフィールドと値
      where: 'classId = ?', // 更新する条件
      whereArgs: [id], // 条件に対応する値
    );
  }
}
