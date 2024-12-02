import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lingo_tales/pages/auth/authservice.dart';
import 'package:lingo_tales/pages/auth/login_page.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:lingo_tales/services/styles.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _image;
  bool _obscureText = true;

  final AuthService _authService = AuthService(); // Use your AuthService

  Future<void> _register(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty || name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required.')),
      );
      return;
    }

    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image to register.')),
      );
      return;
    }

    try {
      UserCredential result = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        String imageUrl = await _uploadImageToFirebase(user.uid);

        await _authService.saveUserToFirestore(user, name, imageUrl);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred.')),
      );
    }
  }

  Future<String> _uploadImageToFirebase(String userId) async {
    final storageRef = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child('$userId.jpg');
    UploadTask uploadTask = storageRef.putFile(_image!);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<void> _getImage() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: const Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.camera);
                  },
                ),
                const Padding(padding: EdgeInsets.all(8.0)),
                GestureDetector(
                  child: const Text('Gallery'),
                  onTap: () {
                    Navigator.of(context).pop(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (source != null) {
      final pickedFile = await _picker.pickImage(source: source);

      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textScaleFactor = MediaQuery.maybeTextScalerOf(context)?.scale(1);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              const SizedBox(height: 120),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 240,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/Logo.png'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: <Widget>[
                    _buildInputContainer(textScaleFactor),
                    const SizedBox(height: 30),
                    if (_image != null) _buildProfileImage(),
                    const SizedBox(height: 20),
                    _buildRegisterButton(context, textScaleFactor),
                    const SizedBox(height: 20),
                    _buildUploadButton(textScaleFactor),
                    const SizedBox(height: 10),
                    _buildLoginButton(context, textScaleFactor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputContainer(double? textScaleFactor) {
    return FadeInUp(
      duration: const Duration(milliseconds: 1800),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primaryColor),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.2),
              blurRadius: 20.0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            _buildTextField("Name", _nameController, textScaleFactor),
            _buildTextField("Email", _emailController, textScaleFactor),
            _buildPasswordField(textScaleFactor),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hintText, TextEditingController controller,
      double? textScaleFactor) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.primaryColor),
        ),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey[700],
            fontSize: 14 * (textScaleFactor ?? 1.0),
          ),
        ),
        style: TextStyle(
          fontSize: 14 * (textScaleFactor ?? 1.0),
        ),
      ),
    );
  }

  Widget _buildPasswordField(double? textScaleFactor) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _passwordController,
        obscureText: _obscureText,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Password",
          hintStyle: TextStyle(
            color: Colors.grey[700],
            fontSize: 14 * (textScaleFactor ?? 1.0),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility_off : Icons.visibility,
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
        style: TextStyle(
          fontSize: 14 * (textScaleFactor ?? 1.0),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return FadeInUp(
      duration: const Duration(milliseconds: 2000),
      child: CircleAvatar(
        radius: 40,
        backgroundImage: FileImage(_image!),
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context, double? textScaleFactor) {
    return FadeInUp(
      duration: const Duration(milliseconds: 1900),
      child: GestureDetector(
        onTap: () => _register(context),
        child: _buildButton("Register", textScaleFactor),
      ),
    );
  }

  Widget _buildUploadButton(double? textScaleFactor) {
    return FadeInUp(
      duration: const Duration(milliseconds: 1900),
      child: GestureDetector(
        onTap: _getImage,
        child: _buildButton("Upload Image", textScaleFactor),
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context, double? textScaleFactor) {
    return FadeInUp(
      duration: const Duration(milliseconds: 2000),
      child: TextButton(
        onPressed: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        ),
        child: Text(
          "Login",
          style: TextStyle(
            color: AppColors.secondaryColor,
            fontSize: 16 * (textScaleFactor ?? 1.0),
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, double? textScaleFactor) {
    return Container(
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
          text,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16 * (textScaleFactor ?? 1.0),
          ),
        ),
      ),
    );
  }
}
