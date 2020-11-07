import 'package:entropy_client/api/apiCommunication.dart';
import 'package:entropy_client/homePage/saveAndReadReports.dart';
import 'package:entropy_client/models/report.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../main.dart' show AppLocalizations;

/// The Card that's shown when a report is queued for the user to interact
/// 
/// Author: David Pescariu @davidp-ro

class ReportCard extends StatefulWidget {
  ReportCard({
    @required this.reportList,
    @required this.currentIndex,
    @required this.pageSetState,
  });

  final List<Report> reportList;
  final int currentIndex;
  final Function pageSetState;

  @override
  _ReportCardState createState() => _ReportCardState();
}

class _ReportCardState extends State<ReportCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: CARD_BACKGROUND,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(
              __getTitle(widget.reportList[widget.currentIndex].type),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: FONT_FAMILY,
                fontSize: 18,
                color: Colors.black,
              ),
            ),
            subtitle: Column(
              children: <Widget>[
                Text(
                  __getSubtitle(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: FONT_FAMILY,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
                Text(
                  AppLocalizations.of(context).translate('report-text'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: FONT_FAMILY,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 8.0),
              child: Icon(Icons.announcement),
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              OutlineButton.icon(
                onPressed: () {
                  removeReport(widget.reportList[widget.currentIndex]);
                  widget.reportList.removeAt(widget.currentIndex);
                  widget.pageSetState();
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                icon:
                    const Icon(Icons.remove_circle_outline, color: Colors.red),
                label: Text(
                  AppLocalizations.of(context).translate('report-remove'),
                  style: TextStyle(
                    fontFamily: FONT_FAMILY,
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
                highlightedBorderColor: GRADIENT_START,
              ),
              OutlineButton.icon(
                onPressed: () {
                  _addReport(context);
                  removeReport(widget.reportList[widget.currentIndex]);
                  widget.reportList.removeAt(widget.currentIndex);
                  widget.pageSetState();
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                label: Text(
                  AppLocalizations.of(context).translate('report-adddetails'),
                  style: TextStyle(
                    fontFamily: FONT_FAMILY,
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
                highlightedBorderColor: GRADIENT_START,
              ),
            ],
          )
        ],
      ),
    );
  }

  String __getSubtitle() {
    if (widget.reportList[widget.currentIndex].niceAddress != null) {
      return "${widget.reportList[widget.currentIndex].niceAddress}";
    } else {
      return "Coordinates: ${widget.reportList[widget.currentIndex].lat} ${widget.reportList[widget.currentIndex].long}";
    }
  }

  /// Get a nice looking string from a marker type
  ///
  /// Param [originalType] - [String]: type recived from server
  ///
  /// Returns [String], nicely formatted
  String __getTitle(String originalTitle) {
    switch (originalTitle) {
      case ('unsafe'):
        return AppLocalizations.of(context).translate('report-unsafe');
        break;
      case ('custom'):
        return AppLocalizations.of(context).translate('report-custom');
        break;
      case ('panic'):
        return AppLocalizations.of(context).translate('report-panic');
        break;
      default:
        return "Something went wrong";
        break;
    }
  }

  /// Show a [ModalBottomSheet] to confirm what happened
  _addReport(BuildContext context) {
    String _selection;
    // Please be careful with VVV 'cause I also use theese for the API
    List<String> _types = ['Theft', 'Robbery', 'Violence', 'Unsafe'];

    /// Actually add the marker
    ///
    /// Param [selection] - [String] The selected type
    __confirmedAdd(String selection) {
      addMarkerToServer(
        widget.reportList[widget.currentIndex].lat,
        widget.reportList[widget.currentIndex].long,
        selection.toLowerCase().trim(),
        // This (^^) is dangerous, 'cause the server will accept any type but
        // the map will fail to load if the type isn't valid
        // As long as we don't take any user input it's fine (so like this, where
        // the user can only select smh from a list)
      );
    }

    showModalBottomSheet<dynamic>(
        context: context,
        isScrollControlled: false,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setModalState) {
            return Container(
                height: MediaQuery.of(context).size.height * 0.25,
                color: Colors.transparent,
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: DropdownButton<String>(
                          hint: Text(AppLocalizations.of(context)
                              .translate('report-please')),
                          value: _selection,
                          onChanged: (newVal) {
                            setModalState(() {
                              _selection = newVal;
                            });
                          },
                          items: _types.map((e) {
                            return DropdownMenuItem(
                              child: new Text(e),
                              value: e,
                            );
                          }).toList(),
                        ),
                      ),
                      RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 7,
                          color: GRADIENT_START,
                          child: Text(
                            AppLocalizations.of(context)
                                .translate('report-confirm'),
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w100,
                                fontFamily: 'Poppins'),
                          ),
                          onPressed: () => __confirmedAdd(_selection)),
                      Container(
                        height: 6,
                      ),
                      Text(
                        AppLocalizations.of(context).translate('report-help'),
                        style: TextStyle(
                          color: Color.fromRGBO(0, 0, 0, 0.8),
                          fontFamily: 'Poppins',
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ));
          });
        });
  }
}
