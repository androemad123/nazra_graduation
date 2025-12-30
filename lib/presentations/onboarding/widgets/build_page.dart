import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../resources/font_manager.dart';
import '../../resources/styles_manager.dart';

class BuildPage extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final double imageHeight;
  final double imageWidth;

  const BuildPage({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.imageHeight,
    required this.imageWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 12, left: 12, top: 40, bottom: 12),
      child: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image Section
            Image.asset(
              imagePath,
              height: imageHeight.h,
              width: imageWidth.w, // Adjust height as needed
              fit: BoxFit.contain,
            ),
            SizedBox(height: 20.h),

            // Title Section
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontFamily: 'poppins',
                fontSize: 32.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h),

            // Subtitle Section
            Padding(
              padding:  EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                subtitle,
                style: regularStyle(fontSize: FontSize.s16, color: Theme.of(context).colorScheme.onSurface),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
