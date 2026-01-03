import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:skeletonizer/skeletonizer.dart';

import '../../app/bloc/activity_log/activity_log_bloc.dart';
import '../../app/models/activity_log_model.dart';
import '../../app/repositories/activity_log_repository.dart';
import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';
import '../../generated/l10n.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ActivityLogBloc(
        repository: ActivityLogRepository(),
      )..add(LoadActivityLogs()),
      child: const _ActivityLogView(),
    );
  }
}

class _ActivityLogView extends StatefulWidget {
  const _ActivityLogView();

  @override
  State<_ActivityLogView> createState() => _ActivityLogViewState();
}

class _ActivityLogViewState extends State<_ActivityLogView> {
  String selectedFilter = 'All';

  Widget buildFilterChip(String label) {
    final isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
        context.read<ActivityLogBloc>().add(FilterActivityLogs(label));
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD8B075) : ColorManager.lighterGray,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: regularStyle(
            fontSize: 13,
            color: isSelected ? Colors.white : ColorManager.darkGray,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: AppBar(
        backgroundColor: ColorManager.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          S.of(context).activityLog,
          style: semiBoldStyle(fontSize: 18, color: Colors.black),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  buildFilterChip(S.of(context).all),
                  SizedBox(width: 8.w),
                  buildFilterChip(S.of(context).complaints),
                  SizedBox(width: 8.w),
                  buildFilterChip(S.of(context).communities),
                  SizedBox(width: 8.w),
                  buildFilterChip(S.of(context).rewards),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Activity list
            Expanded(
              child: BlocBuilder<ActivityLogBloc, ActivityLogState>(
                builder: (context, state) {
                  if (state is ActivityLogLoading) {
                    return Skeletonizer(
                      enabled: true,
                      child: ListView.builder(
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          return _ActivityItem(
                            activity: ActivityLog(
                              id: 'dummy',
                              userId: 'dummy',
                              type: ActivityType.complaint,
                              title: 'Loading activity title...',
                              description: 'Loading description...',
                              createdAt: DateTime.now(),
                            ),
                          );
                        },
                      ),
                    );
                  } else if (state is ActivityLogLoaded) {
                    if (state.filteredActivities.isEmpty) {
                      return Center(
                        child: Text(
                          S.of(context).noActivitiesFound,
                          style: regularStyle(fontSize: 14, color: Colors.grey),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: state.filteredActivities.length,
                      itemBuilder: (context, index) {
                        final activity = state.filteredActivities[index];
                        return _ActivityItem(activity: activity);
                      },
                    );
                  } else if (state is ActivityLogError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final ActivityLog activity;

  const _ActivityItem({required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 33,
            backgroundColor: ColorManager.lightBrown.withOpacity(0.2),
            child: Icon(
              _getIcon(activity.type),
              color: ColorManager.brown,
              size: 30,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: regularStyle(fontSize: 14, color: ColorManager.black),
                ),
                SizedBox(height: 4.h),
                Text(
                  _formatDate(activity.createdAt),
                  style: regularStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(ActivityType type) {
    switch (type) {
      case ActivityType.complaint:
        return Icons.camera_alt;
      case ActivityType.community:
        return Icons.home;
      case ActivityType.vote:
        return Icons.thumb_up;
      case ActivityType.reward:
        return Icons.card_giftcard;
      case ActivityType.comment:
        return Icons.chat_bubble_outline;
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return "Just now";
    }
  }
}
