import 'package:e_minder/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/reset_password.dart';

class SignIn extends StatefulWidget {
  final Function toggleView;
  const SignIn({Key? key, required this.toggleView }) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
        resizeToAvoidBottomInset: false,
      body: Container(
          decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/auth_screen_bg.jpg"),
                fit: BoxFit.fill,
              )
          ),
          child:Padding(
        padding: EdgeInsets.all(16),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          ImageIcon(
              AssetImage("assets/logo.png"),
              color: Colors.deepPurple[800],
              size: 95
          ),
          SizedBox(height: 25,),
          Text(
              'Welcome Back!',
              style: GoogleFonts.bebasNeue(fontSize: 48, color: Colors.white),
          ),
          SizedBox(height: 10),
          Text(
            'You\'ve been missed!',
            style: TextStyle(
              fontSize: 20,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20,),
          Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 20.0),
                  SizedBox(
                    width: 350,
                    child: TextFormField(
                        style: TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            hintText: "Email Address",
                            hintStyle: TextStyle(color: Colors.grey)
                        ),
                        validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                        onChanged: (val) {
                          setState(() {
                            email = val;
                          });
                        }
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  SizedBox(
                    width: 350,
                    child: TextFormField(
                        style: TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                            hintText: "Password",
                            hintStyle: TextStyle(color: Colors.grey)
                        ),
                        obscureText: true,
                        validator: (val) => val!.length < 6 ? 'Password must be at least 6 charachters long' : null,
                        onChanged: (val) {
                          setState(() {
                            password = val;
                          });
                        }
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.deepPurple[800],
                      minimumSize: Size(250,45)
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        dynamic user = await _auth.signINWithEmailAndPassword(email, password);
                        if (user == null) {
                          setState(() {
                            error = 'Invalid credentials';
                          });
                        }
                      }
                    },
                    child: const Text('Sign in', style: TextStyle(fontSize: 18),)
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    error,
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 13.0
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Not a member?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                      ),
                      InkWell(
                          child:Text(
                          ' Register Now!',
                        style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold,),
                      ),
                        onTap: ()=> {widget.toggleView()},
                      ),

                    ],
                  ),
                  SizedBox(height: 5,),
                  InkWell(
                    child:Text(
                      ' Forgot password?',
                      style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold,),
                    ),
                    onTap: ()=> Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext context) => ResetPassword())),
                  )

                ]
              ),
            )

        ],
      )),
    )
    ));



    // return Scaffold(
    //   backgroundColor: Colors.deepPurple[100],
    //   appBar: AppBar(
    //     backgroundColor: Colors.deepPurple[800],
    //     elevation: 5.0,
    //     title: const Text('Sign in to e-minder'),
    //     actions: <Widget>[
    //       TextButton.icon(
    //         onPressed: () {
    //           widget.toggleView();
    //         },
    //         icon: const Icon(Icons.person),
    //         label: const Text('Register')
    //       )
    //     ],
    //   ),
    //   body: Container(
    //     padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
    //     child: Form(
    //       key: _formKey,
    //       child: Column(
    //         children: <Widget>[
    //           const SizedBox(height: 20.0),
    //           TextFormField(
    //             decoration: const InputDecoration(
    //               hintText: "Email Address"
    //             ),
    //             validator: (val) => val!.isEmpty ? 'Enter an email' : null,
    //             onChanged: (val) {
    //               setState(() {
    //                 email = val;
    //               });
    //             }
    //           ),
    //           const SizedBox(height: 20.0),
    //           TextFormField(
    //             decoration: const InputDecoration(
    //               hintText: "Password"
    //             ),
    //             obscureText: true,
    //             validator: (val) => val!.length < 6 ? 'Password must be at least 6 charachters long' : null,
    //             onChanged: (val) {
    //               setState(() {
    //                 password = val;
    //               });
    //             }
    //           ),
    //           const SizedBox(height: 20.0),
    //           ElevatedButton(
    //             style: ElevatedButton.styleFrom(
    //               primary: Colors.deepPurple[800]
    //             ),
    //             onPressed: () async {
    //               if (_formKey.currentState!.validate()) {
    //                 dynamic user = await _auth.signINWithEmailAndPassword(email, password);
    //                 if (user == null) {
    //                   setState(() {
    //                     error = 'Invalid credentials';
    //                   });
    //                 }
    //               }
    //             },
    //             child: const Text('Sign in')
    //           ),
    //           const SizedBox(height: 10.0),
    //           Text(
    //             error,
    //             style: TextStyle(
    //               color: Colors.red[700],
    //               fontSize: 13.0
    //             ),
    //           )
    //         ]
    //       ),
    //     )
    //   ),
    // );
  }
}