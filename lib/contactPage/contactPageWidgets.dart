import 'package:flutter/material.dart';
import '../constants.dart';
import '../main.dart' show AppLocalizations;

/// Widgets for the cotact page
/// 
/// Author: David Pescariu @davidp-ro

/// Add a contact button
///
/// Param [onPressed] - [GestureTapCallback] pressed button action
class AddButton extends StatelessWidget {
  AddButton({@required this.onPressed});

  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return new RawMaterialButton(
      onPressed: onPressed,
      fillColor: Colors.white,
      splashColor: Colors.white70,
      shape: const StadiumBorder(),
      child: new Padding(
        padding: EdgeInsets.all(10.0),
        child: new Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Icon(
              Icons.add,
              color: Colors.black,
            ),
            new SizedBox(
              width: 10.0,
            ),
            new Text(
              AppLocalizations.of(context).translate('contact-addcontact'),
              maxLines: 1,
              style: TextStyle(
                fontFamily: FONT_FAMILY,
                fontSize: 16,
                color: Colors.black,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SendTestSMS extends StatelessWidget {
  SendTestSMS({@required this.onPressed});

  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return new RawMaterialButton(
      onPressed: onPressed,
      fillColor: Colors.white,
      splashColor: Colors.white70,
      shape: const StadiumBorder(),
      child: new Padding(
        padding: EdgeInsets.all(10.0),
        child: new Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Icon(
              Icons.send,
              color: Colors.black,
            ),
            new SizedBox(
              width: 10.0,
            ),
            new Text(
              AppLocalizations.of(context).translate('contact-testsms'),
              maxLines: 1,
              style: TextStyle(
                fontFamily: FONT_FAMILY,
                fontSize: 16,
                color: Colors.black,
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// Remove a contact button
///
/// Param [onPressed] - [GestureTapCallback] pressed button action
class RemoveButton extends StatelessWidget {
  RemoveButton({@required this.onPressed});

  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return new RawMaterialButton(
      onPressed: onPressed,
      fillColor: Colors.red,
      splashColor: Colors.redAccent,
      shape: const StadiumBorder(),
      child: new Padding(
        padding: EdgeInsets.all(10.0),
        child: new Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Icon(
              Icons.remove_circle_outline,
              color: Colors.white,
            ),
            new SizedBox(
              width: 10.0,
            ),
            new Text(
              AppLocalizations.of(context).translate('contact-remove'),
              maxLines: 1,
              style: TextStyle(
                fontFamily: FONT_FAMILY,
                fontSize: 16,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}

// BETA: Show message status on contact page
class SmsStatus extends StatelessWidget {
  SmsStatus({@required this.onPressed});

  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return new RawMaterialButton(
      onPressed: onPressed,
      fillColor: Colors.green,
      splashColor: Colors.greenAccent,
      shape: const StadiumBorder(),
      child: new Padding(
        padding: EdgeInsets.all(10.0),
        child: new Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Icon(
              Icons.call,
              color: Colors.white,
            ),
            new SizedBox(
              width: 10.0,
            ),
            new Text(AppLocalizations.of(context).translate('contact-call'),
                maxLines: 1,
                style: TextStyle(
                  fontFamily: FONT_FAMILY,
                  fontSize: 16,
                  color: Colors.white,
                ))
          ],
        ),
      ),
    );
  }
}

/// Contact Card
///
/// Param [contactName] - [String] The name of the contact on the card
/// Param [contactPhone] - [String] The phone of the contact on the card
/// Param [onPressedRemove] - [GestureTapCallback] pressed Remove Contact action
/// Param [onPressedSmsStatus] - [GestureTapCallback] pressed Call Contact action
class ContactCard extends StatelessWidget {
  final String contactName;
  final String contactPhone;
  final GestureTapCallback onPressedRemove;
  final GestureTapCallback onPressedSmsStatus;

  ContactCard(
      {@required this.contactName,
      @required this.contactPhone,
      @required this.onPressedRemove,
      @required this.onPressedSmsStatus});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 2.0, right: 2.0, top: 1.0, bottom: 1.0),
      child: new Card(
          color: Color.fromRGBO(255, 255, 255, 0.85),
          child: new Column(
            children: <Widget>[
              new ListTile(
                title: new Text(
                  "$contactName",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: FONT_FAMILY,
                    fontSize: 18,
                  ),
                ),
                subtitle: new Text("$contactPhone",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: FONT_FAMILY,
                      fontSize: 16,
                    )),
                contentPadding:
                    EdgeInsets.only(top: 0, right: 10, left: 10, bottom: 0),
              ),
              new ButtonBar(
                alignment: MainAxisAlignment.spaceBetween,
                buttonPadding:
                    EdgeInsets.only(top: 0, right: 10, left: 10, bottom: 0),
                children: <Widget>[
                  new RemoveButton(onPressed: onPressedRemove),
                  new SmsStatus(onPressed: onPressedSmsStatus),
                ],
              )
            ],
          )),
    );
  }
}
