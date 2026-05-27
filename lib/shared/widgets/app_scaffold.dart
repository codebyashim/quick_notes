import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith('/dashboard/files')) return 1;
    if (location.startsWith('/dashboard/profile')) return 2;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard/notes');
      case 1:
        context.go('/dashboard/files');
      case 2:
        context.go('/dashboard/profile');
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final selectedIndex = _locationToIndex(location);
    final isWide = MediaQuery.of(context).size.width >= 700;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: const Color(0xFF1E1F22),
              selectedIndex: selectedIndex,
              onDestinationSelected: (i) => _onTap(context, i),
              labelType: NavigationRailLabelType.all,
              minWidth: 80,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.note_alt_outlined),
                  selectedIcon: Icon(Icons.note_alt_rounded),
                  label: Text('Notes'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.folder_outlined),
                  selectedIcon: Icon(Icons.folder_rounded),
                  label: Text('Files'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: Text('Profile'),
                ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (i) => _onTap(context, i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt_outlined),
            activeIcon: Icon(Icons.note_alt_rounded),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder_rounded),
            label: 'Files',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
