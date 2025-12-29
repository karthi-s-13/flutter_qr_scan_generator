import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int activeIndex;
  final Function(int)? onTap;

  const AppBottomNav({
    super.key,
    required this.activeIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFF0B0F14),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _item(Icons.qr_code_scanner, "Scan", 0),
          _item(Icons.add_box_outlined, "Create", 1),
          _item(Icons.history, "History", 2),
        ],
      ),
    );
  }

  Widget _item(IconData icon, String label, int index) {
    final bool active = index == activeIndex;

    return GestureDetector(
      onTap: () => onTap?.call(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: active ? const Color(0xFF4F8CFF) : Colors.white60,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: active ? const Color(0xFF4F8CFF) : Colors.white60,
            ),
          ),
        ],
      ),
    );
  }
}
