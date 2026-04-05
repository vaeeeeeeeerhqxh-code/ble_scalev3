import 'package:flutter/material.dart';
import 'scan_page.dart';
import 'settings_screen.dart';
import 'ble_scan_page.dart';
import 'main.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  List<Widget> get _pages => [
    const ScanPage(title: 'Главная'),
    const SettingsPage(),
  ];

  void _openBleScan() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BleScanPage()),
    );
  }

  void _toggleTheme() {
    themeNotifier.value = themeNotifier.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, mode, _) {
        final isDark = mode == ThemeMode.dark;
        final barColor = isDark ? const Color(0xFF1A2340) : Colors.white;
        final iconColor = isDark ? Colors.white38 : Colors.black38;
        final activeColor = const Color(0xFF4C6EF5);

        return Scaffold(
          body: IndexedStack(
            index: _index,
            children: _pages,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _openBleScan,
            backgroundColor: const Color(0xFF4C6EF5),
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomAppBar(
            color: barColor,
            shape: const CircularNotchedRectangle(),
            notchMargin: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.home,
                    color: _index == 0 ? activeColor : iconColor,
                  ),
                  onPressed: () => setState(() => _index = 0),
                ),
                const SizedBox(width: 40),
                IconButton(
                  icon: Icon(
                    Icons.settings,
                    color: _index == 1 ? activeColor : iconColor,
                  ),
                  onPressed: () => setState(() => _index = 1),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}