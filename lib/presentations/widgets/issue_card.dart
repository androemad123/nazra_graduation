import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../app/models/issue_model.dart';
import '../../generated/l10n.dart';
import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';

class IssueCard extends StatelessWidget {
  final Issue issue;
  final VoidCallback onTap;
  final bool hasUserVoted;
  final VoidCallback? onVote;

  const IssueCard({
    super.key,
    required this.issue,
    required this.onTap,
    this.hasUserVoted = false,
    this.onVote,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Colors.green;
      case 'escalated':
        return Colors.orange;
      case 'pending':
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'garbage & waste':
        return Icons.delete_outline;
      case 'road & sidewalk damage':
        return Icons.construction;
      case 'trees & vegetation':
        return Icons.park;
      default:
        return Icons.report_problem_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(issue.status);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    _getCategoryIcon(issue.category),
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
                        issue.title,
                        style: semiBoldStyle(
                          fontSize: 16.sp,
                          color: isDarkMode
                              ? ColorManager.lightGray
                              : ColorManager.gray,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        issue.category,
                        style: regularStyle(
                          fontSize: 13.sp,
                          color: ColorManager.lightGray,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    issue.status.toUpperCase(),
                    style: semiBoldStyle(
                      fontSize: 12.sp,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              issue.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: regularStyle(
                fontSize: 14.sp,
                color: isDarkMode ? ColorManager.lightGray : ColorManager.gray,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        hasUserVoted ? Icons.thumb_up : Icons.thumb_up_outlined,
                        color: hasUserVoted ? Colors.blue : ColorManager.lightGray,
                      ),
                      onPressed: onVote,
                    ),
                    Text(
                      '${issue.voteCount} ${S.of(context).votes}',
                      style: regularStyle(
                        fontSize: 14.sp,
                        color: ColorManager.lightGray,
                      ),
                    ),
                  ],
                ),
                Text(
                  S.of(context).tapToViewDetails,
                  style: regularStyle(
                    fontSize: 12.sp,
                    color: ColorManager.lightGray,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

