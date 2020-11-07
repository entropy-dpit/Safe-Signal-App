import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' show Position;
import 'package:flutter/services.dart' show rootBundle;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'mapPageWidgets.dart' as widgets;
import 'apiConnector.dart';
import 'package:entropy_client/constants.dart';
import 'dart:ui';
import '../main.dart' show AppLocalizations;

/// Main [Google Map] implementation
/// 
/// Authors:
///   David Pescariu @davidp-ro
///   Raul Popa @Raul-Popa
///   Dorin Cuibus @Dorin07

class GoogleMapPage extends StatefulWidget {
  GoogleMapPage({
    @required this.mapStyle,
    @required this.currentPosition,
    @required this.markers,
    @required this.polygons,
  });
  final String mapStyle;
  final Position currentPosition;
  final Map<MarkerId, Marker> markers;
  final Map<PolygonId, Polygon> polygons;

  @override
  _GoogleMapPageState createState() => _GoogleMapPageState(
        mapStyle: mapStyle,
        currentPosition: currentPosition,
        markers: markers,
        polygons: polygons,
      );
}

class _GoogleMapPageState extends State<GoogleMapPage> {
  _GoogleMapPageState({
    @required this.mapStyle,
    @required this.currentPosition,
    @required this.markers,
    @required this.polygons,
  });
  final String mapStyle;
  final Position currentPosition;
  final Map<MarkerId, Marker> markers;
  final Map<PolygonId, Polygon> polygons;
  GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.setMapStyle(mapStyle);
  }

  String _typeToAdd;
  String _selection;
  bool _addMode = false;

  @override
  Widget build(BuildContext context) {
    List<String> _types = ['Theft', 'Robbery', 'Violence', 'Unsafe'];
    return Stack(
      children: <Widget>[
        Positioned(
          child: GoogleMap(
            // Set options:
            onMapCreated: _onMapCreated, // Ran after map initialization
            mapToolbarEnabled: false, // Don't show the 'get directions' buttons
            zoomControlsEnabled: false, // Don't show the zoom buttons
            myLocationEnabled: true, // Show blue dot
            myLocationButtonEnabled: false, // Do not show location button
            compassEnabled: false, // Do not show compass in top left corner
            onTap: _handleAdd,
            initialCameraPosition: CameraPosition(
              target: LatLng(
                // Center screen on current position
                currentPosition.latitude,
                currentPosition.longitude,
              ),
              zoom: 14.0,
            ),
            markers: Set<Marker>.of(markers.values), // Put markers on map
            polygons: Set<Polygon>.of(polygons.values),
          ),
        ),
        Positioned(
          top: 40,
          left: 20,
          child: new widgets.BackButton(
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Positioned(
          // Add a report button:
          top: MediaQuery.of(context).size.height - 60,
          right: (MediaQuery.of(context).size.width / 2) - 72, // Centered
          child: new widgets.AddButton(onPressed: () {
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
                                      .translate('map-reporttext')),
                                  value: _selection,
                                  onChanged: (newVal) {
                                    setModalState(() {
                                      _selection = newVal;
                                      _typeToAdd = newVal;
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
                                        .translate('map-confirm'),
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w100,
                                        fontFamily: 'Poppins'),
                                  ),
                                  onPressed: () {
                                    setModalState(() {
                                      _addMode = true;
                                    });
                                    Navigator.pop(context);
                                  }),
                              Container(
                                height: 6,
                              ),
                              Text(
                                AppLocalizations.of(context)
                                    .translate('map-reporthelp'),
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
          }),
        ),
        Positioned(
          // Go to user's position and zoom in
          top: MediaQuery.of(context).size.height - 65,
          right: (MediaQuery.of(context).size.width / 2) - 170,
          child: widgets.LocalizeButton(
            onPressed: () => _moveMapToUserPosition(currentPosition),
          ),
        )
      ],
    );
  }

  /// Moves and zooms the camera on the user's position
  ///
  /// Param [latLng] - [Position] current user position
  _moveMapToUserPosition(Position latLng) {
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          bearing: 0,
          target: LatLng(
            latLng.latitude,
            latLng.longitude,
          ),
          zoom: 17.0,
        ),
      ),
    );
  }

  /// Helper function for getting the marker's icon
  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  /// This handles the adding of a new marker both on the map and on the server
  ///
  /// Param - [point] - [LatLng] The new marker's location (where the user tapped
  /// on the map)
  _handleAdd(LatLng point) async {
    if (_addMode == true) {
      if (point != null) {
        var lat = double.parse(point.latitude.toStringAsFixed(5));
        var long = double.parse(point.longitude.toStringAsFixed(5));

        /// Showing the marker on the map with it's coresponding icon
        final Uint8List markerIcon = await getBytesFromAsset(
            'assets/images/${_typeToAdd.toLowerCase()}.png',
            (ui.window.physicalSize.width * 0.08).toInt());
        var _icon = BitmapDescriptor.fromBytes(markerIcon);
        final MarkerId markerId = MarkerId(markers.length.toString());
        final Marker marker = Marker(
          markerId: markerId,
          position: LatLng(lat, long),
          infoWindow: InfoWindow(
            title: AppLocalizations.of(context).translate('map-newmarkertitle'),
          ),
          icon: _icon,
        );

        /// Add to the map
        markers[markerId] = marker;

        /// Add to the server
        addMarker(lat, long, _typeToAdd.toLowerCase());

        setState(() {
          _addMode = false;
        });
      } else {
        debugPrint("var point is null!");
      }
    }
  }
}
