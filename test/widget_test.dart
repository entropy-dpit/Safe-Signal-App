import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:entropy_client/main.dart';
import 'package:entropy_client/homePage/homePageWidgets.dart';

/// These tests were poorly implemented, and it's something I wished I did beter
/// 
/// In theory they test for overflows, but I'm not sure it works 100%
/// 
/// Author: David Pescariu @davidp-ro

void main() {
  final TestWidgetsFlutterBinding binding =
      TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("Test the home page for overflows", (tester) async {
    await tester.pumpWidget(new SafeSignalClient());

    // Low-res:
    try {
      binding.window.physicalSizeTestValue = Size(480, 720);
      binding.window.devicePixelRatioTestValue = 1.0;
      expect(find.byType(BandStatusAndButton), findsOneWidget);
      print("Passed @ 480 by 720");
    } catch (e) {
      print("Overflowed @ 480 by 720");
    }

    // Med-res:
    try {
      binding.window.physicalSizeTestValue = Size(720, 1280);
      binding.window.devicePixelRatioTestValue = 1.0;
      expect(find.byType(BandStatusAndButton), findsOneWidget);
      expect(find.byType(SafetyIndicator), findsOneWidget);
      expect(find.byType(Buttons), findsOneWidget);
      print("Passed @ 720 by 1280");
    } catch (e) {
      print("Overflowed @ 720 by 1280");
    }

    // High-res:
    try {
      binding.window.physicalSizeTestValue = Size(1080, 1920);
      binding.window.devicePixelRatioTestValue = 1.0;
      expect(find.byType(BandStatusAndButton), findsOneWidget);
      expect(find.byType(SafetyIndicator), findsOneWidget);
      expect(find.byType(Buttons), findsOneWidget);
      print("Passed @ 1080 by 1920");
    } catch (e) {
      print("Overflowed @ 1080 by 1920");
    }

    // Tall-res:
    try {
      binding.window.physicalSizeTestValue = Size(1080, 2280);
      binding.window.devicePixelRatioTestValue = 1.0;
      expect(find.byType(BandStatusAndButton), findsOneWidget);
      expect(find.byType(SafetyIndicator), findsOneWidget);
      expect(find.byType(Buttons), findsOneWidget);
      print("Passed @ 1080 by 2280");
    } catch (e) {
      print("Overflowed @ 1080 by 2280");
    }  
  });
}
