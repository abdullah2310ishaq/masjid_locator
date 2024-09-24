import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:masjid_locator/src/auth/pages/sign_up.dart';
import 'package:masjid_locator/src/screens/users/mosque_detail.dart';
import 'package:masjid_locator/src/screens/welcome_screen.dart';
import 'package:masjid_locator/src/screens/muazzins/masjid_rep_home_page.dart';
import 'package:masjid_locator/src/screens/users/user_home_page.dart';

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
        '/detail':(context)=> MosqueDetailPage(mosqueName: '',),
      },
    );
  }
}
