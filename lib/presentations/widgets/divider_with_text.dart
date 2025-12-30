import 'package:flutter/material.dart';

class DividerWithText extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final Color lineColor;
  final double thickness;
  final double indent;
  final double endIndent;

  const DividerWithText({
    super.key,
    required this.text,
    this.textStyle,
    this.lineColor = Colors.grey,
    this.thickness = 1,
    this.indent = 8,
    this.endIndent = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: lineColor,
            thickness: thickness,
            indent: indent,
            endIndent: indent,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            text,
            style: textStyle ?? Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        Expanded(
          child: Divider(
            color: lineColor,
            thickness: thickness,
            indent: endIndent,
            endIndent: endIndent,
          ),
        ),
      ],
    );
  }
}
