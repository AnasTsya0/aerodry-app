import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType keyboardType;

  const CustomTextField({
    super.key,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13, color: Color(0xFF0D3B8C)),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFFB8C1D1)),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFF2F8CFF)),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 45,
            minHeight: 48,
          ),
          suffixIcon: suffixIcon,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 45,
            minHeight: 48,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: const BorderSide(color: Color(0xFF2F8CFF), width: 1),
          ),
        ),
      ),
    );
  }
}
