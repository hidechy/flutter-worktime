import 'package:flutter/material.dart';

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
        var ex_data_4 = (ex_data[4]).split('/');
        for (var j = 0; j < ex_data_4.length; j++) {
          _list.add(ex_data_4[j]);
        }

        Map _map = Map();
        _map['ym'] = ex_data[0];
        _map['summary'] = ex_data[1];
        _map['company'] = ex_data[2];
        _map['genba'] = ex_data[3];
        _map['daily'] = _list;

        _resultData.add(_map);
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('勤務時間'),
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
          _resultList(),
        ],
      ),
    );
  }

  /**
   * リスト表示
   */
  Widget _resultList() {
    return ListView.builder(
      itemCount: _resultData.length,
      itemBuilder: (context, int position) => _listItem(position: position),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('${_resultData[position]['ym']}'),
                  Text('${_resultData[position]['summary']}'),
                ],
              ),
              Container(
                alignment: Alignment.topRight,
                child: Text('${_resultData[position]['company']}'),
              ),
              Container(
                alignment: Alignment.topRight,
                child: Text('${_resultData[position]['genba']}'),
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
