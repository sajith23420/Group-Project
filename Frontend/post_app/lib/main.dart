import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:post_app/firebase_options.dart'; // Import Firebase options
import 'package:post_app/screens/login_screen.dart';
import 'package:post_app/screens/main_app_shell.dart';
import 'package:post_app/screens/splash_screen.dart'; // Keep SplashScreen for initial loading

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SL Post App', // Updated title
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Use StreamBuilder to listen to authentication state changes
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Show splash screen while checking auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          // If user is logged in, navigate to MainAppShell
          if (snapshot.hasData) {
            return const MainAppShell();
          }
          // Otherwise, show LoginScreen
          return const LoginScreen();
        },
      ),
    );
  }
}
