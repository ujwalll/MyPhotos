import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthenticationService with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  String userUid;
  String error;
  String get getUserUid => userUid;
  String get gerError => error;

  Future logOut() async {
    userUid = null;
    error = null;
    await _firebaseAuth.signOut();
  }

  Future signIn({String email, String password}) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      User user = userCredential.user;
      userUid = user.uid;
      assert(userUid != null);
      print(userUid);
      error = null;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      error = e.message;
      userUid = null;
    }
  }

  Future signUp({String email, String password}) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      User user = userCredential.user;
      userUid = user.uid;
      assert(userUid != null);
      print(userUid);
      error = null;
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      error = e.message;
      userUid = null;
    }
  }
}
