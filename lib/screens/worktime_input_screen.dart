import 'package:flutter/material.dart';

import '../utilities/utility.dart';

import 'dart:convert';
import 'package:http/http.dart';

import 'package:toast/toast.dart';

class WorktimeInputScreen extends StatefulWidget {
  final String date;
  final String start;
  final String end;
  WorktimeInputScreen(
      {@required this.date, @required this.start, @required this.end});

  @override
  _WorktimeInputScreenState createState() => _WorktimeInputScreenState();
}

class _WorktimeInputScreenState extends State<WorktimeInputScreen> {
  Utility _utility = Utility();

  String _dialogSelectedStartTime = '';
  String _dialogSelectedEndTime = '';

  DateTime _prevDate = DateTime.now();
  DateTime _nextDate = DateTime.now();

  String _prevStart = "";
  String _prevEnd = "";

  String _nextStart = "";
  String _nextEnd = "";

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
    if (widget.start != '') {
      _dialogSelectedStartTime =
          '${widget.start.split(":")[0]}:${widget.start.split(":")[1]}';
    }
    if (widget.end != '') {
      _dialogSelectedEndTime =
          '${widget.end.split(":")[0]}:${widget.end.split(":")[1]}';
    }

    _utility.makeYMDYData(widget.date, 0);
    _prevDate = new DateTime(int.parse(_utility.year),
        int.parse(_utility.month), int.parse(_utility.day) - 1);
    _nextDate = new DateTime(int.parse(_utility.year),
        int.parse(_utility.month), int.parse(_utility.day) + 1);

    ////////////////////////////////////////
    Map data = Map();

    String url = "http://toyohide.work/BrainLog/api/worktimemonthdata";
    Map<String, String> headers = {'content-type': 'application/json'};
    String body = json.encode({"date": '${widget.date}'});
    Response response = await post(url, headers: headers, body: body);

    if (response != null) {
      data = jsonDecode(response.body);

      if (data['data'].length > 0) {
        //prev
        _utility.makeYMDYData(_prevDate.toString(), 0);
        var _date = '${_utility.year}-${_utility.month}-${_utility.day}';
        if (data['data'][_date] != null) {
          _prevStart = data['data'][_date]['work_start'];
          _prevEnd = data['data'][_date]['work_end'];
        }

        //next
        _utility.makeYMDYData(_nextDate.toString(), 0);
        var _date2 = '${_utility.year}-${_utility.month}-${_utility.day}';
        if (data['data'][_date2] != null) {
          _nextStart = data['data'][_date2]['work_start'];
          _nextEnd = data['data'][_date2]['work_end'];
        }
      }
    }
    ////////////////////////////////////////

    setState(() {});
  }

  /**
   *
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.1),
        title: _getScreenTitle(),
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
              SizedBox(
                height: 80,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    tooltip: '前日',
                    onPressed: () => _goWorktimeInputScreen(
                      context: context,
                      date: _prevDate.toString(),
                      start: _prevStart,
                      end: _prevEnd,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    tooltip: '翌日',
                    onPressed: () => _goWorktimeInputScreen(
                      context: context,
                      date: _nextDate.toString(),
                      start: _nextStart,
                      end: _nextEnd,
                    ),
                  ),
                ],
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                margin: const EdgeInsets.all(20),
                color: Colors.black.withOpacity(0.3),
                child: Container(
                  margin: EdgeInsets.all(20),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: 80,
                            child: Text('Work Start'),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: IconButton(
                              icon: const Icon(Icons.access_time),
                              tooltip: 'jump',
                              onPressed: () =>
                                  _showStartTimePicker(context: context),
                              color: Colors.blueAccent,
                            ),
                          ),
                          Text('${_dialogSelectedStartTime}'),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            width: 80,
                            child: Text('Work End'),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: IconButton(
                              icon: const Icon(Icons.access_time),
                              tooltip: 'jump',
                              onPressed: () =>
                                  _showEndTimePicker(context: context),
                              color: Colors.blueAccent,
                            ),
                          ),
                          Text('${_dialogSelectedEndTime}'),
                        ],
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: RaisedButton(
                          color: Colors.greenAccent.withOpacity(0.3),
                          child: Icon(Icons.input),
                          onPressed: () => _uploadWorktimeData(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /**
   *
   */
  Widget _getScreenTitle() {
    _utility.makeYMDYData(widget.date, 0);
    var _date = '${_utility.year}-${_utility.month}-${_utility.day}';

    return Container(
      color: _utility.getBgColor(
        _date,
        _dialogSelectedStartTime,
        _dialogSelectedEndTime,
      ),
      child: Text('${_date}（${_utility.youbiStr}）'),
    );
  }

  /**
   *
   */
  void _showStartTimePicker({BuildContext context}) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: (widget.start != '')
          ? TimeOfDay(
              hour: int.parse(widget.start.split(":")[0]),
              minute: int.parse(widget.start.split(":")[1]),
            )
          : TimeOfDay.now(),
      builder: (BuildContext context, Widget child) {
        return child;
      },
    );

    if (selectedTime != null) {
      _dialogSelectedStartTime =
          '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
      setState(() {});
    }
  }

  /**
   *
   */
  void _showEndTimePicker({BuildContext context}) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: (widget.end != '')
          ? TimeOfDay(
              hour: int.parse(widget.end.split(":")[0]),
              minute: int.parse(widget.end.split(":")[1]),
            )
          : TimeOfDay.now(),
      builder: (BuildContext context, Widget child) {
        return child;
      },
    );

    if (selectedTime != null) {
      _dialogSelectedEndTime =
          '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
      setState(() {});
    }
  }

  /**
   *
   */
  void _uploadWorktimeData() async {
    _utility.makeYMDYData(widget.date, 0);

    Map<String, dynamic> _uploadData = Map();
    _uploadData['date'] = '${_utility.year}-${_utility.month}-${_utility.day}';
    _uploadData['work_start'] = _dialogSelectedStartTime;
    _uploadData['work_end'] = _dialogSelectedEndTime;

    String url = "http://toyohide.work/BrainLog/api/worktimeinsert";
    Map<String, String> headers = {'content-type': 'application/json'};
    String body = json.encode(_uploadData);
    await post(url, headers: headers, body: body);

    Toast.show('登録が完了しました', context, duration: Toast.LENGTH_LONG);
  }

  /**
   *
   */
  void _goWorktimeInputScreen(
      {BuildContext context, String date, String start, String end}) {
    Navigator.pushReplacement(
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
}
