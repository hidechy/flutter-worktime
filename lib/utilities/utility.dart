import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Utility {
  /**
   * 背景取得
   */
  Widget getBackGround() {
    return Image.asset(
      'assets/image/bg.jpg',
      fit: BoxFit.cover,
      color: Colors.black.withOpacity(0.7),
      colorBlendMode: BlendMode.darken,
    );
  }

  /**
   * 日付データ作成
   */
  String year;
  String month;
  String day;
  String youbi;
  String youbiStr;
  int youbiNo;

  void makeYMDYData(String date, int noneDay) {
    List explodedDate = date.split(' ');
    List explodedSelectedDate = explodedDate[0].split('-');
    year = explodedSelectedDate[0];
    month = explodedSelectedDate[1];

    if (noneDay == 1) {
      var f = new NumberFormat("00");
      day = f.format(1);
    } else {
      day = explodedSelectedDate[2];
    }

    DateTime youbiDate =
        DateTime(int.parse(year), int.parse(month), int.parse(day));
    youbi = DateFormat('EEEE').format(youbiDate);
    switch (youbi) {
      case "Sunday":
        youbiStr = "日";
        youbiNo = 0;
        break;
      case "Monday":
        youbiStr = "月";
        youbiNo = 1;
        break;
      case "Tuesday":
        youbiStr = "火";
        youbiNo = 2;
        break;
      case "Wednesday":
        youbiStr = "水";
        youbiNo = 3;
        break;
      case "Thursday":
        youbiStr = "木";
        youbiNo = 4;
        break;
      case "Friday":
        youbiStr = "金";
        youbiNo = 5;
        break;
      case "Saturday":
        youbiStr = "土";
        youbiNo = 6;
        break;
    }
  }

  /**
   * 月末日取得
   */
  String monthEndDateTime;
  void makeMonthEnd(int year, int month, int day) {
    monthEndDateTime = new DateTime(year, month, day).toString();
  }

/**
 * 背景色取得
 */
  getBgColor(String date, String start, String end) {
    makeYMDYData(date, 0);

    Color _color = null;

    switch (youbiNo) {
      case 0:
        _color = Colors.redAccent[700].withOpacity(0.3);
        break;

      case 6:
        _color = Colors.blueAccent[700].withOpacity(0.3);
        break;

      default:
        if (start == '' && end == '') {
          _color = Colors.greenAccent[700].withOpacity(0.3);
        } else {
          _color = Colors.black.withOpacity(0.3);
        }

        break;
    }

    return _color;
  }

  /**
   *
   */
  int getMinusMinutes({end, year, month, day}) {
    //-------------------// pattern
    var _minusPattern = 0;

    if (int.parse(year) >= 2021) {
      if (int.parse(month) >= 2) {
        _minusPattern = 1;
      }
    }

    // switch (_displayYear) {
    //   case '2021':
    //     switch (_displayMonth) {
    //       case '02':
    //       case '03':
    //         _minusPattern = 1;
    //         break;
    //     }
    //     break;
    // }
    //-------------------// pattern

    switch (_minusPattern) {
      case 0:
        return 60;
        break;
      case 1:
        var ex_end = end.split(":");

        var _endTime = new DateTime(
          int.parse(year),
          int.parse(month),
          int.parse(day),
          int.parse(ex_end[0]),
          int.parse(ex_end[1]),
        );

        //(1)
        var _hikaku1 = new DateTime(
            int.parse(year), int.parse(month), int.parse(day), 17, 30);
        int diffMinutes1 = _endTime.difference(_hikaku1).inMinutes;
        var _minus1 = (diffMinutes1 > 0) ? 30 : 0;

        //(2)
        var _hikaku2 = new DateTime(
            int.parse(year), int.parse(month), int.parse(day), 22, 00);
        int diffMinutes2 = _endTime.difference(_hikaku2).inMinutes;
        var _minus2 = (diffMinutes2 > 0) ? 30 : 0;

        return (60 + _minus1 + _minus2);

        break;
    }
  }

  /**
   * 金額を3桁区切りで表示する
   */
  final formatter = NumberFormat("#,###");
  String makeCurrencyDisplay(String text) {
    return formatter.format(int.parse(text));
  }
}
