import 'package:flutter/material.dart';
import 'package:workingtime/screens/estimate_screen.dart';
import 'result_screen.dart';
import 'worktime_input_screen.dart';

import '../utilities/utility.dart';

import 'dart:convert';
import 'package:http/http.dart';

import 'package:flutter_slidable/flutter_slidable.dart';

class MonthListScreen extends StatefulWidget {
  final String date;

  MonthListScreen({@required this.date});

  @override
  _MonthListScreenState createState() => _MonthListScreenState();
}

class _MonthListScreenState extends State<MonthListScreen> {
  Utility _utility = Utility();

  String _displayYear = '';
  String _displayMonth = '';
  String _displayDay = '';

  String monthEndDay;

  List<Map<dynamic, dynamic>> _monthData = List();

  DateTime _prevMonth = DateTime.now();
  DateTime _nextMonth = DateTime.now();

  double _monthWorkingTotal = 0.0;

  String company;
  String genba;

  int _holidayNum = 0;

  List _thisMonthWorkday = List();

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
    _utility.makeYMDYData(widget.date, 0);

    _displayYear = _utility.year;
    _displayMonth = _utility.month;
    _displayDay = _utility.day;

    _prevMonth = new DateTime(
        int.parse(_utility.year), int.parse(_utility.month) - 1, 1);

    _nextMonth = new DateTime(
        int.parse(_utility.year), int.parse(_utility.month) + 1, 1);

    _utility.makeMonthEnd(
        int.parse(_displayYear), int.parse(_displayMonth) + 1, 0);

    _utility.makeYMDYData(_utility.monthEndDateTime, 0);
    monthEndDay = _utility.day;

    //#############################
    var _holiday;
    String url3 = "http://toyohide.work/BrainLog/api/getholiday";
    Map<String, String> headers3 = {'content-type': 'application/json'};
    String body3 = json.encode({"date": ''});
    Response response3 = await post(url3, headers: headers3, body: body3);

    if (response3 != null) {
      _holiday = jsonDecode(response3.body);
    }
    //#############################

    //-------------------------------------------
    String url2 = "http://toyohide.work/BrainLog/api/workinggenbaname";
    Map<String, String> headers2 = {'content-type': 'application/json'};
    String body2 = json.encode({"date": ''});
    Response response2 = await post(url2, headers: headers2, body: body2);

    if (response2 != null) {
      var data2 = jsonDecode(response2.body);

      for (var i = 0; i < data2['data'].length; i++) {
        if (data2['data'][i]['yearmonth'] ==
            '${_displayYear}-${_displayMonth}') {
          company = data2['data'][i]['company'];
          genba = data2['data'][i]['genba'];
        }
      }
    }
    //-------------------------------------------

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

    for (var i = 1; i <= int.parse(monthEndDay); i++) {
      var date = _displayYear +
          "-" +
          _displayMonth.padLeft(2, '0') +
          "-" +
          i.toString().padLeft(2, '0');

      Map _map = Map();
      _map['date'] = date;
      _map['holiday'] = _getHoliday(date: date, holiday: _holiday);

      _map['work_start'] = "";
      _map['work_end'] = "";
      _map['diff'] = "";

      _map['minus'] = "";

      if (data['data'].length > 0) {
        if (data['data'][date] != null) {
          _map['work_start'] = data['data'][date]['work_start'];
          _map['work_end'] = data['data'][date]['work_end'];

          //-------------------------------//
          var ex_start = data['data'][date]['work_start'].split(":");
          var ex_end = data['data'][date]['work_end'].split(":");

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
            end: data['data'][date]['work_end'],
            year: _displayYear,
            month: _displayMonth,
            day: _displayDay,
          );
          _map['minus'] = "${_minusMinutes}min";

          var onedayDiff = ((diffMinutes - _minusMinutes) / 60);
          _map['diff'] = "${onedayDiff}hrs";

          _monthWorkingTotal += onedayDiff;
          //-------------------------------//
        }
      }

      _monthData.add(_map);
    }

    //----------------------//
    for (var i = 0; i < _monthData.length; i++) {
      if (_getHolidayFlag(position: i) == 1) {
        _holidayNum++;
      }
    }
    //----------------------//

    setState(() {});
  }

  /**
   *
   */
  int _getHoliday({String date, holiday}) {
    var _flag = 0;
    for (var i = 0; i < holiday['data'].length; i++) {
      if (holiday['data'][i] == date) {
        _flag = 1;
        break;
      }
    }

    return _flag;
  }

  /**
   *
   */
  @override
  Widget build(BuildContext context) {
    var _workday = _thisMonthWorkday.toSet().toList();
    var _workDayNum = _workday.length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.1),
        title: Text('${_displayYear}-${_displayMonth}'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.skip_previous),
            tooltip: '前月',
            onPressed: () => _goPrevMonth(context: context),
          ),
          IconButton(
            icon: const Icon(Icons.skip_next),
            tooltip: '翌月',
            onPressed: () => _goNextMonth(context: context),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _utility.getBackGround(),
          Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.yellowAccent.withOpacity(0.3),
                      width: 10,
                    ),
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.topRight,
                      padding: EdgeInsets.only(right: 10),
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 3),
                              ),
                            ),
                            child: Text('${_workDayNum}'),
                          ),
                          GestureDetector(
                            onTap: () => _goEstimateScreen(workday: _workday),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.green[900].withOpacity(0.5),
                              ),
                              child: Text('estimate'),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () => _goResultScreen(),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.green[900].withOpacity(0.5),
                              ),
                              child: Text('result'),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              alignment: Alignment.topRight,
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 3),
                                ),
                              ),
                              child: Text('${_monthWorkingTotal}'),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: () =>
                                _goMonthListScreen(date: widget.date),
                            color: Colors.greenAccent,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: <Widget>[
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 80,
                                child: Text('Company : '),
                              ),
                              Expanded(
                                child: Text('${company}'),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 80,
                                child: Text('Genba : '),
                              ),
                              Expanded(
                                child: Text('${genba}'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
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

    return Slidable(
      actionPane: const SlidableDrawerActionPane(),
      actionExtentRatio: 0.15,
      child: Card(
        color: _utility.getBgColor(
          _monthData[position]['date'],
          _monthData[position]['work_start'],
          _monthData[position]['work_end'],
        ),
        elevation: 10.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ListTile(
          title: DefaultTextStyle(
            style: TextStyle(fontSize: 12),
            child: Row(
              children: <Widget>[
                Text('${_monthData[position]['date']}（${_utility.youbiStr}）'),
                Expanded(
                  child: (_getHolidayFlag(position: position) == 1)
                      ? Container(
                          alignment: Alignment.topRight,
                          child: Text('Holiday'),
                        )
                      : Table(
                          children: [
                            TableRow(children: [
                              Container(
                                alignment: Alignment.topCenter,
                                child: Text(
                                    '${_monthData[position]['work_start']}'),
                              ),
                              Container(
                                alignment: Alignment.topCenter,
                                child:
                                    Text('${_monthData[position]['work_end']}'),
                              ),
                              Container(
                                alignment: Alignment.topRight,
                                child: Text(
                                  '${_monthData[position]['minus']}',
                                  style: TextStyle(
                                      color:
                                          Colors.yellowAccent.withOpacity(0.5)),
                                ),
                              ),
                              Container(
                                alignment: Alignment.topRight,
                                child: Text('${_monthData[position]['diff']}'),
                              ),
                            ]),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),

      //actions: <Widget>[],
      secondaryActions: <Widget>[
        _getInputButton(position),
      ],
    );
  }

  /**
   *
   */
  Widget _getInputButton(int position) {
    var _disp = _getHolidayFlag(position: position);

    if (_disp == 1) {
      return IconSlideAction(
        color: _utility.getBgColor(
          _monthData[position]['date'],
          _monthData[position]['work_start'],
          _monthData[position]['work_end'],
        ),
        foregroundColor: Colors.black.withOpacity(0.1),
        icon: Icons.crop_square,
      );
    } else {
      return IconSlideAction(
        color: _utility.getBgColor(
          _monthData[position]['date'],
          _monthData[position]['work_start'],
          _monthData[position]['work_end'],
        ),
        foregroundColor: Colors.blueAccent,
        icon: Icons.details,
        onTap: () => _goWorktimeInputScreen(
          context: context,
          date: _monthData[position]['date'],
          start: _monthData[position]['work_start'],
          end: _monthData[position]['work_end'],
        ),
      );
    }
  }

  /**
   *
   */
  int _getHolidayFlag({position}) {
    _utility.makeYMDYData(_monthData[position]['date'], 0);

    var _disp = 0;
    switch (_utility.youbiNo) {
      case 0:
      case 6:
        _disp = 1;
        break;
      default:
        _disp = 0;
        break;
    }

    if (_disp == 0) {
      if (_monthData[position]['holiday'] == 1) {
        _disp = 1;
      }
    }

    if (_disp == 0) {
      _thisMonthWorkday.add(_monthData[position]['date']);
    }

    return _disp;
  }

  /**
   *
   */
  void _goPrevMonth({BuildContext context}) {
    _goMonthListScreen(date: '${_prevMonth}');
  }

  /**
   *
   */
  void _goNextMonth({BuildContext context}) {
    _goMonthListScreen(date: '${_nextMonth}');
  }

  /**
   *
   */
  void _goMonthListScreen({String date}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MonthListScreen(date: '${date}'),
      ),
    );
  }

  /**
   *
   */
  void _goWorktimeInputScreen(
      {BuildContext context, String date, String start, String end}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorktimeInputScreen(
          date: date,
          start: start,
          end: end,
        ),
      ),
    );
  }

  /**
   *
   */
  void _goEstimateScreen({workday}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EstimateScreen(
          workday: workday,
        ),
      ),
    );
  }

  /**
   *
   */
  void _goResultScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(),
      ),
    );
  }
}
