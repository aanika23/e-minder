import 'package:e_minder/screens/auth/authenticate.dart';
import 'package:e_minder/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e_minder/models/user.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);

    // return Home (if user is signed in) or Authenticate (if user is not signed in)
    if (user == null) {
      return Authenticate();
    } else {
      return Home();
    }
  }
}