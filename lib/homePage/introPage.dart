import 'package:entropy_client/homePage/homePage.dart';
import 'package:entropy_client/loadingPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'homePage.dart';
import 'homePageWidgets.dart';
import '../loadingPage.dart';

/// Gets called from [main.dart]
/// 
/// Will either show the introduction or redirect to the home page if the intro
/// was completed.
/// 
/// Authors:
///   Raul Popa @Raul-Popa
///   David Pescariu @davidp-ro

class IntroScreen extends StatefulWidget {
  IntroScreen({Key key}) : super(key: key);

  @override
  IntroScreenState createState() => new IntroScreenState();
}

class IntroScreenState extends State<IntroScreen> {
  Future<bool> getSeenStatus() async {
    final SharedPreferences _prefs = await SharedPreferences.getInstance();

    return _prefs.getBool('hasSeen') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return new FutureBuilder(
        future: getSeenStatus(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == true) {
              return HomePage();
            } else {
              return Intro();
            }
          } else {
            return LoadingPage();
          }
        });
  }
}
