import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skype/models/MessageModel.dart';
import 'package:skype/models/UserModel.dart';
import 'package:skype/provider/image_upload_provider.dart';
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

  Future<List<UserModel>> fetchAllUsers(User user) =>
      _firebaseMethods.fetchAllUsers(user);

  Future<void> addMessageToDb(MessageModel messageModel, UserModel senderModel,
          UserModel receiverModel) =>
      _firebaseMethods.addMessageToDb(messageModel, senderModel, receiverModel);

  void uploadImage(
          {@required File image,
          @required String receiverId,
          @required String senderId,
          @required ImageUploadProvider imageUploadProvider}) =>
      _firebaseMethods.uploadImage(
          image, receiverId, senderId, imageUploadProvider);

  Future<UserModel> getUserDetails() => _firebaseMethods.getUserDetails();
}
