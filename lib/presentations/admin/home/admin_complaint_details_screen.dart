import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:intl/intl.dart';

import '../../../app/models/complaint_model.dart';
import '../../../app/repositories/complaint_repository.dart';
import '../../resources/color_manager.dart';
import '../../resources/styles_manager.dart';

class AdminComplaintDetailsScreen extends StatefulWidget {
  final Complaint complaint;

  const AdminComplaintDetailsScreen({super.key, required this.complaint});

  @override
  State<AdminComplaintDetailsScreen> createState() =>
      _AdminComplaintDetailsScreenState();
}

class _AdminComplaintDetailsScreenState
    extends State<AdminComplaintDetailsScreen> {
  final ComplaintRepository _repository = ComplaintRepository();

  @override
  Widget build(BuildContext context) {
    final complaint = widget.complaint;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ Images Section (Carousel)
            if (complaint.imageUrls.isNotEmpty) ...[
              SizedBox(
                height: 220.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: complaint.imageUrls.length,
                  separatorBuilder: (_, __) => SizedBox(width: 12.w),
                  itemBuilder: (_, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.network(
                        complaint.imageUrls[index],
                        width: 300.w,
                        height: 220.h,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 300.w,
                          height: 220.h,
                          color: Colors.grey[300],
                          child:
                              const Icon(Icons.image_not_supported, size: 50),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24.h),
            ],

            // 🏷️ Header: Category & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    complaint.category,
                    style: boldStyle(fontSize: 22.sp, color: ColorManager.brown),
                  ),
                ),
                _StatusChip(
                  label: complaint.status.toUpperCase().replaceAll('_', ' '),
                  color: _getStatusColor(complaint.status),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // 🚨 Priority Badge
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(complaint.priority).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: _getPriorityColor(complaint.priority).withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.priority_high_rounded,
                        size: 16.sp,
                        color: _getPriorityColor(complaint.priority),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${complaint.priority.toUpperCase()} PRIORITY',
                        style: semiBoldStyle(
                          fontSize: 12.sp,
                          color: _getPriorityColor(complaint.priority),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM d, yyyy • HH:mm')
                      .format(complaint.createdAt.toDate()),
                  style: regularStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // 📝 Description Card
            _InfoCard(
              title: 'Description',
              icon: Icons.description_outlined,
              child: Text(
                complaint.description,
                style: regularStyle(
                  fontSize: 15.sp,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 16.h),

            // 📍 Location Card
            _InfoCard(
              title: 'Location & Address',
              icon: Icons.location_on_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    complaint.address,
                    style: regularStyle(
                      fontSize: 15.sp,
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.map, size: 16.sp, color: Colors.grey),
                      SizedBox(width: 6.w),
                      Text(
                        '${complaint.location.latitude.toStringAsFixed(6)}, ${complaint.location.longitude.toStringAsFixed(6)}',
                        style: regularStyle(fontSize: 13.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // 🤖 AI Analysis Card (Highlighted)
            if (complaint.aiAnalysis != null)
              Container(
                margin: EdgeInsets.only(bottom: 16.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.deepPurple.withOpacity(0.1)
                      : Colors.deepPurple.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: Colors.deepPurple.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome,
                            color: Colors.deepPurple, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'AI Analysis',
                          style: semiBoldStyle(
                              fontSize: 16.sp, color: Colors.deepPurple),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    _DetailRow(
                      label: 'Is Valid Issue?',
                      value: complaint.aiAnalysis!.isIssue ? "Yes" : "No",
                      valueColor: complaint.aiAnalysis!.isIssue
                          ? Colors.green
                          : Colors.red,
                    ),
                    if (complaint.aiAnalysis!.confidenceLevel != null) ...[
                      SizedBox(height: 8.h),
                      _DetailRow(
                        label: 'Confidence',
                        value: complaint.aiAnalysis!.confidenceLevel!,
                      ),
                    ],
                    if (complaint.aiAnalysis!.description != null) ...[
                      SizedBox(height: 8.h),
                      Text(
                        'AI Summary:',
                        style: semiBoldStyle(
                            fontSize: 13.sp, color: Colors.deepPurple),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        complaint.aiAnalysis!.description!,
                        style: regularStyle(
                            fontSize: 14.sp,
                            color: isDarkMode ? Colors.white70 : Colors.black87),
                      ),
                    ],
                  ],
                ),
              ),

            // ℹ️ Metadata Card
            _InfoCard(
              title: 'Metadata',
              icon: Icons.info_outline,
              child: Column(
                children: [
                  _DetailRow(label: 'User ID', value: complaint.userId),
                  SizedBox(height: 8.h),
                  _DetailRow(label: 'Likes', value: '${complaint.likes}'),
                  SizedBox(height: 8.h),
                  _DetailRow(
                    label: 'Last Updated',
                    value: DateFormat('MMM d, HH:mm')
                        .format(complaint.updatedAt.toDate()),
                  ),
                ],
              ),
            ),
            SizedBox(height: 100.h), // Spacing for FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStatusUpdateDialog(),
        backgroundColor: ColorManager.brown,
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text('Update Status', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'not_issue':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'emergency':
        return Colors.red;
      case 'high':
        return Colors.deepOrange;
      case 'medium':
        return Colors.amber;
      case 'low':
        return Colors.lightGreen;
      default:
        return Colors.grey;
    }
  }

  void _showStatusUpdateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Update Status',
                    style: boldStyle(fontSize: 18.sp, color: ColorManager.black),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Status Options
              _StatusOptionTile(
                label: 'Pending',
                icon: Icons.hourglass_empty,
                color: Colors.orange,
                isSelected: widget.complaint.status == 'pending',
                onTap: () => _updateStatus('pending', ctx),
              ),
              SizedBox(height: 12.h),
              _StatusOptionTile(
                label: 'In Progress',
                icon: Icons.loop,
                color: Colors.blue,
                isSelected: widget.complaint.status == 'in_progress',
                onTap: () => _updateStatus('in_progress', ctx),
              ),
              SizedBox(height: 12.h),
              _StatusOptionTile(
                label: 'Resolved',
                icon: Icons.check_circle_outline,
                color: Colors.green,
                isSelected: widget.complaint.status == 'resolved',
                onTap: () => _updateStatus('resolved', ctx),
              ),
              SizedBox(height: 12.h),
              _StatusOptionTile(
                label: 'Not Issue',
                icon: Icons.cancel_outlined,
                color: Colors.grey,
                isSelected: widget.complaint.status == 'not_issue',
                onTap: () => _updateStatus('not_issue', ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateStatus(String newStatus, BuildContext ctx) async {
    try {
      await _repository.updateComplaintStatus(widget.complaint.id, newStatus);
      if (mounted) {
        Navigator.pop(ctx);
        Navigator.pop(context); // Go back to list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $newStatus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

// -----------------------------------------------------------------------------
// 🧱 Helper Widgets
// -----------------------------------------------------------------------------

class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDarkMode ? ColorManager.darkBeige : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: ColorManager.brown, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                title,
                style: semiBoldStyle(fontSize: 16.sp, color: ColorManager.brown),
              ),
            ],
          ),
          Divider(height: 24.h, thickness: 0.5, color: Colors.grey[300]),
          child,
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: boldStyle(fontSize: 12.sp, color: Colors.white),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: regularStyle(fontSize: 14.sp, color: Colors.grey),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: semiBoldStyle(
              fontSize: 14.sp,
              color: valueColor ?? (isDarkMode ? Colors.white : Colors.black87),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusOptionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusOptionTile({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(width: 12.w),
            Text(
              label,
              style: semiBoldStyle(
                fontSize: 16.sp,
                color: isSelected ? color : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected) Icon(Icons.check, color: color, size: 20.sp),
          ],
        ),
      ),
    );
  }
}
