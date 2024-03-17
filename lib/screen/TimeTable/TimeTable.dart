import 'package:flutter/material.dart';
import '../../components/TimeTableComponet.dart'; // 正しいパスに置き換えてください
import 'package:shared_preferences/shared_preferences.dart';

class TimeTable extends StatefulWidget {
  @override
  _TimeTableState createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> {
  @override
  void initState() {
    _fetchData();
    super.initState();
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

  Future<void> _fetchData() async {
    final prefs = await SharedPreferences.getInstance();

    // SharedPreferencesからデータを読み込む
    // 値が存在しない場合はnullを許容
    final int? year = prefs.getInt('defaultYear');
    final String? semester = prefs.getString('defaultSemester');
    final int? grade = prefs.getInt('defaultGrade');
    timeTableData = {
      "year": year,
      "semester": semester,
      "grade": grade,
    };
    print(timeTableData);
  }

  void _onFacultyChanged(String? selected) {
    // 選択された項目に基づいて何かアクションを行う
    print("Selected lesson: $selected");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('マイスケジュール'),
      ),
      body: TimeTableComponent(
        lessonData: lessonData,
        timeTableData: timeTableData,
        selectedLessonData: selectedLessonData,
        onSelected: _onFacultyChanged,
      ),
    );
  }
}
