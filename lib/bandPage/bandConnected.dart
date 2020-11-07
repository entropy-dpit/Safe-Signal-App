/// Page shown when a band is paired
///
/// Show related widgets for when the band is connected and deals with BT comms
///
/// Disclaimer: Our Bluetooth Codebase is a mess, please don't use it if it's
/// your first project, 'cause it definitly was ours and well, see for yourself :)
///
/// Author: David Pescariu

import 'dart:async';
import 'package:entropy_client/bandPage/testBand.dart';
import 'package:entropy_client/bandPage/bandConnectedWidgets.dart';
import 'package:entropy_client/services/handlePanic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../main.dart' show AppLocalizations;

/* ------------------ SHARED PREFRENCES ------------------ */

/// All theese get the correct [SharedPrefrences], self-explanatory

Future<bool> setIsBandPaired(bool newValue) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.setBool(KEY_ISBANDPAIRED, newValue);
}

Future<bool> setBandMacAddress(String macAdress) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.setString(KEY_BANDMAC, macAdress);
}

Future<String> getBandMacAddress() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.getString(KEY_BANDMAC);
}

Future<bool> setTestModeActive(bool state) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.setBool(KEY_ISTESTMODEACTIVE, state);
}

Future<bool> getTestModeActive() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.getBool(KEY_ISTESTMODEACTIVE);
}

/* ---------------- ^ SHARED PREFRENCES ^ ---------------- */

class BandConnected extends StatefulWidget {
  @override
  _BandConnectedState createState() => _BandConnectedState();
}

class _BandConnectedState extends State<BandConnected> {
  bool stop = false; // To stop the freaking timer
  String deviceMac = ""; // Band mac
  bool reacted = false; // To prevent 200 calls at once

  @override
  void initState() {
    // __stopScan() async {
    //   await FlutterBlue.instance.stopScan();
    // }
    __disableTestMode() async {
      await setTestModeActive(false);
    }

    // __stopScan();
    __disableTestMode();
    getBandMacAddress().then((macAddr) {
      deviceMac += macAddr;
    });

    super.initState();
  }

  /// Called when the user goes back
  ///
  /// Used to cancel the Timer
  @override
  void dispose() {
    stop = true;
    print("Disposing [bandConnected]");
    super.dispose();
  }

  // This also prevents 200 calls at once (just reacted wasn't enough)
  int howManyCalls = 0;

  /// Check to see if the band is transmitting any sort of alert
  ///
  /// MUST be run periodically, ie: In a [Timer()]
  _checkNewData() async {
    if (deviceMac == "") return; // The MAC wan't recieved yet, quit

    try {
      await FlutterBlue.instance.startScan(allowDuplicates: false);
      debugPrint("Starting scanning [in bandConnected]...");
    } catch (e) {
      print("Already scanning");
    }

    await Future.delayed(
      Duration(milliseconds: 1000),
    ); // Scan for 500ms to get some results
    FlutterBlue.instance
        .stopScan(); // Stop scanning. Sometimes it wont stop... too bad

    FlutterBlue.instance.scanResults.forEach((results) {
      results.forEach((result) async {
        if (result.device.id.toString() == deviceMac) {
          // The device is a band:
          int recvData =
              result.advertisementData.manufacturerData.values.elementAt(0)[0];

          print("DATA :: $recvData");

          // Opted for if's because switch expressions must be constant and
          // >= PANIC_MODE isn't exactly constant
          if (recvData == FEELING_UNSAFE && !reacted) {
            ++howManyCalls;
            if (howManyCalls > 1) return;
            reacted = true;
            initiatePanic("unsafe");
            await Future.delayed(Duration(seconds: 5)).then((_) {
              howManyCalls = 0;
            });
            await FlutterBlue.instance.scanResults.drain();
            reacted = false;
          } else if (recvData == USER_ACTION && !reacted) {
            throw new UnimplementedError('Custom user action not implemented.');
          } else if (recvData >= PANIC_MODE && !reacted) {
            ++howManyCalls;
            if (howManyCalls > 1) return;
            reacted = true;
            initiatePanic("panic");
            await Future.delayed(Duration(seconds: 5)).then((_) {
              howManyCalls = 0;
            });
            await FlutterBlue.instance.scanResults.drain();
            reacted = false;
          } else {
            FlutterBlue.instance.scanResults.drain();
            reacted = false;
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    FlutterBlue.instance.stopScan();

    /// Wait for 5 secs so you (well we during the demo) have time to go to the
    /// test page before it starts scanning and literally ruins everything
    Timer.periodic(Duration(milliseconds: 1000), (Timer t) async {
      if (stop) {
        t.cancel();
      } else {
        if (await getTestModeActive() == true) {
          debugPrint("Is in test mode, should not scan!");
        } else {
          await _checkNewData();
        }
      }
    });

    return new Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [GRADIENT_START, GRADIENT_END],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.5, 0.5),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp),
      ),
      child: new Scaffold(
        backgroundColor: Colors.transparent,
        appBar: new AppBar(
            leading: new IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: new Text(
              AppLocalizations.of(context).translate('bt-c-title'),
              style: TextStyle(
                fontFamily: FONT_FAMILY,
                fontWeight: FontWeight.normal,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent),
        body: SingleChildScrollView(
          child: new Column(
            children: <Widget>[
              new Container(height: 10),
              new DisconnectCard(
                onPressed: () => _handleDisconnect(context),
              ),
              new Container(height: 2),
              new TestCard(
                onPressed: () async {
                  stop = true; // Stop timer
                  final resp = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TestBandScreen()));
                  if (resp == "success") {
                    /// Will only work if the user quits using the top [AppBar] button
                    ///
                    /// So if they go back using the phone button the scan will not start,
                    /// so they need to go back once more to the [mainPage] for the scan
                    /// to start again... too bad
                    ///
                    /// So, uhm, use the top bottom during the demo?
                    await setTestModeActive(false);
                    setState(() {
                      stop = false;
                    });
                  }
                },
              ),
              new Container(height: 7),
              new BuyBand(onTapImage: () async {
                print("::: Entering manual activation! :::");
                stop = true;
                await Future.delayed(Duration(seconds: 1));
                const MANUAL_PANIC_MODE = "unsafe";
                print("::: Stopped scanning :::");
                print("::: Activating panic mode -> $MANUAL_PANIC_MODE! :::");
                initiatePanic(MANUAL_PANIC_MODE);
              }),
              new Container(height: 2),
              new Support(),
              new Container(height: 2),
              new Socials(),
              new Container(height: 2),
              new Rate(),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle disconnecting from the band
  ///
  /// Param [context] - [BuildContext] To quit the connected page
  _handleDisconnect(BuildContext context) {
    setBandMacAddress("");
    setIsBandPaired(false);
    // Sending update will trigger a setState() in HomePage
    Navigator.pop(context, "update");
  }
}

// <3 Valve engineers for the too bad
