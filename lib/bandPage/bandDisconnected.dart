import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'scanResultTile.dart';
import '../constants.dart';
import '../main.dart' show AppLocalizations;

/// Band not connected page
/// 
/// Author: David Pescariu @davidp-ro

_launch(String linkToLaunch) async {
  if (await canLaunch(linkToLaunch)) {
    await launch(linkToLaunch);
  } else {
    throw 'Could not launch $linkToLaunch';
  }
}

Future<bool> setIsBandPaired(bool newValue) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.setBool(KEY_ISBANDPAIRED, newValue);
}

Future<bool> setBandMacAddress(String macAdress) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  return prefs.setString(KEY_BANDMAC, macAdress);
}

class BandDisconnected extends StatefulWidget {
  @override
  _BandDisconnectedState createState() => _BandDisconnectedState();
}

class _BandDisconnectedState extends State<BandDisconnected> {
  @override
  Widget build(BuildContext context) {
    return new StreamBuilder(
      stream: FlutterBlue.instance.state,
      initialData: BluetoothState.unknown,
      builder: (context, snapshot) {
        final state = snapshot.data;
        if (state == BluetoothState.on) {
          return FindBands();
        }
        return BluetoothOff(state: state);
      },
    );
  }
}

class FindBands extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
              AppLocalizations.of(context).translate('bt-d-title'),
              style: TextStyle(
                  fontFamily: FONT_FAMILY, fontWeight: FontWeight.normal),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent),
        body: new ListView(
          children: <Widget>[
            Card(
              color: CARD_BACKGROUND,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ListTile(
                    title: Center(
                      child: Text(
                        AppLocalizations.of(context).translate('bt-d-how'),
                        style: TextStyle(
                            fontSize: 18,
                            fontFamily: FONT_FAMILY,
                            fontWeight: FontWeight.normal),
                      ),
                    ),
                    subtitle: Column(
                      children: <Widget>[
                        const Image(
                          image: AssetImage("assets/images/how_to_pair.png"),
                          height: 120,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              AppLocalizations.of(context)
                                  .translate('bt-d-text'),
                              style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: FONT_FAMILY,
                                  fontWeight: FontWeight.normal),
                            ),
                            Container(
                                width: (5 * MediaQuery.of(context).size.width) /
                                    100),
                            OutlineButton.icon(
                              onPressed: () => _launch(HOW_TO_PAIR_LINK),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              icon: const Icon(Icons.info_outline),
                              label: Text(
                                AppLocalizations.of(context)
                                    .translate('bt-d-btn'),
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: FONT_FAMILY,
                                    fontWeight: FontWeight.normal),
                              ),
                              highlightedBorderColor: GRADIENT_START,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            StreamBuilder<List<ScanResult>>(
              stream: FlutterBlue.instance.scanResults,
              initialData: [],
              builder: (context, snapshot) => Column(
                children: snapshot.data
                    .map((result) => ScanResultTile(
                          result: result,
                          onTapConnect: () => _bindBand(context, result),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
        floatingActionButton: StreamBuilder(
          stream: FlutterBlue.instance.isScanning,
          initialData: false,
          builder: (context, snapshot) {
            if (snapshot.data) {
              return FloatingActionButton(
                child: const Icon(Icons.stop),
                onPressed: () => FlutterBlue.instance.stopScan(),
                //label: const Text("Stop Searching"),
                backgroundColor: Colors.red,
              );
            } else {
              return FloatingActionButton(
                child: const Icon(Icons.search),
                onPressed: () => FlutterBlue.instance.startScan(),
                //label: const Text("Search"),
                backgroundColor: GRADIENT_START,
                tooltip: "Search for bands",
              );
            }
          },
        ),
      ),
    );
  }

  /// Bind a band as the users current band
  /// 
  /// Param [context] - [BuildContext] current ctx, so we can pop it
  /// Param [_result] - [ScanResult] the band "result"
  _bindBand(BuildContext context, ScanResult _result) {
    String macAddress = _result.device.id.toString();
    if (macAddress.startsWith("00:A0:50")) { // Cypress MAC
      print(macAddress);
      setIsBandPaired(true);
      setBandMacAddress(macAddress);
      Navigator.pop(context, "update");
    } else {
      print("Not band");
    }
  }
}

class BluetoothOff extends StatelessWidget {
  BluetoothOff({this.state});

  final BluetoothState state;

  String _showMessageForState(BluetoothState _state) {
    switch (_state) {
      case BluetoothState.off:
        return "Please turn on Bluetooth!";
        break;
      case BluetoothState.turningOn:
        return "Bluetooth is turning on";
        break;
      case BluetoothState.unauthorized:
        return "The required permissions weren't given!";
        break;
      default:
        return "Something went wrong, try re-installing";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [GRADIENT_START, GRADIENT_END],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.5, 0.5),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white,
            ),
            Text(_showMessageForState(state),
                style: Theme.of(context).primaryTextTheme.subtitle1.copyWith(
                      color: Colors.white,
                      fontFamily: FONT_FAMILY,
                      fontSize: 18,
                    )),
          ],
        ),
      ),
    );
  }
}
