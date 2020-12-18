import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:skype/models/UserModel.dart';
import 'package:skype/screens/home_screen.dart';
import 'package:skype/utils/utilities.dart';

class FirebaseMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  Future<User> getCurrentUser() async {
    User currentUser;
    currentUser = _auth.currentUser;
    return currentUser;
  }

  // User class
  UserModel userModel = UserModel();

  Future<UserCredential> signIn() async {
    GoogleSignInAccount _signInAccount = await _googleSignIn.signIn();
    GoogleSignInAuthentication _signInAuthentification =
        await _signInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: _signInAuthentification.accessToken,
      idToken: _signInAuthentification.idToken,
    );
    UserCredential user = await _auth.signInWithCredential(credential);
    return user;
  }

  Future<bool> authenticateUser(UserCredential user) async {
    QuerySnapshot result = await firestore
        .collection("users")
        .where("email", isEqualTo: user.user.email)
        .get();

    final List<DocumentSnapshot> docs = result.docs;

    // if user is registered then length of list > 0 or less than 0
    return docs.length == 0 ? true : false;
  }

  Future<void> addDataToDb(UserCredential currentUser) {
    String username = Utils.getUsername(currentUser.user.email);
    userModel = UserModel(
        uid: currentUser.user.uid,
        email: currentUser.user.email,
        name: currentUser.user.displayName,
        profilePhoto: currentUser.user.photoURL,
        username: username);

    firestore
        .collection("users")
        .doc(currentUser.user.uid)
        .set(userModel.toMap(userModel));
    return null;
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
