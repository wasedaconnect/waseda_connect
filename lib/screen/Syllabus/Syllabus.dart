import 'package:flutter/material.dart';
import 'SyllabusSearchResult.dart';

class Syllabus extends StatefulWidget {
  @override
  _SyllabusSearchScreenState createState() => _SyllabusSearchScreenState();
}

class _SyllabusSearchScreenState extends State<Syllabus> {
  final TextEditingController _controller = TextEditingController();
  String _selectedValue1 = '選択肢1-1';
  String _selectedValue2 = '選択肢2-1';
  String _selectedValue3 = '選択肢3-1';

  // 仮のデータリスト
  final List<String> _dropdownValues1 = ['選択肢1-1', '選択肢1-2', '選択肢1-3'];
  final List<String> _dropdownValues2 = ['選択肢2-1', '選択肢2-2', '選択肢2-3'];
  final List<String> _dropdownValues3 = ['選択肢3-1', '選択肢3-2', '選択肢3-3'];

  void _searchSyllabus() {
    // 検索ロジックを実行し、結果を取得 (ここではダミーの結果を使用)
    final searchResults =
        List.generate(10, (index) => '検索結果 $index : ${_controller.text}');

    // 検索結果を表示する新しいページに遷移
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            SyllabusSearchResultsScreen(searchResults: searchResults),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('シラバス検索'),
      ),
      body: SingleChildScrollView(
        // SingleChildScrollViewを追加してスクロール可能に
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                value: _selectedValue1,
                onChanged: (newValue) {
                  setState(() {
                    _selectedValue1 = newValue!;
                  });
                },
                items: _dropdownValues1
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'カテゴリ1',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                value: _selectedValue2,
                onChanged: (newValue) {
                  setState(() {
                    _selectedValue2 = newValue!;
                  });
                },
                items: _dropdownValues2
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'カテゴリ2',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: DropdownButtonFormField<String>(
                value: _selectedValue3,
                onChanged: (newValue) {
                  setState(() {
                    _selectedValue3 = newValue!;
                  });
                },
                items: _dropdownValues3
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'カテゴリ3',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: '検索',
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: _searchSyllabus,
                child: Text('検索'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
