# prisma.ai-app
Public release of the app's source code

# How to build it?
- Go into `android/app/src/main/AndroidManifest.xml` and search for `meta-data android:name="com.google.android.geo.API_KEY"`
- Insert your Google API Key (Google Maps and Geocoding must be active!)
- Go into `AppDelegate.swift` and insert the same key as above
- Go into `lib/services/sendSms.dart` and once again insert the key into `GEOCODING_API_KEY`
- Go into `lib/api/apiUtils.dart` and change `APIKEY` and the `IP` with your credentials
- `flutter pub get`
- `flutter run` to live-run on your phone or emulator

# What is prisma.ai?
prisma.ai is an upcoming start-up meant to increase you safety in the city

# Who is behind prisma.ai?
- David Pescariu - Co-founder & Developer
- Raul Popa - Co-founder & Developer & Designer

# License and Copyright
The sources are released under the GNU GPLv3 license, which requires you to credit us,
and keep the code open-source.

---

# Who was Team Entropy?
- The people behind Safe Signal, a new step in personal safety.
- We won 2nd Place during the 2020 DpIT Contest

# The OG Safe Signal Team
- David Pescariu - Lead Developer
- Raul Popa - Developer and Lead Designer
- Andra Bolboaca - Business Relations
- Ioana Gabor - Developer
- Ana Pop - Design and Public Relations
- Dorin Cuibus - Developer