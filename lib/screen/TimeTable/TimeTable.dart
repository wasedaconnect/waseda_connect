import 'package:flutter/material.dart';
import '../../components/TimeTableComponet.dart'; // 正しいパスに置き換えてください

class TimeTable extends StatefulWidget {
  @override
  _TimeTableState createState() => _TimeTableState();
}

class _TimeTableState extends State<TimeTable> {
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

  Map<String, dynamic> timeTableData = {
    "year": 2024,
    "semester": "春",
  };

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
