import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:post_app/screens/login_screen.dart';
import 'package:post_app/firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Added imports
import 'package:post_app/screens/main_app_shell.dart';
import 'package:post_app/screens/admin_dashboard_screen.dart';
import 'package:post_app/services/api_client.dart';
import 'package:post_app/services/user_auth_api_service.dart';
import 'package:post_app/models/user_model.dart';
import 'package:post_app/services/token_provider.dart';

// Added import for Provider
import 'package:provider/provider.dart';
import 'package:post_app/providers/user_provider.dart'; // Your UserProvider

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;

  // Added service variables
  late final ApiClient _apiClient;
  late final UserAuthApiService _userAuthApiService;
  late final TokenProvider _tokenProvider;

  @override
  void initState() {
    super.initState();
    // Initialize services
    _tokenProvider = TokenProvider(FirebaseAuth.instance);
    _apiClient = ApiClient(_tokenProvider);
    _userAuthApiService = UserAuthApiService(_apiClient);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Added profile fetching and navigation logic (adapted from LoginScreen)
  Future<void> _fetchProfileAndNavigate(User user) async {
    try {
      final UserModel userProfile = await _userAuthApiService.getUserProfile();

      if (mounted) {
        // Set the user in UserProvider
        Provider.of<UserProvider>(context, listen: false).setUser(userProfile);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Signup successful & profile fetched! Welcome ${userProfile.displayName ?? userProfile.email}.')),
        );
        if (userProfile.role == 'admin') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const AdminDashboardScreen()),
            (Route<dynamic> route) => false, // Remove all previous routes
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainAppShell()),
            (Route<dynamic> route) => false, // Remove all previous routes
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Signup successful, but failed to fetch user profile: $e. Please try logging in.')),
        );
        // Navigate to login screen as a fallback if profile fetch fails
        Navigator.pushAndRemoveUntil(
          // Changed to pushAndRemoveUntil
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
      // Optionally, sign out the user if profile fetch fails critically
      // await FirebaseAuth.instance.signOut(); // Consider if this is desired UX
    }
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Debug print for troubleshooting
        print('Signup successful for: ${_emailController.text.trim()}');

        if (userCredential.user != null) {
          // UserProvider will be updated in _fetchProfileAndNavigate
          await _fetchProfileAndNavigate(userCredential.user!);
        } else {
          // This case should ideally not happen if createUserWithEmailAndPassword succeeds
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Signup completed but no user object found. Please login.')),
            );
            // Clear UserProvider if necessary
            Provider.of<UserProvider>(context, listen: false).clearUser();
            Navigator.pushAndRemoveUntil(
              // Changed to pushAndRemoveUntil
              context,
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false,
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'The account already exists for that email.';
        } else {
          errorMessage = 'Signup failed: ${e.message}';
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
          Provider.of<UserProvider>(context, listen: false).clearUser();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('An unexpected error occurred: $e')),
          );
          Provider.of<UserProvider>(context, listen: false).clearUser();
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() {
      _isLoading = true;
    });
    try {
      GoogleSignIn googleSignIn;
      if (kIsWeb) {
        googleSignIn = GoogleSignIn(
            clientId: DefaultFirebaseOptions.web
                .iosClientId); // Ensure web clientId is used if applicable, or general one
      } else {
        googleSignIn = GoogleSignIn(
          clientId: (Theme.of(context).platform == TargetPlatform.iOS)
              ? DefaultFirebaseOptions
                  .currentPlatform.iosClientId // Corrected to currentPlatform
              : null,
        );
      }
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.user != null) {
        // UserProvider will be updated in _fetchProfileAndNavigate
        await _fetchProfileAndNavigate(userCredential.user!);
      } else {
        // This case should ideally not happen if signInWithCredential succeeds
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Google Signup completed but no user object found. Please login.')),
          );
          Provider.of<UserProvider>(context, listen: false).clearUser();
          Navigator.pushAndRemoveUntil(
            // Changed to pushAndRemoveUntil
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Google Sign-Up failed: ${e.message}')), // Removed ANSI escape code
        );
        Provider.of<UserProvider>(context, listen: false).clearUser();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'An unexpected error occurred during Google Sign-Up: $e')),
        );
        Provider.of<UserProvider>(context, listen: false).clearUser();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 230,
                  color: Colors.pinkAccent,
                ),
                Positioned(
                  top: 60,
                  left: 32,
                  width: 101,
                  height: 66,
                  child: Image.asset("assets/post_icon.png"),
                ),
                Positioned(
                  top: 0,
                  left: 210,
                  width: 250,
                  height: 180,
                  child: Image.asset(
                    'assets/special_icon.png',
                  ),
                ),
              ],
            ),
            Container(
              transform: Matrix4.translationValues(0.0, -40.0, 0.0),
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                ),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Sign Up",
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Create your account to get started",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              hintText: "Email",
                              border: InputBorder.none,
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(r'\\S+@\\S+\\.\\S+')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const Divider(color: Colors.yellow),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: "Password",
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters long';
                              }
                              return null;
                            },
                          ),
                          const Divider(color: Colors.yellow),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              hintText: "Confirm Password",
                              border: InputBorder.none,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signup,
                        style: ButtonStyle(
                          backgroundColor:
                              WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.hovered)) {
                                return Colors.yellow;
                              }
                              return Colors.grey.shade300;
                            },
                          ),
                          foregroundColor:
                              WidgetStateProperty.all(Colors.black),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(
                                horizontal: 80, vertical: 14),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.black)
                            : const Text("Sign Up"),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Colors.grey),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: Image.asset(
                          'assets/google_logo.png',
                          height: 24,
                          width: 24,
                        ),
                        onPressed: _isLoading ? null : _handleGoogleSignUp,
                        label: const Text('Continue with Google'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // Navigate to LoginScreen, but allow going back to it if needed (e.g. if user explicitly wants to login)
                          // If the intent is to replace and not allow back, use pushReplacement.
                          // For now, using push so user can go back if they clicked "Already have an account?" by mistake from another flow.
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                        },
                        child: const Text(
                          "Already have an account? Login",
                          style: TextStyle(color: Colors.pink),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//thilan
