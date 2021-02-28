/// This is the main entry point for the prisma.ai App, formerly known as 
/// Safe Signal App - we are currently undergoing a rebranding.
/// 
/// (C) prisma.ai 2021 or respective owners of libraries
///
/// * Public Source Release - Released 11 Nov 2020 | Updated Feb 2021 * 
///
/// ----------------------------------------------------------------------------
///
/// prisma.ai Team:
///   David Pescariu - Co-founder & Developer
///   Raul Popa - Co-founder & Developer & Designer
///
/// Safe-Signal OG Team:
///   David Pescariu - Most Codebase
///   Raul Popa - Home, Map and About/Intro pages
///   Ioana Gabor - Backend zone generation
///   Dorin Cuibus - Some map work

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'homePage/introPage.dart';

void main() {
  runApp(SafeSignalClient());
}

// ----------------------------------------------------------------------------

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // Helper method to keep the code in the widgets concise
  // Localizations are accessed using an InheritedWidget "of" syntax
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Map<String, String> _localizedStrings;

  Future<bool> load() async {
    // Load the language JSON file from the "lang" folder
    String jsonString =
        await rootBundle.loadString('i18n/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  // This method will be called from every widget which needs a localized text
  String translate(String key) {
    return _localizedStrings[key];
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  // This delegate instance will never change (it doesn't even have fields!)
  // It can provide a constant constructor.
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Include all of your supported language codes here
    return ['en', 'ro', 'de'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // AppLocalizations class is where the JSON loading actually runs
    AppLocalizations localizations = new AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// ----------------------------------------------------------------------------

class SafeSignalClient extends StatefulWidget {
  @override
  _SafeSignalClientState createState() => _SafeSignalClientState();
}

class _SafeSignalClientState extends State<SafeSignalClient> {
  final _title = "Safe Signal";

  @override
  Widget build(BuildContext context) {
    /// Lock the app in portrait mode:
    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp],
    );

    return new MaterialApp(
      supportedLocales: [
        Locale('en', 'UK'),
        Locale('ro', 'RO'),
        Locale('de', 'DE'),
      ],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      title: _title,
      debugShowCheckedModeBanner: false,
      color: Color.fromARGB(255, 74, 49, 102),
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 251, 139, 36),
        scaffoldBackgroundColor: Color.fromARGB(255, 227, 100, 20),
      ),
      home: new IntroScreen(),
    );
  }
}
