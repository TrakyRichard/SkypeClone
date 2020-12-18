import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skype/resources/firebase_repository.dart';
import 'package:skype/screens/home_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skype/utils/universal_variable.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  FirebaseRepository _firebaseRepository = FirebaseRepository();
  bool isLoginPressed = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      body: Stack(children: [
        Center(child: loginButton()),
        isLoginPressed
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container()
      ]),
    );
  }

  Widget loginButton() {
    return Shimmer.fromColors(
      baseColor: Colors.white,
      highlightColor: UniversalVariables.senderColor,
      child: FlatButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          onPressed: () => performLogin(),
          child: Text(
            "Login",
            style: TextStyle(
                fontSize: 35, fontWeight: FontWeight.w900, letterSpacing: 1.2),
          )),
    );
  }

  void performLogin() {
    setState(() {
      isLoginPressed = true;
    });
    _firebaseRepository.signIn().then((UserCredential user) => {
          if (user != null)
            {authenticate(user)}
          else
            {print('There was an error')}
        });
  }

  void authenticate(UserCredential user) {
    _firebaseRepository.authenticateUser(user).then((isNewUser) {
      if (isNewUser) {
        setState(() {
          isLoginPressed = false;
        });
        _firebaseRepository.addDataToDb(user).then((_) {
          return Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return HomeScreen();
          }));
        });
      } else {
        setState(() {
          isLoginPressed = false;
        });
        return Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return HomeScreen();
        }));
      }
    });
  }
}
