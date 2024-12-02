import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lingo_tales/pages/auth/authservice.dart';
import 'package:lingo_tales/services/styles.dart';
import 'package:lingo_tales/services/widgets/google.dart';
import 'package:lingo_tales/pages/auth/reg_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;

  // Helper function to show SnackBar
  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage('Please fill in both email and password.');
      return;
    }

    try {
      final user = await _authService.signInWithEmail(email, password);
      if (user == null) {
        _showMessage('Login failed. Please check your credentials.');
      }
    } on FirebaseAuthException catch (e) {
      _showMessage('Login failed: ${e.message}');
    } catch (e) {
      _showMessage('An unexpected error occurred.');
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      final user = await _authService.signInWithGoogle();
      if (user == null) {
        _showMessage('Google sign-in failed. Please try again.');
      }
    } catch (e) {
      _showMessage('An unexpected error occurred.');
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('Please enter your email to reset password.');
      return;
    }

    try {
      await _authService.resetPassword(email);
      _showMessage('Password reset email sent.');
    } on FirebaseAuthException catch (e) {
      _showMessage('Password reset failed: ${e.message}');
    } catch (e) {
      _showMessage('An unexpected error occurred.');
    }
  }

  void _navigateToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.textScaleFactorOf(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 120),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Image.asset(
                'assets/Logo.png',
                height: 240,
                fit: BoxFit.fill,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                children: [
                  FadeInUp(
                    duration: const Duration(milliseconds: 1800),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primaryColor),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(143, 148, 251, .2),
                            blurRadius: 20.0,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Email",
                              hintStyle: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14 * textScaleFactor,
                              ),
                            ),
                          ),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Password",
                              hintStyle: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 14 * textScaleFactor,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: _obscureText
                                      ? AppColors.tertiryColor
                                      : AppColors.primaryColor,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: _login,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryColor,
                            AppColors.secondaryColor,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16 * textScaleFactor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  CustomGoogleButton(
                    onPressed: _loginWithGoogle,
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _resetPassword,
                    child: Text(
                      "Forgot Password?",
                      style: TextStyle(
                        color: AppColors.secondaryColor,
                        fontSize: 16 * textScaleFactor,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _navigateToRegister,
                    child: Text(
                      "Register",
                      style: TextStyle(
                        color: AppColors.secondaryColor,
                        fontSize: 16 * textScaleFactor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
