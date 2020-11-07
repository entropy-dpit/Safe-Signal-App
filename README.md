# Safe-Signal-App
Public release of the app's source code

# How to build it?
- Go into `android/app/src/main/AndroidManifest.xml` and search for `meta-data android:name="com.google.android.geo.API_KEY"`
- Insert your Google API Key (Google Maps and Geocoding must be active!)
- Go into `AppDelegate.swift` and insert the same key as above
- Go into `lib/services/sendSms.dart` and once again insert the key into `GEOCODING_API_KEY`
- Go into `lib/api/apiUtils.dart` and change `APIKEY` and the `IP` with your credentials
- `flutter pub get`
- `flutter run` to live-run on your phone or emulator

# The Team
- David Pescariu - Lead Developer
- Raul Popa - Developer and Lead Designer
- Andra Bolboaca - Business Relations
- Ioana Gabor - Developer
- Ana Pop - Design and Public Relations
- Dorin Cuibus - Developer

# License and Copyright
The sources are released under the GNU GPLv3 license, which requires you to credit us,
and keep the code open-source.

You may find all necessary licenses in the *LICENSES.txt* file.

This was made during the 2020 DPIT Academy by Team Entropy.