import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart'; // Your Firebase options file
import 'package:post_app/screens/login_screen.dart';
import 'package:post_app/screens/main_app_shell.dart';
import 'package:post_app/screens/splash_screen.dart'; // Keep SplashScreen for initial loading

// Added imports for Provider
import 'package:provider/provider.dart';
import 'package:post_app/providers/user_provider.dart'; // Your UserProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
          // Note: At this point, UserProvider might not have the UserModel yet.
          // UserModel is typically fetched after login/signup and then set in UserProvider.
          if (snapshot.hasData) {
            // Consider fetching user profile here if not already handled post-login/signup
            // or ensure login/signup flow populates UserProvider.
            return const MainAppShell();
          }
          // Otherwise, show LoginScreen
          return const LoginScreen();
        },
      ),
    );
  }
}
