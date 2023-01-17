import 'package:e_minder/models/user.dart';
import 'package:e_minder/services/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:e_minder/screens/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User?>.value(
      initialData: null,
      value: AuthService().userAuthStream,
      child: const MaterialApp(
        home: Wrapper(),
      ),
    );
  }
}
