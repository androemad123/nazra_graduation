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
import '../../app/repositories/community_repository.dart';
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
    final communityRepo = CommunityRepository();
    
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
            final steps = [
              {
                'title': S.of(context).statusNew,
                'date': DateFormat('d MMM, hh:mm a').format(issue.createdAt.toDate()),
                'description': S.of(context).issueReported,
              },
              {
                'title': S.of(context).statusUnderReview,
                'date': _getStatusDate(issue.statusHistory, 'in_review', S.of(context),
                    isPassed: currentStep >= 1,
                    subsequentStatuses: ['escalated', 'resolved'],
                    fallback: issue.updatedAt),
                'description': S.of(context).issueUnderReview,
              },
              {
                'title': S.of(context).statusEscalated,
                'date': _getStatusDate(issue.statusHistory, 'escalated', S.of(context),
                    isPassed: currentStep >= 2,
                    subsequentStatuses: ['resolved'],
                    fallback: issue.updatedAt),
                'description': S.of(context).issueEscalated,
              },
              {
                'title': S.of(context).statusResolved,
                'date': _getStatusDate(issue.statusHistory, 'resolved', S.of(context),
                    isPassed: currentStep >= 3,
                    fallback: issue.updatedAt),
                'description': S.of(context).issueResolved,
              },
            ];



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

                    // 🤖 AI Analysis Card (like complaint admin details)
                    if (issue.aiAnalysis != null) ...[
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.05),
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
                                Icon(
                                  Icons.auto_awesome,
                                  color: Colors.deepPurple,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  S.of(context).aiAnalysisTitle,
                                  style: semiBoldStyle(
                                    fontSize: 16.sp,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            _buildAiRow(
                              label: S.of(context).isValidIssue,
                              value: issue.aiAnalysis!.isIssue
                                  ? S.of(context).yes
                                  : S.of(context).no,
                              valueColor: issue.aiAnalysis!.isIssue
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            if (issue.aiAnalysis!.confidenceLevel != null) ...[
                              SizedBox(height: 8.h),
                              _buildAiRow(
                                label: S.of(context).confidence,
                                value: issue.aiAnalysis!.confidenceLevel!,
                              ),
                            ],
                            if (issue.aiAnalysis!.issueType != null) ...[
                              SizedBox(height: 8.h),
                              _buildAiRow(
                                label: S.of(context).category,
                                value: issue.aiAnalysis!.issueType!,
                              ),
                            ],
                            if (issue.aiAnalysis!.description != null) ...[
                              SizedBox(height: 8.h),
                              Text(
                                S.of(context).aiSummary,
                                style: semiBoldStyle(
                                  fontSize: 13.sp,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                issue.aiAnalysis!.description!,
                                style: regularStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

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

                    // Owner-only status controls
                    StreamBuilder(
                      stream: communityRepo.watchCommunity(issue.communityId),
                      builder: (context, communitySnap) {
                        final community = communitySnap.data;
                        final isOwner = community?.ownerId == currentUserId;
                        if (!isOwner) {
                          return const SizedBox.shrink();
                        }

                        return Column(
                          children: [
                            SizedBox(height: 16.h),
                            AppTextBtn(
                              buttonText: 'Update Status',
                              textStyle: semiBoldStyle(
                                fontSize: 16,
                                color: ColorManager.white,
                              ),
                              backGroundColor: ColorManager.brown,
                              borderRadius: 12.r,
                              onPressed: () => _showStatusUpdateDialog(
                                context: context,
                                issue: issue,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    
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

  Widget _buildAiRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
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
              color: valueColor ?? Colors.black87,
            ),
          ),
        ),
      ],
    );
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

  Future<void> _showStatusUpdateDialog({
    required BuildContext context,
    required Issue issue,
  }) async {
    final s = S.of(context);
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        child: Padding(
          padding: EdgeInsets.all(18.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                s.updateStatus,
                style: boldStyle(fontSize: 18.sp, color: ColorManager.black),
              ),
              SizedBox(height: 14.h),
              ListTile(
                title: Text(s.statusEscalated),
                leading: const Icon(Icons.priority_high_rounded, color: Colors.orange),
                onTap: () {
                  context.read<IssueBloc>().add(EscalateIssueRequested(issue.id));
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                title: Text(s.statusResolved),
                leading: const Icon(Icons.check_circle_outline, color: Colors.green),
                onTap: () {
                  context.read<IssueBloc>().add(ResolveIssueRequested(issue.id));
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

