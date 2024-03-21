import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waseda_connect/components/ListForm.dart';
import 'package:waseda_connect/constants/Dict.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waseda_connect/main.dart';
import 'package:waseda_connect/provider/provider.dart';


class Tutorial extends ConsumerStatefulWidget {
  @override
  _TutorialState createState() => _TutorialState();
}

class _TutorialState extends ConsumerState<Tutorial> {
  String? selectedFaculty;
  String? selectedDepartment;
  String? selectedGrade;
  List<String>? departmentDict;
  void _onFacultyChanged(dynamic newFaculty) {
    setState(() {
      selectedFaculty = newFaculty;
      // 学部が変更されたら、学科の選択をリセット
      selectedDepartment = null;
      departmentDict = wasedaFacultiesAndDepartmentsDict[selectedFaculty];
    });
  }

  void _onDepartmentChanged(dynamic newDepartment) {
    setState(() {
      selectedDepartment = newDepartment;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('学年と学科を選択'),
      ),
      body: Center(
        // 全体を中央に配置
        child: SingleChildScrollView(
          // スクロール可能にする
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 子ウィジェットを中央に配置
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(15), // 余白を追加
                child: ListForm(
                    items: wasedaFacultiesAndDepartmentsDict.keys.toList(),
                    selectedItem: selectedFaculty,
                    onSelected: _onFacultyChanged,
                    text: "学部を選択してください"),
              ),
              // 学部が選択されている場合のみ学科を表示
              if (selectedFaculty != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  // 余白を追加
                  child: ListForm(
                      items: departmentDict,
                      selectedItem: selectedDepartment,
                      onSelected: _onDepartmentChanged,
                      text: "学科を選択してください"),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0), // 上下の余白を追加
                child: ElevatedButton(
                  child: Text('保存'),
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    if (selectedFaculty != null) {
                      await prefs.setString('faculty', selectedFaculty!);
                    }
                    if (selectedDepartment != null) {
                      await prefs.setString('department', selectedDepartment!);
                    }
                    // チュートリアルが表示されたことを保存

                    await prefs.setBool('tutorialShown', true);
                    ref.read(updateTimeTableProvider.notifier).state = true;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) =>
                              MyHomePage()), // NewPageに遷移ソフトウェア
                      (Route<dynamic> route) => false,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
