import 'package:flutter/material.dart';
import '../../constants/Dict.dart';
import 'package:shared_preferences/shared_preferences.dart';


class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String? selectedFaculty;
  String? selectedDepartment;
  List<String>? departmentDict;

  @override
  void initState() {
    super.initState();
    _fetchData();

  }

  Future<void> _fetchData() async {
    if(selectedFaculty != null) return;
    final prefs = await SharedPreferences.getInstance();
    selectedFaculty = prefs.getString('faculty');
    selectedDepartment = prefs.getString('department');
    departmentDict = wasedaFacultiesAndDepartmentsDict[selectedFaculty];
  }

  void _onFacultyChanged(String? newFaculty) {
    setState(() {
      selectedFaculty = newFaculty;
      // 学部が変更されたら、学科の選択をリセット
      selectedDepartment = null;
      departmentDict = wasedaFacultiesAndDepartmentsDict[selectedFaculty];
    });
  }

  void _saveFacultyAndDepartment(BuildContext context) async{
    if(selectedFaculty == null || selectedDepartment == null){
      print('保存不可');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('学部または学科が選択されていません。'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          margin: EdgeInsets.only(top: 80.0, bottom:10.0, right: 20.0, left: 20.0), // 上部に表示するためのマージン調整
        ),
      );
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('faculty', selectedFaculty!);
    await prefs.setString('department', selectedDepartment!);
    print("保存完了：${selectedFaculty}/${selectedDepartment}");
    // showTopSnackBar(context, '保存完了：${selectedFaculty}/${selectedDepartment}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('保存完了：${selectedFaculty}/${selectedDepartment}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green, // 色を変更
        margin: EdgeInsets.only(top: 80.0, bottom:10.0, right: 20.0, left: 20.0), // 上部に表示
      ),
    );
  }
  // void showTopSnackBar(BuildContext context, String message) {
  //   // OverlayEntryの作成
  //   OverlayEntry overlayEntry = OverlayEntry(
  //     builder: (context) => Positioned(
  //       top: 100.0, // ステータスバーの高さに応じて調整
  //       left: MediaQuery.of(context).size.width * 0.1,
  //       right: MediaQuery.of(context).size.width * 0.1,
  //       child: Material(
  //         color: Colors.transparent, // 背景を透明に
  //         child: Container(
  //           padding: EdgeInsets.all(8.0),
  //           color: Colors.blue, // ここで背景色を設定
  //           child: Text(
  //             message,
  //             style: TextStyle(color: Colors.white),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );

  //   // OverlayにOverlayEntryを追加
  //   Overlay.of(context)!.insert(overlayEntry);

  //   // 3秒後にOverlayEntryを削除
  //   Future.delayed(Duration(seconds: 3)).then((value) => overlayEntry.remove());
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('設定'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FutureBuilder(
                future: _fetchData(), // 非同期処理を指定
                builder: (context, snapshot) {
                  // 非同期処理が完了したら、UIを表示
                  if (snapshot.connectionState == ConnectionState.done) {
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: '学部'),
                      value: wasedaFacultiesAndDepartmentsDict.keys.contains(selectedFaculty)
                        ? selectedFaculty
                        : null,
                      items: wasedaFacultiesAndDepartmentsDict.keys.map((String key) {
                        return DropdownMenuItem<String>(
                          value: key,
                          child: Text(key),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _onFacultyChanged(value);
                          // 必要に応じて他の処理をここに追加
                          print(value);
                        });
                      },
                    );
                  } else {
                    // 非同期処理中の場合はローディングインジケータを表示
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
              FutureBuilder(
                future: _fetchData(), // 非同期処理を指定
                builder: (context, snapshot) {
                  // 非同期処理が完了したら、UIを表示
                  if (snapshot.connectionState == ConnectionState.done) {
                    return DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: '学科'),
                      value: departmentDict!.contains(selectedDepartment)
                        ? selectedDepartment
                        : null,
                      items: departmentDict?.map((String department) {
                          return DropdownMenuItem<String>(
                            value: department,
                            child: Text(department),
                          );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDepartment = value;
                          // 必要に応じて他の処理をここに追加
                          print(value);
                        });
                      },
                    );
                  } else {
                    // 非同期処理中の場合はローディングインジケータを表示
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    // 追加機能のロジックを実装
                    _saveFacultyAndDepartment(context);
                  },
                  child: Text('保存'),
                )
              )
            ],
          ),
        ),
      ),
    );
  }
}