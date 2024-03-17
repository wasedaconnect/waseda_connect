import 'package:flutter/material.dart';
import 'package:waseda_connect/models/TimeTableModel.dart';
import 'package:waseda_connect/screen/Tutorial/Tutorial2.dart';
import '../../components/TimeTableComponet.dart'; // 正しいパスに置き換えてください
import 'package:shared_preferences/shared_preferences.dart';

class TimeTable extends StatefulWidget {
  @override
  _TimeTableState createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> {
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 依存関係が変更された（例えば、ページに戻った）ときにデータを再フェッチする
    _fetchData();
  }

  // ダミーデータの定義
  List<Map<String, dynamic>> lessonData = [
    {"id": "1", "name": "数学", "day": "月", "period": 1},
    {"id": "2", "name": "英語", "day": "火", "period": 2},
  ];

  Map<String, dynamic> selectedLessonData = {
    "id": "1",
    "name": "数",
    "day": "月",
    "period": 1
  };
  Map<String, dynamic>? timeTableData;

  int? defaultYear;
  String? defaultSemester;
  int? defaultGrade;
  List<TimeTableModel>? allTimeTablesData;
  Future<void> _fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    final TimeTableLogic instance = TimeTableLogic();
    var newTimeTablesData = await instance.getAllTimeTables();
    // SharedPreferencesからデータを読み込む
    // 値が存在しない場合はnullを許容
    setState(() {
      defaultYear = prefs.getInt('defaultYear');
      defaultSemester = prefs.getString('defaultSemester');
      defaultGrade = prefs.getInt('defaultGrade');
      allTimeTablesData = newTimeTablesData;
    });

    print(defaultGrade);
    print("よんだよね");
  }

  void _onFacultyChanged(String? selected) {
    // 選択された項目に基づいて何かアクションを行う
    print("Selected lesson: $selected");
  }

  //タイムテーブルの遷移。
  Future<void> _setTimeTable(String id) async {
    final TimeTableLogic instance = TimeTableLogic();
    var newTimeTableData = await instance.getTimeTable(id);
    if (newTimeTableData != null) {
      setState(() {
        defaultYear = newTimeTableData.year;
        defaultSemester = newTimeTableData.semester;
        defaultGrade = newTimeTableData.grade;
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('defaultYear', newTimeTableData.year);
      await prefs.setString('defaultSemester', newTimeTableData.semester);
      await prefs.setInt('defaultGrade', newTimeTableData.grade);
    }
  }

  Future<void> _addNewTimeTable() async {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Tutorial2()),
    );
  }

  @override
  Widget build(BuildContext context) {
    var appBarText =
        "令和${defaultYear ?? ""}年度　${defaultSemester ?? ""}学期　${defaultGrade ?? ""}年";
    return Scaffold(
      appBar: AppBar(title: Text(appBarText), actions: <Widget>[
        IconButton(
          onPressed: () {
            _showTitleOptions(context);
          },
          icon: Icon(Icons.add),
        ),
      ]),
      body: TimeTableComponent(
        lessonData: lessonData,
        timeTableData: timeTableData,
        selectedLessonData: selectedLessonData,
        onSelected: _onFacultyChanged,
      ),
    );
  }

  void _showTitleOptions(BuildContext context) {
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(100, 80, 0, 20), // メニューの位置を調整
      items: [
        ...?allTimeTablesData
                ?.map<PopupMenuEntry<String>>((dynamic timeTableData) {
              // PopupMenuItemの型を<String>に指定し、childにRowウィジェットを使用
              return PopupMenuItem<String>(
                value: timeTableData.id, // valueにはString型のIDを指定
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 200),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "令和${timeTableData.year ?? ""}年度　${timeTableData.semester ?? ""}学期　${timeTableData.grade ?? ""}年"), // childにはTextウィジェットを使用してnameを表示
                      IconButton(
                        icon: Icon(Icons.delete, size: 20.0),
                        onPressed: () {
                          // 時間割の消去処理をここに記述
                          // 注意: このコンテキストでは直接状態を変更できないため、適切なコールバックを使用する
                        },
                      ),
                    ],
                  ),
                ),
              );
            }).toList() ??
            [],
        PopupMenuItem<String>(
          value: 'add_new', // 新しい時間割を追加するための特別な値
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, size: 24.0),
              Text('時間割を追加'),
            ],
          ),
        ),
      ],
    ).then((String? newValue) {
      if (newValue != null) {
        if (newValue == 'add_new') {
          // 新しい時間割を追加する処理
          _addNewTimeTable();
        } else {
          _setTimeTable(newValue);
        }
      }
    });
  }
}
