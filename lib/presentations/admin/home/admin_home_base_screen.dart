import 'package:flutter/material.dart';

import '../../profile/profile_screen.dart';
import '../../resources/color_manager.dart';
import '../../resources/styles_manager.dart';
import '../../../generated/l10n.dart';
import '../statistics/statistics_screen.dart';
import 'admin_home_screen.dart';

class AdminHomeBaseScreen extends StatefulWidget {
  const AdminHomeBaseScreen({super.key});

  @override
  State<AdminHomeBaseScreen> createState() => _AdminHomeBaseScreenState();
}

//good now lets make the admin side i want to check on login if the user logging is role == admin then show admin_base_home_screen.dart if he is any thing other than admin show the usual home page
class _AdminHomeBaseScreenState extends State<AdminHomeBaseScreen> {

  int _selectedIndex = 0; // Track selected bottom nav item
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected tab
    });
  }

  final List<Widget> screens = [
    AdminHomeScreen(),
    StatisticsScreen(),
    ProfileScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens, // Display the selected screen
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 10,
          backgroundColor: ColorManager.white,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: regularStyle(fontSize: 14, color: Colors.green),
          unselectedLabelStyle: regularStyle(fontSize: 12, color: Colors.blue),

          // 👇 Disable ripple / highlight effects
          enableFeedback: false,
          // removes sound/vibration feedback

          items: [
            BottomNavigationBarItem(
              icon: _buildNavIcon(Icons.home_filled, 0),
              label: S.of(context).home,
            ),
            BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.insert_chart_outlined_rounded, 1),
                label: S.of(context).statistics),

            BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.person_3_outlined, 2),
                label: S.of(context).profile),
          ],
        ),
      ),
    );

  }
  Widget _buildNavIcon(IconData icon, int index) {
    final bool isSelected = _selectedIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected
            ? ColorManager.lightBrown.withOpacity(0.8)
            : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(8),
      child: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.grey[600],
        size: isSelected ? 28 : 24,
      ),
    );
  }

}
