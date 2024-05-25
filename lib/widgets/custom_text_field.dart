import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final bool obscureText;
  final TextStyle textStyle;
  final InputDecoration decoration;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText = '',
    this.obscureText = false,
    this.textStyle = const TextStyle(),
    this.decoration = const InputDecoration(),
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: decoration.copyWith(
        labelText: labelText,
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 12.0),
      ),
      style: textStyle,
    );
  }
}
