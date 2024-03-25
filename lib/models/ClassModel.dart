import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import '../utils/DatabaseHelper.dart';

class ClassModel {
  final String pKey; //キーとして追加
  // final String academicYear; //年度
  final int department; //学部
  final String courseName; //コースの名前
  final String instructor; //教師名
  final int semester; //学期
  // final String classTime 時間
  final String courseCategory; //授業カテゴリー
  final int assignedYear; //割り当て年
  final int credits; //単位数
  final String classroom; //教室
  final String campus; //キャンパス
  // final String courseKey;//こーづコード
  // final String classCode;//クラスコード
  final String languageUsed;
  final int teachingMethod; //オンラインか対面か
  final String courseCode; //コースのコード、学科とかわかるかも
  final String majorField; //大分類
  final String subField; //中分類
  final String minorField; //小分類
  final String level; //レベル
  final String classFormat; //形式
  final int isOpened;
  // 新しい属性を追加
  final int classDay1; //何曜日か（月曜日：1、火曜日：２　のように入っている
  final int classStart1; //スタートする時限（フルオンデマンドやその他の時は10か11が入っている。）
  final int classTime1; //何時間分のコマか
  //コマが週に二個あるときの２
  final int classDay2;
  final int classStart2;
  final int classTime2;

  ClassModel({
    required this.pKey,
    required this.department,
    required this.courseName,
    required this.instructor,
    required this.semester,
    required this.courseCategory,
    required this.assignedYear,
    required this.credits,
    required this.classroom,
    required this.campus,
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
    required this.isOpened,
  });

  factory ClassModel.fromMap(Map<String, dynamic> map) {
    return ClassModel(
        pKey: map['pKey'],
        department: map['department'],
        courseName: map['courseName'],
        instructor: map['instructor'],
        semester: map['semester'],
        courseCategory: map['courseCategory'],
        assignedYear: map['assignedYear'],
        credits: map['credits'],
        classroom: map['classroom'],
        campus: map['campus'],
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
        isOpened: map['isOpened']);
  }

  Map<String, dynamic> toMap() {
    return {
      'pKey': pKey,

      'department': department,
      'courseName': courseName,
      'instructor': instructor,
      'semester': semester,

      'courseCategory': courseCategory,
      'assignedYear': assignedYear,
      'credits': credits,
      'classroom': classroom,
      'campus': campus,

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
      'isOpened': isOpened
    };
  }
}

class ClassLogic {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  //今は使っていないCSVインポート
  Future<void> insertClass() async {
    final rawData = await rootBundle.loadString('assets/ClassData.csv'); //テスト用
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
          department: int.parse(rowData[1]) ?? 0,
          courseName: rowData[2],
          instructor: rowData[3],
          semester: int.parse(rowData[4]) ?? 0,
          courseCategory: rowData[6],
          assignedYear: int.parse(rowData[7]) ?? 0,
          credits: int.parse(rowData[8]) ?? 0,
          classroom: rowData[9],
          campus: rowData[10],
          languageUsed: rowData[13],
          teachingMethod: int.parse(rowData[14]) ?? 0,
          courseCode: rowData[15],
          majorField: rowData[16],
          subField: rowData[17],
          minorField: rowData[18],
          level: rowData[19],
          classFormat: rowData[20],
          isOpened: int.parse(rowData[21]) ?? 0,
          // 新しい属性
          classDay1: int.parse(rowData[22]) ?? 0,
          classStart1: int.parse(rowData[23]) ?? 0,
          classTime1: int.parse(rowData[24]) ?? 0,
          classDay2: int.parse(rowData[25]) ?? 0,
          classStart2: int.parse(rowData[26]) ?? 0,
          classTime2: int.parse(rowData[27]) ?? 0,
          pKey: rowData[28]);

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

//コースネームでlike検索。
  Future<List<ClassModel>> searchClassesByName(String courseName) async {
    final db = await _dbHelper.classDatabase;
    final List<Map<String, dynamic>> maps = await db.query(
      'classes',
      where: 'courseName LIKE ?',
      whereArgs: ['%$courseName%'],
      limit: 30000,
    );

    return List.generate(maps.length, (i) {
      return ClassModel.fromMap(maps[i]);
    });
  }

//pKeyでサーチする。
  Future<ClassModel> searchClassesByPKey(String pKey) async {
    final db = await _dbHelper.classDatabase;
    final List<Map<String, dynamic>> maps = await db.query(
      'classes',
      where: 'pKey = ?',
      whereArgs: [pKey], // pKeyの値をwhere句の?に渡す
      limit: 1,
    );
    print("maps");
    if (maps.isEmpty) {
      //ダミーデータを参照したとき
      print("ダミーの場合");
      return ClassModel(
          pKey: "dummydata",
          department: 0,
          courseName: "",
          instructor: "",
          semester: 0,
          courseCategory: "",
          assignedYear: 0,
          credits: 0,
          classroom: "",
          campus: "",
          languageUsed: "",
          teachingMethod: 0,
          courseCode: "",
          majorField: "",
          subField: "",
          minorField: "",
          level: "",
          classFormat: "",
          classDay1: 0,
          classStart1: 0,
          classTime1: 0,
          classDay2: 0,
          classStart2: 0,
          classTime2: 0,
          isOpened: 0);
    }
    print(maps[0]['pKey']);
    print(pKey);
    return ClassModel(
      pKey: maps[0]['pKey'],
      department: maps[0]['department'],
      courseName: maps[0]['courseName'],
      instructor: maps[0]['instructor'],
      semester: maps[0]['semester'],
      courseCategory: maps[0]['courseCategory'],
      assignedYear: maps[0]['assignedYear'],
      credits: maps[0]['credits'],
      classroom: maps[0]['classroom'],
      campus: maps[0]['campus'],
      languageUsed: maps[0]['languageUsed'],
      teachingMethod: maps[0]['teachingMethod'],
      courseCode: maps[0]['courseCode'],
      majorField: maps[0]['majorField'],
      subField: maps[0]['subField'],
      minorField: maps[0]['minorField'],
      level: maps[0]['level'],
      classFormat: maps[0]['classFormat'],
      classDay1: maps[0]['classDay1'],
      classStart1: maps[0]['classStart1'],
      classTime1: maps[0]['classTime1'],
      classDay2: maps[0]['classDay2'],
      classStart2: maps[0]['classStart2'],
      classTime2: maps[0]['classTime2'],
      isOpened: maps[0]['isOpened'],
    );
  }

  Future<List<ClassModel>> searchClasses(
      // 各変数を999で初期化
      // 引数があれば値を更新し検索条件とする
      {
    int department = 0,
    int semester = 0,
    int day = 0,
    int time = 0,
    int teachingMethod = 0,
  }) async {
    final db = await _dbHelper.classDatabase;
    List<String> whereClauses = [];
    List<dynamic> whereArgs = [];

    print('searchClasses: $department : $semester : $day : $time');

    // 条件を動的に構築
    if (semester != 0) {
      whereClauses.add('semester = ?');
      whereArgs.add(semester);
    }

    // 曜日と時限が両方とも選択されている場合
    // 複数コマ連続の授業を検索するため、classTimeを組み合わせたクエリを作成し、ORで接続している
    if (day != 0 && time != 0) {
      // 普通に1コマの授業のクエリ
      String innerClause =
          '((classDay1 = ? AND classStart1 = ?) OR (classDay2 = ? AND classStart2 = ?))';
      whereArgs.addAll([day, time, day, time]);

      // classTimeの組み合わせのクエリを作成
      // 例えば「月4」で検索された場合
      //    1つ目のループで月3,月2,月1を作成 (最大の連続コマが4コマなので検索された時限から遡り最大3つ分をループ)
      //    2つ目のループで授業のコマ数(classTime)を作成(検索された時限-対象の次元-1+2で初期値を取れる。そこから最大コマ4までをループでクエリ生成)
      for (int i = time - 1; i >= (time - 3 > 0 ? time - 3 : 1); i--) {
        // classTimeの開始値を計算する
        int startTime = 2 + (time - 1 - i);

        for (int classTime = startTime; classTime <= 4; classTime++) {
          innerClause += " OR ";

          innerClause +=
              "((classDay1 = ? AND classStart1 = ? AND classTime1 = ?) OR (classDay2 = ? AND classStart2 = ? AND classTime2 = ?))";
          whereArgs.addAll([day, i, classTime, day, i, classTime]);
        }
      }
      whereClauses.add('($innerClause)');
    } else if (day != 0) {
      if (day == 7) {
        whereClauses.add('classDay1 = ?');
        whereArgs.addAll([day]);
      } else {
        whereClauses.add('(classDay1 = ? OR classDay2 = ?)');
        whereArgs.addAll([day, day]);
      }
    } else if (time != 0) {
      // 時限だけが入力されている場合のクエリの作成
      // アルゴリズムに着いては上記記載の両方入力されている場合を参照
      String innerClause = '(classStart1 = ? OR classStart2 = ?)';
      whereArgs.addAll([time, time]);

      for (int i = time - 1; i >= (time - 3 > 0 ? time - 3 : 1); i--) {
        int startTime = 2 + (time - 1 - i);

        for (int classTime = startTime; classTime <= 4; classTime++) {
          innerClause += " OR ";
          innerClause +=
              "((classStart1 = ? AND classTime1 = ?) OR (classStart2 = ? AND classTime1 = ?))";
          whereArgs.addAll([i, classTime, i, classTime]);
        }
      }
      whereClauses.add('($innerClause)');
    }
    if (teachingMethod != 0) {
      whereClauses.add('teachingMethod = ?');
      whereArgs.add(teachingMethod);
    }
    if (department != 0) {
      whereClauses.add('department = ?');
      whereArgs.add(department);
    }

    // WHERE句を組み立て
    String? whereClause =
        whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    print(whereClause);

    // クエリ実行
    final List<Map<String, dynamic>> maps = await db.query('classes',
        where: whereClause,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        limit: 35000);

    // 結果をClassModelのリストに変換
    return List<ClassModel>.from(maps.map((map) => ClassModel.fromMap(map)));
  }

  // pkeyから授業名をStringで取得し、lesson(授業の表示名)に更新する処理
  Future<void> updateLessonClassname(String pkey) async {
    print('授業の表示名の変更(値が空の時)');

    final class_db = await _dbHelper.classDatabase;
    final lesson_db = await _dbHelper.lessonDatabase;

    final List<Map<String, dynamic>> queryResult = await class_db.query(
      'classes', // テーブル名
      columns: ['courseName'], // 取得したいカラムのリスト
      where: 'pKey = ?', // 条件
      whereArgs: [pkey], // 条件に使う値のリスト
    );
    print(queryResult);
    String classname = "";
    if (queryResult.isNotEmpty) {
      classname = queryResult.first['courseName'] as String;
    } else {
      classname = '';
    }

    await lesson_db.update(
      'lessons',
      {'name': classname}, // 更新するフィールドと値
      where: 'classId = ?', // 更新する条件
      whereArgs: [pkey], // 条件に対応する値
    );
  }

  // pkeyから教室名をStringで取得し、lesson(教室)に更新する処理
  Future<void> updateLessonClassroom(String pkey) async {
    print('教室の表示名の変更(値が空の時)');
    final class_db = await _dbHelper.classDatabase;
    final lesson_db = await _dbHelper.lessonDatabase;

    final List<Map<String, dynamic>> queryResult = await class_db.query(
      'classes', // テーブル名
      columns: ['classroom'], // 取得したいカラムのリスト
      where: 'pKey = ?', // 条件
      whereArgs: [pkey], // 条件に使う値のリスト
    );
    print('a');
    String classroom = "";
    if (queryResult.isNotEmpty) {
      classroom = queryResult.first['classroom'] as String;
      // classroomには、指定したpKeyを持つ行のclassroomカラムの値が格納されます。
    } else {
      classroom = '';
    }
    await lesson_db.update(
      'lessons',
      {'classroom': classroom}, // 更新するフィールドと値
      where: 'classId = ?', // 更新する条件
      whereArgs: [pkey], // 条件に対応する値
    );
  }
}
