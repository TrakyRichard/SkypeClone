import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:skype/resources/firebase_repository.dart';
import 'package:skype/screens/login_screen.dart';
import 'package:skype/screens/pages/chat_list_screen.dart';
import 'package:skype/utils/universal_variable.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController pageController;
  int _page = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseRepository _firebaseRespository = FirebaseRepository();
    return Scaffold(
      backgroundColor: UniversalVariables.blackColor,
      body: PageView(
        children: [
          Container(
            child: ChatListScreen(),
          ),
          Center(
            child: Text("Call List Screen"),
          ),
          Center(
            child: Text("Historique List Screen"),
          ),
        ],
        physics: NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: (value) {
          onPageChange(value);
        },
      ),
      bottomNavigationBar: Container(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: CupertinoTabBar(
            backgroundColor: UniversalVariables.blackColor,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.chat,
                    color: (_page == 0)
                        ? UniversalVariables.lightBlueColor
                        : UniversalVariables.greyColor,
                  ),
                  label: "Chats"),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.call,
                    color: (_page == 1)
                        ? UniversalVariables.lightBlueColor
                        : UniversalVariables.greyColor,
                  ),
                  label: "Call"),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.contact_phone,
                    color: (_page == 2)
                        ? UniversalVariables.lightBlueColor
                        : UniversalVariables.greyColor,
                  ),
                  label: "Historique"),
            ],
            onTap: (value) => navigationTapped(value),
            currentIndex: _page,
          ),
        ),
      ),
    );
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  void onPageChange(int page) {
    setState(() {
      _page = page;
    });
  }
}

// Container(
//           child: Center(
//               child: FlatButton(
//                   onPressed: () {
//                     _firebaseRespository.signOut().then((_) =>
//                         Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                                 builder: (context) => LoginScreen())));
//                   },
//                   child: Text("HomePage"))),
//         )
