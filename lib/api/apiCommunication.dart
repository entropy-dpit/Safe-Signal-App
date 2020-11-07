/// Abstractization for the API
/// 
/// Author: David Pescariu @davidp-ro

import 'package:flutter/material.dart';
import 'apiUtils.dart';

/// Return markers from a specific zone in a [List]
/// Example call: await getDataFromServer(46, 23)
///
/// [lat] - latitude zone <- [int]
/// [long] - longitude zone <- [int]
///
/// Returns [List] of [String] <- ["46.785&23.613&theft", ...]
Future<List<String>> getMarkersFromServer(lat, long) async {
  List<String> mapData = List<String>(); // Returned list
  Map<String, dynamic> raw = await fetchMarkers(lat, long); // Raw data

  // Preventing null exceptions:
  if (raw != null) {
    if (raw['data'] == 'fail') {
      // responseCode != 200 | ie. 500 == server error
      mapData.add("fail"); // Gets checked from mapPage.dart
    } else {
      List<dynamic> received = raw['data']; // List of all the data bunched up

      received.forEach((marker) {
        mapData.add(marker.toString());
      });
    }
  } else {
    // raw == null
    mapData.add("fail"); // Gets checked from mapPage.dart
    debugPrint("[FAIL in module apiCommunication] List<> raw was null");
  }

  return mapData; // Return the usable List
}

/// Add a marker
/// Example call: await addDataToServer(46.123, 23.456, "marker_theft")
///
/// [lat] - latitude (exact) <- [double]
/// [long] - longitude (exact) <- [double]
/// [type] - type of the "thing" that gets added <- [String]
///
/// Returns [int] <- 0 = Success | -1 = Fail
Future<int> addMarkerToServer(lat, long, type) async {
  Map<String, dynamic> response = await addMarker(lat, long, type);
  if (response != null) {
    if (response["SUCCESS"] == "data_added") {
      return 0; // Added successfully
    } else {
      return -1; // Fail
    }
  } else {
    // Response is null
    return -1;
  }
}

// Delete a marker/zone/etc...
// Example call: await deleteDataFromServer(46.123, 23.456)
//
// lat - latitude (exact) <- double
// long - longitude (exact) <- double
//
// Returns int <- 0 = Success | -1 = Fail
Future<int> deleteMarkersFromServer(lat, long) async {
  // Might not get implemented.
  throw new UnimplementedError("deleteMarkersFromServer not implemented yet");
}

/* ZONES */

/// Return valid zones from a specific zone in a [List]
/// Example call: await getDataFromServer(46, 23)
///
/// [lat] - latitude zone <- [int]
/// [long] - longitude zone <- [int]
///
/// Returns [List] of [String] <- ["46.785&23.613&theft", ...]
Future<List<dynamic>> getZonesFromServer(lat, long) async {
  List<dynamic> mapData = List<dynamic>(); // Returned list
  Map<String, dynamic> raw = await fetchZones(lat, long); // Raw data

  // Preventing null exceptions:
  if (raw != null) {
    if (raw['data'] == 'fail') {
      // responseCode != 200 | ie. 500 == server error
      mapData.add("fail"); // Gets checked from mapPage.dart
    } else {
      List<dynamic> received = raw['data']; // List of all the data bunched up

      received.forEach((zone) {
        if (zone == "end") {
          // Theoretically not neccesarry bcs len(end) > 2, but you know...
          mapData.add(zone);
        } else if (zone.length > 2) {
          // Do not accept anything less than a triangle
          mapData.add(zone);
        }
      });
    }
  } else {
    mapData.add("fail"); // Gets checked from mapPage.dart
    debugPrint("[FAIL in module apiCommunication] List<> raw was null");
  }

  return mapData; // Return the usable List
}
