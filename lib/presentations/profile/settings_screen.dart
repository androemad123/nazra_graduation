import 'package:app/presentations/profile/widget/profile_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../app/provider/language_provider.dart';
import '../../app/provider/theme_provider.dart';
import '../../generated/l10n.dart';
import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final languageProvider = context.watch<LanguageProvider>();

    final isDark = themeProvider.isDarkMode;
    final selectedLanguage = languageProvider.languageCode == 'ar'
        ? s.arabic
        : s.english;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          s.settings,
          style: semiBoldStyle(
              fontSize: 18, color: Theme.of(context).colorScheme.onSurface),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Account Settings ---
            _SettingsSection(
              title: s.accountSettings,
              children: [
                ProfileTile(
                  icon: Icons.lock_outline,
                  title: s.changePassword,
                  onTap: () {},
                ),
                ProfileTile(
                  icon: Icons.person_outline,
                  title: s.editPersonalInfo,
                  onTap: () {},
                ),
                ProfileTile(
                  icon: Icons.language,
                  title: s.language,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LanguageChip(
                        label: s.english,
                        selected: selectedLanguage == s.english,
                        onTap: () => languageProvider.setLanguage('en'),
                      ),
                      SizedBox(width: 8.w),
                      _LanguageChip(
                        label: s.arabic,
                        selected: selectedLanguage == s.arabic,
                        onTap: () => languageProvider.setLanguage('ar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // --- Notifications ---
            _SettingsSection(
              title: s.notifications,
              children: [
                ProfileTile(
                  icon: Icons.notifications_outlined,
                  title: s.appNotifications,
                  trailing: Switch(
                    activeThumbColor: ColorManager.lightBrown,
                    value: true,
                    onChanged: (_) {},
                  ),
                ),
                ProfileTile(
                  icon: Icons.report_gmailerrorred_outlined,
                  title: s.complaintUpdates,
                  trailing: Switch(
                    activeThumbColor: ColorManager.lightBrown,
                    value: true,
                    onChanged: (_) {},
                  ),
                ),
                ProfileTile(
                  icon: Icons.group_outlined,
                  title: s.communityUpdates,
                  trailing: Switch(
                    activeThumbColor: ColorManager.lightBrown,
                    value: false,
                    onChanged: (_) {},
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // --- Appearance ---
            _SettingsSection(
              title: s.appearance,
              children: [
                ProfileTile(
                  icon: Icons.dark_mode_outlined,
                  title: s.darkMode,
                  trailing: Switch(
                    activeThumbColor: ColorManager.lightBrown,
                    value: isDark,
                    onChanged: (_) => themeProvider.toggleTheme(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 12.h, left: 4.w),
            child: Text(
              title,
              style: semiBoldStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: selected ? ColorManager.lightBrown : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: regularStyle(
            fontSize: 14,
            color: selected
                ? ColorManager.white
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
