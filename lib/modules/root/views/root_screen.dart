import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/modules/browse/views/browse_screen.dart';
import 'package:movie_app/modules/home/views/home_screen.dart';
import 'package:movie_app/modules/login/cubits/auth_cubit.dart';
import 'package:movie_app/modules/login/cubits/auth_state.dart';
import 'package:movie_app/modules/movie/views/my_watch_list_screen.dart';
import 'package:movie_app/modules/profile/views/profile_screen.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  final List<Widget> _screens = [
    const HomeTMDBScreen(),
    const BrowseScreen(),
    const MyWatchlistScreen(),
    const ProfileScreen(),
  ];
  final List<String> _titles = ['Home', 'Browse', 'Watchlist', 'Profile'];
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _screens[_selectedIndex],
      bottomNavigationBar: _bottomNavigateBar(),
    );
  }

  Widget _bottomNavigateBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05), width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(icon: Icons.home_rounded, label: 'Home', index: 0),
            _buildNavItem(
              icon: Icons.explore_rounded,
              label: 'Browse',
              index: 1,
            ),
            _buildNavItem(
              icon: Icons.bookmark_rounded,
              label: 'Watchlist',
              index: 2,
            ),
            _buildNavItem(
              icon: Icons.person_rounded,
              label: 'Profile',
              index: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    final primaryColor = const Color(0xFFFF6B35);

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : Colors.grey[500],
              size: 26,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
