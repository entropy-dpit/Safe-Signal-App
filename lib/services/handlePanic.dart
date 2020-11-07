import 'package:entropy_client/homePage/saveAndReadReports.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../showToastWithMessage.dart';
import 'sendSms.dart';

/// Handle the panic calls, send SMS, add report to queue, etc
/// 
/// Author: David Pescariu @davidp-ro

String alertStatus = "uninitiated";
bool reacted = false;

/// Start initiating a [panic] event
///
/// Param (optional) [context] - [BuildContext] Context to show the dialog
/// Param [typeOfAlert] - [String] The type of the alert
///   Types:
///     ["unsafe"] -> (ex) When the bracelet was only pressed once
///     ["panic"] -> (ex) When the bracelet was pressed more than 4 times
///
/// If no [BuildContext] is given the user will not have the posibility of manually
/// overriding the alertstatus -> it WILL get automaticly sent!
///
/// How to add a new alert type:
///   [1.] -> Create a case for it in [initiatePanic]
///   [2.] -> Create a case for it in [_reactToPanic]
///   [3.] -> Profit?
///   [Note 1] Make sure to set alertStatus to "uninitiated" when done
///   [Note 2] Make sure to include in the if in .then() below a new "override"
/// if you have a new one added
void initiatePanic(String typeOfAlert, {BuildContext context}) async {
  switch (typeOfAlert) {
    case "panic":
      alertStatus = "initiated_panic";
      if (context != null) {
        showDialog(
          context: context,
          child: PanicDialog(),
        );
      }
      break;
    case "unsafe":
      alertStatus = "auto_unsafe";
      if (!reacted) _reactToPanic();
      showToastWithMessage("Sending an SMS to your contacts");
      return;
      break;
    default:
      print("Invalid typeOfAlert > $typeOfAlert in initiatePanic");
  }

  for (int secondCounter = 0; secondCounter < 10; ++secondCounter) {
    // // Skip the wait if it's only unsafe as we aren't showing any dialog
    // //to cancel it anyway:
    // if (alertStatus == "auto_unsafe") break;

    // Otherwise wait 10 seconds where the user can override the alert
    await Future.delayed(Duration(seconds: 1)).then((_) {
      /// This will continue to run even if the dialog is exited, not an issue
      ///
      /// Here we handle the [alertStatus], and react accrodingly, ie:
      /// -> Send an emergency SMS or Cancel the alert
      if (alertStatus == "override_send_panic" ||
          alertStatus == "override_cancel") {
        secondCounter = 99; // Stop looping
        if (!reacted) _reactToPanic(); // Got an override, react now!
      }
    });
  }
  switch (alertStatus) {
    case "initiated_panic":
      // No manual override occured, send automatically
      alertStatus = "auto_panic";
      break;
    default:
      break;
  }

  if (!reacted) _reactToPanic();
}

/***************************** "Private" methods ******************************/

/// React to a panic accordingly
///
/// Based on the [alertStatus] it will, for ex send an alert, a "feeling unsafe"
/// sms or cancel an alert.
void _reactToPanic() {
  reacted = true; // Avoid new calls
  print("Reacting to $alertStatus");
  switch (alertStatus) {
    case "override_send_panic":
      _sendAlert(
        notify113: true,
        typeOfMessage: "panic",
      );
      alertStatus = "uninitiated";
      break;
    case "auto_panic":
      _sendAlert(
        notify113: true,
        typeOfMessage: "panic",
      );
      alertStatus = "uninitiated";
      break;
    case "auto_unsafe":
      _sendAlert(
        typeOfMessage: "unsafe",
      );
      alertStatus = "uninitiated";
      break;
    case "override_cancel":
      alertStatus = "uninitiated";
      break;
    default:
      // Technically speaking we should *never* get here
      print("Invalid alertStatus -> $alertStatus");
      alertStatus = "uninitiated";
      break;
  }
  reacted = false; // Ready to recieve new calls
}

/// Final handler before sending an alert or message
void _sendAlert({bool notify113 = false, String typeOfMessage = "undefined"}) {
  // If we need to firstly notify EMS
  if (notify113) {
    send113Alert();
  }
  // Send sms to contacts
  handleSMSCall(typeOfMessage);
}

/// Manual override for the automatic countdown that sends the alert immediattly
///
/// Param [context] - [BuildContext] -> Dialog context to dismiss it.
void _manualOverrideSendNow(BuildContext context) {
  alertStatus = "override_send_panic";
  showToastWithMessage("Sending alert now! Help is on the way");
  Navigator.pop(context);
}

/// Manual override for the automatic countdown that cancels the alert
///
/// Param [context] - [BuildContext] -> Dialog context to dismiss it.
void _manualOverrideCancel(BuildContext context) {
  alertStatus = "override_cancel";
  showToastWithMessage("Warning: Cancelling alert!");
  Navigator.pop(context);
}

/// Dialog from where you can cancel or send "now" the alert
class PanicDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /// NOTE: Intentionally left default font, Poppins kinda breaks the dialog

    final padding = 0.28 * MediaQuery.of(context).size.height;

    return Padding(
      padding:
          EdgeInsets.only(top: padding, bottom: padding, left: 0, right: 0),
      child: AlertDialog(
        title: Center(child: Text("Panic mode activtion")),
        content: Center(
          child: Column(
            children: <Widget>[
              Text("Detected panic mode from bracelet!"),
              Text("Sending alert in 10 seconds")
            ],
          ),
        ),
        actions: <Widget>[
          Center(
            child: FloatingActionButton.extended(
              onPressed: () => _manualOverrideSendNow(context),
              label: Text(
                "Send alert now!",
                style: TextStyle(
                  fontFamily: FONT_FAMILY,
                  fontSize: 18,
                ),
              ),
              icon: Icon(Icons.call_made),
            ),
          ),
          Container(height: 5),
          Center(
            child: FloatingActionButton.extended(
              onPressed: () => _manualOverrideCancel(context),
              backgroundColor: Colors.red,
              label: Text(
                "CANCEL ALERT",
                style: TextStyle(
                  fontFamily: FONT_FAMILY,
                  fontSize: 14,
                ),
              ),
              icon: Icon(Icons.cancel),
            ),
          ),
        ],
      ),
    );
  }
}
