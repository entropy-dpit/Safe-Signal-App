import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../constants.dart';
import '../main.dart' show AppLocalizations;

/// The card tile that shows the BT result
/// 
/// Author: David Pescariu @davidp-ro

// ignore: must_be_immutable
class ScanResultTile extends StatelessWidget {
  ScanResultTile({this.result, this.onTapConnect});

  final ScanResult result;
  final VoidCallback onTapConnect;

  bool isEntropyBand = false;

  String niceMfcDataSubtitle(ScanResult _result, BuildContext context) {
    try {
      List<int> _data =
          result.advertisementData.manufacturerData.values.elementAt(0);

      if (_data[0] == 0xff) {
        return AppLocalizations.of(context).translate('bt-d-pairing');
      } else {
        return AppLocalizations.of(context).translate('bt-d-notpairing');
      }
    } catch (e) {
      print(e);
      return '';
    }
  }

  Widget _buildTitle(BuildContext context) {
    final String mfcDataSubtitle = niceMfcDataSubtitle(result, context);

    if (result.device.name.length > 0) {
      if (result.device.name == "Safe Signal Band") {
        isEntropyBand = true;
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              result.device.name,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              mfcDataSubtitle,
              style: Theme.of(context).textTheme.caption.copyWith(
                    fontFamily: FONT_FAMILY,
                  ),
              overflow: TextOverflow.ellipsis,
            )
          ],
        );
      } else {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              AppLocalizations.of(context).translate('bt-d-generic'),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              result.device.name,
              style: Theme.of(context).textTheme.caption,
            )
          ],
        );
      }
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AppLocalizations.of(context).translate('bt-d-generic'),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            result.device.id.toString(),
            style: Theme.of(context).textTheme.caption,
          )
        ],
      );
    }
  }

  String getNiceHexArray(List<int> bytes) {
    return '[${bytes.map((i) => i.toRadixString(16).padLeft(2, '0')).join(', ')}]'
        .toUpperCase();
  }

  String getNiceManufacturerData(Map<int, List<int>> data) {
    if (data.isEmpty) {
      return null;
    }
    List<String> res = [];
    data.forEach((id, bytes) {
      res.add(
          '${id.toRadixString(16).toUpperCase()}: ${getNiceHexArray(bytes)}');
    });
    return res.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    Widget _title = _buildTitle(context);

    if (isEntropyBand) {
      return Card(
        color: CARD_BACKGROUND,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.adjust),
              title: _title,
              trailing: OutlineButton.icon(
                onPressed: onTapConnect,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                icon: const Icon(Icons.near_me, color: Colors.blueAccent),
                label: Text(
                  AppLocalizations.of(context).translate('bt-d-connect'),
                  style: TextStyle(fontFamily: FONT_FAMILY, fontSize: 12),
                ),
                highlightedBorderColor: GRADIENT_START,
              ),
              // trailing: SizedBox(
              //   width: 90,
              //   height: 40,
              //   child:
              // ),
            ),
          ],
        ),
      );
    } else {
      return Card(
        color: Color.fromRGBO(255, 255, 255, 0.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.cancel),
              title: _title,
            ),
          ],
        ),
      );
    }
  }
}
