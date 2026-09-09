import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../attendance/presentation/screens/attendance_board_screen.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../events/presentation/screens/events_screen.dart';
import '../../../notices/presentation/screens/notices_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  void _onTabSelected(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardScreen(onNavigateTab: _onTabSelected),
          const AttendanceBoardScreen(),
          const NoticesScreen(),
          const EventsScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,
        indicatorColor: AppColors.primaryBlue.withValues(alpha: 0.12),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon:
                Icon(Icons.dashboard_rounded, color: AppColors.primaryBlue),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today_rounded,
                color: AppColors.primaryBlue),
            label: 'Attendance',
          ),
          NavigationDestination(
            icon: Icon(Icons.feed_outlined),
            selectedIcon:
                Icon(Icons.feed_rounded, color: AppColors.primaryBlue),
            label: 'Notices',
          ),
          NavigationDestination(
            icon: Icon(Icons.celebration_outlined),
            selectedIcon:
                Icon(Icons.celebration_rounded, color: AppColors.primaryBlue),
            label: 'Events',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon:
                Icon(Icons.person_rounded, color: AppColors.primaryBlue),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
