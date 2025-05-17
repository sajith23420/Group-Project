import 'package:flutter/material.dart';
import 'package:post_app/screens/signup_screen.dart';
import 'package:post_app/screens/main_app_shell.dart';
import 'package:post_app/screens/admin_dashboard_screen.dart'; // Added import
import 'package:post_app/screens/forgot_password_screen.dart'; // Added import

class LoginScreen extends StatefulWidget { // Changed to StatefulWidget
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> { // Added State class

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    if (_formKey.currentState!.validate()) {
      // Admin credentials
      const String adminEmail = 'sajithbandara23420@gmail.com';
      const String adminPassword = '23420';

      String enteredEmail = _emailController.text.trim();
      String enteredPassword = _passwordController.text.trim();

      if (enteredEmail == adminEmail && enteredPassword == adminPassword) {
        // Navigate to Admin Dashboard
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
        );
      } else {
        // Navigate to Customer Dashboard (MainAppShell) for regular users
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainAppShell()),
        );
      }
    }
  }

  void _navigateToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  void _handleGoogleSignIn() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google Sign-In tapped')),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                      "Login",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Login using your existing postal",
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Email cannot be empty';
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
                                return 'Password cannot be empty';
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
                        onPressed: _login, // Removed context parameter
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith<Color>(
                            (Set<WidgetState> states) {
                              if (states.contains(WidgetState.hovered)) {
                                return Colors.yellow;
                              }
                              return Colors.grey.shade300;
                            },
                          ),
                          foregroundColor: WidgetStateProperty.all(Colors.black),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.symmetric(horizontal: 80, vertical: 14),
                          ),
                        ),
                        child: const Text("Login"),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Column(
                        children: [
                          TextButton(
                            onPressed: () { // Added navigation
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                              );
                            },
                            child: const Text(
                              "Forgot Password",
                              style: TextStyle(color: Colors.pink),
                            ),
                          ),
                          TextButton(
                            onPressed: _navigateToSignup,
                            child: const Text(
                              "Not Registered Yet?",
                              style: TextStyle(color: Colors.pink),
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text('or'),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
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
                            onPressed: _handleGoogleSignIn, // Removed context parameter
                            label: const Text('Continue with Google'),
                          ),
                        ],
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
