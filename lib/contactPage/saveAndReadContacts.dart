import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import '../main.dart' show AppLocalizations;

/// Utility to save and get contacts from the device
/// 
/// This wasn't implemented very well, it's better to use a SQLite or at least
/// a JSON file, not the mess that I did, sorry learned a lot in the meantime...
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
  return File("$path/contacts.entropy");
}

/// Write [contacts] to [file]
///
/// Param [String] - [contacts] The string that gets written to the file
///
/// Returns [File] instance but it's not used
Future<File> writeContacts(String contacts) async {
  final file = await _localFile;
  if (await file.exists()) {
    file.delete();
  }
  return file.writeAsString(contacts);
}

/// Read contacts from the file
///
/// Returns [String] - If contacts present "{Name1:Nr1, Name2:Nr2}", or if
/// no contacts are present returns a [_demoMessage], or if smh fails returns
/// "fail", but it *shouldn't* happen
Future<String> readContacts() async {
  var _demoMessage =
      "{To add a close contact tap the add button:To remove a contact tap the remove button}";
  final file = await _localFile;

  if (await file.exists()) {
    String _contacts = await file.readAsString();
    if (_contacts != null) {
      if (_contacts != "{}") {
        return _contacts;
      } else {
        // Empty contact list so show the demo one
        return _demoMessage;
      }
    } else {
      return "fail";
    }
  } else {
    // No contact saved so write some demo data
    return _demoMessage;
  }
}
