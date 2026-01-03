import 'package:app/presentations/complains/widgets/status_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../app/models/complaint_model.dart';
import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';

class ComplaintDetailsScreen extends StatelessWidget {
  final Complaint complaint;

  const ComplaintDetailsScreen({super.key, required this.complaint});

  @override
  Widget build(BuildContext context) {
    // Define your step data
    final steps = [
      {
        'title': 'NEW',
        'date': '22 Sep, 10:30 PM',
        'description': 'Report received',
      },
      {
        'title': 'Under review',
        'date': '25 Sep, 08:30 AM',
        'description': 'The report has been reviewed and classified',
      },
      {
        'title': 'In Progress',
        'date': '27 Sep, 10:00 AM',
        'description': 'Our team has started working on solving the problem',
      },
      {
        'title': 'Fixed',
        'date': '27 Sep, 03:00 PM',
        'description': 'Your reported problem is now fixed',
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
          'Details',
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
                          _buildInfoRow('Report number', "#RE_${complaint.id}"),
                          SizedBox(height: 6.h),
                          _buildInfoRow('Category', complaint.category),
                          SizedBox(height: 6.h),
                          _buildInfoRow(
                            'Submission date',
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
              "Report status",
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