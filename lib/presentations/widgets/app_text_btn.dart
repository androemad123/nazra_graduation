import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextBtn extends StatelessWidget {
  final double? borderRadius;
  final Color? backGroundColor;
  final Color? borderColor;  // Border color parameter
  final double? borderWidth; // Border width parameter
  final double? horizontalPadding;
  final double? verticalPadding;
  final double? buttonWidth;
  final double? buttonHeight;
  final String buttonText;
  final TextStyle textStyle;
  final VoidCallback onPressed;

  const AppTextBtn({
    super.key,
    this.borderRadius,
    this.backGroundColor,
    this.horizontalPadding,
    this.verticalPadding,
    this.buttonWidth,
    this.buttonHeight,
    required this.buttonText,
    required this.textStyle,
    required this.onPressed,
    this.borderColor,    // Added to constructor
    this.borderWidth = 1.0, // Default border width
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: buttonWidth ?? double.infinity,  // Ensure button adapts to screen width
      height: buttonHeight ?? 56.h,           // Make height responsive
      decoration: BoxDecoration(
        color: backGroundColor ?? Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(borderRadius ?? 10.0),
        border: Border.all(
          color: borderColor ?? Colors.transparent,
          width: borderWidth ?? 1.0,
        ),
      ),
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          overlayColor: WidgetStateProperty.all<Color>(Colors.transparent), // 👈 removes splash
          splashFactory: NoSplash.splashFactory, // 👈 disables ripple animation
          padding: WidgetStateProperty.all<EdgeInsets>(
            EdgeInsets.symmetric(
              horizontal: horizontalPadding ?? 12.w,
              vertical: verticalPadding ?? 14.h,
            ),
          ),

        ),
        child: Text(
          buttonText,
          style: textStyle,
        ),
      ),
    );
  }
}
