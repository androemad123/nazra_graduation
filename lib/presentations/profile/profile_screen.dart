import 'package:app/presentations/profile/settings_screen.dart';
import 'package:app/presentations/profile/widget/profile_stat_card.dart';
import 'package:app/presentations/profile/widget/profile_tile.dart';
import 'package:flutter/material.dart';

import '../../../routing/routes.dart';
import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';
import 'activity_log_screen.dart';
import '../../generated/l10n.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _onLogoutPressed(BuildContext context) {
  Navigator.pushReplacementNamed(context, Routes.loginRoute);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

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
                      s.defaultUserName,
                      style: semiBoldStyle(fontSize: 18, color: ColorManager.darkGray),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.defaultUserEmail,
                      style: regularStyle(fontSize: 14, color: ColorManager.gray),
                    ),
                    const SizedBox(height: 28),

                    // --- Stats Row ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ProfileStatCard(
                          label: s.points,
                          value: '0',
                          icon: Icons.emoji_events_outlined,
                        ),
                        ProfileStatCard(
                          label: s.communities,
                          value: '1',
                          icon: Icons.people_alt_outlined,
                        ),
                        ProfileStatCard(
                          label: s.complaints,
                          value: '1',
                          icon: Icons.receipt_long_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

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
                          MaterialPageRoute(builder: (context) => const SettingsScreen()),
                        );
                      },
                    ),
                    ProfileTile(
                      icon: Icons.logout,
                      title:  s.logout,
                      onTap: ()=> _onLogoutPressed(context),
                      iconColor: ColorManager.brown,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
}
