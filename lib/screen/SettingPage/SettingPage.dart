import 'package:flutter/material.dart';
import '../../constants/Dict.dart';
import 'package:waseda_connect/components/Utility.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:waseda_connect/provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingPage extends ConsumerStatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends ConsumerState<SettingPage> {
  String? selectedFaculty;
  String? selectedDepartment;
  List<String>? departmentList;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (selectedFaculty != null) return;
    final prefs = await SharedPreferences.getInstance();
    selectedFaculty = prefs.getString('faculty');
    selectedDepartment = prefs.getString('department');
    departmentList = wasedaFacultiesAndDepartmentsDict[selectedFaculty];
  }

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

  void _saveFacultyAndDepartment(BuildContext context) async {
    if (selectedFaculty == null || selectedDepartment == null) {
      print('保存不可');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('学部または学科が選択されていません。'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
          margin: EdgeInsets.only(
              top: 80.0,
              bottom: 10.0,
              right: 20.0,
              left: 20.0), // 上部に表示するためのマージン調整
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
        content: Text('保存完了：${selectedFaculty} / ${selectedDepartment}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green, // 色を変更
        margin: EdgeInsets.only(
            top: 80.0, bottom: 10.0, right: 20.0, left: 20.0), // 上部に表示
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
    final pageTransition = ref.watch(updateSettingProvider);

    if (pageTransition) {
      // ページ遷移が検知された場合に実行する関数
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _fetchData();
        // 必要に応じて、状態をリセット
        ref.read(updateSettingProvider.notifier).state = false;
      });
    }

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
                    return DropdownCustomComponent(
                      value: selectedFaculty, //
                      label: '学部を選択してください',
                      onChanged: _onFacultyChanged,
                      itemDict: departments,
                      limmit: 14,
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
                    return DropdownCustomComponent(
                      value: selectedDepartment, //
                      label: '学科を選択してください',
                      onChanged: (value) {
                        setState(() {
                          print(value);
                          selectedDepartment = value!;
                        });
                      },
                      itemList: departmentList,
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
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
