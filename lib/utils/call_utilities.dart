import 'dart:math';

import 'package:flutter/material.dart';
import 'package:skype/models/CallModel.dart';
import 'package:skype/models/UserModel.dart';
import 'package:skype/resources/call_methods.dart';
import 'package:skype/screens/callScreens/call_screen.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial({UserModel from, UserModel to, context}) async {
    CallModel callModel = CallModel(
        callerId: from.uid,
        callerName: from.name,
        callerPic: from.profilePhoto,
        receiverId: to.uid,
        receiverName: to.name,
        receiverPic: to.profilePhoto,
        channelId: Random().nextInt(1000).toString());

    bool callMade = await callMethods.makeCall(call: callModel);

    callModel.hasDialled = true;

    if (callMade) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => CallScreen(call: callModel)));
    }
  }
}
