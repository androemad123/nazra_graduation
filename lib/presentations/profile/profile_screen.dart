import 'package:app/presentations/profile/settings_screen.dart';
import 'package:app/presentations/profile/widget/profile_stat_card.dart';
import 'package:app/presentations/profile/widget/profile_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../app/repositories/complaint_repository.dart';
import '../../../app/repositories/community_repository.dart';
import '../../../app/bloc/auth/auth_bloc.dart';
import '../../../app/bloc/auth/auth_event.dart';
import '../../../app/bloc/auth/auth_state.dart';
import '../../../routing/routes.dart';
import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';
import 'activity_log_screen.dart';
import 'help_screen.dart';
import '../../generated/l10n.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ComplaintRepository _complaintRepository = ComplaintRepository();
  final CommunityRepository _communityRepository = CommunityRepository();

  void _onLogoutPressed(BuildContext context) {
    context.read<AuthBloc>().add(AuthLogoutRequested());
  }

  Future<_ProfileStats> _loadStats(String userId) async {
    final complaints = await _complaintRepository.getUserComplaints();
    final communities = await _communityRepository.watchCommunities().first;

    final joinedCount = communities
        .where((c) => c.members.contains(userId))
        .length;
    final complaintsCount = complaints.length;
    final points = complaints.fold<int>(
      0,
      (sum, c) => sum + ((c['likes'] as num?)?.toInt() ?? 0),
    );

    return _ProfileStats(
      points: points,
      communities: joinedCount,
      complaints: complaintsCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(s.loggedOutSuccessfully)),
          );
          Navigator.pushReplacementNamed(context, Routes.loginRoute);
        } else if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error ?? s.logoutFailed)),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;
        final user = state.user;
        final isAdmin = user?.role == 'admin';

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- Profile Icon ---
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: ColorManager.beige,
                      child: Icon(
                        Icons.person,
                        color: ColorManager.brown,
                        size: 45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.displayName ?? s.defaultUserName,
                      style: semiBoldStyle(fontSize: 18, color: ColorManager.darkGray),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? s.defaultUserEmail,
                      style: regularStyle(fontSize: 14, color: ColorManager.gray),
                    ),
                    const SizedBox(height: 28),

                    // --- Stats Row ---
                    if (!isAdmin && user != null)
                      FutureBuilder<_ProfileStats>(
                        future: _loadStats(user.uid),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final stats = snapshot.data!;
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  ProfileStatCard(
                                    label: s.points,
                                    value: '${stats.points}',
                                    icon: Icons.emoji_events_outlined,
                                  ),
                                  ProfileStatCard(
                                    label: s.communities,
                                    value: '${stats.communities}',
                                    icon: Icons.people_alt_outlined,
                                  ),
                                  ProfileStatCard(
                                    label: s.complaints,
                                    value: '${stats.complaints}',
                                    icon: Icons.receipt_long_outlined,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                            ],
                          );
                        },
                      ),

                    // --- Action Tiles ---
                    ProfileTile(
                      icon: Icons.settings_outlined,
                      title: s.settings,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsScreen()),
                        );
                      },
                    ),
                    ProfileTile(
                      icon: Icons.list_alt_outlined,
                      title: s.activityLog,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ActivityLogScreen()),
                        );
                      },
                    ),
                    ProfileTile(
                      icon: Icons.card_giftcard_outlined,
                      title: s.rewardsCenter,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SettingsScreen()),
                        );
                      },
                    ),
                    ProfileTile(
                      icon: Icons.help_outline,
                      title: s.help,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HelpScreen()),
                        );
                      },
                    ),
                    ProfileTile(
                      icon: Icons.logout,
                      title: isLoading ? s.loggingOut : s.logout,
                      onTap: isLoading ? null : () => _onLogoutPressed(context),
                      iconColor: ColorManager.brown,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileStats {
  final int points;
  final int communities;
  final int complaints;

  const _ProfileStats({
    required this.points,
    required this.communities,
    required this.complaints,
  });
}
