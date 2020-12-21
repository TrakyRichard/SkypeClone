import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skype/provider/image_upload_provider.dart';
import 'package:skype/provider/user_provider.dart';
import 'package:skype/resources/firebase_repository.dart';
import 'package:skype/screens/home_screen.dart';
import 'package:skype/screens/login_screen.dart';
import 'package:skype/screens/search_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    FirebaseRepository _repository = FirebaseRepository();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ImageUploadProvider>(
          create: (_) => ImageUploadProvider(),
        ),
        ChangeNotifierProvider(create: (_) => UserProvider())
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Skype Clone',
          initialRoute: '/',
          routes: {
            '/search_screen': (context) => SearchScreen(),
          },
          theme: ThemeData(
              visualDensity: VisualDensity.adaptivePlatformDensity,
              brightness: Brightness.dark),
          home: FutureBuilder(
            future: _repository.getCurrentUser(),
            builder: (context, AsyncSnapshot<User> snapshot) {
              if (snapshot.hasData) {
                return HomeScreen();
              } else {
                return LoginScreen();
              }
            },
          )),
    );
  }
}
