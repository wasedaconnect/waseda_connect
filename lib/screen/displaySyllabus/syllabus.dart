// 無限ループのListViewを作成

import 'package:flutter/material.dart';


Widget syllabusToWidget(Syllabus model) {
  return Container(
      padding: const EdgeInsets.all(1), child: Text('syllabusToWidget'));
}

class DisplaySyllabus extends StatefulWidget {
  const DisplaySyllabus({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: InfinityScrollPage(),
    );
  }
}

class InfinityScrollPage extends StatefulWidget {
  const InfinityScrollPage({Key? key}) : super(key: key);

  @override
  State<InfinityScrollPage> createState() => _InfinityScrollPageState();
}

class _InfinityScrollPageState extends State<InfinityScrollPage> {
  final List<String> _contents = [];
  final int loadLength = 30;

  int _lastIndex = 0;

  Future<void> _getContents() async {
    await Future.delayed(const Duration(seconds: 3));

    for (int i = _lastIndex; i < _lastIndex + loadLength; i++) {
      _contents.add('Item $i');
    }

    _lastIndex += loadLength;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Infinity Scroll Sample')),
      body: Center(
        child: FutureBuilder(
          future: _getContents(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }
            //4
            return InfinityListView(
              contents: _contents,
              getContents: _getContents,
            );
          },
        ),
      ),
    );
  }
}

class InfinityListView extends StatefulWidget {
  final List<String> contents;
  final Future<void> Function() getContents;

  const InfinityListView({
    Key? key,
    required this.contents,
    required this.getContents,
  }) : super(key: key);

  @override
  State<InfinityListView> createState() => _InfinityListViewState();
}

class _InfinityListViewState extends State<InfinityListView> {
  //5
  late ScrollController _scrollController;
  //6
  bool _isLoading = false;

  //7
  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(() async {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent * 0.95 &&
          !_isLoading) {
        _isLoading = true;

        await widget.getContents();

        setState(() {
          _isLoading = false;
        });
      }
    });
    super.initState();
  }
}