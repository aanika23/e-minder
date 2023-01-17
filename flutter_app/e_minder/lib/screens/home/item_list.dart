import 'package:e_minder/models/item.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_minder/screens/home/item_tile.dart';
import 'package:e_minder/screens/home/delete_item.dart';

import '../../models/user.dart';

class ItemList extends StatefulWidget {
  const ItemList({Key? key}) : super(key: key);

  @override
  State<ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  @override
  Widget build(BuildContext context) {
    final items = Provider.of<List<Item>>(context);
    final user = Provider.of<User>(context, listen: false);
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return DeleteItem(
            item_name: (items[index]).name,
           item:items[index],
            uID: user.uid,
           rfid: (items[index]).rfid,
           child: ItemTile(item: items[index]),
        );

      },
    );
  }
}