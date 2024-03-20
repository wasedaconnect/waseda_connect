import 'package:flutter/material.dart';
import '../../constants/Dict.dart';
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
          SearchFormWithSelect(),
          SearchFormWithText(),
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

// 1つ目の検索方法
// プルダウンのSelectから値を変更し検索する
// 検索結果はページ遷移した先で表示する
class SearchFormWithSelect extends StatefulWidget {
  @override
  _SyllabusSearchSelectState createState() => _SyllabusSearchSelectState();
}

class _SyllabusSearchSelectState extends State<SearchFormWithSelect> {
  List<ClassModel>? SearchSelectResult;

  final Map<int, String> numToPeriod = {
    1: '1',
    2: '2',
    3: '3',
    4: '4',
    5: '5',
    6: '6',
    7: '7',
    0: 'その他'
  };
  int selectedSemester = 1;
  int selectedDay = 1;
  int selectedPeriod = 1;

  Future<void> _searchSyllabus(
      int selectedSemester, int selectedDay, int selectedPeriod) async {
    final ClassLogic instance = ClassLogic();
    final newAllSyllabusData = await instance.searchClasses(
        semester: selectedSemester, day: selectedDay, time: selectedPeriod);
    setState(() {
      SearchSelectResult = newAllSyllabusData;
    });
    print(SearchSelectResult!.length);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<int>(
              value: termMap.keys.firstWhere(
                  (key) => termMap[key] == selectedSemester,
                  orElse: () => 0),
              decoration: InputDecoration(labelText: '学期'),
              items: termMap.keys.map((int key) {
                return DropdownMenuItem<int>(
                  value: key,
                  child: Text(termMap[key]!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  print(value);
                  selectedSemester = value!;
                });
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: numToDay.keys.firstWhere(
                  (key) => numToDay[key] == selectedDay,
                  orElse: () => 0),
              decoration: InputDecoration(labelText: '曜日'),
              items: numToDay.keys.map((int key) {
                return DropdownMenuItem<int>(
                  value: key,
                  child: Text(numToDay[key]!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  print(value);
                  selectedDay = value!;
                });
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: numToPeriod.keys.firstWhere(
                  (key) => numToPeriod[key] == selectedDay,
                  orElse: () => 0),
              decoration: InputDecoration(labelText: '曜日'),
              items: numToPeriod.keys.map((int key) {
                return DropdownMenuItem<int>(
                  value: key,
                  child: Text(numToPeriod[key]!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  print(value);
                  selectedPeriod = value!;
                });
              },
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Perform search with selectedSemester, selectedDay, and selectedPeriod
                print(
                    'searchClasses: $selectedSemester : $selectedDay : $selectedPeriod');
                _searchSyllabus(selectedSemester, selectedDay, selectedPeriod);
              },
              child: Text('検索'),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchSelectResultPage extends StatelessWidget {
  final List<String> searchResult;

  const SearchSelectResultPage({required this.searchResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search Results'),
      ),
      body: ListView.builder(
        itemCount: searchResult.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(searchResult[index]),
          );
        },
      ),
    );
  }
}

// 2つ目の検索方法
// テキストフォームに文字列を入力し検索する
// 検索結果は直下に表示される。
class SearchFormWithText extends StatefulWidget {
  @override
  _SyllabusSearchTextState createState() => _SyllabusSearchTextState();
}

class _SyllabusSearchTextState extends State<SearchFormWithText> {
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
    return Container(
      child: Center(
          child: Column(
        children: <Widget>[
          Card(
              margin: const EdgeInsets.all(1.0),
              child: InkWell(
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            classData.courseName,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            classData.instructor,
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            '${termMap[classData.semester]} ${numToDay[classData.classDay1]} 時限(Dictまだ)${classData.classStart1}',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  print(classData.pKey);
                },
              ))
        ],
      )),
    );
  }
}
