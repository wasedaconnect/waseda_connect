import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/DatabaseHelper.dart';

class ClassModel {
  final String academicYear; //学年
  final String department; //学部
  final String courseName; //コースの名前
  final String instructor;
  final String semester;
  final String classTime;
  final String courseCategory;
  final String assignedYear;
  final String credits;
  final String classroom;
  final String campus;
  final String courseKey;
  final String classCode;
  final String languageUsed;
  final String teachingMethod;
  final String courseCode;
  final String majorField;
  final String subField;
  final String minorField;
  final String level;
  final String classFormat;
  // 新しい属性を追加
  final int classDay1; //何曜日か（月曜日：1、火曜日：２　のように入っている
  final int classStart1; //スタートする時限（オンデマンドや無の時は10か11が入っている。）
  final int classTime1; //何時間分のコマか
  //コマが週に二個あるときの２
  final int classDay2;
  final int classStart2;
  final int classTime2;

  ClassModel({
    required this.academicYear,
    required this.department,
    required this.courseName,
    required this.instructor,
    required this.semester,
    required this.classTime,
    required this.courseCategory,
    required this.assignedYear,
    required this.credits,
    required this.classroom,
    required this.campus,
    required this.courseKey,
    required this.classCode,
    required this.languageUsed,
    required this.teachingMethod,
    required this.courseCode,
    required this.majorField,
    required this.subField,
    required this.minorField,
    required this.level,
    required this.classFormat,
    // 新しい属性の初期化
    required this.classDay1,
    required this.classStart1,
    required this.classTime1,
    required this.classDay2,
    required this.classStart2,
    required this.classTime2,
  });

  factory ClassModel.fromMap(Map<String, dynamic> map) {
    return ClassModel(
      academicYear: map['academicYear'],
      department: map['department'],
      courseName: map['courseName'],
      instructor: map['instructor'],
      semester: map['semester'],
      classTime: map['classTime'],
      courseCategory: map['courseCategory'],
      assignedYear: map['assignedYear'],
      credits: map['credits'],
      classroom: map['classroom'],
      campus: map['campus'],
      courseKey: map['courseKey'],
      classCode: map['classCode'],
      languageUsed: map['languageUsed'],
      teachingMethod: map['teachingMethod'],
      courseCode: map['courseCode'],
      majorField: map['majorField'],
      subField: map['subField'],
      minorField: map['minorField'],
      level: map['level'],
      classFormat: map['classFormat'],
      // 新しい属性をマップから読み込む
      classDay1: map['classDay1'],
      classStart1: map['classStart1'],
      classTime1: map['classTime1'],
      classDay2: map['classDay2'],
      classStart2: map['classStart2'],
      classTime2: map['classTime2'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'academicYear': academicYear,
      'department': department,
      'courseName': courseName,
      'instructor': instructor,
      'semester': semester,
      'classTime': classTime,
      'courseCategory': courseCategory,
      'assignedYear': assignedYear,
      'credits': credits,
      'classroom': classroom,
      'campus': campus,
      'courseKey': courseKey,
      'classCode': classCode,
      'languageUsed': languageUsed,
      'teachingMethod': teachingMethod,
      'courseCode': courseCode,
      'majorField': majorField,
      'subField': subField,
      'minorField': minorField,
      'level': level,
      'classFormat': classFormat,
      // 新しい属性をマップに追加
      'classDay1': classDay1,
      'classStart1': classStart1,
      'classTime1': classTime1,
      'classDay2': classDay2,
      'classStart2': classStart2,
      'classTime2': classTime2,
    };
  }
}

class ClassLogic {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> insertClass() async {
    final rawData = await rootBundle.loadString('assets/ClassData.csv');
    // CSVデータをリストに変換（ヘッダーをスキップ）
    List<List<dynamic>> listData =
        CsvToListConverter(eol: '\n', shouldParseNumbers: false)
            .convert(rawData)
            .skip(1)
            .toList();
    int i = 0;

    final db = await _dbHelper.classDatabase;
    var batch = db.batch(); // バッチ処理の開始
    for (var rowData in listData) {
      var classData = ClassModel(
        academicYear: rowData[0],
        department: rowData[1],
        courseName: rowData[2],
        instructor: rowData[3],
        semester: rowData[4],
        classTime: rowData[5],
        courseCategory: rowData[6],
        assignedYear: rowData[7],
        credits: rowData[8],
        classroom: rowData[9],
        campus: rowData[10],
        courseKey: rowData[11],
        classCode: rowData[12],
        languageUsed: rowData[13],
        teachingMethod: rowData[14],
        courseCode: rowData[15],
        majorField: rowData[16],
        subField: rowData[17],
        minorField: rowData[18],
        level: rowData[19],
        classFormat: rowData[20],
        // 新しい属性
        classDay1: int.parse(rowData[22]) ?? 0,
        classStart1: int.parse(rowData[23]) ?? 0,
        classTime1: int.parse(rowData[24]) ?? 0,
        classDay2: int.parse(rowData[25]) ?? 0,
        classStart2: int.parse(rowData[26]) ?? 0,
        classTime2: int.parse(rowData[27]) ?? 0,
      );

      batch.insert(
        'classes',
        classData.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      i += 1;
      print(i);
    }

    await batch.commit(noResult: true); // バッチ処理のコミット
  }

  Future<List<ClassModel>> searchClassesByName(String courseName) async {
    final db = await _dbHelper.classDatabase;
    final List<Map<String, dynamic>> maps = await db.query(
      'classes',
      where: 'courseName LIKE ?',
      whereArgs: ['%$courseName%'],
    );

    return List.generate(maps.length, (i) {
      return ClassModel.fromMap(maps[i]);
    });
  }
}
