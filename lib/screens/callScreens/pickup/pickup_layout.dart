import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skype/models/CallModel.dart';
import 'package:skype/provider/user_provider.dart';
import 'package:skype/resources/call_methods.dart';
import 'package:skype/screens/callScreens/pickup/pickup_screen.dart';

class PickUpLayout extends StatelessWidget {
  final Widget scaffold;
  final CallMethods callMethods = CallMethods();

  PickUpLayout({@required this.scaffold});
  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    return (userProvider != null && userProvider.getUser != null)
        ? StreamBuilder<DocumentSnapshot>(
            stream: callMethods.callStream(uid: userProvider.getUser.uid),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data.data() != null) {
                CallModel callModel =
                    CallModel.fromMap(() => snapshot.data.data());
                if (!callModel.hasDialled) {
                  return PickUpScreen(callModel: callModel);
                }
                // print(callModel.hasDialled);
              }
              return scaffold;
            },
          )
        : Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}
