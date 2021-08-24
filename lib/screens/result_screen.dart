import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../utilities/utility.dart';

import 'dart:convert';
import 'package:http/http.dart';

class ResultScreen extends StatefulWidget {
  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  Utility _utility = Utility();

  List<Map<dynamic, dynamic>> _resultData = List();

  final ItemScrollController _itemScrollController = ItemScrollController();

  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();

  int maxNo = 0;

  List<Map<dynamic, dynamic>> _yearList = List();

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
    ////////////////////////////////////////
    Map data = Map();

    String url = "http://toyohide.work/BrainLog/api/worktimesummary";
    Map<String, String> headers = {'content-type': 'application/json'};
    String body = json.encode({"date": ''});
    Response response = await post(url, headers: headers, body: body);

    if (response != null) {
      data = jsonDecode(response.body);

      var _inputedYear = "";
      for (var i = 0; i < data['data'].length; i++) {
        var ex_data = (data['data'][i]).split(';');

        List _list = List();
        var daily_data = (ex_data[6]).split('/');
        for (var j = 0; j < daily_data.length; j++) {
          _list.add(daily_data[j]);
        }

        Map _map = Map();
        _map['ym'] = ex_data[0];
        _map['summary'] = ex_data[1];
        _map['company'] = ex_data[2];
        _map['genba'] = ex_data[3];
        _map['salary'] = ex_data[4];
        _map['hour'] = ex_data[5];
        _map['daily'] = _list;

        _resultData.add(_map);

        //
        var ex_ym = (ex_data[0]).split('-');
        if (_inputedYear != ex_ym[0]) {
          Map _map2 = Map();
          _map2['year'] = ex_ym[0];
          _map2['index'] = i;
          _yearList.add(_map2);
        }
        _inputedYear = ex_ym[0];
      }
    }
    ////////////////////////////////////////

    maxNo = _resultData.length;

    setState(() {});
  }

  /**
   *
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('勤務時間'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_downward),
          color: Colors.greenAccent,
          onPressed: () => _scroll(pos: maxNo),
        ),
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
              Container(
                child: Wrap(
                  children: _makeYearBtn(),
                ),
              ),
              Expanded(
                child: _resultList(),
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
  void _scroll({pos}) {
    _itemScrollController.scrollTo(
      index: pos,
      duration: Duration(seconds: 1),
      curve: Curves.easeInOutCubic,
    );
  }

  /**
   *
   */
  Widget _resultList() {
    return ScrollablePositionedList.builder(
      itemBuilder: (context, index) {
        return _listItem(position: index);
      },
      itemCount: _resultData.length,
      itemScrollController: _itemScrollController,
      itemPositionsListener: _itemPositionsListener,
    );
  }

  /**
   * リストアイテム表示
   */
  Widget _listItem({int position}) {
    var _workDayCount = _getWorkDayCount(position: position);

    return Card(
      color: Colors.black.withOpacity(0.3),
      child: DefaultTextStyle(
        style: TextStyle(fontSize: 10),
        child: Container(
          margin: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${_resultData[position]['ym']}',
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.greenAccent.withOpacity(0.7)),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Table(
                          children: [
                            TableRow(children: [
                              Container(
                                child: Text('${_workDayCount}'),
                                alignment: Alignment.topRight,
                              ),
                              Container(
                                child:
                                    Text('${_resultData[position]['summary']}'),
                                alignment: Alignment.topRight,
                              ),
                              (_resultData[position]['salary'] == "")
                                  ? Container()
                                  : Container(
                                      child: Text(
                                          '${_utility.makeCurrencyDisplay(_resultData[position]['salary'])}'),
                                      alignment: Alignment.topRight,
                                    ),
                              (_resultData[position]['hour'] == "")
                                  ? Container()
                                  : Container(
                                      child: Text(
                                          '${_utility.makeCurrencyDisplay(_resultData[position]['hour'])}'),
                                      alignment: Alignment.topRight,
                                    ),
                            ]),
                          ],
                        ),
                        Text('${_resultData[position]['company']}'),
                        Text('${_resultData[position]['genba']}'),
                      ],
                    ),
                  ),
                ],
              ),
              _dailyList(position: position),
            ],
          ),
        ),
      ),
    );
  }

  /**
   *
   */
  Widget _dailyList({position}) {
    List<Widget> _list = List();

    for (var i = 0; i < _resultData[position]['daily'].length; i++) {
      var ex_data = (_resultData[position]['daily'][i]).split('|');
      _list.add(
        Container(
          decoration: BoxDecoration(color: _getBgColor(wday: ex_data[5])),
          child: Row(
            children: <Widget>[
              Container(
                width: 60,
                child: Text('${ex_data[0]}'),
              ),
              Container(
                decoration: (ex_data[6] == '1')
                    ? BoxDecoration(color: Colors.yellowAccent.withOpacity(0.3))
                    : null,
                width: 60,
                child: Text('${ex_data[1]}'),
              ),
              Container(
                width: 60,
                child: Text('${ex_data[2]}'),
              ),
              Container(
                width: 50,
                child: Text('${ex_data[3]}'),
              ),
              Container(
                decoration: (ex_data[4] == '0')
                    ? BoxDecoration(color: Colors.yellowAccent.withOpacity(0.3))
                    : null,
                width: 70,
                child: Text('${ex_data[4]}'),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _list,
      ),
    );
  }

  /**
   *
   */
  Color _getBgColor({wday}) {
    Color _color = null;

    switch (wday) {
      case '0':
        _color = Colors.redAccent[700].withOpacity(0.3);
        break;

      case '6':
        _color = Colors.blueAccent[700].withOpacity(0.3);
        break;

      default:
        _color = Colors.black.withOpacity(0.3);

        break;
    }

    return _color;
  }

  int _getWorkDayCount({int position}) {
    var _workDayCount = 0;
    for (var i = 0; i < _resultData[position]['daily'].length; i++) {
      var ex_data = (_resultData[position]['daily'][i]).split('|');
      if (ex_data[1] != "") {
        _workDayCount++;
      }
    }

    return _workDayCount;
  }

  /**
   *
   */
  List _makeYearBtn() {
    List<Widget> _btnList = List();
    for (var i = 1; i < _yearList.length; i++) {
      _btnList.add(
        GestureDetector(
          onTap: () => _scroll(pos: _yearList[i]['index']),
          child: Container(
            color: Colors.green[900].withOpacity(0.5),
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text('${_yearList[i]['year']}'),
          ),
        ),
      );
    }
    return _btnList;
  }
}
