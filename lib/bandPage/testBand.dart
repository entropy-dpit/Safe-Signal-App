import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';

/// This is so buggy that I don't even know what I messed up so badly.
/// Just leave this file alone, it might (will...) leak memory when going back
/// to the previous page.
/// 
/// Author: David Pescariu @davidp-ro

/* ------------------ SHARED PREFRENCES ------------------ */

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

class TestBandScreen extends StatefulWidget {
  @override
  _TestBandScreenState createState() => _TestBandScreenState();
}

class _TestBandScreenState extends State<TestBandScreen> {
  bool hasRecievedData = false;
  String deviceMac = "";

  // @override
  // void dispose() {
  //   FlutterBlue.instance.stopScan();
  //   debugPrint("Disposing testBand");
  //   super.dispose();
  // }

  @override
  void initState() {
    __inTestMode() async {
      await setTestModeActive(true);
    }

    // __stopScan() async {
    //   await FlutterBlue.instance.stopScan();
    // }

    // __stopScan();
    __inTestMode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // FlutterBlue.instance.isScanning.listen((resp) {
    //   if (resp == false) {
    //     FlutterBlue.instance.startScan(allowDuplicates: true);
    //     debugPrint("Starting scanning [in testBand]...");
    //   }
    // });

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
              onPressed: () => Navigator.pop(context, "success"),
            ),
            title: new Text(
              "Test your Safe Signal Band",
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

              /// Instructions on how to test:
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Image(
                  image: AssetImage('assets/images/how_to_test.png'),
                  width: 512,
                ),
              ),

              /// Loading indicator
              new Container(height: 10),
              new FutureBuilder(
                future: _checkForActiveBand(),
                initialData: false,
                builder: (context, snapshot) {
                  if (!hasRecievedData) {
                    return CircularProgressIndicator(
                      value: null,
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Colors.white),
                    );
                  } else {
                    return Icon(
                      Icons.done,
                      color: Colors.green,
                      size: 48,
                    );
                  }
                },
              ),
              new Container(height: 0.25 * MediaQuery.of(context).size.height),
              new FlatButton(
                onPressed: () => _showDebugInfo(context),
                child: Text("Show advanced info"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Check to see if anything was pressed on the band
  Future<bool> _checkForActiveBand() async {
    if (deviceMac == "") {
      deviceMac += await getBandMacAddress();
    }

    if (hasRecievedData) return true;

    FlutterBlue.instance.scanResults.forEach((results) {
      results.forEach((result) {
        if (result.device.id.toString() == deviceMac) {
          /// The device is a band:
          if (result.advertisementData.manufacturerData.values
                  .elementAt(0)[0] !=
              0) {
            // <-- See this, <3 dartfmt, also see the arrow? Our lord and saviour dartfmt won't allow the comment to be on the same line as >0) {< so now it just looks like it's pointing to nowhere. I just,... why... at least it will allow this comment to reach collumn 273. Dear dartfmt, get your head out of your own ass and start formatiing things like a normal person not a dyslexic 5yo with a learning disability. Leave my ifs on the same line and don't ever spread a function call on multiple lines you dim-witted thick as pig shit baboon child. With love, David Pescariu and Raul Popa
            /// Explanation:
            /// manufacturerData is a map, and we need the first value from the map
            /// which is a List. From the list we need once again the first element.
            hasRecievedData = true;
            print("Band works!");
            setState(() {
              // Refresh
            });
            return true;
          }
        }
        return false;
      });
    });

    return false;
  }

  _showDebugInfo(BuildContext context) async {
    String _deviceMac = await getBandMacAddress();

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    String textDump =
        "If you need help do not hesitate to contact us, and please include a screenshot of the info bellow:\n"
        "---\n***BEGIN_DATA***\n---"
        "\nPAIRED_MAC_ADDR: $_deviceMac\nHAS_RCV_DATA: $hasRecievedData\n---"
        "\nVERSION: $version\nBUILD: $buildNumber\n---"
        "\n***END_DATA***";

    showDialog(
      context: context,
      child: Padding(
        padding: const EdgeInsets.only(top: 100, bottom: 100),
        child: AlertDialog(
          title: Text("Advanced Info"),
          content: Center(
            child: Text(textDump),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
