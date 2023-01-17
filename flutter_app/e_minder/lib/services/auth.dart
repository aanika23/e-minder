import 'package:e_minder/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;

class AuthService {
  final fba.FirebaseAuth _auth = fba.FirebaseAuth.instance;

  // create user object based on Firebase User 
  User? _createUserProfile(fba.User? fbUser) {
    return fbUser != null ?  User(uid: fbUser.uid) : null;
  }

  // stream that listens to user authentication changes
  Stream<User?> get userAuthStream {
    return _auth.authStateChanges().map(_createUserProfile);
  }

  // sign in anonymously 
  Future signInAnon() async {
    try {
      fba.UserCredential credential = await _auth.signInAnonymously();
      fba.User? fbUser = credential.user;
      return _createUserProfile(fbUser);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // register with email & password
  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      fba.UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      fba.User? fbUser = credential.user;
      return _createUserProfile(fbUser);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign in with email & password
  Future signINWithEmailAndPassword(String email, String password) async {
    try {
      fba.UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      fba.User? fbUser = credential.user;
      return _createUserProfile(fbUser);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // register with Google account

  // sign in with Google account

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch(e) {
      print(e.toString());
      return null;
    }
  }

  Future sendResetEmail(String email) async {
    await fba.FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  String getCurrentUserEmail(){
    var currentEmail = fba.FirebaseAuth.instance.currentUser?.email;
    if (currentEmail == null){
      return " ";
    } else {
      return currentEmail.toString();
    }
  }

}