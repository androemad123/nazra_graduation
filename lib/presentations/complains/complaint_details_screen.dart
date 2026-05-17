import 'package:app/presentations/complains/widgets/status_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app/models/complaint_model.dart';
import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';
import '../../generated/l10n.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../app/repositories/complaint_feedback_repository.dart';

class ComplaintDetailsScreen extends StatelessWidget {
  final Complaint complaint;

  const ComplaintDetailsScreen({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final issueTypeLabel = _displayIssueType(complaint);
    final showFeedbackButton = _shouldShowFeedbackButton(complaint);
    // Define your step data

    int currentStep;
    switch (complaint.status) {
      case 'pending':
        currentStep = 0;
        break;
      case 'in_review':
        currentStep = 1;
        break;
      case 'in_progress':
        currentStep = 2;
        break;
      case 'resolved':
      case 'not_issue':
        currentStep = 3;
        break;
      default:
        currentStep = 0;
    }

    final steps = [
      {
        'title': s.statusNew,
        'date': DateFormat('d MMM, hh:mm a').format(complaint.createdAt.toDate()),
        'description': s.reportReceived,
      },
      {
        'title': s.statusUnderReview,
        'date': _getStatusDate(complaint.statusHistory, 'in_review', s,
            isPassed: currentStep >= 1,
            subsequentStatuses: ['in_progress', 'resolved', 'not_issue'],
            fallback: complaint.updatedAt),
        'description': s.reportReviewedClassified,
      },
      {
        'title': s.inProgress,
        'date': _getStatusDate(complaint.statusHistory, 'in_progress', s,
            isPassed: currentStep >= 2,
            subsequentStatuses: ['resolved', 'not_issue'],
            fallback: complaint.updatedAt),
        'description': s.teamStartedSolving,
      },
      {
        'title': s.fixed,
        'date': _getStatusDate(complaint.statusHistory, 'resolved', s,
            isPassed: currentStep >= 3,
            fallback: (complaint.status == 'resolved' || complaint.status == 'not_issue') ? complaint.updatedAt : null),
        'description': s.issueResolved,
      },
    ];

    // Determine current step based on complaint.status

    return Scaffold(
      appBar: AppBar(
        title: Text(
          s.details,
          style: semiBoldStyle(fontSize: 18.sp, color: ColorManager.black),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: ColorManager.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🧾 Header Card
            Card(
              color: ColorManager.white,
              elevation: 2,
              shadowColor: Colors.black54,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Row(
                  children: [
                    Container(
                      width: 70.w,
                      height: 70.h,
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: ColorManager.lighterBeige,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child:  Icon(
                        size: 50  ,
                        Icons.construction_rounded,
                        color: ColorManager.lightBrown,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow(s.reportNumber, "#RE_${complaint.id}"),
                          SizedBox(height: 6.h),
                          _buildInfoRow(s.category, issueTypeLabel),
                          SizedBox(height: 6.h),
                          _buildInfoRow(
                            s.submissionDate,
                            // Example: format your Timestamp to readable date
                            DateFormat('d MMM yyyy')
                                .format(complaint.createdAt.toDate()),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 20.h),

            /// 🖼️ Images Section
            if (complaint.imageUrls.isNotEmpty) ...[
              SizedBox(
                height: 200.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: complaint.imageUrls.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: CachedNetworkImage(
                          imageUrl: complaint.imageUrls[index],
                          width: 300.w,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 300.w,
                            color: ColorManager.lighterBeige,
                            child: const Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 300.w,
                            color: ColorManager.lighterBeige,
                            child: const Icon(Icons.error),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20.h),
            ],

            /// 📊 Report Status
            Text(
              s.reportStatus,
              style:
              boldStyle(fontSize: 16.sp, color: ColorManager.darkBrown),
            ),
            SizedBox(height: 12.h),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: List.generate(steps.length, (index) {
                    return StatusTile(
                      title: steps[index]['title']!,
                      date: steps[index]['date']!,
                      description: steps[index]['description']!,
                      isActive: index == currentStep,
                      isCompleted: index <= currentStep,
                      isLast: index == steps.length - 1,
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: showFeedbackButton
          ? FloatingActionButton.extended(
              onPressed: () => _onReportDelayPressed(context),
              backgroundColor: ColorManager.brown,
              icon: const Icon(Icons.report_gmailerrorred, color: Colors.white),
              label: Text(
                s.reportDelay,
                style: const TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
          semiBoldStyle(fontSize: 12.sp, color: ColorManager.lightBrown),
        ),
        SizedBox(width: 20,),
        Expanded(
          child: Text(
            value,
            style: semiBoldStyle(
              fontSize: 14,
              color: ColorManager.darkGray,
            ),
            overflow: TextOverflow.ellipsis, // 👈 optional
            maxLines: 1,                      // 👈 prevent overflow
            softWrap: true,
          ),
        ),
      ],
    );
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

  String _getStatusDate(List<StatusHistoryEntry> history, String status, S s,
      {bool isPassed = false, List<String> subsequentStatuses = const [], Timestamp? fallback}) {
    try {
      final entry = history.firstWhere((e) => e.status == status);
      return DateFormat('d MMM, hh:mm a').format(entry.timestamp.toDate());
    } catch (_) {
      // If the target status is missing but we've moved past it,
      // find the EARLIEST change that moved us beyond this step.
      if (subsequentStatuses.isNotEmpty) {
        final passEntries = history.where((e) => subsequentStatuses.contains(e.status)).toList();
        if (passEntries.isNotEmpty) {
          passEntries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          return DateFormat('d MMM, hh:mm a').format(passEntries.first.timestamp.toDate());
        }
      }

      if (isPassed && fallback != null) {
        return DateFormat('d MMM, hh:mm a').format(fallback.toDate());
      }
      return s.pending;
    }
  }

  bool _shouldShowFeedbackButton(Complaint complaint) {
    final status = complaint.status.toLowerCase();
    return status != 'resolved' &&
        status != 'fixed' &&
        status != 'not_issue';
  }

  bool _canReportDelay(Complaint complaint) {
    if (!_shouldShowFeedbackButton(complaint)) return false;
    final ageDays = DateTime.now().difference(complaint.createdAt.toDate()).inDays;
    return ageDays >= _thresholdDaysByPriority(complaint.priority);
  }

  int _daysUntilFeedbackAllowed(Complaint complaint) {
    final ageDays = DateTime.now().difference(complaint.createdAt.toDate()).inDays;
    final threshold = _thresholdDaysByPriority(complaint.priority);
    return (threshold - ageDays).clamp(1, threshold);
  }

  String _displayPriority(String priority) {
    return priority
        .trim()
        .split('_')
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  void _onReportDelayPressed(BuildContext context) {
    if (_canReportDelay(complaint)) {
      _showDelayFeedbackDialog(context);
    } else {
      _showFeedbackWaitDialog(context);
    }
  }

  Future<void> _showFeedbackWaitDialog(BuildContext context) async {
    final s = S.of(context);
    final thresholdDays = _thresholdDaysByPriority(complaint.priority);
    final daysRemaining = _daysUntilFeedbackAllowed(complaint);

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.feedbackNotAvailableTitle),
        content: Text(
          s.feedbackWaitMessage(
            _displayPriority(complaint.priority),
            thresholdDays,
            daysRemaining,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.close),
          ),
        ],
      ),
    );
  }

  int _thresholdDaysByPriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'emergency':
      case 'high':
        return 1;
      case 'medium':
        return 4;
      case 'low':
      default:
        return 7;
    }
  }

  Future<void> _showDelayFeedbackDialog(BuildContext context) async {
    final s = S.of(context);
    final ctrl = TextEditingController();

    final bool? submit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.reportDelay),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          style: regularStyle(fontSize: 16, color: Colors.black),
          decoration: InputDecoration(

            hintText: s.feedbackOptionalMessage,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.submit),
          ),
        ],
      ),
    );

    if (submit != true) return;

    try {
      await ComplaintFeedbackRepository().submitDelayFeedback(
        complaintId: complaint.id,
        complaintPriority: complaint.priority,
        complaintCreatedAt: complaint.createdAt.toDate(),
        immediateActionRequired: complaint.aiAnalysis?.immediateActionRequired ?? false,
        safetyHazard: complaint.aiAnalysis?.safetyHazard ?? false,
        message: ctrl.text,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.feedbackSent)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${s.error}: $e')),
        );
      }
    }
  }
}