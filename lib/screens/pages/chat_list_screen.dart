import 'package:flutter/material.dart';
import 'package:skype/resources/firebase_repository.dart';
import 'package:skype/utils/universal_variable.dart';
import 'package:skype/utils/utilities.dart';
import 'package:skype/widgets/appbar.dart';
import 'package:skype/widgets/customtile.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

final FirebaseRepository _firebaseRepository = FirebaseRepository();

class _ChatListScreenState extends State<ChatListScreen> {
  String currentUserId;
  String initials = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _firebaseRepository.getCurrentUser().then((user) {
      setState(() {
        currentUserId = user.uid;
        initials = Utils.getInitials(user.displayName);
      });
    });
  }

  CustomAppBar customAppBar(BuildContext context) {
    return CustomAppBar(
        title: UserCircle(initials),
        actions: [
          IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () {
                return Navigator.pushNamed(context, "/search_screen");
              }),
          IconButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white,
              ),
              onPressed: () {})
        ],
        leading: IconButton(
          icon: Icon(Icons.notifications, color: Colors.white),
          onPressed: () {},
        ),
        centerTitle: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      appBar: customAppBar(context),
      floatingActionButton: NewChatButton(),
      body: ChatListContainer(currentUserId),
    );
  }
}

class ChatListContainer extends StatefulWidget {
  final String currentUserId;

  ChatListContainer(this.currentUserId);
  @override
  _ChatListContainerState createState() => _ChatListContainerState();
}

class _ChatListContainerState extends State<ChatListContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: 20,
        itemBuilder: (context, index) {
          return CustomTile(
            mini: false,
            onTap: () {},
            title: Text(
              "The CS media",
              style: TextStyle(
                  color: Colors.white, fontFamily: "Arial", fontSize: 19),
            ),
            subTitle: Text(
              "Hello",
              style:
                  TextStyle(color: UniversalVariables.greyColor, fontSize: 14),
            ),
            leading: Container(
              constraints: BoxConstraints(maxHeight: 60, maxWidth: 60),
              child: Stack(
                children: [
                  CircleAvatar(
                    maxRadius: 30,
                    backgroundColor: Colors.grey,
                    backgroundImage: NetworkImage(
                        "https://pbs.twimg.com/profile_images/1196420026858905601/ZOBrOhub_400x400.jpg"),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      height: 13,
                      width: 13,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: UniversalVariables.onlineDotColor,
                          border: Border.all(
                              color: UniversalVariables.blackColor, width: 2)),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class NewChatButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: UniversalVariables.fabGradient,
          borderRadius: BorderRadius.circular(50)),
      child: Icon(
        Icons.edit,
        color: Colors.white,
        size: 25,
      ),
      padding: EdgeInsets.all(15),
    );
  }
}

class UserCircle extends StatelessWidget {
  final String text;
  UserCircle(this.text);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: UniversalVariables.separatorColor),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Text(
              text,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: UniversalVariables.lightBlueColor,
                  fontSize: 13),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 12,
              width: 12,
              decoration: BoxDecoration(
                  color: UniversalVariables.onlineDotColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: UniversalVariables.blackColor, width: 2)),
            ),
          )
        ],
      ),
    );
  }
}
