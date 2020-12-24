import 'package:flutter/material.dart';
import 'package:skype/models/CallModel.dart';
import 'package:skype/resources/call_methods.dart';
import 'package:skype/screens/callScreens/call_screen.dart';
import 'package:skype/screens/chatScreens/widgets/cached_image.dart';
import 'package:skype/utils/permission.dart';

class PickUpScreen extends StatefulWidget {
  final CallModel callModel;

  PickUpScreen({@required this.callModel});

  @override
  _PickUpScreenState createState() => _PickUpScreenState();
}

class _PickUpScreenState extends State<PickUpScreen> {
  final CallMethods callMethods = CallMethods();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.70,
          ),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Incomming",
                style: TextStyle(
                  fontSize: 30,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              CachedImage(
                widget.callModel.callerPic,
                isRound: true,
                radius: 180,
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                widget.callModel.callerName,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              SizedBox(height: 55),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      icon: Icon(
                        Icons.call_end,
                        color: Colors.redAccent,
                        size: 40,
                      ),
                      onPressed: () async {
                        await callMethods.endCall(call: widget.callModel);
                      }),
                  SizedBox(
                    width: 30,
                  ),
                  IconButton(
                      color: Colors.green,
                      icon: Icon(
                        Icons.call,
                        size: 40,
                      ),
                      onPressed: () async => await Permissions
                              .cameraAndMicrophonePermissionsGranted()
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CallScreen(
                                  call: widget.callModel,
                                ),
                              ))
                          : {})
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
