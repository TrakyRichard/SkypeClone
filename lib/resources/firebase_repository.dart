import 'package:firebase_auth/firebase_auth.dart';
import 'package:skype/resources/firebase_methods.dart';

class FirebaseRepository {
  FirebaseMethods _firebaseMethods = FirebaseMethods();

  Future<User> getCurrentUser() => _firebaseMethods.getCurrentUser();

  Future<UserCredential> signIn() => _firebaseMethods.signIn();

  Future<bool> authenticateUser(UserCredential user) =>
      _firebaseMethods.authenticateUser(user);

  Future<void> addDataToDb(UserCredential user) =>
      _firebaseMethods.addDataToDb(user);

  Future<void> signOut() => _firebaseMethods.signOut();
}