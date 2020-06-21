import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class BaseAuth {
  Future<String> signIn(String email, String password);
  Future<String> signUp(String email, String password,var userId,String _name);
  Future<FirebaseUser> getCurrentUser();
  Future<String> getUserUid();
  Future<void> signOut();

}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signIn(String email, String password) async {
    AuthResult result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    FirebaseUser user = result.user;
    return user.uid;
  }

  Future<String> signUp(String email, String password,var userId,String _name) async {
    AuthResult result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    DocumentReference documnentReference =
    Firestore.instance.collection("users").document(userId);
    Map<String,String> users ={
      "useruid" :userId,
      "username":_name
    };
    documnentReference.setData(users).whenComplete((){
      print("$userId has added");
    });
    FirebaseUser user = result.user;
    return user.uid;
  }

  Future<FirebaseUser> getCurrentUser() async {

     FirebaseUser user = await _firebaseAuth.currentUser();
     return user;
  }
  Future<String> getUserUid() async{
    return (await _firebaseAuth.currentUser()).uid;

  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }
}
