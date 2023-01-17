import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_minder/models/item.dart';
import 'package:flutter/cupertino.dart';


class DatabaseService {
  final String uid;
  DatabaseService({ required this.uid });

  // collection reference
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference itemCollection = FirebaseFirestore.instance.collection('items');
  final CollectionReference registrationCollection = FirebaseFirestore.instance.collection('registration');

  Future registerItem(String name, String weekDays, String startTime,
      String endTime,bool ready) async {

    Map<String, dynamic> dataToUpdate = {
      'name': name,
      'owner': uid,
      'days': weekDays,
      'from': startTime,
      'to': endTime,
      'ready': ready,
    };

    await registrationCollection.doc("taginfo").update(dataToUpdate);
  }

  // create an item list from query snapshot
  List<Item> _itemListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc){
      return Item(
        rfid: doc.id,
        name: doc.get('name'),
      );
    }).toList();
  }

  // get item stream
  Stream<List<Item>> get items {
    return userCollection.doc(uid).collection('items').snapshots()
      .map(_itemListFromSnapshot);
  }

  deleteItem(String rfid)  {
    itemCollection.doc(rfid).delete();
    userCollection.doc(uid).collection('items').doc(rfid).delete();
  }
  
  addTimeWindow(int milliseconds){
    Map<String, dynamic> dataToUpdate = {
      'window': milliseconds,
    };
    userCollection.doc(uid).set(dataToUpdate);

  }
}
