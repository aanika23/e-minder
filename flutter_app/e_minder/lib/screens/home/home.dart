import 'package:e_minder/models/user.dart';
import 'package:e_minder/screens/home/item_list.dart';
import 'package:e_minder/screens/home/item_registration_form.dart';
import 'package:e_minder/screens/home/item_scan.dart';
import 'package:e_minder/services/auth.dart';
import 'package:e_minder/services/database.dart';
import 'package:e_minder/services/help_support.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_minder/models/item.dart';
import 'package:e_minder/services/user_settings.dart';


class Home extends StatelessWidget {
  Home({Key? key}) : super(key: key);

  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    void _showItemRegistrationPanel() {
      showModalBottomSheet(
        context: context, 
        builder: (context) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
            child: const ItemRegistrationForm(),
          );
        }
      );
    }

    return StreamProvider<List<Item>>.value(
      value: DatabaseService(uid: user!.uid).items, 
      initialData: const [],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('e-minder'),
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
          //foregroundColor: Colors.grey[200],
          elevation: 5.0,
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                  accountEmail: Text(AuthService().getCurrentUserEmail()),
                  currentAccountPicture: GestureDetector(
                    child: const CircleAvatar(
                      backgroundImage: NetworkImage("https://media.wired.co.uk/photos/60c8730fa81eb7f50b44037e/3:2/w_3329,h_2219,c_limit/1521-WIRED-Cat.jpeg"),
                    )
                  ),
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage("assets/slider_bg.jpg")
                  )
                ), accountName: null,
              ),
              new ListTile(
                title: new Text("Settings"),
                trailing: new Icon(Icons.person),
                onTap: () => Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => UserSettings())),
              ),
              new ListTile(
                title: new Text("Help and Support"),
                trailing: new Icon(Icons.headset_mic_outlined),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => HelpSupport())),
              ),
              new Divider(),
              new ListTile(
                title: new Text("Sign Out", style: TextStyle(color: Colors.deepOrange)),
                trailing: new Icon(Icons.exit_to_app, color: Colors.deepOrange,),
                onTap: () async {await _auth.signOut();},
              ),
              new ListTile(
                title: new Text("Close"),
                trailing: new Icon(Icons.cancel),
                onTap: () => Navigator.of(context).pop(),
              )
            ],
          )
        ),
        body: const ItemList(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showItemRegistrationPanel(),
          icon: const Icon(Icons.add),
          label: const Text('New item'),
          backgroundColor: Colors.deepPurple[200],
          foregroundColor: Colors.grey[800],
        ),
      ),
    );
  }
}