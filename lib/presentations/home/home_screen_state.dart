import 'package:flutter/material.dart';

import '../../generated/l10n.dart' show S;
import '../resources/color_manager.dart';
import '../resources/styles_manager.dart';
import 'home.dart';

class HomeScreenState extends StatefulWidget {
  const HomeScreenState({super.key});

  @override
  State<HomeScreenState> createState() => _HomeScreenStateState();
}

class _HomeScreenStateState extends State<HomeScreenState> {
  int _selectedIndex = 0; // Track selected bottom nav item
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected tab
    });
  }

  final List<Widget> screens = [
    Home(),
    Placeholder(),
    Placeholder(),
    Placeholder()
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
                icon: _buildNavIcon(Icons.edit_document, 1),
                label: S.of(context).complaints),
            BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.people_outlined, 2),
                label: S.of(context).communities),
            BottomNavigationBarItem(
                icon: _buildNavIcon(Icons.person_3_outlined, 3),
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
