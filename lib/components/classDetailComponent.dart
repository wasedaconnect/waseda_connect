import 'package:flutter/material.dart';
import 'package:waseda_connect/models/ClassModel.dart';

class ClassDetailComponent extends StatefulWidget {
  final String classId;

  ClassDetailComponent({Key? key, required this.classId}) : super(key: key);

  @override
  _ClassDetailComponentState createState() => _ClassDetailComponentState();
}

class _ClassDetailComponentState extends State<ClassDetailComponent> {
  ClassModel? classData;

  @override
  void initState() {
    super.initState();
    _fetchClassInfoById(widget.classId);
  }

  Future<void> _fetchClassInfoById(String classId) async {
    final ClassLogic instance = ClassLogic();
    final ClassModel newClassData = await instance.searchClassesByPKey(classId);
    setState(() {
      classData = newClassData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('授業詳細'),
      ),
      body: classData == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('属性')),
                  DataColumn(label: Text('情報')),
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(Text('ID')),
                    DataCell(Text(classData!.pKey)),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('コース名')),
                    DataCell(Text(classData!.courseName)),
                  ]),
                  DataRow(cells: [
                    DataCell(Text('講師')),
                    DataCell(Text(classData!.instructor)),
                  ]),
                ],
              ),
            ),
    );
  }
}
