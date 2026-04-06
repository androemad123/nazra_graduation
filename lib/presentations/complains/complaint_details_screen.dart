import 'package:app/presentations/complains/widgets/status_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../app/models/complaint_model.dart';
import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';
import '../../generated/l10n.dart';
import 'package:intl/intl.dart';

class ComplaintDetailsScreen extends StatelessWidget {
  final Complaint complaint;

  const ComplaintDetailsScreen({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    // Define your step data
    final steps = [
      {
        'title': s.statusNew,
        'date': '22 Sep, 10:30 PM',
        'description': s.reportReceived,
      },
      {
        'title': s.statusUnderReview,
        'date': '25 Sep, 08:30 AM',
        'description': s.reportReviewedClassified,
      },
      {
        'title': s.inProgress,
        'date': '27 Sep, 10:00 AM',
        'description': s.teamStartedSolving,
      },
      {
        'title': s.fixed,
        'date': '27 Sep, 03:00 PM',
        'description': s.issueResolved,
      },
    ];

    // Determine current step based on complaint.status
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
                          _buildInfoRow(s.category, complaint.category),
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
}