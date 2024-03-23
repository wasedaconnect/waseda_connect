import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:waseda_connect/main.dart';
import 'package:waseda_connect/constants/Dict.dart';
import 'package:waseda_connect/provider/provider.dart';
import 'package:waseda_connect/components/Utility.dart';
import 'package:waseda_connect/components/ListForm.dart';

class Tutorial extends ConsumerStatefulWidget {
  @override
  _TutorialState createState() => _TutorialState();
}

class _TutorialState extends ConsumerState<Tutorial> {
  String? selectedFaculty;
  String? selectedDepartment;
  String? selectedGrade;
  List<String>? departmentList;

  // 学部選択のデフォルトを0に
  int selectedDepartments = 0;
  // 学部選択の表示を大学に限定
  // Dict.dartのdepartmentsから値を選択
  int limmitDepartments = 14;

  void _onFacultyChanged(dynamic newFaculty) {
    print(newFaculty);
    setState(() {
      selectedFaculty = newFaculty;
      // 学部が変更されたら、学科の選択をリセット
      selectedDepartment = null;
      departmentList = wasedaFacultiesAndDepartmentsDict[selectedFaculty];
      print(departmentList);
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
        title: Text('学部と学科を選択'),
      ),
      body: SingleChildScrollView(
        // スクロール可能にする
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 100.0),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0),
                      bottomLeft: Radius.circular(20.0),
                    ),
                    child: Image.asset(
                      'assets/logo/WasedaConnect.png',
                      width: 150,
                      height: 150,
                    ),
                  ), // 画像を追加
                ),
                SizedBox(height: 64.0),
                Text('初期設定',
                    style:
                        TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                Padding(
                  padding: const EdgeInsets.all(15), // 余白を追加
                  // 3.23 ListFormをDropdownButtonFormFieldに変更
                  //      それに伴い_onFacultyChangedも変更
                  child: DropdownCustomComponent(
                    value: selectedFaculty, //
                    label: '学部を選択してください',
                    onChanged: _onFacultyChanged,
                    itemDict: departments,
                    limmit: 14,
                  ),
                ),
                // 学部が選択されている場合のみ学科を表示
                if (selectedFaculty != null && selectedFaculty != '')
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    // 余白を追加
                    child: DropdownCustomComponent(
                      value: selectedDepartment, //
                      label: '学科を選択してください',
                      onChanged: (value) {
                        setState(() {
                          print(value);
                          selectedDepartment = value!;
                        });
                      },
                      itemList: departmentList,
                    ),
                  ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16.0), // 上下の余白を追加
                  child: ElevatedButton(
                    child: Text('決定'),
                    onPressed: () async {
                      final prefs = await SharedPreferences.getInstance();
                      if (selectedFaculty != null) {
                        await prefs.setString('faculty', selectedFaculty!);
                      }
                      if (selectedDepartment != null) {
                        await prefs.setString(
                            'department', selectedDepartment!);
                      }
                      // チュートリアルが表示されたことを保存

                      await prefs.setBool('tutorialShown', true);
                      ref.read(updateTimeTableProvider.notifier).state = true;
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
