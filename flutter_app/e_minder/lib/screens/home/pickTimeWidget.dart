import 'package:flutter/material.dart';

var endTime = "0000";
var startTime = "0000";

class TimePickerWidget extends StatefulWidget {
  final String timeType;
  String get_endTime(){
    return endTime;
  }

  void reset_time(){
    startTime = "0000";
    endTime = "0000";
  }

  String get_startTime(){
    return startTime;
  }

  const TimePickerWidget({
    required this.timeType,
    Key? key,
  }) : super(key: key);


  @override
  _TimePickerWidgetState createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  TimeOfDay time = TimeOfDay.now();

  String getText() {
    if (time == null) {
      return '0000';
    } else {
      final hours = time.hour.toString().padLeft(2, '0');
      final minutes = time.minute.toString().padLeft(2, '0');
      final timeString = '$hours$minutes';
      return timeString;
    }
  }


  @override
  Widget build(BuildContext context) => ElevatedButton(
    child: Text('Select',style: TextStyle(color: Colors.grey[800]),),
    //text: getText(),
    style: ElevatedButton.styleFrom(
      primary: Colors.deepPurple[100],
    ),
    onPressed: () => pickTime(context),
  );

  Future pickTime(BuildContext context) async {
    final initialTime = TimeOfDay(hour: 9, minute: 0);
    var newTime = await showTimePicker(
      context: context,
      initialTime: time ?? initialTime,
    );

    if (newTime == null) return;

    setState(() => time = newTime);
    if(widget.timeType == "start"){
      startTime = getText();
    } else if(widget.timeType == "end"){
      endTime = getText();
    }
  }
}