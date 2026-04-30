import 'package:app/presentations/profile/widget/profile_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../app/bloc/auth/auth_bloc.dart';
import '../../app/bloc/auth/auth_event.dart';
import '../../app/provider/language_provider.dart';
import '../../app/repositories/user_repository.dart';
import '../../app/provider/theme_provider.dart';
import '../../generated/l10n.dart';
import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';

class SettingsScreen extends StatefulWidget {
  final bool openEditPersonalInfoOnStart;

  const SettingsScreen({
    super.key,
    this.openEditPersonalInfoOnStart = false,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _appNotificationsEnabled = true;
  bool _complaintUpdatesEnabled = true;
  bool _communityUpdatesEnabled = false;
  final UserRepository _userRepository = UserRepository();
  bool _isSavingPersonalInfo = false;

  @override
  void initState() {
    super.initState();
    if (widget.openEditPersonalInfoOnStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showEditPersonalInfoDialog();
      });
    }
  }

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
                  onTap: _showEditPersonalInfoDialog,
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
                    value: _appNotificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _appNotificationsEnabled = value;
                      });
                    },
                  ),
                ),
                ProfileTile(
                  icon: Icons.report_gmailerrorred_outlined,
                  title: s.complaintUpdates,
                  trailing: Switch(
                    activeThumbColor: ColorManager.lightBrown,
                    value: _complaintUpdatesEnabled,
                    onChanged: (value) {
                      setState(() {
                        _complaintUpdatesEnabled = value;
                      });
                    },
                  ),
                ),
                ProfileTile(
                  icon: Icons.group_outlined,
                  title: s.communityUpdates,
                  trailing: Switch(
                    activeThumbColor: ColorManager.lightBrown,
                    value: _communityUpdatesEnabled,
                    onChanged: (value) {
                      setState(() {
                        _communityUpdatesEnabled = value;
                      });
                    },
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

  Future<void> _showEditPersonalInfoDialog() async {
    final s = S.of(context);
    final authState = context.read<AuthBloc>().state;
    final user = authState.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.unexpectedError)),
      );
      return;
    }

    final nameController = TextEditingController(text: user.displayName ?? '');
    final phoneController = TextEditingController(text: user.phoneNumber ?? '');

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: ColorManager.lighterBeige,
              insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 6.h),
              contentPadding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 10.h),
              actionsPadding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 14.h),
              title: Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: ColorManager.lightBrown.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.person_outline,
                      size: 20.sp,
                      color: ColorManager.brown,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      s.editPersonalInfo,
                      style: semiBoldStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.editPersonalInfo,
                    style: regularStyle(
                      fontSize: 13,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.65),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  TextField(
                    controller: nameController,
                    textInputAction: TextInputAction.next,
                    decoration: _profileFieldDecoration(
                      context: context,
                      hintText: s.fullNameHint,
                      icon: Icons.person_outline,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _profileFieldDecoration(
                      context: context,
                      hintText: s.phoneHint,
                      icon: Icons.phone_outlined,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _isSavingPersonalInfo
                      ? null
                      : () => Navigator.of(dialogContext).pop(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  ),
                  child: Text(
                    s.cancel,
                    style: regularStyle(
                      fontSize: 14,
                      color: ColorManager.darkGray,
                    ),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorManager.brown,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                  ),
                  onPressed: _isSavingPersonalInfo
                      ? null
                      : () async {
                          setDialogState(() {
                            _isSavingPersonalInfo = true;
                          });
                          try {
                            await _userRepository.updatePersonalInfo(
                              uid: user.uid,
                              displayName: nameController.text,
                              phoneNumber: phoneController.text,
                            );
                            context.read<AuthBloc>().add(AuthAppStarted());
                            if (!mounted) return;
                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('${s.editPersonalInfo} ${s.save}')),
                            );
                          } catch (_) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(s.unexpectedError)),
                            );
                          } finally {
                            if (mounted) {
                              setDialogState(() {
                                _isSavingPersonalInfo = false;
                              });
                            }
                          }
                        },
                  child: _isSavingPersonalInfo
                      ? SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(s.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  InputDecoration _profileFieldDecoration({
    required BuildContext context,
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.35),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      prefixIcon: Icon(icon, size: 20.sp, color: ColorManager.gray),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.15),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: ColorManager.lightBrown, width: 1.2),
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
