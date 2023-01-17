import 'package:e_minder/models/user.dart';
import 'package:e_minder/screens/home/item_registration_form.dart';
import 'package:e_minder/screens/home/add_schedule.dart';
import 'package:e_minder/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:e_minder/screens/home/pickTimeWidget.dart';

class ItemScan extends StatefulWidget {
  const ItemScan({Key? key}) : super(key: key);

  @override
  State<ItemScan> createState() => _ItemScan();
}

class _ItemScan extends State<ItemScan> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {

    final user = Provider.of<User>(context);

    return Form(
        key: _formKey,
        child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const Text(
              'Register Tag',
              style: TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 50.0),
            const Text(
              'Please move your tag closer to the reader.',
              style:TextStyle(fontSize: 20.0, fontFamily: 'RobotoMono', fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            SpinKitPulse(color: Colors.blueGrey,size: 150,duration: Duration(milliseconds: 1000),),
            const SizedBox(height: 30.0),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: Colors.deepPurple[200],
                    fixedSize: const Size(240, 20)
                ),
                onPressed: () async {
                  if(_formKey.currentState!.validate()) {

                    var schedule = new AddSchedule();
                    var timeSched = new TimePickerWidget(timeType: '',);
                    var regForm = new ItemRegistrationForm();

                    var weekdays = schedule.get_WeekDays();
                    var startTime = timeSched.get_startTime();
                    var endTime = timeSched.get_endTime();
                    String itemName = regForm.get_itemName();
                    bool ready = true;

                    if(startTime == endTime){
                      startTime = "0000";
                      endTime = "0000";
                    }

                    if (itemName.isEmpty){
                      showDialog(context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: Text('Invalid Submission'),
                            content: Text("A valid name is required for the item. Please fix item name and try again!"),
                            actions: <Widget>[
                              TextButton(onPressed: () => {
                                Navigator.pop(context, 'OK'),
                                Navigator.pop(context),
                              }, child: const Text('OK'))
                            ],

                          )
                      );
                    } else {
                      await DatabaseService(uid: user.uid).registerItem(itemName, weekdays, startTime,endTime, ready);
                      timeSched.reset_time();
                      regForm.reset_itemName();
                      schedule.reset_weekDays();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    }
                  }
                },
                child: Text(
                  'Register Tag',
                  style: TextStyle(color: Colors.grey[800]),
                )
            ),
          ],
        )
    )
    );


  }
}