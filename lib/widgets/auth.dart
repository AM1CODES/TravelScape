import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:travelscape/widgets/model/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AppUser? _userFromFirebaseUser(User? user) {
    return user != null ? AppUser(uid: user.uid) : null;
  }

  Stream<AppUser?> get user {
    return _auth
        .idTokenChanges()
        .map((User? user) => _userFromFirebaseUser(user));
  }

  String error = '';
  Future signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      print(e.code);
      switch (e.code) {
        case 'invalid-email':
          error = "Enter A Valid Email-Id";
          break;
        case 'wrong-password':
          error = "Incorrect Password";
          break;
        case 'user-not-found':
          error = "User Not Found";
          break;
        case 'user-disabled':
          error = "User diasbled";
          break;
        case 'too-many-requests':
          error = "Too many requests";
          break;
        default:
          error = "Unknown error";
          break;
      }
      return error;
    }
  }

  Future register(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      user!.sendEmailVerification();
      FirebaseFirestore.instance.collection('/users').doc(user.uid).set({
        'uid': user.uid,
        'email': email,
        'name': name,
        'points': 0,
        // 'events': initialEvents,
      });
      return _userFromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          error = "Please Enter a Valid Email";
          break;
        case 'email-already-in-use':
          error = "This Email ID is already in use";
          break;
        case 'weak-password':
          error = "Enter a Stronger Password";
          break;
        default:
          print(e.code);
          error = "Unknown Error Occured";
          break;
      }
      return error;
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  //sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
