import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../model/qr_style_result.dart';

class CustomizeQrPage extends StatefulWidget {
  final String data;
  final Color fgColor;
  final Color bgColor;
  final bool showLogo;

  const CustomizeQrPage({
    super.key,
    required this.data,
    required this.fgColor,
    required this.bgColor,
    required this.showLogo,
  });

  @override
  State<CustomizeQrPage> createState() => _CustomizeQrPageState();
}

class _CustomizeQrPageState extends State<CustomizeQrPage> {
  late Color qrColor;
  late Color backgroundColor;
  late bool showLogo;

  @override
  void initState() {
    super.initState();
    qrColor = widget.fgColor;
    backgroundColor = widget.bgColor;
    showLogo = widget.showLogo;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _returnResult();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121826),
        appBar: AppBar(
          backgroundColor: const Color(0xFF121826),
          elevation: 0,
          title: const Text("Customize QR"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _returnResult,
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              /// ================= QR PREVIEW =================
              Column(
                children: [
                  const SizedBox(height: 24),
                  Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: widget.data,
                        size: 240,
                        foregroundColor: qrColor,
                        backgroundColor: backgroundColor,
                        embeddedImage: showLogo
                            ? const AssetImage('assets/logo.png')
                            : null,
                        embeddedImageStyle:
                            const QrEmbeddedImageStyle(
                          size: Size(42, 42),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Live Preview",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const Spacer(),
                ],
              ),

              /// ================= BOTTOM SHEET =================
              DraggableScrollableSheet(
                initialChildSize: 0.45,
                minChildSize: 0.3,
                maxChildSize: 0.75,
                builder: (context, controller) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F1420),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(height: 16),
                        DefaultTabController(
                          length: 4,
                          child: Expanded(
                            child: Column(
                              children: [
                                const TabBar(
                                  indicatorColor: Color(0xFF4F8CFF),
                                  labelColor: Color(0xFF4F8CFF),
                                  unselectedLabelColor: Colors.white60,
                                  tabs: [
                                    Tab(text: "Color"),
                                    Tab(text: "Shape"),
                                    Tab(text: "Logo"),
                                    Tab(text: "Style"),
                                  ],
                                ),
                                Expanded(
                                  child: TabBarView(
                                    children: [
                                      _colorTab(),
                                      _placeholder(
                                          "Shape options coming soon"),
                                      _logoTab(),
                                      _placeholder(
                                          "Style presets coming soon"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= RETURN RESULT =================
  void _returnResult() {
    Navigator.pop(
      context,
      QrStyleResult(
        qrColor: qrColor,
        bgColor: backgroundColor,
        showLogo: showLogo,
      ),
    );
  }

  // ================= COLOR TAB =================
  Widget _colorTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("QR Color",
            style: TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        _colorSelector(
          color: qrColor,
          label: "Foreground",
          onTap: () => _openColorPicker(
            initial: qrColor,
            onSelect: (c) => setState(() => qrColor = c),
          ),
        ),
        const SizedBox(height: 24),
        const Text("Background Color",
            style: TextStyle(color: Colors.white)),
        const SizedBox(height: 8),
        _colorSelector(
          color: backgroundColor,
          label: "Background",
          onTap: () => _openColorPicker(
            initial: backgroundColor,
            onSelect: (c) =>
                setState(() => backgroundColor = c),
          ),
        ),
        const SizedBox(height: 16),
        _contrastWarning(),
      ],
    );
  }

  // ================= LOGO TAB =================
  Widget _logoTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          value: showLogo,
          activeColor: const Color(0xFF4F8CFF),
          title: const Text(
            "Show Logo",
            style: TextStyle(color: Colors.white),
          ),
          onChanged: (v) => setState(() => showLogo = v),
        ),
      ],
    );
  }

  // ================= HELPERS =================
  Widget _colorSelector({
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
            const Spacer(),
            const Icon(Icons.palette, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  void _openColorPicker({
    required Color initial,
    required ValueChanged<Color> onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F1420),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        Color tempColor = initial;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                ColorPicker(
                  pickerColor: tempColor,
                  onColorChanged: (c) {
                    tempColor = c;
                    onSelect(c);
                  },
                  enableAlpha: false,
                  displayThumbColor: true,
                  pickerAreaHeightPercent: 0.6,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F8CFF),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text("Done"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _contrastWarning() {
    final diff = (qrColor.computeLuminance() -
            backgroundColor.computeLuminance())
        .abs();

    return Row(
      children: [
        Icon(
          diff > 0.35
              ? Icons.check_circle
              : Icons.warning_amber,
          color: diff > 0.35
              ? Colors.greenAccent
              : Colors.orangeAccent,
        ),
        const SizedBox(width: 8),
        Text(
          diff > 0.35
              ? "Good contrast for scanning"
              : "Low contrast may affect scan",
          style: TextStyle(
            color: diff > 0.35
                ? Colors.greenAccent
                : Colors.orangeAccent,
          ),
        ),
      ],
    );
  }

  Widget _placeholder(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(color: Colors.white54),
      ),
    );
  }
}
