import 'package:entropy_client/homePage/saveAndReadReports.dart';
import 'package:entropy_client/reportsPage/reportsPage.dart';
import 'package:flutter/material.dart';
import 'package:intro_slider/intro_slider.dart';
import '../constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bandPage/bandPage.dart';
import 'package:entropy_client/contactPage/contactPage.dart';
import '../mapPage/mapPage.dart';
import 'package:entropy_client/constants.dart';
import 'package:intro_slider/slide_object.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:entropy_client/homePage/homePage.dart';
import '../main.dart' show AppLocalizations;

/// Widgets for the home page
///
/// Authors:
///   Raul Popa @Raul-Popa
///   David Pescariu @davidp-ro

/// This class is to create a gradient AppBar but it lacks a back button
/// functionality so instead of implementing one I just worked around the need
/// of an AppBar
class GradientAppBar extends StatelessWidget {
  final String title;
  final double barHeight = 50.0;

  GradientAppBar(this.title);

  @override
  Widget build(BuildContext context) {
    final double statusbarHeight = MediaQuery.of(context).padding.top;

    return new Container(
      padding: EdgeInsets.only(top: statusbarHeight),
      height: statusbarHeight + barHeight,
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.transparent, Colors.transparent],
            tileMode: TileMode.clamp),
      ),
    );
  }
}

class Intro extends StatefulWidget {
  @override
  _IntroState createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  List<Slide> slides = new List();
  Map<Permission, PermissionStatus> permissions;

  void getPermission() async {
    // ignore: unused_local_variable
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.phone,
      Permission.contacts,
      Permission.sms
    ].request();
  }

  void makeSlides() {
    slides.add(
      new Slide(
        widgetTitle: Text(
          AppLocalizations.of(context).translate('intro-onetitle'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontFamily: FONT_FAMILY,
            fontSize: 24,
          ),
        ),
        widgetDescription: Text(
          AppLocalizations.of(context).translate('intro-onetext'),
          textAlign: TextAlign.justify,
          style: TextStyle(
            color: Colors.white,
            fontFamily: FONT_FAMILY,
            fontSize: 14,
          ),
        ),
        backgroundColor: Color(0xff0F4C5C),
      ),
    );
    slides.add(
      new Slide(
        widgetTitle: Text(
          AppLocalizations.of(context).translate('intro-twotitle'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontFamily: FONT_FAMILY,
            fontSize: 24,
          ),
        ),
        description: AppLocalizations.of(context).translate('intro-twotext'),
        styleDescription: TextStyle(
          color: Colors.white,
          fontFamily: FONT_FAMILY,
          fontSize: 18,
        ),
        backgroundColor: Color(0xff5F0F40),
      ),
    );
    slides.add(
      new Slide(
        title: AppLocalizations.of(context).translate('intro-threetitle'),
        styleTitle: TextStyle(
          color: Colors.white,
          fontFamily: FONT_FAMILY,
          fontSize: 24,
        ),
        description: AppLocalizations.of(context).translate('intro-threetext'),
        styleDescription: TextStyle(
          color: Colors.white,
          fontFamily: FONT_FAMILY,
          fontSize: 18,
        ),
        backgroundColor: Color(0xff843dd4),
      ),
    );
  }

  void onDonePress() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('hasSeen', true);
    getPermission();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    makeSlides();
    return new IntroSlider(
      slides: this.slides,
      isShowSkipBtn: false,
      onDonePress: this.onDonePress,
    );
  }
}

/// This class contains the Title
class TextTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.25,
      child: Align(
          alignment: Alignment.center,
          child: Center(
            child: Text(
              AppLocalizations.of(context).translate('home-title'),
              style: TextStyle(
                fontSize: 24,
                fontFamily: 'Poppins',
                color: Colors.white,
              ),
            ),
          )),
    );
  }
}

/// This class is the dynamic Band part
class BandStatusAndButton extends StatefulWidget {
  @override
  _BandStatusAndButtonState createState() => _BandStatusAndButtonState();
}

/// State for BandStatusAndButton
///
/// Will get SharedPrefs and display the text and button accordingly
class _BandStatusAndButtonState extends State<BandStatusAndButton> {
  Future<bool> isBandPaired() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    return preferences.getBool(KEY_ISBANDPAIRED) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      /// Show band status - disconnected/connected and
      /// Show button text according to band status
      future: isBandPaired(),
      initialData: false,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          String _bandStatus;
          String _buttonText;
          if (snapshot.data == true) {
            _bandStatus =
                AppLocalizations.of(context).translate('home-band-con');
            _buttonText =
                AppLocalizations.of(context).translate('home-band-btn-con');
          } else {
            _bandStatus =
                AppLocalizations.of(context).translate('home-band-dis');
            _buttonText =
                AppLocalizations.of(context).translate('home-band-btn-dis');
          }
          //iReallyHateFlutterSometimes();
          return ListTile(
            leading: Text(
              _bandStatus,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w200,
                  fontFamily: 'Poppins'),
            ),
            trailing: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 7,
                color: Colors.white,
                child: Text(
                  _buttonText,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w200,
                      fontFamily: 'Poppins'),
                ),
                onPressed: () async {
                  final res = await Navigator.push(context,
                      MaterialPageRoute(builder: (context) => BandPage()));
                  if (res == "update") {
                    setState(() {
                      // Update text;
                    });
                  }
                }),
          );
        } else {
          /// We should never have to wait so much, but...
          return LinearProgressIndicator(
            backgroundColor: GRADIENT_START,
          );
        }
      },
    );
  }
}

/// This class is the round-ish thing that atm is only green...
// ignore: must_be_immutable
class SafetyIndicator extends StatelessWidget {
  var _dangerColor;
  var _dangerText;
  var zoneDangerIndex = 4;

  @override
  Widget build(BuildContext context) {
    if (zoneDangerIndex < 5) {
      _dangerText = AppLocalizations.of(context).translate('home-zone-safe');
      _dangerColor = Colors.lightGreen;
    } else if (zoneDangerIndex < 7) {
      _dangerText = AppLocalizations.of(context).translate('home-zone-unsafe');
      _dangerColor = Colors.yellow;
    } else {
      _dangerText =
          AppLocalizations.of(context).translate('home-zone-dangerous');
      _dangerColor = Colors.red;
    }

    return FractionallySizedBox(
      widthFactor: 0.7,
      child: Container(
        color: Colors.transparent,
        height: MediaQuery.of(context).size.height * 0.25,
        child: Card(
          elevation: 7,
          color: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  MediaQuery.of(context).size.height * 0.1)),
          child: FractionallySizedBox(
            heightFactor: 0.95,
            widthFactor: 0.97,
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      MediaQuery.of(context).size.height * 0.1 -
                          MediaQuery.of(context).size.height * 0.0375 / 9)),
              color: _dangerColor,
              child: Container(
                height: 175,
                child: ListTile(
                  title: Center(
                    child: Text(
                      _dangerText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Button to see the map
class SeeMapButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.18,
      width: MediaQuery.of(context).size.height * 0.18,
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 7,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              AppLocalizations.of(context).translate('home-map'),
              style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width < 1080 ? 12 : 14,
                  fontWeight: FontWeight.w100,
                  fontFamily: 'Poppins'),
            ),
            Container(
              color: Colors.transparent,
              height: 5,
            ),
            Icon(Icons.map),
          ],
        ),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => MapPage()));
        },
      ),
    );
  }
}

/// Button to see the contacts
class SeeContactsButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.18,
      width: MediaQuery.of(context).size.height * 0.18,
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 7,
        color: Colors.white,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                AppLocalizations.of(context).translate('home-contacts'),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize:
                        MediaQuery.of(context).size.width < 1080 ? 12 : 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Poppins'),
              ),
              Container(
                color: Colors.transparent,
                height: 5,
              ),
              Icon(Icons.contacts),
            ]),
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => ContactPage()));
        },
      ),
    );
  }
}

class ReportFeed extends StatefulWidget {
  ReportFeed({@required this.onTapNoReport});

  final GestureTapCallback onTapNoReport;

  @override
  _ReportFeedState createState() => _ReportFeedState();
}

class _ReportFeedState extends State<ReportFeed> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getReports(),
      initialData: [],
      builder: (context, AsyncSnapshot<List> snapshot) {
        if (snapshot.data == null || snapshot.data == []) {
          return RaisedButton(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 7,
            color: Colors.white,
            disabledColor: Colors.white,
            disabledElevation: 4,
            disabledTextColor: Colors.black,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  AppLocalizations.of(context).translate('home-no-reports'),
                  style: TextStyle(
                      fontSize:
                          MediaQuery.of(context).size.width < 1080 ? 12 : 14,
                      fontWeight: FontWeight.w400,
                      fontFamily: 'Poppins'),
                ),
              ],
            ),
            onPressed: widget.onTapNoReport,
          );
        } else {
          return RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 7,
              color: Colors.white,
              disabledColor: Colors.white,
              disabledElevation: 4,
              disabledTextColor: Colors.black,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      (snapshot.data.length == 1
                          ? AppLocalizations.of(context)
                              .translate('home-one-report')
                          : "${snapshot.data.length}" +
                              AppLocalizations.of(context)
                                  .translate('home-more-reports')),
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width < 1080
                              ? 12
                              : 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: 'Poppins'),
                    ),
                    Container(width: 5),
                    Icon(Icons.info_outline),
                  ]),
              onPressed: () async {
                final res = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReportsPage(
                      reports: snapshot.data,
                      basicallyJustAsetState: widget.onTapNoReport,

                      /// This is no joke required, DO NOT DELETE
                      /// Yes I know [onTapNoReport] is just a setState() but it's a high level setState so it's needed
                    ),
                  ),
                );
                if (res == "update") {
                  setState(() {});
                }
              });
        }
      },
    );
  }
}

/// This class implements the above buttons
class Buttons extends StatelessWidget {
  Buttons({@required this.onTapNoReport});

  final GestureTapCallback onTapNoReport;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SeeMapButton(),
                Container(
                  color: Colors.transparent,
                  width: 25,
                ),
                SeeContactsButton(),
              ],
            ),
            Container(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ReportFeed(onTapNoReport: onTapNoReport),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
