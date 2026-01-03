import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../resources/color_manager.dart';
import '../../resources/styles_manager.dart';

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Widget? trailing; // <-- NEW: allows custom trailing widget

  const ProfileTile({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.transparent, // <-- remove ripple splash
          highlightColor: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: ListTile(
              minTileHeight: 60.h,
              contentPadding: EdgeInsets.zero,
              leading: Icon(icon, color: iconColor ?? ColorManager.lightBrown),
              title: Text(
                title,
                style: regularStyle(fontSize: 15, color: ColorManager.darkGray),
              ),
              trailing: trailing ??
                  Icon(Icons.arrow_forward_ios,
                      size: 16, color: ColorManager.lightBrown),
            ),
          ),
        ),
      ),
    );
  }
}
