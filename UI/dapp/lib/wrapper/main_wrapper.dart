import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;
  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 1;

  void _goToBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: double.infinity,
            child: widget.navigationShell,
          ),
          Positioned(
            left: 0.0,
            right: 0,
            bottom: 20,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(30.0)),
              child: SlidingClippedNavBar(
                backgroundColor: Colors.white,
                onButtonPressed: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                  _goToBranch(_selectedIndex);
                },
                activeColor: const Color.fromARGB(255, 26, 213, 173),
                selectedIndex: _selectedIndex,
                barItems: [
                  BarItem(icon: Icons.groups, title: 'Groups'),
                  BarItem(icon: Icons.dashboard, title: 'Home'),
                  BarItem(icon: Icons.task, title: 'Transaction'),
                  BarItem(icon: Icons.account_circle, title: 'Portfolio')
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
