import 'package:flutter/material.dart';

import '../../resources/color_manager.dart';
import '../../resources/styles_manager.dart';

class StatusTile extends StatelessWidget {
  final String title;
  final String date;
  final String description;
  final bool isActive;
  final bool isCompleted;
  final bool isLast;

  const StatusTile({
    super.key,
    required this.title,
    required this.date,
    required this.description,
    this.isActive = false,
    this.isCompleted = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFC9A56B);
    const activeColor = Color(0xFF73BC97);
    const grayColor = Color(0xFF9E9E9E);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            // Circle status indicator
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: isActive ? activeColor : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? activeColor : primaryColor,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? Icon(
                Icons.check,
                color: isActive ? Colors.white : primaryColor,
                size: 35,
              )
                  : const SizedBox.shrink(),
            ),

            // Vertical line (unless it's the last)
            if (!isLast)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  height: 50,
                  width: 2,
                  color: Colors.grey.shade400,
                ),
              ),
          ],
        ),
        const SizedBox(width: 16),

        // Text content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title + Date
              Text.rich(
                TextSpan(
                  text: title,
                  style: semiBoldStyle(
                    fontSize: 17,
                    color: Colors.black87,
                  ),
                  children: [
                    TextSpan(
                      text: "   $date",
                      style: regularStyle(
                        fontSize: 13,
                        color: grayColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),

              // Description
              Text(
                description,
                style: regularStyle(
                  fontSize: 14,
                  color: ColorManager.darkBrown,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}
