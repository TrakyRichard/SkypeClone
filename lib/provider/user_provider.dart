import 'package:flutter/material.dart';
import 'package:skype/models/UserModel.dart';
import 'package:skype/resources/firebase_repository.dart';

class UserProvider with ChangeNotifier {
  UserModel _userModel;
  FirebaseRepository _firebaseRepository = FirebaseRepository();

  UserModel get getUser => _userModel;

  void refreshUser() async {
    UserModel userModel = await _firebaseRepository.getUserDetails();

    _userModel = userModel;
    notifyListeners();
  }
}
