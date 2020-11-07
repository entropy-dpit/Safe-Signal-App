import 'package:entropy_client/api/apiCommunication.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'apiConnector.dart';
import '../loadingPage.dart';
import '../showToastWithMessage.dart';
import 'googleMap.dart';
import '../main.dart' show AppLocalizations;

/// The map page, contains the code for the geolocation as well as for the GM
/// 
/// Authors:
///   David Pescariu @davidp-ro
///   Raul Popa @Raul-Popa

Position _currentPosition;

/// Export the [_currentPosition] for the sms sender service
///
/// Returns [Map] with key [lat] and value [long] as [String] (rounded to 3 digits)
Future<Map<String, String>> exportCurrentPosition() async {
  Map<String, String> _coords = Map<String, String>();

  if (_currentPosition != null) {
    _coords[_currentPosition.latitude.toStringAsFixed(5)] =
        _currentPosition.longitude.toStringAsFixed(5);
  } else {
    // Location wasn't obtained prior to req so force get location
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    await geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      _coords[position.latitude.toStringAsFixed(5)] =
          position.longitude.toStringAsFixed(5);
    }).catchError((e) {
      debugPrint("[FAIL] Get location (export) failed: " + e);
    });
  }

  return _coords;
}

Future<Uint8List> getBytesFromAsset(String path, int width) async {
  ByteData data = await rootBundle.load(path);
  ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
      targetWidth: width);
  ui.FrameInfo fi = await codec.getNextFrame();
  return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
      .buffer
      .asUint8List();
}

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  Map<PolygonId, Polygon> zones = <PolygonId, Polygon>{};
  Position _currentPosition;
  String _mapStyle;
  bool emptyZone = false;

  @override
  void initState() {
    super.initState();

    rootBundle.loadString('assets/googleMapsStyle.json').then((string) {
      // Load map style
      _mapStyle = string;
    });
  }

  /// Get a nice looking string from a marker type
  ///
  /// Param [originalType] - [String]: type recived from server
  ///
  /// Returns [String], nicely formatted
  String getNiceTitle(String originalType) {
    switch (originalType) {
      case ('robbery'):
        return AppLocalizations.of(context).translate('map-robberytitle');
        break;
      case ('theft'):
        return AppLocalizations.of(context).translate('map-thefttitle');
        break;
      case ('violence'):
        return AppLocalizations.of(context).translate('map-violencetitle');
        break;
      case ('unsafe'):
        return AppLocalizations.of(context).translate('map-unsafetitle');
        break;
      case ('unknown'):
        return AppLocalizations.of(context).translate('map-unknowntitle');
        break;
      default:
        return "Unknown type!";
        break;
    }
  }

  /// Add a marker to a specified location
  ///
  /// Param [atLat] - [double]: Marker latitude
  /// Param [atLong] - [double]: Marker longitude
  /// Param [type] - [String]: the marker type ie: theft
  void addMarker(atLat, atLong, type, reportedDate) async {
    final Uint8List markerIcon = await getBytesFromAsset(
        'assets/images/$type.png',
        (ui.window.physicalSize.width * 0.065).toInt());
    var _icon = BitmapDescriptor.fromBytes(markerIcon);
    var markerIdVal = markers.length; // Unique id/marker
    final MarkerId markerId = MarkerId(markerIdVal.toString());

    var _title = getNiceTitle(type);
    var _content = AppLocalizations.of(context).translate('map-reported') +
        "$reportedDate";

    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(atLat, atLong),
      infoWindow: InfoWindow(title: _title, snippet: _content),
      icon: _icon,
    );
    setState(() {
      markers[markerId] = marker;
    });
  }

  /// Add a zone to a specified location
  ///
  /// Param [zonePoints] - [List]: Zone Points ([LatLng])
  void addZone(List<dynamic> zonePoints, Color zoneColor) async {
    List<LatLng> _createCorrectPoints() {
      final List<LatLng> points = <LatLng>[];
      zonePoints.forEach((_zone) {
        points.add(LatLng(_zone[0], _zone[1]));
      });
      return points;
    }

    final PolygonId _id = PolygonId(zones.length.toString());
    final Polygon polygon = Polygon(
        polygonId: _id,
        fillColor: zoneColor,
        strokeWidth: 0,
        points: _createCorrectPoints(),
        consumeTapEvents: true,
        onTap: () => showToastWithMessage(
            "${zonePoints.length} Events were reported in this zone"));

    setState(() {
      zones[_id] = polygon;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentPosition != null) {
      // Wait for the position
      if (markers.length != 0 || zones.length != 0) {
        // Wait for the data to get added
        // Got markers, show map with markers and zones
        print(zones);
        return new GoogleMapPage(
          mapStyle: _mapStyle,
          currentPosition: _currentPosition,
          markers: markers,
          polygons: zones,
        );
      } else {
        // We got the location, now get data:
        if (!emptyZone) {
          // Still loading
          _getMapData(_currentPosition.latitude, _currentPosition.longitude);
          return new LoadingPage();
        } else {
          /// Loaded but no markers in current area, so just load the map
          return new GoogleMapPage(
            mapStyle: _mapStyle,
            currentPosition: _currentPosition,
            markers: markers,
            polygons: zones,
          );
        }
      }
    } else {
      // Get location
      _getCurrentLocation();
      return new LoadingPage();
    }
  }

  /// Get current location
  _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      debugPrint("[FAIL] Get location failed: " + e);
      showToastWithMessage("Unable to get location, check permissions!");
      Navigator.pop(context);
    });
  }

  /// Get markers and zones from server and add them to the map
  ///
  /// Param [lat] - [double] Coords of the current location
  /// Param [long] - [double] Coords of the current location
  _getMapData(lat, long) async {
    List<String> _markers = await getMarkers(lat, long);
    List<dynamic> _zones = await getZonesFromServer(lat, long);

    /// Markers:
    if (_markers[0] == "end") {
      emptyZone = true;
      showToastWithMessage("No reports in your area");
      setState(() {
        markers = {};
      });
    } else {
      if (_markers[0] != "fail") {
        // We got the data
        for (int index = 0; index < _markers.length; ++index) {
          if (_markers[index] == "end") break;
          var _marker = _markers[index].split('&');
          addMarker(
            double.parse(_marker[0]),
            double.parse(_marker[1]),
            _marker[2],
            _marker[3],
          );
        }
      } else {
        // Something went wrong, server down etc...
        showToastWithMessage("Failed to retrieve markers, try again later...");
        Navigator.pop(context);
      }
    }

    /// Get a color dynamically
    ///
    /// Will always be translucent - [150 Alpha]
    ///
    /// Param [factor] - [int] The factor that's used to choose the color
    ///   ie. __getColorForZone(_zones[index].length)
    ///
    /// Returns [Color]
    Color __getColorForZone(int factor) {
      if (factor <= 3) {
        // Yellow
        return Color.fromARGB(150, 245, 203, 66);
      } else if (factor <= 5) {
        // Orange
        return Color.fromARGB(150, 245, 167, 66);
      } else {
        // Red
        return Color.fromARGB(150, 220, 10, 10);
      }
    }

    /// Zones:
    if (_zones[0] == "end") {
      setState(() {
        zones = {};
      });
    } else {
      if (_markers[0] != "fail") {
        for (int index = 0; index < _zones.length; ++index) {
          if (_zones[index] == "end") break;
          addZone(
            _zones[index],
            __getColorForZone(_zones[index].length),
          );
        }
      } else {
        // Something went wrong, server down etc...
        showToastWithMessage("Failed to retrieve zones, try again later...");
        Navigator.pop(context);
      }
    }
  }
}
