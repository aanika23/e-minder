import 'package:e_minder/models/user.dart';
import 'package:e_minder/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_minder/screens/home/add_schedule.dart';
import 'package:e_minder/screens/home/item_scan.dart';


String _itemName = "";
class ItemRegistrationForm extends StatefulWidget {
  const ItemRegistrationForm({Key? key}) : super(key: key);

  String get_itemName(){
    return _itemName;
  }

  void reset_itemName(){
    _itemName = "";
  }

  @override
  State<ItemRegistrationForm> createState() => _ItemRegistrationFormState();

}

class _ItemRegistrationFormState extends State<ItemRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  //form values


  @override
  Widget build(BuildContext context) {


    void _showItemScanPanel() {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
              child: const ItemScan(),
            );
          }
      );
    }
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          const Text(
            'Enter item details',
            style: TextStyle(fontSize: 18.0),
          ),
          const SizedBox(height: 20.0),
          TextFormField(
            decoration: const InputDecoration(
              hintText: "Name"
            ),
            validator: (value) => value!.isEmpty ? 'Give your item a name' : null,
            onChanged: (value) => setState(() => _itemName = value),
          ),
          const SizedBox(height: 40.0),
          Container(
            width: 280.0,
            height: 50.0,
            child:   OutlinedButton(
              onPressed: () { _showAddSchedulePanel(); },
              child: Row(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child:Text(
                      'Add Schedule',
                      style: TextStyle(color:Colors.grey[700]),
                      textAlign: TextAlign.left,
                    ),

                  ),
                  SizedBox(width: 100),
                  // Align(
                  //   alignment: Alignment.centerRight,
                  //   child:Text(
                  //     'None >',
                  //     style: TextStyle(color:Colors.grey[500]),
                  //     textAlign: TextAlign.right,
                  //   ),
                  //
                  // )
                ],
              ),
            ),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Colors.deepPurple[200] 
            ),
              onPressed: () => _showItemScanPanel(),
            child: Text(
              'Find Tag',
              style: TextStyle(color: Colors.grey[800]),
            )
          ),

        ],
      )
    );
  }
  void _showAddSchedulePanel() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            child: AddSchedule(),
          );
        }
    );
  }
}
