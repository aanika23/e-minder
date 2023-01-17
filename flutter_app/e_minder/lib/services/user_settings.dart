import 'package:flutter/material.dart';
import 'package:e_minder/services/wifi.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:intl/intl.dart';
import 'package:e_minder/services/reset_password.dart';
import 'package:e_minder/services/database.dart';

import '../models/user.dart';

class UserSettings extends StatefulWidget{
  @override
  _UserSettings createState() => _UserSettings();

}

class _UserSettings extends State<UserSettings>{

  //TO-DO: get this value from db and set it
  double _value = 1;



  @override
  Widget build(BuildContext context){
    final user = Provider.of<User>(context);

    AlertDialog _getTimerWindow(){
      return AlertDialog(
        title: const Text("Select Scanning Time"),
        insetPadding: EdgeInsets.symmetric(vertical: 200),
        content: StatefulBuilder(builder: (context,state){
          return SfSlider(
            value: _value,
            min: 0.0,
            max: 120,
            interval: 60,
            activeColor: Colors.deepPurple,
            showLabels: true,
            showTicks: true,
            enableTooltip: true,
            numberFormat: NumberFormat("0.#s"),
            onChanged: (newValue){
              if(newValue < 1){
                newValue = 1;
              }
              _value = newValue;
              state(() {});
              setState(() {});
            },
          );
        }),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.pop(context, 'Cancel'),
              child: const Text("Cancel")
          ),
          TextButton(
              onPressed: () async {
                //TO-DO: Insert in db
                Navigator.pop(context, 'Submit');
                await DatabaseService(uid: user.uid).addTimeWindow((_value*1000).round());
              },
              child: const Text("Submit")
          ),
        ],
      );
    }



    return Scaffold(
      appBar: AppBar(
        title: const Text("User Settings"),
        flexibleSpace: Container(
          decoration:
          BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/auth_screen_bg.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,//deepPurple[800],
        foregroundColor: Colors.grey[200],
        elevation: 5.0,
      ),
      body: Container(
        padding: const EdgeInsets.all(10),
          child: ListView(
            children: <Widget>[
              ListTile(
             title: new Text("WiFi Settings"),
                trailing: new Icon(Icons.wifi),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => const WifiSetup())),
              ),
              ListTile(
                title: new Text("Reset Password"),
                trailing: new Icon(Icons.password),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ResetPassword())),
              ),
              ListTile(
                title: new Text("Adjust Scanning Time for Reminders"),
                trailing: new Icon(Icons.timer),
                onTap: () => {
                    showDialog(context: context,
                        builder: (BuildContext context) => _getTimerWindow())
                },
              ),
            ],
          )
      ),
    );
  }

  GestureDetector buildSettingOption(BuildContext context, String title, Icon icon){
    return GestureDetector(
      onTap: () {

      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600]
            ),),
            SizedBox(width: 120),
            icon,
          ],
        )
      )
    );
  }

}

