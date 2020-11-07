import 'package:entropy_client/loadingPage.dart';
import 'package:entropy_client/models/report.dart';
import 'package:entropy_client/reportsPage/reportCard.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import '../main.dart' show AppLocalizations;

/// Will throw a [setState() or markNeedsBuild() called during build.], too bad
/// just ignore it, it's finee
///
/// Explanation:
///   It calls a setState() after .pop() when the page is no longer in use
/// 
/// It really is fine, David Pescariu @davidp-ro

class ReportsPage extends StatefulWidget {
  ReportsPage({
    @required this.reports,
    @required this.basicallyJustAsetState,
  });

  final List<Report> reports;
  final GestureTapCallback basicallyJustAsetState;

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  bool built = false;

  @override
  Widget build(BuildContext context) {
    if (widget.reports.length == 0) {
      Navigator.pop(context);
      return new LoadingPage();
    } else // I wanted to have the return on the same row, dartfmt does not...
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
              onPressed: () => Navigator.pop(context, "update"),
            ),
            title: new Text(
              AppLocalizations.of(context).translate('report-title'),
              style: TextStyle(
                fontFamily: FONT_FAMILY,
                fontWeight: FontWeight.normal,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
          ),
          body: RefreshIndicator(
            color: GRADIENT_START,
            backgroundColor: CARD_BACKGROUND,
            onRefresh: () {
              // Will make sure to remove reports that have been dealt withs
              setState(() {});
              return Future.delayed(Duration(milliseconds: 200));
            },
            child: new Column(
              children: <Widget>[
                new Expanded(
                  child: new ListView.builder(
                    itemCount: widget.reports.length,
                    itemBuilder: _itemBuilder,
                  ),
                )
              ],
            ),
          ),
        ),
      );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    if (!built) {
      if (index == widget.reports.length) {
        built = true;
      } else {
        return new ReportCard(
          reportList: widget.reports,
          currentIndex: index,
          pageSetState: widget.basicallyJustAsetState,
        );
      }
    }
  }
}
