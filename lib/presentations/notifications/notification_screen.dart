import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../app/bloc/notification/notification_bloc.dart';
import '../../app/models/notification_model.dart';
import '../../generated/l10n.dart';
import '../resources/color_manager.dart';
import '../chat/chat_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Load notifications when screen opens
    context.read<NotificationBloc>().add(LoadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).notifications),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: S.of(context).markAllAsRead,
            onPressed: () {
              context.read<NotificationBloc>().add(MarkAllAsRead());
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return Skeletonizer(
              enabled: true,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                itemCount: 6,
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  return _NotificationCard(
                    notification: AppNotification(
                      id: 'dummy',
                      recipientId: 'dummy',
                      senderId: 'dummy',
                      title: 'Loading Notification Title',
                      body: 'Loading notification body content...',
                      type: NotificationType.general,
                      createdAt: DateTime.now(),
                    ),
                  );
                },
              ),
            );
          } else if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return _buildEmptyState();
            }
            return ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              itemCount: state.notifications.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return _NotificationCard(notification: notification);
              },
            );
          } else if (state is NotificationError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: ColorManager.brown.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 64.sp,
              color: ColorManager.brown,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            S.of(context).noNotificationsYet,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: ColorManager.gray,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            S.of(context).weWillLetYouKnow,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ColorManager.lightGray,
                ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;

  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    final isRead = notification.isRead;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        if (!isRead) {
          context.read<NotificationBloc>().add(MarkAsRead(notification.id));
        }
        if (notification.type == NotificationType.chatMessage && notification.relatedId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(peerUserId: notification.relatedId!),
            ),
          );
        }
        // TODO: Navigate to related content based on notification.type and notification.relatedId
      },
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: isRead
              ? Border.all(color: Colors.transparent)
              : Border.all(color: ColorManager.brown.withOpacity(0.3), width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: _getIconColor(notification.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                _getIcon(notification.type),
                color: _getIconColor(notification.type),
                size: 24.sp,
              ),
            ),
            SizedBox(width: 12.w),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
                            color: isRead ? theme.textTheme.titleSmall?.color : ColorManager.black,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8.r,
                          height: 8.r,
                          margin: EdgeInsets.only(left: 8.w),
                          decoration: const BoxDecoration(
                            color: ColorManager.brown,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notification.body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12.sp,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _formatDate(notification.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10.sp,
                      color: ColorManager.gray,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.vote:
        return Icons.thumb_up_rounded;
      case NotificationType.statusChange:
        return Icons.info_rounded;
      case NotificationType.joinRequest:
        return Icons.person_add_rounded;
      case NotificationType.requestAccepted:
        return Icons.check_circle_rounded;
      case NotificationType.chatMessage:
        return Icons.chat_bubble_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.vote:
        return Colors.blue;
      case NotificationType.statusChange:
        return Colors.orange;
      case NotificationType.joinRequest:
        return Colors.purple;
      case NotificationType.requestAccepted:
        return Colors.green;
      case NotificationType.chatMessage:
        return Colors.teal;
      default:
        return ColorManager.gray;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return DateFormat('MMM d, h:mm a').format(date);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return "Just now";
    }
  }
}
