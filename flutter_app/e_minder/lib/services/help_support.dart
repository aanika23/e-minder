import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:e_minder/services/auth.dart';
//import 'package:firebase_auth_forgot_password/utils.dart';

class HelpSupport extends StatefulWidget{
  @override
  _HelpSupportState createState() => _HelpSupportState();

}

class _HelpSupportState extends State<HelpSupport>{
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  @override
  void dispose(){
    emailController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help and Support"),
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
        foregroundColor: Colors.grey[200],
        elevation: 5.0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Please enter your email, \nand we will contact you as soon as possible!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                cursorColor: Colors.white,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(labelText: 'Email'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: (email) =>
                email != null && !EmailValidator.validate(email) ? 'Invalid Email' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(50),
                    primary: Colors.deepPurple[800]
                ),
                icon: Icon(Icons.email_outlined),
                label: Text(
                  'Contact Me',
                  style: TextStyle(fontSize: 24),
                ),
                onPressed: () => {},

              )

            ],
          ),
        ),
      ),
    );
  }

}