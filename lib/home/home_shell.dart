import 'package:flutter/material.dart';

import '../features/scanner/presentation/scanner_page.dart';
import '../features/generator/presentation/generator_page.dart';
import '../features/history/presentation/history_page.dart';
import '../features/scanner/widgets/bottom_nav_bar.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    ScannerPage(),
    GeneratorPage(),
    HistoryPage(),
  ];

  void onNavTap(int index) {
    if (index == currentIndex) return;
    setState(() => currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: AppBottomNav(
        activeIndex: currentIndex,
        onTap: onNavTap,
      ),
    );
  }
}
