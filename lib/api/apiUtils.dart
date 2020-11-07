/// Deals with API communication
/// 
/// Author: David Pescariu @davidp-ro

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const APIKEY = "YOUR_API_KEY";
const IP = "YOUR_API_SERVER_IP:PORT";

/// Call the API and get the 'raw' marker data
///
/// Param [lat] - latitude zone <- [int]
/// Param [long] - longitude zone <- [int]
///
/// Returns [Map] -> {data:actual_data}
Future<Map<String, dynamic>> fetchMarkers(lat, long) async {
  final url = "http://" +
      IP +
      "/get_markers?key=" +
      APIKEY +
      "&lat=" +
      lat.toString() +
      "&long=" +
      long.toString();

  http.Response response = await http.get(url);
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    debugPrint("[FAIL in module apiUtils::fetchMarkers] - Received " +
        response.statusCode.toString() +
        " from server.");
    return {'data': 'fail'};
  }
}

/// Call the API and add a marker
///
/// [lat] - latitude <- [double]
/// [long] - longitude <- [double]
/// [type] - type of the added thing <- [String]
///
/// Returns [Map] -> {SUCCESS/FAIL:<text>}
Future<Map<String, dynamic>> addMarker(lat, long, type) async {
  final url = "http://" +
      IP +
      "/add_marker?key=" +
      APIKEY +
      "&lat=" +
      lat.toString() +
      "&long=" +
      long.toString() +
      "&type=" +
      type.toString();

  http.Response response = await http.get(url);
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    debugPrint("[FAIL in module apiUtils::addMarker] - Received " +
        response.statusCode.toString() +
        " from server.");
    return {'data': 'fail'};
  }
}

/// Call the API and delete markers
///
/// [lat] - latitude <- [double]
/// [long] - longitude <- [double]
///
/// It will delete every marker that's at the given [lat] and [long], usually
/// should be just one, but just keep this in mind, if used here.
///
/// Returns [Map] -> {SUCCESS/FAIL:<text>}
Future<Map<String, dynamic>> deleteMarkers(lat, long) async {
  final url = "http://" +
      IP +
      "/del_data?key=" +
      APIKEY +
      "&lat=" +
      lat.toString() +
      "&long=" +
      long.toString();

  http.Response response = await http.get(url);
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    debugPrint("[FAIL in module apiUtils::deleteMarkers] - Received " +
        response.statusCode.toString() +
        " from server.");
    return {'data': 'fail'};
  }
}

/* ZONES */

/// Call the API and get the 'raw' zone data
///
/// Param [lat] - latitude zone <- [int]
/// Param [long] - longitude zone <- [int]
///
/// Returns [Map] -> {data:actual_data}
Future<Map<String, dynamic>> fetchZones(lat, long) async {
  final url = "http://" +
      IP +
      "/get_zones?key=" +
      APIKEY +
      "&lat=" +
      lat.toString() +
      "&long=" +
      long.toString();

  http.Response response = await http.get(url);
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    debugPrint("[FAIL in module apiUtils::fetchZones] - Received " +
        response.statusCode.toString() +
        " from server.");
    return {'data': 'fail'};
  }
}
