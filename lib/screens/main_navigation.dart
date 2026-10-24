import 'package:flutter/material.dart';
import 'package:yaqin/localization/app_localization.dart';
import 'package:yaqin/screens/radar_screen.dart';
import 'package:yaqin/screens/map_screen.dart';
import 'package:yaqin/screens/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  final String currentUserId;
  const MainNavigation({Key? key, required this.currentUserId}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final loc = YaqinLocalization.of(context);

    final pages = [
      RadarScreen(currentUserId: widget.currentUserId),
      MapScreen(currentUserId: widget.currentUserId),
      ProfileScreen(currentUserId: widget.currentUserId),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Theme.of(context).primaryColor,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.radar),
            label: loc.translate('radar'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map_outlined),
            activeIcon: const Icon(Icons.map),
            label: loc.translate('map'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: loc.translate('profile'),
          ),
        ],
      ),
    );
  }
}
