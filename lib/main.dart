import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:masjid_locator/src/auth/pages/otp_screen.dart';
import 'package:masjid_locator/src/auth/pages/sign_up.dart';
import 'package:masjid_locator/src/providers/namaz_provider.dart';
import 'package:masjid_locator/src/screens/welcome_screen.dart';
import 'package:masjid_locator/src/screens/muazzins/masjid_rep_home_page.dart';
import 'package:masjid_locator/src/screens/users/user_home_page.dart';
import 'package:masjid_locator/src/screens/users/map_screen.dart';
import 'package:masjid_locator/src/screens/users/nearby.dart';
import 'package:provider/provider.dart';
import 'package:masjid_locator/src/providers/auth_provider.dart';
import 'package:masjid_locator/src/auth/pages/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),

      ChangeNotifierProvider(create: (_) => PrayerProvider()),
    
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masjid Locator',
      initialRoute: '/userHome',
      routes: {
        '/': (context) => const WelcomePage(),
        '/login': (context) => LoginPage(),
         '/userHome': (context) => UserHomePage(),
        '/signUp': (context) => SignUpPage(),
        '/userHome': (context) => UserHomePage(),
        '/muadhinHome': (context) => MuadhinHomePage(),
        // '/prayer': (context) => NearbyMosquesScreens(),
        '/map': (context) => NearbyMosquesScreen (),
        
      },
    );
  }
}
