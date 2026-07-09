import 'package:flutter/material.dart';
import 'file_browser_screen.dart';
import 'locker_screen.dart';
import 'theme_selector_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final _screens = const [
    FileBrowserScreen(),
    LockerScreen(),
    ThemeSelectorScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.02), end: Offset.zero).animate(anim),
            child: child,
          ),
        ),
        child: KeyedSubtree(key: ValueKey(_index), child: _screens[_index]),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: theme.colorScheme.surface,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.folder_rounded), label: 'Files'),
          NavigationDestination(icon: Icon(Icons.lock_rounded), label: 'Locker'),
          NavigationDestination(icon: Icon(Icons.palette_rounded), label: 'Themes'),
        ],
      ),
    );
  }
}
