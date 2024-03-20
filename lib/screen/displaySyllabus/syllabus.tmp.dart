// SyllabusをAPIで検索

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DisplaySyllabus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'シラバス検索',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _syllabusData = [];
  int _currentPage = 1;
  bool _isLoading = false;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _fetchSyllabus('SILS', _currentPage + 1);
    }
  }

  Future<void> _fetchSyllabus(String courseCode, int page) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
        'https://api.wasedatime.com/v1/syllabus/$courseCode?page=$page');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      print(jsonData);
      final List<String> syllabusList = List<String>.from(jsonData['data']);

      setState(() {
        if (page == 1) {
          _syllabusData = syllabusList;
        } else {
          _syllabusData.addAll(syllabusList);
        }
        _currentPage = page;
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load syllabus data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Waseda Time Syllabus'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            ElevatedButton(
              onPressed: () => _fetchSyllabus('SILS', 1),
              child: Text('国際教養学部: SILS'),
            ),
            ElevatedButton(
              onPressed: () => _fetchSyllabus('SILS', 1),
              child: Text('国際教養学部: SILS'),
            ),
            ElevatedButton(
              onPressed: () => _fetchSyllabus('PSE', 1),
              child: Text('政治経済学部: PSE'),
            ),
            ElevatedButton(
              onPressed: () => _fetchSyllabus('SSS', 1),
              child: Text('社会科学部: SSS'),
            ),
            ElevatedButton(
              onPressed: () => _fetchSyllabus('FSE', 1),
              child: Text('基幹理工学部: FSE'),
            ),
            ElevatedButton(
              onPressed: () => _fetchSyllabus('CSE', 1),
              child: Text('想像理工学部: CSE'),
            ),
            ElevatedButton(
              onPressed: () => _fetchSyllabus('ASE', 1),
              child: Text('先進理工学部: ASE'),
            ),
            ElevatedButton(
              onPressed: () => _fetchSyllabus('LAW', 1),
              child: Text('法学部: LAW'),
            ),
            ElevatedButton(
              onPressed: () => _fetchSyllabus('HSS', 1),
              child: Text('文学部: HSS'),
            ),
            ElevatedButton(
              onPressed: () => _fetchSyllabus('EDU', 1),
              child: Text('教育学部: EDU'),
            ),
            ElevatedButton(
              onPressed: () => _fetchSyllabus('SOC', 1),
              child: Text('商学部: SOC'),
            ),
            ElevatedButton(
              onPressed: () => _fetchSyllabus('HUM', 1),
              child: Text('人間科学部: HUM'),
            ),
            ElevatedButton(
              onPressed: () => _fetchSyllabus('SPS', 1),
              child: Text('スポーツ科学部: SPS'),
            ),
            ElevatedButton(
              onPressed: () => _fetchSyllabus('GEC', 1),
              child: Text('グローバル: GEC'),
            ),
            // Add other ElevatedButton widgets for other departments similarly
            Expanded(
              child: _buildSyllabusList(),
            ),
            _isLoading ? CircularProgressIndicator() : SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget _buildSyllabusList() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _syllabusData.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_syllabusData[index]),
        );
      },
    );
  }
}

void main() {
  runApp(DisplaySyllabus());
}
