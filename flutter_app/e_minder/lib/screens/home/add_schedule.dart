import 'package:e_minder/models/user.dart';
import 'package:e_minder/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:e_minder/screens/home/pickTimeWidget.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

List<String> checkedWeekList = [];
class AddSchedule extends StatefulWidget {
  const AddSchedule({Key? key}) : super(key: key);
  String get_WeekDays(){
    if (checkedWeekList.isEmpty){
      return "mtwhfsn";
    } else {
      return checkedWeekList.join("");
    }
  }

  void reset_weekDays(){
    checkedWeekList.clear();
  }


  @override
  State<AddSchedule> createState() => _AddSchedule();
}

class _AddSchedule extends State<AddSchedule> {
  final _formKey = GlobalKey<FormState>();
  final CalendarController _controller = CalendarController();
  //form values
  late String _itemName;
  late String _itemRfid;
  bool oneTime = false;
  bool repeated = false;
  String startOneTime = "Start";
  String endOneTime = "End";



  @override
  Widget build(BuildContext context) {

    AlertDialog showCalender(context, String title){
      return AlertDialog(
        title: Text(title),
        content: Container(
          height: 250,
          width: 60,
          child: ListView(
            children: <Widget>[
              SfCalendar(
                view: CalendarView.month,
                showDatePickerButton: true,
                onSelectionChanged: (CalendarSelectionDetails details) async {
                  if(title == "Select Start Time"){
                    setState((){
                      startOneTime = DateFormat('dd/MM/yy').format(details.date!).toString();
                    });
                  }else {
                    endOneTime = DateFormat('dd/MM/yy').format(details.date!).toString();
                  }
                },
              ),
              Text('Would you like to approve of this message?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Next'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    }





    return Form(
        key: _formKey,
        child: SingleChildScrollView(
          //scrollDirection: Axis.horizontal,
        child: Column(
          children: <Widget>[
            const SizedBox(height: 20.0),
            Column(
              children: <Widget>[
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children:<Widget>[
                  _getWeekButton("M"),
                  _getWeekButton("Tu"),
                  _getWeekButton("W"),
                  _getWeekButton("Th"),
                ]),
                const SizedBox(height: 5.0),
                Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,children:<Widget>[
                  const SizedBox(width: 35.0),
                  _getWeekButton("F"),
                  _getWeekButton("Sa"),
                  _getWeekButton("Su"),
                ]),
                const SizedBox(height: 35.0),
                Row(children: <Widget>[
                  const SizedBox(width:20.0),
                  Text(
                      "Start",
                      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, fontFamily: 'RobotoMono'),
                  ),
                  const SizedBox(width: 88.0),
                  TimePickerWidget(timeType: "start",),

                ],

                ),
                const SizedBox(height: 20.0),
                Row(children: <Widget>[
                  const SizedBox(width:20.0),
                  Text(
                    "End",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, fontFamily: 'RobotoMono'),
                  ),
                  const SizedBox(width: 100.0),
                  TimePickerWidget(timeType: "end",),

                ],

                ),
              ],
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.deepPurple[200],
                  fixedSize: const Size(240, 10),
                ),
                onPressed: () => {
                  Navigator.of(context).pop(),
                },
                child: Text(
                  'Submit',
                  style: TextStyle(color: Colors.grey[800]),
                )
            )

          ],
        ))
    );





    }


}


ElevatedButton _getWeekButton(String weekDay){
  return ElevatedButton(
    child: Text(
      weekDay.toUpperCase(),
      style: TextStyle(fontSize: 12),
    ),
    onPressed: () => {
      if(checkedWeekList.contains(weekDay)){
        checkedWeekList.remove(weekDay)
      } else {
          if (weekDay == "Th"){
            checkedWeekList.add("h")
          } else if (weekDay == "Su"){
            checkedWeekList.add("n")
          } else if(weekDay == "Sa"){
            checkedWeekList.add("s")
          } else if (weekDay == "Tu"){
            checkedWeekList.add("t")
          } else {
            checkedWeekList.add(weekDay.toLowerCase())
          }
      },
    },
    style: ElevatedButton.styleFrom(
        fixedSize: const Size(40, 40),
        shape: const CircleBorder(),
        primary: Colors.blueGrey[400],
  ),
  );
}






















