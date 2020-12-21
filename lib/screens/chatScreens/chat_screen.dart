import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:skype/constants/strings.dart';
import 'package:skype/enum/view_state.dart';
import 'package:skype/models/MessageModel.dart';
import 'package:skype/models/UserModel.dart';
import 'package:skype/provider/image_upload_provider.dart';
import 'package:skype/resources/firebase_repository.dart';
import 'package:skype/screens/callScreens/pickup/pickup_layout.dart';
import 'package:skype/screens/chatScreens/widgets/cached_image.dart';
import 'package:skype/utils/call_utilities.dart';
import 'package:skype/utils/permission.dart';
import 'package:skype/utils/universal_variable.dart';
import 'package:skype/utils/utilities.dart';
import 'package:skype/widgets/appbar.dart';
import 'package:skype/widgets/customtile.dart';

class ChatScreen extends StatefulWidget {
  final UserModel receiver;

  ChatScreen({this.receiver});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController textFieldController = TextEditingController();
  FirebaseRepository _firebaseRepository = FirebaseRepository();
  ScrollController listScrollController = ScrollController();
  bool isWritting = false;
  UserModel senderModel;
  String _currentUserId;
  bool showEmojiPiker = false;
  FocusNode textFieldFocus = FocusNode();
  ImageUploadProvider _imageUploadProvider;
  // CallUtils callUtils = CallUtils();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _firebaseRepository.getCurrentUser().then((user) {
      _currentUserId = user.uid;

      setState(() {
        senderModel = UserModel(
            uid: user.uid, name: user.displayName, profilePhoto: user.photoURL);
      });
    });
  }

  showKeyboard() {
    return textFieldFocus.requestFocus();
  }

  hideKeyboard() {
    return textFieldFocus.unfocus();
  }

  hideEmojiContainer() {
    setState(() {
      showEmojiPiker = false;
    });
  }

  showEmojiContainer() {
    Future.delayed(Duration(milliseconds: 100));
    setState(() {
      showEmojiPiker = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      appBar: customAppBar(context),
      body: Column(
        children: [
          // RaisedButton(
          //   onPressed: () {
          //     _imageUploadProvider.getViewState == ViewState.LOADING
          //         ? _imageUploadProvider.setToIdle()
          //         : _imageUploadProvider.setToLoading();
          //   },
          //   child: Text("Change View State"),
          // ),
          Flexible(child: messageList()),
          _imageUploadProvider.getViewState == ViewState.LOADING
              ? Container(
                  child: CircularProgressIndicator(),
                  margin: EdgeInsets.only(right: 15),
                  alignment: Alignment.centerRight,
                )
              : Container(),
          chatControls(),
          showEmojiPiker
              ? Offstage(
                  child: Container(
                    child: emojiContainer(),
                  ),
                  offstage: !showEmojiPiker,
                )
              : SizedBox.shrink()
        ],
      ),
    );
  }

  emojiContainer() {
    return EmojiPicker(
      bgColor: UniversalVariables.separatorColor,
      indicatorColor: UniversalVariables.blueColor,
      rows: 3,
      columns: 7,
      onEmojiSelected: (emoji, category) {
        setState(() {
          isWritting = true;
        });
        // print(emoji);
        textFieldController.text = textFieldController.text + emoji.emoji;
      },
      recommendKeywords: ["face", "happy", "party", "sad", "racing", "horse"],
      numRecommended: 50,
    );
  }

  Widget messageList() {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(MESSAGES_COLLECTION)
            .doc(_currentUserId)
            .collection(widget.receiver.uid)
            .orderBy(TIMESTAMP_FIELD, descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          // SchedulerBinding.instance.addPostFrameCallback((_) {
          //   listScrollController.animateTo(
          //       listScrollController.position.minScrollExtent,
          //       duration: Duration(milliseconds: 250),
          //       curve: Curves.easeInOut);
          // });
          return ListView.builder(
            itemCount: snapshot.data.docs.length,
            reverse: true,
            controller: listScrollController,
            padding: EdgeInsets.all(10),
            itemBuilder: (context, index) {
              return chatMessageItem(snapshot.data.docs[index]);
            },
          );
        });
  }

  Widget chatMessageItem(DocumentSnapshot snapshot) {
    MessageModel _message = MessageModel.fromMap(snapshot.data);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      child: Container(
        alignment: _message.senderId == _currentUserId
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: _message.senderId == _currentUserId
            ? senderLayout(_message)
            : receiverLayout(_message),
      ),
    );
  }

  Widget senderLayout(MessageModel message) {
    Radius messageRadius = Radius.circular(10);

    return Container(
      margin: EdgeInsets.only(top: 12),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
          color: UniversalVariables.senderColor,
          borderRadius: BorderRadius.only(
              topLeft: messageRadius,
              topRight: messageRadius,
              bottomLeft: messageRadius)),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: getMessage(message),
      ),
    );
  }

  getMessage(MessageModel message) {
    return message.type != MESSAGE_TYPE_IMAGE
        ? Text(
            message.message,
            style: TextStyle(color: Colors.white, fontSize: 16.0),
          )
        : message.photoUrl != null
            ? CachedImage(
                message.photoUrl,
                height: 250,
                width: 250,
                radius: 10,
              )
            : SizedBox.shrink();
  }

  Widget receiverLayout(MessageModel message) {
    Radius messageRadius = Radius.circular(10);

    return Container(
      margin: EdgeInsets.only(top: 12),
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
      decoration: BoxDecoration(
          color: UniversalVariables.receiverColor,
          borderRadius: BorderRadius.only(
              bottomRight: messageRadius,
              topRight: messageRadius,
              bottomLeft: messageRadius)),
      child: Padding(padding: EdgeInsets.all(10), child: getMessage(message)),
    );
  }

  CustomAppBar customAppBar(context) {
    return CustomAppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      centerTitle: false,
      title: Text(widget.receiver.name),
      actions: [
        IconButton(
            icon: Icon(Icons.video_call),
            onPressed: () async =>
                await Permissions.cameraAndMicrophonePermissionsGranted()
                    ? CallUtils.dial(
                        from: senderModel,
                        to: widget.receiver,
                        context: context)
                    : {}),
        IconButton(icon: Icon(Icons.call), onPressed: () {}),
      ],
    );
  }

  pickImage({@required ImageSource source}) async {
    File selectedImage = await Utils.pickImage(source: source);

    _firebaseRepository.uploadImage(
        image: selectedImage,
        receiverId: widget.receiver.uid,
        senderId: _currentUserId,
        imageUploadProvider: _imageUploadProvider);
  }

  Widget chatControls() {
    setWrittingTo(bool val) {
      setState(() {
        isWritting = val;
      });
    }

    addMediaModal(context) {
      showModalBottomSheet(
        context: context,
        elevation: 0,
        backgroundColor: UniversalVariables.blackColor,
        builder: (context) {
          return Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  children: [
                    FlatButton(
                        onPressed: () => Navigator.pop(context),
                        child: Expanded(
                          child: Align(
                              alignment: Alignment.centerLeft,
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                              )),
                        )),
                    Text(
                      "Content and tools",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Flexible(
                  child: ListView(
                children: [
                  ModalTile(
                      title: "Media",
                      subtitle: "Share photo and Video",
                      iconData: Icons.image,
                      onTap: () {
                        pickImage(source: ImageSource.gallery);
                        Navigator.pop(context);
                      }),
                  ModalTile(
                    title: "Contact",
                    subtitle: "Share contact",
                    iconData: Icons.contacts,
                  ),
                  ModalTile(
                    title: "Location",
                    subtitle: "Share a location",
                    iconData: Icons.add_location,
                  ),
                  ModalTile(
                    title: "Schedule Call",
                    subtitle: "Arrange a skype call and get reminders",
                    iconData: Icons.schedule,
                  ),
                  ModalTile(
                    title: "Create Poll",
                    subtitle: "Share photo and Video",
                    iconData: Icons.poll,
                  ),
                ],
              ))
            ],
          );
        },
      );
    }

    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              addMediaModal(context);
            },
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: UniversalVariables.fabGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
              child: Stack(
            children: [
              TextField(
                onTap: () => hideEmojiContainer(),
                focusNode: textFieldFocus,
                controller: textFieldController,
                style: TextStyle(color: Colors.white),
                onChanged: (value) {
                  value.length > 0 && value.trim() != ""
                      ? setWrittingTo(true)
                      : setWrittingTo(false);
                },
                decoration: InputDecoration(
                  hintText: "Tapper un message",
                  hintStyle: TextStyle(color: UniversalVariables.greyColor),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50)),
                      borderSide: BorderSide.none),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                  filled: true,
                  fillColor: UniversalVariables.separatorColor,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onPressed: () {
                    if (!showEmojiPiker) {
                      // KeyBoard is visible
                      hideKeyboard();
                      showEmojiContainer();
                    } else {
                      // Keyboard is hidden
                      showKeyboard();
                      hideEmojiContainer();
                    }
                  },
                  icon: Icon(Icons.face),
                ),
              )
            ],
          )),
          isWritting
              ? SizedBox.shrink()
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Icon(Icons.record_voice_over),
                ),
          isWritting
              ? SizedBox.shrink()
              : GestureDetector(
                  onTap: () => pickImage(source: ImageSource.camera),
                  child: Icon(Icons.camera_alt)),
          isWritting
              ? Container(
                  margin: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      gradient: UniversalVariables.fabGradient,
                      shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(Icons.send, size: 15),
                    onPressed: () => sendMessage(),
                  ),
                )
              : SizedBox.shrink()
        ],
      ),
    );
  }

  sendMessage() {
    var text = textFieldController.text;

    MessageModel messageModel = MessageModel(
      receiverId: widget.receiver.uid,
      senderId: senderModel.uid,
      message: text,
      timestamp: Timestamp.now(),
      type: "text",
    );

    setState(() {
      isWritting = false;
      textFieldController.clear();
    });

    _firebaseRepository.addMessageToDb(
        messageModel, senderModel, widget.receiver);
  }
}

class ModalTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData iconData;
  final Function onTap;

  const ModalTile(
      {Key key,
      @required this.title,
      @required this.subtitle,
      @required this.iconData,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: CustomTile(
        onTap: onTap,
        mini: false,
        leading: Container(
          margin: EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: UniversalVariables.receiverColor),
          padding: EdgeInsets.all(10),
          child: Icon(
            iconData,
            color: UniversalVariables.greyColor,
            size: 38,
          ),
        ),
        subTitle: Text(
          subtitle,
          style: TextStyle(color: UniversalVariables.greyColor, fontSize: 14),
        ),
        title: Text(
          title,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
