import 'package:entropy_client/homePage/aboutPage.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:entropy_client/homePage/homePageWidgets.dart';
import 'package:entropy_client/constants.dart';
import '../main.dart' show AppLocalizations;

/// Main home page for the app
/// 
/// Authors:
///   David Pescariu @davidp-ro
///   Raul Popa @Raul-Popa

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //FlutterBlue flutterBlue = FlutterBlue.instance;

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [GRADIENT_START, GRADIENT_END],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.5, 0.5),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp,
          ),
        ),
        child: Column(
          children: <Widget>[
            new TextTitle(),
            Padding(
              padding: EdgeInsets.all(4),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.73,
                child: Card(
                  elevation: 7,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  color: Color.fromRGBO(255, 255, 255, 0.9),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.70,
                    child: Column(
                      children: <Widget>[
                        new BandStatusAndButton(),
                        Container(
                          color: Colors.transparent,
                          height: 7,
                        ),
                        new SafetyIndicator(),
                        Container(
                          color: Colors.transparent,
                          height: 20,
                        ),
                        new Buttons(onTapNoReport: () {
                          setState(() {});
                        }),
                        Container(
                          color: Colors.transparent,
                          height: 7,
                        ),
                        Expanded(
                          child: Align(
                            alignment: FractionalOffset.bottomCenter,
                            child: ButtonBar(
                              alignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    elevation: 7,
                                    color: Colors.white,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          "?  ",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                            AppLocalizations.of(context)
                                                .translate('home-help'),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w200,
                                              fontFamily: FONT_FAMILY,
                                            )),
                                      ],
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Intro()));
                                    }),
                                RaisedButton(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(20)),
                                    elevation: 7,
                                    color: Colors.white,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                            AppLocalizations.of(context)
                                                .translate('home-about'),
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w200,
                                              fontFamily: FONT_FAMILY,
                                            )),
                                        Icon(Icons.question_answer)
                                      ],
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AboutPage()));
                                    })
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
