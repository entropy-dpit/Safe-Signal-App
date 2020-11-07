import 'package:entropy_client/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart' show AppLocalizations;

/// About page
/// 
/// Author: Raul Popa @Raul-Popa

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [GRADIENT_START, GRADIENT_END],
          begin: const FractionalOffset(0.0, 0.0),
          end: const FractionalOffset(0.5, 0.5),
          stops: [0.0, 1.0],
          tileMode: TileMode.clamp,
        ),
      ),
      child: Scaffold(
        appBar: new AppBar(
          leading: new IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: new Text(
            AppLocalizations.of(context).translate('about-about'),
            style: TextStyle(
              fontFamily: FONT_FAMILY,
              fontWeight: FontWeight.normal,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                AppLocalizations.of(context).translate('about-whomegalul'),
                style: TextStyle(
                  fontFamily: FONT_FAMILY,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                child: Text(
                  AppLocalizations.of(context).translate('about-main'),
                  style: TextStyle(
                    fontFamily: FONT_FAMILY,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                child: Text(
                  AppLocalizations.of(context).translate('about-thanks'),
                  style: TextStyle(
                    fontFamily: FONT_FAMILY,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Text(
                AppLocalizations.of(context).translate('about-links'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: FONT_FAMILY,
                  fontSize: 18,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 7,
                  color: Colors.white,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                            AppLocalizations.of(context)
                                .translate('about-facebook'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w200,
                              fontFamily: FONT_FAMILY,
                            )),
                      ]),
                  onPressed: () async {
                    launch(FACEBOOK_LINK);
                  },
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 7,
                  color: Colors.white,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                            AppLocalizations.of(context)
                                .translate('about-instagram'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w200,
                              fontFamily: FONT_FAMILY,
                            )),
                      ]),
                  onPressed: () async {
                    launch(INSTAGRAM_LINK);
                  },
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.65,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 7,
                  color: Colors.white,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          AppLocalizations.of(context).translate('about-dpit'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w200,
                            fontFamily: FONT_FAMILY,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ]),
                  onPressed: () async {
                    launch(DPIT_LINK);
                  },
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.50,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  elevation: 7,
                  color: Colors.white,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          AppLocalizations.of(context).translate('about-legal'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w200,
                            fontFamily: FONT_FAMILY,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ]),
                  onPressed: () async {
                    launch(LEGAL_LINK);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
