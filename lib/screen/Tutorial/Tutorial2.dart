import 'package:flutter/material.dart';
import 'package:waseda_connect/components/ListForm.dart';
import 'package:waseda_connect/models/TimeTableModel.dart';

class Tutorial2 extends StatefulWidget {
  @override
  _Tutorial2State createState() => _Tutorial2State();
}

class _Tutorial2State extends State<Tutorial2> {
  String? selectedSemester;
  int? selectedYear;
  int? selectedGrade;
  final List<String> semesters = ['春', '秋'];
  final List<int> grades = [1, 2, 3, 4];
  final List<int> years = [5, 6];

  void _onSelectedSemester(dynamic newValue) {
    setState(() {
      selectedSemester = newValue;
    });
  }

  void _onSelectedYear(dynamic newValue) {
    setState(() {
      selectedYear = newValue;
    });
  }

  void _onSelectedGrade(dynamic newValue) {
    setState(() {
      selectedGrade = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('学期・年度・学年を選択'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ListForm(
                  items: semesters,
                  selectedItem: selectedSemester,
                  onSelected: _onSelectedSemester,
                  text: "学期を選択してください"),
              ListForm(
                  items: grades,
                  selectedItem: selectedGrade,
                  onSelected: _onSelectedGrade,
                  text: "学年を選択してください"),
              ListForm(
                  items: years,
                  selectedItem: selectedYear,
                  onSelected: _onSelectedYear,
                  text: "年度を選択してください"),
              ElevatedButton(
                child: Text('保存'),
                onPressed: () async {
                  final newTimeTable = TimeTableModel(
                    id: 'a', // 実際にはユニークなIDを生成
                    grade: selectedGrade!,
                    createdAt: DateTime.now().toString(), // 現在の日時を設定
                    semester: selectedSemester!,
                    year: selectedYear!,
                  );

                  // TimeTableLogicのインスタンスを作成
                  final TimeTableLogic instance = TimeTableLogic();

                  // newTimeTableをデータベースに挿入する処理を呼び出す
                  await instance.insertTimeTable(newTimeTable);

                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
