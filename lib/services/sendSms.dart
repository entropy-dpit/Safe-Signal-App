import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:entropy_client/constants.dart';
import 'package:entropy_client/homePage/saveAndReadReports.dart';
import 'package:entropy_client/models/report.dart';
import 'package:http/http.dart' as http;
import 'package:sms_maintained/sms.dart';
import 'package:entropy_client/mapPage/mapPage.dart';
import 'package:entropy_client/showToastWithMessage.dart';
import 'package:entropy_client/contactPage/contactPage.dart';

/// Handle sending SMSs
/// 
/// Author: David Pescariu @davidp-ro

/// Handle the 113 SMS
Future<void> send113Alert() async {
  /* async not needed but it better ilustrates a real situation */
  print("[!MOCK!] ~Would notify 113~");
}

/// To prevent new calls to send SMS
bool acceptNew = true;

/// Handle all other types of SMS other than 113
///
/// Param [typeOfMessage] - [String] The type of the message
///   Types:
///     ["test"] -> Send a test sms
///     ["unsafe"] -> Send a sms that contains ("Is feeling unsafe at <loc>")
///     ["panic"] -> Send a full alert sms ("Alert at <time> at <loc>")
Future<void> handleSMSCall(String typeOfMessage) async {
  DateTime currentTime = new DateTime.now();
  DateTime howLongShouldWait = currentTime.add(
    Duration(seconds: SMS_SENDING_DELAY), // Should be a multiple of 5!
  );
  void __startDelayTimer() {
    /// Start a timer to disallow new calls to be made to avoid sending "double" SMSs
    ///
    ///  Will wait [howLongShouldWait] starting [currentTime]
    /// [SMS_SENDING_DELAY] should be a multiple of 5 mostly to make sense, because
    /// it only checks is [.isAfter()] every 5 seconds
    Timer.periodic(Duration(seconds: 5), (timer) {
      currentTime = DateTime.now(); // Get new time

      if (currentTime.isAfter(howLongShouldWait)) {
        acceptNew = true;
        timer.cancel();
      }
    });
  }

  if (acceptNew) {
    acceptNew = false;
    __startDelayTimer();

    switch (typeOfMessage) {
      case "test":
        _sendTestSms();
        break;
      case "unsafe":
        _sendSms("unsafe");
        //print("[SMS] Mock send");
        break;
      case "panic":
        _sendSms("panic");
        break;
      default:
    }
  }
}

/***************************** "Private" methods ******************************/

/// Check if an internet connection can be established
///
/// Using [example.com] because it is accessible 24/7 from anywhere
///
/// Returns [bool]
Future<bool> _connected() async {
  try {
    final result = await InternetAddress.lookup('example.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  } on SocketException catch (_) {
    return false;
  }
}

const GEOCODING_API_KEY = "GOOGLE_API_KEY";

/// If we are connected to the internet, get a pretty address
///
/// Using the geocode API from Google - reverse geocode, we really should cache
/// the results, see the note at the start of the file
///
/// If the API result is successful we return a [Map] like {ADDRESS:pretty_addr}
/// If it failed we just return the normal coords again
///
/// TODO: Maybe check for connection here to avoid redundant stuff
///
/// Param [_coords] - [Map] of [String]-[String] - The lat/long (present loc.)
///
/// Returns [Map] of [String]-[String] - with the pretty address (or lat/long)
Future<Map<String, String>> _getAddress(Map<String, String> _coords) async {
  // The actual coords
  String _lat = _coords.keys.elementAt(0);
  String _long = _coords.values.elementAt(0);
  print(_lat.toString() + "::::" + _long);
  // API Link
  final url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=" +
      _lat +
      "," +
      _long +
      "&key=" +
      GEOCODING_API_KEY;

  http.Response response = await http.get(url);
  if (response.statusCode == 200) {
    var receivedJson = json.decode(response.body);
    var results = receivedJson["results"];
    // type of results -> List<dynamic>
    if (results != null) {
      // The first result is the one we care about
      // TODO: Check for fails (len of results == 0?)
      var firstResult = results[0];
      var address = firstResult["formatted_address"];
      // Got the address, return it
      return {'ADDRESS': address.toString()};
    } else {
      // Failed so return normal coords
      return _coords;
    }
  } else {
    // Failed so return normal coords
    return _coords;
  }
}

/// Call to send an sms to all the saved contacts
Future<void> _sendSms(String typeOfMessage) async {
  var contacts = await exportContacts();
  var coords;
  Map<String, String> alwaysRawCoords;
  bool isConected = await _connected();

  if (isConected) {
    // Send the address (pretty)
    var _location = await exportCurrentPosition();
    alwaysRawCoords = _location;
    coords = await _getAddress(_location);
  } else {
    // No internet connection so send lat/long only
    coords = await exportCurrentPosition();
    alwaysRawCoords = coords;
  }

  if (contacts.length != 0 && coords.length != 0) {
    contacts.values.forEach((contact) async {
      if (contact.substring(0, 2) == 'To') {
        // Ignore the demo contact:
        showToastWithMessage("SMS not sent - demo contact");
      } else {
        __sendSms(typeOfMessage, contact, coords);
        var niceAddress = isConected ? coords.values.elementAt(0) : null;
        await appendReport(Report(
          double.parse(alwaysRawCoords.keys.elementAt(0)),
          double.parse(alwaysRawCoords.values.elementAt(0)),
          typeOfMessage,
          niceAddress,
        ));
      }
    });
  } else {
    /// FIXME: Sometimes when you first start the app it will not get the contacts
    /// I have no freaking idea why, cause [exportContacts] should call to get contacts
    /// from the save file. Honestly, too bad... FOR THE DEMO:
    /// ->> Firstly enter the [contactsPage] before sending a sms <<-
    contacts.length == 0
        ? showToastWithMessage("Cannot send message! No contacts available")
        : showToastWithMessage("Cannot send message! Couldn't get location");
  }
}

/// Send a "test" sms
Future<void> _sendTestSms() async {
  if (contacts.length != 0) {
    contacts.values.forEach((contact) {
      if (contact.substring(0, 2) == 'To') {
        // Ignore the demo contact:
        showToastWithMessage("SMS not sent - demo contact");
      } else
        __sendTestSms(contact);
    });
  } else {
    // FIXME: Sometimes when you first start the app it will not get the contacts
    contacts.length == 0
        ? showToastWithMessage("Cannot send message! No contacts available")
        : showToastWithMessage("Cannot send message! Couldn't get location");
  }
}

/// Send the alert sms
///
/// Param [contact] - [String] The contact that the message is sent to
/// Param [coords] - [Map] - [String] For the message coordinates (lat/long)
///
/// Returns [int] - 0 = Successful | -1 = Fail
void __sendSms(
    String typeOfMessage, String contact, Map<String, String> coords) async {
  String _lat = coords.keys.elementAt(0);
  String _long = coords.values.elementAt(0);

  String _hour = DateTime.now().hour >= 10
      ? DateTime.now().hour.toString() // 10:45
      : "0" + DateTime.now().hour.toString(); // 09:45

  String _minute = DateTime.now().minute >= 10
      ? DateTime.now().minute.toString() // 11:45
      : "0" + DateTime.now().minute.toString(); // 11:05

  String _message = "";

  switch (typeOfMessage) {
    case "unsafe":
      _message = "Is feeling unsafe ";
      // Append the correct location
      if (_lat == "ADDRESS") {
        // Append pretty address
        _message += "at $_long";
      } else {
        // Append lat/long
        _message += "at lat:$_lat long:$_long";
      }
      break;
    case "panic":
      _message = "Alert at $_hour:$_minute ";
      // Append the correct location
      if (_lat == "ADDRESS") {
        // Append pretty address
        _message += "at $_long";
      } else {
        // Append lat/long
        _message += "at lat:$_lat long:$_long";
      }
      break;
    default:
      print("Wrong arg ::_sendSms -> typeOfMessage: $typeOfMessage");
      break;
  }

  SmsSender smsSender = new SmsSender();
  SmsMessage sms = new SmsMessage(contact, _message.trim());
  smsSender.sendSms(sms);
  print(_message);

  sms.onStateChanged.listen((event) {
    if (event == SmsMessageState.Sent) {
      showToastWithMessage("SMS Sent Successfully");
    } else if (event == SmsMessageState.Fail) {
      showToastWithMessage("Fail - SMS Not Sent!");
    }
  });
}

/// Send the "test" sms
///
/// Param [contact] - [String] The contact that the message is sent to
void __sendTestSms(String contact) async {
  String _message =
      "This is a test of the Safe Signal automated sms sending system, the contact that send you this, chose you as a close contact";

  SmsSender smsSender = new SmsSender();
  SmsMessage sms = new SmsMessage(contact, _message.trim());
  smsSender.sendSms(sms);
  print(_message);

  sms.onStateChanged.listen((event) {
    if (event == SmsMessageState.Sent) {
      showToastWithMessage("Test SMS Sent Successfully");
    } else if (event == SmsMessageState.Fail) {
      showToastWithMessage("Fail - SMS Not Sent!");
    }
  });
}
