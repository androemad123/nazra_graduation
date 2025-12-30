import 'package:flutter/material.dart';

import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';
import '../resources/value_manager.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? prefixIcon;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final TextInputType keyboardType;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.isPassword = false,
    this.obscureText = false,
    this.onToggleObscure,
    this.validator,
    this.onChanged,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fieldBackgroundColor = isDark ? ColorManager.darkCream : Colors.white;
    final borderColor = theme.colorScheme.primary.withOpacity(0.2);
    final hintColor = theme.textTheme.bodyMedium?.color?.withOpacity(0.6) ?? Colors.grey;
    final iconColor = hintColor;
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppMargin.m12),
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: fieldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          if (prefixIcon != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(prefixIcon, color: iconColor),
            ),
          Expanded(
            child: TextFormField(
              controller: controller,
              obscureText: isPassword ? obscureText : false,
              validator: validator,
              onChanged: onChanged,
              keyboardType: keyboardType,
              style: regularStyle(fontSize: 16, color: Colors.black),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle:  TextStyle(
                  fontSize: 16,
                  color: hintColor,
                  fontFamily: "Poppins",
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
              ),
            ),
          ),
          if (isPassword)
            IconButton(
              onPressed: onToggleObscure,
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: iconColor,
              ),
            ),
        ],
      ),
    );
  }
}
