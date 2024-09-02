// screens/register_screen.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';

// import 'package:cardiocare/user_app/models/user_model.dart';
// import 'package:cardiocare/services/db_helper.dart';

import 'package:cardiocare/user_app/widgets/custom_text_field.dart';
import 'package:cardiocare/user_app/widgets/custom_button.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // final AuthService _authService = AuthService();
  // final DatabaseHelper _dbHelper = DatabaseHelper();

  void _register() async {
    // final password = _passwordController.text;

    try {
      // _dbHelper.createUser(user: CardioUser(email: _emailController.text));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Registration failed')));
      log('Registration Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          // title: const Text('Register'),
          ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 56.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/logo.png', height: 100, width: 100),
            const SizedBox(height: 20),
            const Text(
              'Register',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            CustomTextField(
              controller: _emailController,
              labelText: 'Email',
              hintText: 'eg: dev@example.com',
            ),
            const SizedBox(height: 20.0),
            CustomTextField(
              controller: _passwordController,
              labelText: 'Password',
              hintText: 'Enter your password',
              obscureText: true,
            ),
            const SizedBox(height: 20.0),
            CustomTextField(
              controller: _passwordController,
              labelText: 'Confirm Passwword',
              hintText: 'Enter password again',
              obscureText: true,
            ),
            const SizedBox(height: 30.0),
            CustomButton(
              text: 'Register',
              onPressed: _register,
            ),
          ],
        ),
      ),
    );
  }
}
