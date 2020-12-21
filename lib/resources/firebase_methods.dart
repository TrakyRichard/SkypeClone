import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:skype/constants/strings.dart';
import 'package:skype/models/MessageModel.dart';
import 'package:skype/models/UserModel.dart';
import 'package:skype/provider/image_upload_provider.dart';
import 'package:skype/utils/utilities.dart';

class FirebaseMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection("users");
  firebase_storage.Reference storage;
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

  //get User details
  Future<UserModel> getUserDetails() async {
    User currentUser = await getCurrentUser();
    DocumentSnapshot documentSnapshot =
        await _userCollection.document(currentUser.uid).get();
    return UserModel.fromMap(documentSnapshot.data);
  }

  Future<bool> authenticateUser(UserCredential user) async {
    QuerySnapshot result = await firestore
        .collection(USERS_COLLECTION)
        .where(EMAIL_FIELD, isEqualTo: user.user.email)
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
        .collection(USERS_COLLECTION)
        .doc(currentUser.user.uid)
        .set(userModel.toMap(userModel));
    return null;
  }

  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<List<UserModel>> fetchAllUsers(User currentUser) async {
    List<UserModel> userList = List<UserModel>();
    QuerySnapshot querySnapshot =
        await firestore.collection(USERS_COLLECTION).get();

    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id != currentUser.uid) {
        userList.add(UserModel.fromMap(querySnapshot.docs[i].data));
      }
    }

    return userList;
  }

  Future<void> addMessageToDb(MessageModel messageModel, UserModel senderModel,
      UserModel receiverModel) async {
    var map = messageModel.toMap();

    await firestore
        .collection(MESSAGES_COLLECTION)
        .doc(messageModel.senderId)
        .collection(messageModel.receiverId)
        .add(map);
    return await firestore
        .collection(MESSAGES_COLLECTION)
        .doc(messageModel.receiverId)
        .collection(messageModel.senderId)
        .add(map);
  }

  Future<String> uploadImageToStorage(File image) async {
    // firebase_storage.UploadTask storageTask = storage.child(path)
    try {
      storage = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('${DateTime.now().microsecondsSinceEpoch}');
      firebase_storage.UploadTask _uploadTask = storage.putFile(image);
      firebase_storage.TaskSnapshot storageTaskSnapshot = await _uploadTask;
      // UploadTask _uploadTask = storage.putFile(image);

      String url = await storageTaskSnapshot.ref.getDownloadURL();

      return url;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  void setImageMsg(String url, String receiverId, String senderId) async {
    MessageModel _message;

    _message = MessageModel.imageMessage(
        message: "IMAGE",
        receiverId: receiverId,
        senderId: senderId,
        photoUrl: url,
        timestamp: Timestamp.now(),
        type: "image");

    var map = _message.toImageMap();

    // Set the data Message

    await firestore
        .collection(MESSAGES_COLLECTION)
        .doc(_message.senderId)
        .collection(_message.receiverId)
        .add(map);
    await firestore
        .collection(MESSAGES_COLLECTION)
        .doc(_message.receiverId)
        .collection(_message.senderId)
        .add(map);
  }

  void uploadImage(File image, String receiverId, String senderId,
      ImageUploadProvider imageUploadProvider) async {
    // set some loading value to db and show it to user
    imageUploadProvider.setToLoading();
    // get Url from the image bucket
    String url = await uploadImageToStorage(image);

    // hide loading
    imageUploadProvider.setToIdle();

    setImageMsg(url, receiverId, senderId);
  }
}
