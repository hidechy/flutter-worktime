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
          onPressed: () => _scroll(),
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
          _resultList(),
        ],
      ),
    );
  }

  /**
   *
   */
  void _scroll() {
    _itemScrollController.scrollTo(
      index: maxNo,
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
                                child:
                                    Text('${_resultData[position]['summary']}'),
                                alignment: Alignment.topRight,
                              ),
                              Container(
                                child: Text(
                                    '${_utility.makeCurrencyDisplay(_resultData[position]['salary'])}'),
                                alignment: Alignment.topRight,
                              ),
                              Container(
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
}
