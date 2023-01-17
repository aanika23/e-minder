import 'package:flutter/material.dart';
import 'package:e_minder/models/item.dart';

class ItemTile extends StatelessWidget {
  final Item item;
  const ItemTile({Key? key, required this.item }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Card(
        margin: const EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          leading: const Icon(Icons.check_box),
          title: Text(item.name),
          subtitle: Text(
            'RFID: ${item.rfid}',
            style: const TextStyle(
              fontSize: 11.0,
              color: Colors.deepPurple,
            ),
          ),
        ),
      ), 
    );
  }
}