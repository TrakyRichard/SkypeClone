import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:skype/models/UserModel.dart';
import 'package:skype/resources/firebase_repository.dart';
import 'package:skype/screens/chatScreens/chat_screen.dart';
import 'package:skype/utils/universal_variable.dart';
import 'package:skype/widgets/customtile.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  FirebaseRepository _repository = FirebaseRepository();

  List<UserModel> userList;
  String query = "";
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _repository.getCurrentUser().then((User user) {
      _repository.fetchAllUsers(user).then((List<UserModel> list) {
        userList = list;
      });
    });
  }

  searchAppBar() {
    return GradientAppBar(
      gradient: LinearGradient(colors: [
        UniversalVariables.gradientColorStart,
        UniversalVariables.gradientColorEnd
      ]),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + 20),
        child: Padding(
          padding: EdgeInsets.only(left: 20),
          child: TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                query = value;
              });
            },
            cursorColor: UniversalVariables.blackColor,
            autofocus: true,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white, fontSize: 35),
            decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // WidgetsBinding.instance
                    //     .addPostFrameCallback((_) => searchController.clear());
                    searchController.clear();
                  },
                ),
                border: InputBorder.none,
                hintText: "Search",
                hintStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                    color: Color(0x88ffffff))),
          ),
        ),
      ),
    );
  }

  buildSuggestions(String query) {
    final List<UserModel> suggestionList = query.isEmpty
        ? []
        : userList.where((UserModel userModel)
            // (userModel.username.toLowerCase().contains(query.toLowerCase()) ||
            //     (userModel.name.toLowerCase().contains(query.toLowerCase())))
            {
            String _getUsername = userModel.username.toLowerCase();
            String _query = query.toLowerCase();
            String _getName = userModel.name.toLowerCase();
            bool matchesUsername = _getUsername.contains(_query);
            bool matchesName = _getName.contains(_query);

            return (matchesUsername || matchesName);
          }).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        UserModel searchUser = UserModel(
            uid: suggestionList[index].uid,
            profilePhoto: suggestionList[index].profilePhoto,
            name: suggestionList[index].name,
            username: suggestionList[index].username);

        return CustomTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(searchUser.profilePhoto),
          ),
          title: Text(
            searchUser.username,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subTitle: Text(
            searchUser.name,
            style: TextStyle(color: UniversalVariables.greyColor),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatScreen(receiver: searchUser)));
          },
          mini: false,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      appBar: searchAppBar(),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: buildSuggestions(query),
      ),
    );
  }
}
