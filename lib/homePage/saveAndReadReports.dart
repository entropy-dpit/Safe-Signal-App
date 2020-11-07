import 'dart:io';
import 'package:entropy_client/models/report.dart';
import 'package:entropy_client/showToastWithMessage.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

/// Save and get the reports from the user's phone, again I would say it's much
/// better to use a SQLite db or at least JSON
///
/// Author: David Pescariu @davidp-ro

/// Get local [path] from the device
///
/// Returns [String] with the [path]
Future<String> get _localPath async {
  final dir = await getApplicationDocumentsDirectory();
  return dir.path;
}

/// Get the actual file based on the [path]
///
/// Returns [File] Object with the actual file
Future<File> get _localFile async {
  final path = await _localPath;
  return File("$path/reports.entropy");
}

/// Save reports to file
///
/// Param [report] - [Report] Report to be saved
Future<void> appendReport(Report report) async {
  final file = await _localFile;
  String rep =
      "${report.lat.toString()}/${report.long.toString()}/${report.type}/${report.niceAddress}&";
  await file.writeAsString(rep, mode: FileMode.append);
}

/// Delete a report from the savefile. Be ready to see some gore
///
/// Param [report] - [Report] Report to be deleted
Future<void> removeReport(Report report) async {
  // It works - yes
  // Is it inefficient - yes
  // Is the rest of the code inefficient - yes
  // Do I have any idea how to make it better? - well yes, but this stays
  // How do we do it better?
  //  Use a db (sqlite), with Android (maybe works with iOS as well but idk)
  List<Report> reports = await getReports();
  final file = await _localFile;
  if (await file.exists()) {
    await file.delete(); // Delete old file
  }
  reports.forEach((r) async {
    if (r != report) {
      // Not the one that we want to delete so re-save it
      await appendReport(r);
    }
  });
}

/// Get reports from file
///
/// Returns [List<Report>] if no error was found
/// Returns [null] if any error occured
Future<List<Report>> getReports() async {
  final file = await _localFile;
  List<Report> reports = <Report>[];

  if (await file.exists()) {
    String raw = await file.readAsString();
    if (raw != null) {
      List<String> split = raw.split("&");
      split.forEach((r) {
        try {
          List<String> __report = r.split("/");
          if (__report.length != 1) {
            reports.add(Report(
              double.parse(__report[0]),
              double.parse(__report[1]),
              __report[2],
              __report[3],
            ));
          }
        } catch (e) {
          showToastWithMessage("Fail - $e");
          print("FAIL :: saveAndReadReports :: $e");
        }
      });
      // Done parsing
      return reports;
    } else {
      return null;
    }
  } else {
    return null;
  }
}
