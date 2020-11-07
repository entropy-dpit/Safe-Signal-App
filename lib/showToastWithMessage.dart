import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Show a toast message, to notify to user for example
/// 
/// Param [_message] - [dynamic], as long as it can be .toString()ed
void showToastWithMessage(_message) {
  Fluttertoast.showToast(
      msg: _message.toString(),
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black54,
      textColor: Colors.white,
      fontSize: 16.0
  );
}