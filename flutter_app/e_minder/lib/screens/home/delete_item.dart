import 'package:flutter/material.dart';
import '../../services/database.dart';

class DeleteItem<T> extends StatelessWidget{
  final Widget child;
  final T item;
  final String item_name;
  final String uID;
  final String rfid;

  const DeleteItem({
    required this.child,
    Key? key,
    required this.item,
    required this.item_name,
    required this.rfid,
    required this.uID,
  }) : super(key: key);
  
  @override 
  Widget build(BuildContext context) => Dismissible(
      direction:DismissDirection.startToEnd,
      confirmDismiss: (direction){
        return showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              title: Text("Delete Item"),
              content: Text("Are you sure you want to delete Item ${item_name}"),
              actions: [
                ElevatedButton(onPressed: (){
                  Navigator.of(context).pop(false);
                }, child: Text("Cancel")),
                ElevatedButton(onPressed: (){
                  Navigator.of(context).pop(true);
                }, child: Text("Delete"))
              ],
            ));
      },
      key: UniqueKey(),
      background: buildSwipeAction(),
      child: child,
      onDismissed:  (direction) async {
        await DatabaseService(uid: uID).deleteItem(rfid);
      },);

  Widget buildSwipeAction() => Container(
    alignment: Alignment.centerLeft,
    padding: EdgeInsets.symmetric(horizontal: 20),
    color: Colors.red,
    child: (Icon(Icons.delete_forever, color: Colors.white, size: 32)),
  );



}