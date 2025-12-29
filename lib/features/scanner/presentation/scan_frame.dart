import 'package:flutter/material.dart';
import '../widgets/scan_line.dart';

class ScanFrame extends StatelessWidget {
  const ScanFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF4F8CFF),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4F8CFF).withOpacity(0.35),
                  blurRadius: 16,
                )
              ],
            ),
          ),
          const ScanLine(),
        ],
      ),
    );
  }
}
