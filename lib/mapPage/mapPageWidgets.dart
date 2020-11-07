import 'package:flutter/material.dart';
import '../constants.dart';
import '../main.dart' show AppLocalizations;

/// Widgets for the map page
/// 
/// Authors:
///   David Pescariu @davidp-ro
///   Raul Popa @Raul-Popa

const HEROTAG_BACK = 1;
const HEROTAG_ADD = 2;
const HEROTAG_LOCALIZE = 3;

class BackButton extends StatelessWidget {
  BackButton({@required this.onPressed});

  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return new FloatingActionButton(
      heroTag: HEROTAG_BACK,
      onPressed: onPressed,
      child: Icon(Icons.arrow_back),
      backgroundColor: Color.fromRGBO(127, 127, 127, 0.8),
    );
  }
}

class AddButton extends StatelessWidget {
  AddButton({@required this.onPressed});

  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: HEROTAG_ADD,
      onPressed: onPressed,
      label: Text(
        AppLocalizations.of(context).translate('map-reportbtn'),
        style: TextStyle(
          fontFamily: FONT_FAMILY,
        ),
      ),
      icon: Icon(Icons.add),
      backgroundColor: Color.fromRGBO(137, 196, 73, 0.8),
    );
  }
}

class LocalizeButton extends StatelessWidget {
  LocalizeButton({@required this.onPressed});

  final GestureTapCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 3,
      onPressed: onPressed,
      child: Icon(Icons.my_location),
      backgroundColor: Color.fromRGBO(127, 127, 127, 0.8),
    );
  }
}
