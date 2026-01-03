import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../app/bloc/issue/issue_bloc.dart';
import '../../app/bloc/issue/issue_event.dart';
import '../../app/models/issue_model.dart';
import '../../app/repositories/issue_repository.dart';
import '../../generated/l10n.dart';
import '../complains/widgets/status_tile.dart';
import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';
import '../widgets/app_text_btn.dart';

class IssueDetailsScreen extends StatelessWidget {
  final String issueId;
  const IssueDetailsScreen({super.key, required this.issueId});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final issueRepo = IssueRepository();
    
    return BlocProvider(
      create: (_) => IssueBloc(repo: issueRepo),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            S.of(context).issueDetails,
            style: semiBoldStyle(fontSize: 18.sp, color: ColorManager.black),
          ),
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: ColorManager.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: StreamBuilder<Issue?>(
          stream: issueRepo.watchIssue(issueId),
          builder: (context, snapshot) {
            final isLoading = !snapshot.hasData;
            final issue = snapshot.data ?? Issue(
              id: 'dummy',
              communityId: 'dummy',
              userId: 'dummy',
              title: 'Loading Issue Title...',
              description: 'Loading issue description...',
              imageUrls: [],
              category: 'Loading...',
              votes: [],
              status: 'pending',
              createdAt: Timestamp.now(),
              updatedAt: Timestamp.now(),
            );

            final hasVoted = issue.hasUserVoted(currentUserId);

            // Define steps based on issue status
            final steps = [
              {
                'title': S.of(context).statusNew,
                'date': DateFormat('d MMM, hh:mm a').format(issue.createdAt.toDate()),
                'description': S.of(context).issueReported,
              },
              {
                'title': S.of(context).statusUnderReview,
                'date': S.of(context).pendingReview,
                'description': S.of(context).issueUnderReview,
              },
              {
                'title': S.of(context).statusEscalated,
                'date': S.of(context).pendingEscalation,
                'description': S.of(context).issueEscalated,
              },
              {
                'title': S.of(context).statusResolved,
                'date': S.of(context).pendingResolution,
                'description': S.of(context).issueResolved,
              },
            ];

            int currentStep;
            switch (issue.status.toLowerCase()) {
              case 'pending':
                currentStep = 0;
                break;
              case 'in_review': // Assuming this status might exist or map to pending
                currentStep = 1;
                break;
              case 'escalated':
                currentStep = 2;
                break;
              case 'resolved':
                currentStep = 3;
                break;
              default:
                currentStep = 0;
            }

            return Skeletonizer(
              enabled: isLoading,
              child: SingleChildScrollView(
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
                              child: Icon(
                                Icons.report_problem_rounded,
                                size: 40.sp,
                                color: ColorManager.lightBrown,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInfoRow(S.of(context).issueTitle, issue.title),
                                  SizedBox(height: 6.h),
                                  _buildInfoRow(S.of(context).category, issue.category),
                                  SizedBox(height: 6.h),
                                  _buildInfoRow(
                                    S.of(context).reportedOn,
                                    DateFormat('d MMM yyyy').format(issue.createdAt.toDate()),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),


                    SizedBox(height: 12.h),
                    if (issue.imageUrls.isNotEmpty || isLoading) ...[

                      SizedBox(
                        height: MediaQuery.widthOf(context),
                        child: isLoading ? Container(color: Colors.grey[300]) : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: issue.imageUrls.length,
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: CachedNetworkImage(
                                imageUrl: issue.imageUrls[index],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: ColorManager.cream,
                                  child: const Center(child: CircularProgressIndicator()),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: ColorManager.cream,
                                  child: const Icon(Icons.error),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],

                    Column(
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

                    SizedBox(height: 24.h),

                    // Voting Section
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: ColorManager.cream,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: ColorManager.lightBrown.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    S.of(context).communityVotes,
                                    style: semiBoldStyle(fontSize: 16, color: ColorManager.darkBrown),
                                  ),
                                  Text(
                                    S.of(context).voteToEscalate,
                                    style: regularStyle(fontSize: 12, color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: ColorManager.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.thumb_up_rounded, size: 16, color: ColorManager.brown),
                                    SizedBox(width: 6.w),
                                    Text(
                                      '${issue.voteCount}',
                                      style: boldStyle(fontSize: 16, color: ColorManager.brown),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          AppTextBtn(
                            buttonText: hasVoted ? S.of(context).removeVote : S.of(context).voteForEscalation,
                            textStyle: semiBoldStyle(
                              fontSize: 16,
                              color: ColorManager.white,
                            ),
                            backGroundColor: hasVoted ? Colors.grey : ColorManager.brown,
                            borderRadius: 12.r,
                            onPressed: () {
                              if (hasVoted) {
                                context.read<IssueBloc>().add(UnvoteIssueRequested(issue.id));
                              } else {
                                context.read<IssueBloc>().add(VoteIssueRequested(issue.id));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // Escalation Note
                    if (issue.escalationNote != null) ...[
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.orange[800], size: 20),
                                SizedBox(width: 8.w),
                                Text(
                                  S.of(context).escalationNote,
                                  style: semiBoldStyle(fontSize: 16, color: Colors.orange[900]!),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              issue.escalationNote!,
                              style: regularStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            );
          },
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
          style: semiBoldStyle(fontSize: 12.sp, color: ColorManager.lightBrown),
        ),
        SizedBox(width: 20.w),
        Expanded(
          child: Text(
            value,
            style: semiBoldStyle(
              fontSize: 14,
              color: ColorManager.darkGray,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: true,
          ),
        ),
      ],
    );
  }
}

