// import 'package:flutter/material.dart';
// import 'screens/login/login_screen.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: LoginScreen(),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'auth_gate.dart';
import 'screens/splash/splash_screen.dart'; // ✅ IMPORTANT

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp( // ❗ NOT const
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // ✅ START WITH SPLASH
    );
  }
}
