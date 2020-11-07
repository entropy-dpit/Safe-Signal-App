import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:entropy_client/showToastWithMessage.dart';
import 'package:entropy_client/loadingPage.dart';
import 'package:entropy_client/bandPage/bandConnected.dart';
import 'package:entropy_client/bandPage/bandDisconnected.dart';
import '../constants.dart';

/// Get state of bt connectiviy and show relevant page
/// 
/// Author: David Pescariu @davidp-ro

Future<bool> isBandPaired() async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();

  return preferences.getBool(KEY_ISBANDPAIRED) ?? false;
}

class BandPage extends StatefulWidget {
  @override
  _BandPageState createState() => _BandPageState();
}

class _BandPageState extends State<BandPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: new FutureBuilder(
        future: isBandPaired(),
        // ignore: missing_return
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == false) {
              return new BandDisconnected();
            } else {
              return new BandConnected();
            }
          } else if (snapshot.hasError) {
            showToastWithMessage(
                "Couldn't open the band screen [snapshot.hasError]");
            Navigator.pop(context);
          } else {
            return LoadingPage();
          }
        },
      ),
    );
  }
}
