import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';

class QrCustomizePage extends StatefulWidget {
  final String data;

  const QrCustomizePage({super.key, required this.data});

  @override
  State<QrCustomizePage> createState() => _QrCustomizePageState();
}

class _QrCustomizePageState extends State<QrCustomizePage>
    with SingleTickerProviderStateMixin {
  Color fgColor = Colors.black;
  Color bgColor = Colors.white;
  File? logoFile;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  Future<void> _pickLogo() async {
    final XFile? file =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) {
      setState(() => logoFile = File(file.path));
    }
  }

  bool get poorContrast =>
      fgColor.computeLuminance() - bgColor.computeLuminance() < 0.3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121826),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            /// QR PREVIEW
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: QrImageView(
                data: widget.data,
                size: 220,
                foregroundColor: fgColor,
                backgroundColor: bgColor,
                embeddedImage:
                    logoFile != null ? FileImage(logoFile!) : null,
                embeddedImageStyle: const QrEmbeddedImageStyle(
                  size: Size(44, 44),
                ),
              ),
            ),

            if (poorContrast)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  "⚠ Low contrast – QR may not scan properly",
                  style: TextStyle(
                    color: Colors.yellowAccent.shade400,
                    fontSize: 12,
                  ),
                ),
              ),

            const Spacer(),

            /// DRAGGABLE DESIGN PANEL
            Expanded(
              flex: 2,
              child: DraggableScrollableSheet(
                initialChildSize: 0.9,
                minChildSize: 0.6,
                maxChildSize: 1.0,
                builder: (_, controller) {
                  return Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F1420),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),

                        /// TABS
                        TabBar(
                          controller: _tabController,
                          indicatorColor: const Color(0xFF4F8CFF),
                          labelColor: const Color(0xFF4F8CFF),
                          unselectedLabelColor: Colors.white60,
                          tabs: const [
                            Tab(text: "Color"),
                            Tab(text: "Shape"),
                            Tab(text: "Logo"),
                            Tab(text: "Style"),
                          ],
                        ),

                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _colorTab(),
                              _placeholder("Shape controls coming soon"),
                              _logoTab(),
                              _placeholder("Style presets coming soon"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            /// ACTION BUTTONS
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download),
                      label: const Text("Download"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4F8CFF),
                        side: const BorderSide(
                            color: Color(0xFF4F8CFF)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.share),
                      label: const Text("Share"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F8CFF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------- TABS ----------------

  Widget _colorTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text("Foreground Color",
            style: TextStyle(color: Colors.white70)),
        ColorPicker(
          pickerColor: fgColor,
          onColorChanged: (c) => setState(() => fgColor = c),
          enableAlpha: false,
        ),
        const SizedBox(height: 12),
        const Text("Background Color",
            style: TextStyle(color: Colors.white70)),
        ColorPicker(
          pickerColor: bgColor,
          onColorChanged: (c) => setState(() => bgColor = c),
          enableAlpha: false,
        ),
      ],
    );
  }

  Widget _logoTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: _pickLogo,
            icon: const Icon(Icons.image),
            label: const Text("Upload Logo"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F8CFF),
            ),
          ),
          if (logoFile != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                "Logo added and auto-scaled safely",
                style:
                    TextStyle(color: Colors.greenAccent.shade400),
              ),
            ),
        ],
      ),
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
