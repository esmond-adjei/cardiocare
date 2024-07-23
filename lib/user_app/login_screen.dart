import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cardiocare/user_app/dummy_user_data.dart';
import 'package:cardiocare/services/db_helper.dart';
import 'package:cardiocare/user_app/widgets/custom_text_field.dart';
import 'package:cardiocare/user_app/widgets/custom_button.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  void _login() async {
    final password = _passwordController.text;
    try {
      await _dbHelper.getUser(email: _emailController.text);
      Navigator.pushNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      log('Login Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          //
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
              'Login',
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
            const SizedBox(height: 16.0),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Forgot password? Click here',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 30.0),
            CustomButton(
              text: 'Login',
              onPressed: _login,
            ),
            const SizedBox(height: 16.0),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const RegisterScreen()),
                  );
                },
                child: const Text(
                  "Don't have an account? Register",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
