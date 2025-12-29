import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum QRCategory { url, wifi, contact, text }

class GeneratorPage extends StatefulWidget {
  const GeneratorPage({super.key});

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  QRCategory selected = QRCategory.url;

  final TextEditingController urlCtrl = TextEditingController();
  final TextEditingController wifiNameCtrl = TextEditingController();
  final TextEditingController wifiPassCtrl = TextEditingController();
  final TextEditingController contactCtrl = TextEditingController();
  final TextEditingController textCtrl = TextEditingController();

  String qrData = '';

  Color qrColor = Colors.black;
  Color bgColor = Colors.white;
  bool showLogo = false;

  @override
  void dispose() {
    urlCtrl.dispose();
    wifiNameCtrl.dispose();
    wifiPassCtrl.dispose();
    contactCtrl.dispose();
    textCtrl.dispose();
    super.dispose();
  }

  // ---------------- QR DATA ----------------
  void _updateQR() {
    setState(() {
      switch (selected) {
        case QRCategory.url:
          qrData = urlCtrl.text;
          break;
        case QRCategory.wifi:
          qrData =
              "WIFI:T:WPA;S:${wifiNameCtrl.text};P:${wifiPassCtrl.text};;";
          break;
        case QRCategory.contact:
          qrData = contactCtrl.text;
          break;
        case QRCategory.text:
          qrData = textCtrl.text;
          break;
      }
    });
  }

  // ---------------- QR PAINTER (CORE) ----------------
  Future<Uint8List> _generateQrPng() async {
    final painter = QrPainter(
      data: qrData,
      version: QrVersions.auto,
      gapless: true,
      color: qrColor,
      emptyColor: bgColor,
    );

    final image = await painter.toImage(800); // HIGH RES
    final byteData =
        await image.toByteData(format: ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
  }

  // ---------------- SAVE IMAGE ----------------
  Future<void> _saveQrToGallery() async {
    try {
      final pngBytes = await _generateQrPng();

      final downloadsDir =
          Directory('/storage/emulated/0/Download/QR Scanner');

      if (!downloadsDir.existsSync()) {
        downloadsDir.createSync(recursive: true);
      }

      final file = File(
        '${downloadsDir.path}/qr_${selected.name}_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      await file.writeAsBytes(pngBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("QR saved to Downloads/QR Scanner"),
        ),
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to save QR")),
      );
    }
  }

  // ---------------- SHARE IMAGE ----------------
  Future<void> _shareQrImage() async {
    try {
      final pngBytes = await _generateQrPng();

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/qr_share_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'My QR Code',
      );
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to share QR")),
      );
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F14),
        elevation: 0,
        title: const Text("Create QR"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _categoryGrid(),
            const SizedBox(height: 24),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _inputFields(),
            ),

            const SizedBox(height: 24),

            if (qrData.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: QrImageView(
                  data: qrData,
                  size: 160,
                  foregroundColor: qrColor,
                  backgroundColor: bgColor,
                  embeddedImage: showLogo
                      ? const AssetImage('assets/logo.png')
                      : null,
                  embeddedImageStyle:
                      const QrEmbeddedImageStyle(
                    size: Size(32, 32),
                  ),
                ),
              )
            else
              const Center(
                child: Text(
                  "QR Preview will apphear here",
                  style: TextStyle(
                    color: Colors.white54,
                    fontStyle: FontStyle.italic
                  ),
                ),
              ),

            

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    qrData.isEmpty ? null : _openCustomizeSheet,
                child: const Text("Customize QR"),
              ),
            ),

            const SizedBox(height: 32),

            

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: qrData.isEmpty ? null : _saveQrToGallery,
              icon: const Icon(Icons.download),
              label: const Text("Save QR as Image"),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: qrData.isEmpty ? null : _shareQrImage,
              icon: const Icon(Icons.share),
              label: const Text("Share QR Image"),
          ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ---------------- CATEGORY GRID ----------------
  Widget _categoryGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _categoryCard(QRCategory.url, Icons.link, "URL"),
        _categoryCard(QRCategory.wifi, Icons.wifi, "Wi-Fi"),
        _categoryCard(QRCategory.contact, Icons.person, "Contact"),
        _categoryCard(QRCategory.text, Icons.text_fields, "Text"),
      ],
    );
  }

  Widget _categoryCard(QRCategory type, IconData icon, String label) {
    final active = selected == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          selected = type;
          qrData = '';
        });
      },
      child: Card(
        color: active
            ? const Color(0xFF4F8CFF).withOpacity(0.2)
            : Colors.white10,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color:
                    active ? Colors.blueAccent : Colors.white),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    color: active
                        ? Colors.blueAccent
                        : Colors.white)),
          ],
        ),
      ),
    );
  }

  // ---------------- INPUT FIELDS ----------------
  Widget _inputFields() {
    switch (selected) {
      case QRCategory.url:
        return _inputField(urlCtrl, "Enter URL");
      case QRCategory.wifi:
        return Column(
          children: [
            _inputField(wifiNameCtrl, "Wi-Fi Name"),
            const SizedBox(height: 12),
            _inputField(wifiPassCtrl, "Password"),
          ],
        );
      case QRCategory.contact:
        return _inputField(contactCtrl, "Contact details");
      case QRCategory.text:
        return _inputField(textCtrl, "Enter text");
    }
  }

  Widget _inputField(
      TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      onChanged: (_) => _updateQR(),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ---------------- CUSTOMIZE SHEET ----------------
  void _openCustomizeSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B0F14),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _colorPicker("QR Color", qrColor,
                (c) => setState(() => qrColor = c)),
            _colorPicker("Background", bgColor,
                (c) => setState(() => bgColor = c)),
            SwitchListTile(
              value: showLogo,
              title: const Text("Show Logo",
                  style: TextStyle(color: Colors.white)),
              onChanged: (v) =>
                  setState(() => showLogo = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorPicker(
      String label, Color color, Function(Color) onPick) {
    return ListTile(
      title: Text(label,
          style: const TextStyle(color: Colors.white)),
      trailing: GestureDetector(
        onTap: () => showDialog(
          context: context,
          builder: (_) => AlertDialog(
            content: ColorPicker(
              pickerColor: color,
              onColorChanged: onPick,
            ),
          ),
        ),
        child: Container(
          width: 30,
          height: 30,
          color: color,
        ),
      ),
    );
  }
}
