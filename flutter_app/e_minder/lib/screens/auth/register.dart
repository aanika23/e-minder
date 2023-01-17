import 'package:e_minder/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:e_minder/image/auth_screen_bg.jpg' as bgImg;

class Register extends StatefulWidget {
  final Function toggleView;
  const Register({Key? key, required this.toggleView }) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
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
          child:SafeArea(
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
                    'Hello There!',
                    style: GoogleFonts.bebasNeue(fontSize: 48, color: Colors.white),
                  ),
                  SizedBox(height: 20,),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 20.0),
                    TextFormField(
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
                    const SizedBox(height: 20.0),
                    TextFormField(
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
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.deepPurple[800],
                          minimumSize: Size(250,45)
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          dynamic user = await _auth.registerWithEmailAndPassword(email, password);
                          if (user == null) {
                            setState(() {
                              error = 'Invalid email';
                            });
                          }
                        }
                      },
                      child: const Text('Register', style: TextStyle(fontSize: 18),)
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      error,
                      style: TextStyle(
                        color: Colors.deepOrange,
                        fontSize: 15.0
                      ),

                    ),
                    SizedBox(height: 5,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already a member?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                          ),
                        ),
                        InkWell(
                          child:Text(
                            ' Sign in here!',
                            style: TextStyle(color: Colors.lightBlueAccent, fontWeight: FontWeight.bold),
                          ),
                          onTap: ()=> {widget.toggleView()},
                        )
                      ],
                    )
                  ]
                ),
              )

                ],
              )),
        ))

    );
  }
}

//return Scaffold(
//   backgroundColor: Colors.deepPurple[100],
//   appBar: AppBar(
//     backgroundColor: Colors.deepPurple[800],
//     elevation: 5.0,
//     title: const Text('Register to e-minder'),
//     actions: <Widget>[
//       TextButton.icon(
//         onPressed: () {
//           widget.toggleView();
//         },
//         icon: const Icon(Icons.person),
//         label: const Text('Sign in')
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
//                 dynamic user = await _auth.registerWithEmailAndPassword(email, password);
//                 if (user == null) {
//                   setState(() {
//                     error = 'Invalid email';
//                   });
//                 }
//               }
//             },
//             child: const Text('Register')
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