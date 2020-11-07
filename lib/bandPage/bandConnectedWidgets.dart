import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../main.dart' show AppLocalizations;

/// Widgets for the connected page
/// 
/// Author: David Pescariu @davidp-ro

_launch(String linkToLaunch) async {
  if (await canLaunch(linkToLaunch)) {
    await launch(linkToLaunch);
  } else {
    throw 'Could not launch $linkToLaunch';
  }
}

class DisconnectCard extends StatelessWidget {
  DisconnectCard({@required this.onPressed});

  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: CARD_BACKGROUND,
      child: ListTile(
        leading: Icon(Icons.adjust),
        title: Text(
          AppLocalizations.of(context).translate('bt-c-connected'),
          style: TextStyle(
            fontFamily: FONT_FAMILY,
            fontWeight: FontWeight.normal,
          ),
        ),
        trailing: FloatingActionButton.extended(
          heroTag: 1,
          onPressed: onPressed,
          icon: Icon(Icons.bluetooth_disabled),
          label: Text(
            AppLocalizations.of(context).translate('bt-c-btndisconnect'),
            style: TextStyle(
              fontFamily: FONT_FAMILY,
              fontWeight: FontWeight.normal,
            ),
          ),
          backgroundColor: GRADIENT_START,
        ),
      ),
    );
  }
}

class TestCard extends StatelessWidget {
  TestCard({@required this.onPressed});

  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: CARD_BACKGROUND,
      child: ListTile(
        leading: Icon(Icons.assignment),
        title: Text(
          AppLocalizations.of(context).translate('bt-c-test'),
          style: TextStyle(
            fontFamily: FONT_FAMILY,
            fontWeight: FontWeight.normal,
          ),
        ),
        trailing: FloatingActionButton.extended(
          backgroundColor: GRADIENT_START,
          label: Icon(Icons.arrow_forward_ios, color: Colors.white),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

class BuyBand extends StatelessWidget {
  BuyBand({@required this.onTapImage});

  final GestureTapCallback onTapImage;

  @override
  Widget build(BuildContext context) {
    return new Card(
      color: CARD_BACKGROUND,
      child: ListTile(
        title: Center(
          child: Text(
            AppLocalizations.of(context).translate('bt-c-buytext'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: FONT_FAMILY,
              fontSize: 22,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        subtitle: Column(
          children: <Widget>[
            GestureDetector(
              onTap: onTapImage,
              child: Image(
                image: AssetImage('assets/images/more_bands.png'),
              ),
            ),
            ButtonBar(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FloatingActionButton.extended(
                  heroTag: 2,
                  onPressed: () => _launch(WEBSITE_LINK),
                  icon: Icon(Icons.open_in_browser, color: Colors.black),
                  label: Text(
                    AppLocalizations.of(context).translate('bt-c-opensite'),
                    style: TextStyle(
                        fontFamily: FONT_FAMILY,
                        fontWeight: FontWeight.normal,
                        color: Colors.black),
                  ),
                  backgroundColor: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Support extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Card(
      color: CARD_BACKGROUND,
      child: ListTile(
        title: Center(
          child: Text(
            AppLocalizations.of(context).translate('bt-c-supporttext'),
            style: TextStyle(
              fontFamily: FONT_FAMILY,
              fontSize: 22,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        subtitle: ButtonBar(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            FloatingActionButton.extended(
              heroTag: 3,
              onPressed: () => launch(FAQ_LINK),
              icon: Icon(Icons.open_in_browser, color: Colors.black),
              label: Text(
                AppLocalizations.of(context).translate('bt-c-faq'),
                style: TextStyle(
                  fontFamily: FONT_FAMILY,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              backgroundColor: Colors.white,
            ),
            FloatingActionButton.extended(
              heroTag: 4,
              onPressed: () => launch(MAILTO_LINK),
              icon: Icon(Icons.mail, color: Colors.black),
              label: Text(
                AppLocalizations.of(context).translate('bt-c-email'),
                style: TextStyle(
                  fontFamily: FONT_FAMILY,
                  fontWeight: FontWeight.normal,
                  color: Colors.black,
                ),
              ),
              backgroundColor: Colors.white,
            ),
          ],
          alignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
}

class Socials extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Card(
      color: CARD_BACKGROUND,
      child: ListTile(
        title: Center(
          child: Text(
            AppLocalizations.of(context).translate('bt-c-socialtext'),
            style: TextStyle(
              fontFamily: FONT_FAMILY,
              fontSize: 22,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        subtitle: Column(
          children: <Widget>[
            ButtonBar(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FloatingActionButton.extended(
                  heroTag: 5,
                  onPressed: () => _launch(FACEBOOK_LINK),
                  icon: Icon(Icons.open_in_browser, color: Colors.black),
                  label: Text(
                    AppLocalizations.of(context).translate('bt-c-facebook'),
                    style: TextStyle(
                        fontFamily: FONT_FAMILY,
                        fontWeight: FontWeight.normal,
                        color: Colors.black),
                  ),
                  backgroundColor: Colors.white,
                ),
                FloatingActionButton.extended(
                  heroTag: 6,
                  onPressed: () => _launch(INSTAGRAM_LINK),
                  icon: Icon(Icons.open_in_browser, color: Colors.black),
                  label: Text(
                    AppLocalizations.of(context).translate('bt-c-instagram'),
                    style: TextStyle(
                        fontFamily: FONT_FAMILY,
                        fontWeight: FontWeight.normal,
                        color: Colors.black),
                  ),
                  backgroundColor: Colors.white,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Rate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Card(
      color: CARD_BACKGROUND,
      child: ListTile(
        title: Text(
          AppLocalizations.of(context).translate('bt-c-rate'),
          style: TextStyle(
            fontFamily: FONT_FAMILY,
            fontSize: 22,
            fontWeight: FontWeight.normal,
          ),
        ),
        trailing: new IconButton(
          icon: Icon(Icons.rate_review, color: Colors.black),
          onPressed: () => _launch(PLAYSTORE_LINK),
          color: Colors.white,
        ),
      ),
    );
  }
}
