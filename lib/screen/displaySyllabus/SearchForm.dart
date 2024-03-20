import 'package:flutter/material.dart';
import '../Syllabus/SyllabusSearchResult.dart';
import 'package:waseda_connect/models/ClassModel.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Search1'),
            Tab(text: 'Search2'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SearchForm1(),
          SearchForm2(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

class SearchForm1 extends StatefulWidget {
  @override
  _SearchForm1State createState() => _SearchForm1State();
}

class _SearchForm1State extends State<SearchForm1> {
  String selectedSemester = '春';
  String selectedDay = '月';
  String selectedPeriod = '1';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: selectedSemester,
              decoration: InputDecoration(labelText: '学期'),
              items: ['春', '秋', 'その他'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedSemester = value!;
                });
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedDay,
              decoration: InputDecoration(labelText: '曜日'),
              items: ['月', '火', '水', '木', '金', '土', 'その他'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedDay = value!;
                });
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedPeriod,
              decoration: InputDecoration(labelText: '時間'),
              items: ['1', '2', '3', '4', '5', '6', 'その他'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPeriod = value!;
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Perform search with selectedSemester, selectedDay, and selectedPeriod
                print(selectedSemester);
                print(selectedDay);
                print(selectedPeriod);
              },
              child: Text('検索'),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchForm2 extends StatefulWidget {
  @override
  _SyllabusSearchScreenState createState() => _SyllabusSearchScreenState();
}

class _SyllabusSearchScreenState extends State<SearchForm2> {
  List<ClassModel>? allSyllabusData;

  Future<void> _searchSyllabus(String value) async {
    // ここにテキストフィールドの入力値が変化したときの処理を記述
    final ClassLogic instance = ClassLogic();
    final newAllSyllabusData = await instance.searchClassesByName(value);
    setState(() {
      allSyllabusData = newAllSyllabusData;
    });
    print(allSyllabusData!.length);
  }
  // 検索結果を保持するリスト

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('シラバス検索'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextFormField(
              onChanged: (value) async {
                await _searchSyllabus(value); // テキストフィールドの入力が変化するたびに実行
              },
            ),
          ),
          Expanded(
            child: allSyllabusData != null && allSyllabusData!.isNotEmpty
                ? ListView.builder(
                    itemCount: allSyllabusData!.length, // リストのアイテム数
                    itemBuilder: (context, index) {
                      // 各アイテムに対するウィジェットを構築
                      final classData = allSyllabusData![index];
                      return SyllabusItemWidget(
                          classData: classData); // カスタムウィジェット
                    },
                  )
                : Container(), // allSyllabusDataが空の場合は何も表示しない
          ),
        ],
      ),
    );
  }
}

class SyllabusItemWidget extends StatelessWidget {
  final ClassModel classData;

  const SyllabusItemWidget({Key? key, required this.classData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(classData.courseName),
    );
  }
}
