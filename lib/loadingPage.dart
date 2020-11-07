import 'package:flutter/material.dart';
import 'constants.dart';

/// Generic loading page

class LoadingPage extends StatelessWidget {
  @override
  Widget build (BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double barHeight = 50.0;

    return new Container(
      padding: EdgeInsets.only(top: statusBarHeight),
      height: statusBarHeight + barHeight,
      child: Image.asset('assets/loading.gif', scale: 8,),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [GRADIENT_START, GRADIENT_END],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(0.5, 0.5),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp),
      ),
    );
  }
}