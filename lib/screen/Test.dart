import 'package:flutter/material.dart';

class Test extends StatelessWidget {
  final List<String> weekdays = ['月', '火', '水', '木', '金', '土'];

  @override
  Widget build(BuildContext context) {
    // すべての列の幅を均等にするためにFlexColumnWidthを使用
    final Map<int, TableColumnWidth> columnWidths = {
      0: FixedColumnWidth(64.0), // 左上の空白セルと時限数列の幅を固定
      for (int i = 1; i <= weekdays.length; i++)
        i: FlexColumnWidth(),
    };

    // 境界線のスタイルを定義
    final TableBorder tableBorder = TableBorder.all(
      color: Colors.black, // 境界線の色
      width: 1, // 境界線の太さ
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('2024年度春学期'),
      ),
      body: Column(
        children: [
          // 曜日ヘッダー
          Container(
            color: Colors.red,
            child: Table(
              columnWidths: columnWidths,
              border: tableBorder,
              children: [
                TableRow(
                  children: [
                    SizedBox(width: 64.0), // 左上の空白セルの幅を固定
                    for (var day in weekdays) 
                      Center(child: Text(day, style: TextStyle(fontWeight: FontWeight.bold)))
                  ],
                ),
              ],
            ),
          ),
          // 時間割テーブル
          Expanded(
            child: SingleChildScrollView(
              child: Table(
                columnWidths: columnWidths,
                border: tableBorder,
                children: List.generate(6, (index) => _buildTableRow(index + 1, weekdays, context)),
              ),
            ),
          ),
        ],
      ),
    );
  }
  TableRow _buildTableRow(int period, List<String> weekdays, BuildContext context) {
  final startTime = ['8:00', '9:00', '10:00', '11:00', '12:00', '13:00'];
  final endTime = ['8:50', '9:50', '10:50', '11:50', '12:50', '13:50'];

  return TableRow(
    children: [
      Container(
          height: MediaQuery.of(context).size.height * 0.11,
          color: Colors.grey[300],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(startTime[period - 1], style: TextStyle(fontSize: 12)),
                Text('第$period時限', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(endTime[period - 1], style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ),

      // 以下の部分で各授業セルをInkWellでラップしてタップ可能にします
      for (int i = 0; i < weekdays.length; i++)
        InkWell(
          onTap: () {
            // タップ時に編集モーダルを表示
            _showEditModal(context, period, weekdays[i]);
          },
          child: Container(
            height: MediaQuery.of(context).size.height * 0.11,
            child: Center(child: Text('授業 $period-${weekdays[i]}')),
          ),
        ),
    ],
  );
}

void _showEditModal(BuildContext context, int period, String weekday) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      // Dialogの外観をカスタマイズ
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), // この行でダイアログのボーダーを丸くする
        child: Container(
          height: 200, // モーダルの高さを指定
          padding: EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text("授業を編集", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              // 編集用のフォームフィールドやボタンをここに配置
              // 例: TextFormField(), ElevatedButton() など
            ],
          ),
        ),
      );
    },
  );
}


  
}
