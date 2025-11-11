import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  const CustomInput({
    required this.controller,
    required this.labelText,
    super.key,
    this.obscureText = false,
    this.prefixIcon,
  });

  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final IconData? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      ),
      obscureText: obscureText,
    );
  }
}
