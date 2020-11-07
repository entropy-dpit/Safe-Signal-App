import 'package:flutter/material.dart';

/******************************** BAND CODES *********************************/
/// If you change these codes make sure you also have the right implementation
/// in [bandConnected.dart]
///
/// DO NOT CHANGE theese if there is no HARDWARE side implementation for them!
const FEELING_UNSAFE = 0x01;
const USER_ACTION = 0x02;
const PANIC_MODE = 0x04; // Used like this: >= PANIC_MODE !

/***************************** SMS SENDING DELAY *****************************/
/// How long to wait before accepting new SMS requests
const SMS_SENDING_DELAY = 20; // In SECONDS! Should be a multiple of 5!

/************************** SHARED PREFRENCES KEYS **************************/
/// Unless you have a very good reason DO NOT MODIFY theese values, then check all
/// the [SharedPrefrences] functions and make sure everything is still fine, it
/// should be but just to be safe do not modify theese values!
const KEY_ISBANDPAIRED = "isBandPaired";
const KEY_BANDMAC = "pairedBandMac";
const KEY_ISTESTMODEACTIVE = "isTestModeActive";

/***************************** STYLING AND LINKS *****************************/
/// Official Links:
const WEBSITE_LINK =
    'https://www.youtube.com/watch?v=dQw4w9WgXcQ'; //FIXME: Replace
const HOW_TO_PAIR_LINK = "https://www.example.com"; //FIXME: Replace
const FAQ_LINK = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'; //FIXME: Replace
const MAILTO_LINK = 'mailto:safe.signal.entropy@gmail.com?subject=SUPPORT';
const LEGAL_LINK = 'https://github.com/entropy-dpit/entropy-legal';
const DPIT_LINK = 'https://www.facebook.com/descoperatipasiuneainit/';
// Socaials:
const FACEBOOK_LINK = 'https://www.facebook.com/Safe-Signal-110487760734282/';
const INSTAGRAM_LINK = 'https://www.instagram.com/safe_signal/';
const PLAYSTORE_LINK = 'https://play.google.com/store';

/// Gradient:
const GRADIENT_START = Color.fromARGB(255, 251, 139, 36);
const GRADIENT_END = Color.fromARGB(255, 227, 100, 20);

/// Transparent white:
const CARD_BACKGROUND = Color.fromRGBO(255, 255, 255, 0.9);

/// Font:
const FONT_FAMILY = "Poppins";

/******************************** END OF FILE ********************************/
