import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/models/complaint_model.dart';
import '../../generated/l10n.dart';
import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';
import 'app_text_btn.dart';

class ComplaintCard extends StatelessWidget {
  final Complaint complaint;
  final VoidCallback onDetailsPressed;

  const ComplaintCard({
    super.key,
    required this.complaint,
    required this.onDetailsPressed,
  });

  /// 🎯 Map status to color and progress
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      case 'not_issue':
        return Colors.redAccent;
      case 'pending':
      default:
        return Colors.grey;
    }
  }

  int _getProgressValue(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return 100;
      case 'in_progress':
        return 60;
      case 'pending':
        return 20;
      default:
        return 0;
    }
  }

  String _displayIssueType(Complaint complaint) {
    final aiIssueType = complaint.aiAnalysis?.issueType?.trim();
    if (aiIssueType != null && aiIssueType.isNotEmpty) {
      return aiIssueType
          .split('_')
          .where((e) => e.isNotEmpty)
          .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
          .join(' ');
    }

    final category = complaint.category.trim();
    if (category.isNotEmpty) return category;
    return 'Unknown';
  }

  /// 🌳 Get an icon for each category
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'garbage & waste':
      case 'garbage_overflow':
        return Icons.delete_outline;
      case 'road & sidewalk damage':
      case 'pothole':
        return Icons.construction;
      case 'trees & vegetation':
      case 'dead_tree':
        return Icons.park;
      case 'dangerous_structure':
        return Icons.warning_amber_rounded;
      default:
        return Icons.report_problem_outlined;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'emergency':
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(complaint.status);
    final progress = _getProgressValue(complaint.status);
    final priorityColor = _getPriorityColor(complaint.priority);
    final aiConfidenceLabel =
        complaint.aiAnalysis?.confidenceLabel ?? 'UNKNOWN';
    final issueTypeLabel = _displayIssueType(complaint);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDarkMode ? ColorManager.darkBeige : ColorManager.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.grey.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🧱 Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? ColorManager.darkLightBrown
                      : ColorManager.cream,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _getCategoryIcon(
                    complaint.aiAnalysis?.issueType ?? complaint.category,
                  ),
                  color: ColorManager.brown,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 10.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issueTypeLabel,
                      style: semiBoldStyle(
                        fontSize: 16.sp,
                        color: isDarkMode
                            ? ColorManager.lightGray
                            : ColorManager.gray,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      complaint.address,
                      style: regularStyle(
                        fontSize: 13.sp,
                        color: ColorManager.lightGray,
                      ),
                    ),
                  ],
                ),
              ),

              // 🟩 Status
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Text(
                      complaint.status.replaceAll('_', ' ').toUpperCase(),
                      style: semiBoldStyle(
                        fontSize: 12.sp,
                        color: statusColor,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.circle, color: statusColor, size: 10.sp),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          /// 📷 Description
          Text(
            complaint.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: regularStyle(
              fontSize: 14.sp,
              color:
              isDarkMode ? ColorManager.lightGray : ColorManager.gray,
            ),
          ),

          SizedBox(height: 10.h),

          /// 🔋 Progress
          Text(
            S.of(context).progress,
            style: regularStyle(
              fontSize: 14.sp,
              color:
              isDarkMode ? ColorManager.lightGray : ColorManager.gray,
            ),
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    color: statusColor,
                    backgroundColor: ColorManager.lighterGray,
                    minHeight: 8.h,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                "$progress%",
                style: boldStyle(
                  fontSize: 14.sp,
                  color: statusColor,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          /// 🤖 AI Confidence and Priority
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${S.of(context).aiConfidence}: $aiConfidenceLabel",
                style: regularStyle(
                  fontSize: 13.sp,
                  color: ColorManager.lightGray,
                ),
              ),
              Container(
                padding:
                EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: priorityColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  complaint.priority.replaceAll('_', ' ').toUpperCase(),
                  style: semiBoldStyle(
                    fontSize: 12.sp,
                    color: priorityColor,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          /// 🟫 Details Button
          AppTextBtn(
            buttonText: S.of(context).details,
            textStyle: semiBoldStyle(
              fontSize: 15.sp,
              color: ColorManager.white,
            ),
            backGroundColor: ColorManager.brown,
            borderRadius: 12.r,
            onPressed: onDetailsPressed,
          ),
        ],
      ),
    );
  }
}
