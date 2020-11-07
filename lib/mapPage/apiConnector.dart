import '../api/apiCommunication.dart';

/// Further abstractization for the API Calls, not really neccessary
/// 
/// Author: David Pescariu @davidp-ro

/// Call getMarkersFromServer and retrieve information about a zone
///
/// Param [lat] - [int] Coords for the zone to get markers from
/// Param [long] - [int] Coords for the zone to get markers from
///
/// Returns [List] of [String] with marker data
Future<List<String>> getMarkers(lat, long) async {
  Future<List<String>> _data = getMarkersFromServer(
    (lat).toStringAsFixed(5),
    (long).toStringAsFixed(5),
  );

  List<String> data = await _data;

  return data; // ["46.774&23.592&theft",...]
}

/// Call addMarkerToServer and add a marker
///
/// Param [lat] - [int] Coords for the zone to get markers from
/// Param [long] - [int] Coords for the zone to get markers from
/// Param [type] - [String] The type of the marker (ex: marker_theft)
///
/// Returns [int] - response code - 0=ok -1=fail
Future<int> addMarker(lat, long, type) async {
  int res = await addMarkerToServer(lat, long, type);
  return res;
}
