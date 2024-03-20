import 'package:flutter/material.dart';
import '../../constants/Dict.dart';
import '../../models/ClassModel.dart';

class ClassListViewComponent extends StatefulWidget {
  final List<ClassModel>? allSyllabusData;

  const ClassListViewComponent({Key? key, required this.allSyllabusData})
      : super(key: key);

  @override
  State<ClassListViewComponent> createState() => _ClassListViewComponentState();
}

class _ClassListViewComponentState extends State<ClassListViewComponent> {
  @override
  Widget build(BuildContext context) {
    return widget.allSyllabusData != null
        ? ListView.builder(
            itemCount: widget.allSyllabusData!.length,
            itemBuilder: (context, index) {
              final classData = widget.allSyllabusData![index];
              return SyllabusItemWidget(
                classData: classData,
              );
            },
          )
        : Center(
            child: CircularProgressIndicator(),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
