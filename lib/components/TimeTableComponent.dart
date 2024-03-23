import 'package:flutter/material.dart';
import 'package:waseda_connect/models/LessonModel.dart';
import 'package:waseda_connect/models/TimeTableModel.dart';
import '../../constants/Dict.dart'; // 必要に応じてパスを調整してください

class TimeTableComponent extends StatefulWidget {
  final List<LessonModel>? lessonData;

  final TimeTableModel? timeTableData;

  final Function(String?, int, int, TimeTableModel?)? onSelected;
  final Function(String?)? onLongSelected;

  const TimeTableComponent({
    Key? key,
    required this.lessonData,
    required this.timeTableData,
    this.onSelected,
    this.onLongSelected,
  }) : super(key: key);

  @override
  _TimeTableComponentState createState() => _TimeTableComponentState();
}

class _TimeTableComponentState extends State<TimeTableComponent> {
  Map<int, TableColumnWidth> get columnWidths => {
        0: FixedColumnWidth(26.0),
        for (int i = 1; i <= weekdays.length; i++) i: FlexColumnWidth(),
      };

  TableBorder get tableBorder => TableBorder.all(
        color: Colors.grey[250] ?? Colors.grey,
        width: 1,
      );

  // 仮定で一日の最大時限数を6とします
  final int maxPeriods = 6;
  // 曜日のリスト

  // 各時限の開始時間と終了時間（サンプル）
  final List<String> startTime = [
    '9:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00'
  ];
  final List<String> endTime = [
    '9:50',
    '10:50',
    '11:50',
    '12:50',
    '13:50',
    '14:50'
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 曜日ヘッダー
        Container(
          child: Table(
            children: [
              TableRow(
                children: [
                  SizedBox(width: 30.0), // 時限表示用の空白セル
                  for (var day in weekdays)
                    Container(
                      margin: EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        // * ここ現在の日付とって値変えたい。
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            day,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    )
                ],
              ),
            ],
          ),
        ),
        // 時限と授業セル
        Expanded(
          child: SingleChildScrollView(
            child: Table(
              children: [
                for (int period = 1; period <= maxPeriods; period++)
                  TableRow(
                    children: [
                      // 時限表示セル
                      SizedBox(
                        width: 20,
                        child: Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center, // 子ウィジェットを中央に配置
                            children: <Widget>[
                              Text('${startTime[period - 1]}',
                                  style: TextStyle(fontSize: 8)),
                              SizedBox(height: 20),
                              Text('$period',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 20),
                              Text('${endTime[period - 1]}',
                                  style: TextStyle(fontSize: 8)),
                            ],
                          ),
                        ),
                      ), // 各曜日の授業セル
                      for (var day in weekdays_num)
                        if (day == 7)
                          _othersBuildLessonCell(
                              period, day, widget.timeTableData)
                        else
                          _normalBuildLessonCell(
                              period, day, widget.timeTableData),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _normalBuildLessonCell(
      int period, int day, TimeTableModel? timeTableData) {
    // lessonDataがnullの場合は空のリストを使用
    final lessonData = widget.lessonData ?? [];

    // lessonDataから特定の曜日と時限に対応する授業を検索
    var lesson = lessonData.firstWhere(
      (lesson) => lesson.day == day && lesson.period == period,
      orElse: () => LessonModel(
          id: "",
          name: "",
          timeTableId: "",
          createdAt: "",
          day: 0,
          period: 0,
          classroom: "",
          classId: "",
          color: 0),
    );
    return _buildLessonCell(lesson, day, period, timeTableData);
  }

  Widget _othersBuildLessonCell(
      int period, int day, TimeTableModel? timeTableData) {
    // lessonDataがnullの場合は空のリストを使用
    final lessonData = widget.lessonData ?? [];

    // lessonDataから特定の曜日と時限に対応する授業を検索
    var lessonsForDay =
        lessonData.where((lesson) => lesson.day == day).toList();

    // LessonModelの変数を先に宣言し、条件に応じて値を代入
    LessonModel lesson;

    if (period - 1 < lessonsForDay.length) {
      // 存在する場合は、そのレッスンを取得
      lesson = lessonsForDay[period - 1];
    } else {
      // 存在しない場合は、空のLessonModelオブジェクトを返す
      lesson = LessonModel(
        id: "",
        name: "",
        timeTableId: "",
        createdAt: "",
        day: 0,
        period: 0,
        classroom: "",
        classId: "",
        color: 0,
      );
    }

    // _buildLessonCellメソッドにlessonオブジェクトを渡してウィジェットを構築
    return _buildLessonCell(lesson, day, period, timeTableData);
  }

  // selectedLessonDataがnullの場合は空のマップを使用
  Widget _buildLessonCell(
      LessonModel lesson, int day, int period, TimeTableModel? timeTableData) {
    return InkWell(
      onTap: () =>
          widget.onSelected?.call(lesson.classId, day, period, timeTableData!),
      onLongPress: () => widget.onLongSelected?.call(lesson.id),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.11,
        margin: EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: classColor[lesson.color], // 授業セルの色
          borderRadius: BorderRadius.circular(10.0), // 角丸
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 1,
              offset: Offset(0, 2), // 影のオフセット
            ),
          ],
        ),
        child: Center(
          child: Column(
            // Column内の要素を垂直方向に中央揃えするための設定
            mainAxisAlignment: MainAxisAlignment.center,
            // Columnの高さを最小限に設定
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                lesson.name,
                overflow: TextOverflow.ellipsis, // オーバーフロー時に...で省略
                maxLines: 3, // テキストを1行に制限
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              lesson.name.isEmpty
                  ? Container()
                  : Container(
                      margin: EdgeInsets.symmetric(horizontal: 2.0),
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.0), // 左右に8ピクセルのパディングを追加
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.0), // 角丸
                        color: Colors.white, // 背景色
                      ),
                      child: Text(
                        lesson.classroom,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 8,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
