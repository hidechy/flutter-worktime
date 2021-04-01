import 'package:flutter/material.dart';

import '../utilities/utility.dart';

import 'dart:convert';
import 'package:http/http.dart';

class EstimateScreen extends StatefulWidget {
  final List workday;
  EstimateScreen({@required this.workday});

  @override
  _EstimateScreenState createState() => _EstimateScreenState();
}

class _EstimateScreenState extends State<EstimateScreen> {
  Utility _utility = Utility();

  String _displayYear = '';
  String _displayMonth = '';
  String _displayDay = '';

  String monthEndDay;

  List<Map<dynamic, dynamic>> _monthData = List();

  double _monthWorkingTotal = 0.0;

  /**
   * 初期動作
   */
  @override
  void initState() {
    super.initState();

    _makeDefaultDisplayData();
  }

  /**
   * 初期データ作成
   */
  void _makeDefaultDisplayData() async {
    _utility.makeYMDYData(widget.workday[0], 0);

    _displayYear = _utility.year;
    _displayMonth = _utility.month;
    _displayDay = _utility.day;

    ////////////////////////////////////////
    Map data = Map();

    String url = "http://toyohide.work/BrainLog/api/worktimemonthdata";
    Map<String, String> headers = {'content-type': 'application/json'};
    String body = json
        .encode({"date": '${_utility.year}-${_utility.month}-${_utility.day}'});
    Response response = await post(url, headers: headers, body: body);

    if (response != null) {
      data = jsonDecode(response.body);
    }
    ////////////////////////////////////////

    _utility.makeMonthEnd(
        int.parse(_displayYear), int.parse(_displayMonth) + 1, 0);

    _utility.makeYMDYData(_utility.monthEndDateTime, 0);
    monthEndDay = _utility.day;

    for (var i = 1; i <= int.parse(monthEndDay); i++) {
      Map _map = Map();

      var _dt = DateTime(int.parse(_displayYear), int.parse(_displayMonth), i);
      _map['fake'] = ((DateTime.now()).difference(_dt).inMinutes < 0) ? 1 : 0;

      var _date = _dt.toString();

      var ex_date = (_date).split(' ');
      _map['date'] = ex_date[0];

      _map['diff'] = (widget.workday.contains(ex_date[0])) ? "8.0" : "0.0";

      if (data['data'].length > 0) {
        if (data['data'][ex_date[0]] != null) {
          //-------------------------------//
          var ex_start = data['data'][ex_date[0]]['work_start'].split(":");
          var ex_end = data['data'][ex_date[0]]['work_end'].split(":");

          var _startTime = new DateTime(
            int.parse(_displayYear),
            int.parse(_displayMonth),
            int.parse(_displayDay),
            int.parse(ex_start[0]),
            int.parse(ex_start[1]),
          );

          var _endTime = new DateTime(
            int.parse(_displayYear),
            int.parse(_displayMonth),
            int.parse(_displayDay),
            int.parse(ex_end[0]),
            int.parse(ex_end[1]),
          );

          int diffMinutes = _endTime.difference(_startTime).inMinutes;

          var _minusMinutes = _utility.getMinusMinutes(
            end: data['data'][ex_date[0]]['work_end'],
            year: _displayYear,
            month: _displayMonth,
            day: _displayDay,
          );

          var onedayDiff = ((diffMinutes - _minusMinutes) / 60);
          _map['diff'] = "${onedayDiff}";
          //-------------------------------//

        }
      }

      _monthData.add(_map);
    }

    for (var i = 0; i < _monthData.length; i++) {
      _monthWorkingTotal += double.parse(_monthData[i]['diff']);
    }

    setState(() {});
  }

  /**
   *
   */
  @override
  Widget build(BuildContext context) {
    var _workDayNum = widget.workday.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('${_displayYear}-${_displayMonth}'),
        centerTitle: true,

        //-------------------------//これを消すと「←」が出てくる（消さない）
        leading: Icon(
          Icons.check_box_outline_blank,
          color: Color(0xFF2e2e2e),
        ),
        //-------------------------//これを消すと「←」が出てくる（消さない）

        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            color: Colors.greenAccent,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _utility.getBackGround(),
          Column(
            children: <Widget>[
              SizedBox(height: 20),
              _dispSummaryBox(_workDayNum),
              SizedBox(height: 10),
              Expanded(
                child: _monthList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /**
   * リスト表示
   */
  Widget _monthList() {
    return ListView.builder(
      itemCount: _monthData.length,
      itemBuilder: (context, int position) => _listItem(position: position),
    );
  }

  /**
   * リストアイテム表示
   */
  Widget _listItem({int position}) {
    _utility.makeYMDYData(_monthData[position]['date'], 0);

    return Container(
      color: _getBackGroundColor(data: _monthData[position]),
      margin: EdgeInsets.symmetric(horizontal: 60),
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '${_monthData[position]['date']}（${_utility.youbiStr}）',
            style: TextStyle(fontSize: 12),
          ),
          Text(
            '${_monthData[position]['diff']}',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  /**
   *
   */
  Container _dispSummaryBox(int _workDayNum) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      child: Table(
        children: [
          TableRow(children: [
            Container(
              child: Text('予定日数'),
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                color: Colors.green[900].withOpacity(0.5),
              ),
            ),
            Container(
              child: Text(
                '$_workDayNum',
                style: TextStyle(fontSize: 20),
              ),
              alignment: Alignment.topCenter,
            ),
            Container(
              child: Text('予定時間'),
              alignment: Alignment.topCenter,
              decoration: BoxDecoration(
                color: Colors.green[900].withOpacity(0.5),
              ),
            ),
            Container(
              child: Column(
                children: <Widget>[
                  Text(
                    '$_monthWorkingTotal',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }

  /**
   *
   */
  Color _getBackGroundColor({data}) {
    Color _bgColor = Color(0x2e2e2e).withOpacity(0.3);

    if (!widget.workday.contains(data['date'])) {
      _bgColor = Colors.grey.withOpacity(0.3);
    }

    if (data['fake'] == 0) {
      _bgColor = Colors.yellowAccent.withOpacity(0.3);
    }

    return _bgColor;
  }
}
