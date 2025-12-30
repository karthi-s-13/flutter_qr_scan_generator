import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
//import '../../customize/presentation/customize_qr_page.dart';
//import '../../customize/model/qr_style_result.dart';


class QrStyleResult {
  final Color qrColor;
  final Color bgColor;
  final bool showLogo;

  QrStyleResult({
    required this.qrColor,
    required this.bgColor,
    required this.showLogo,
  });
}

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
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController orgCtrl = TextEditingController();

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
          qrData = '''
        BEGIN:VCARD
        VERSION:3.0
        FN:${nameCtrl.text}
        TEL:${phoneCtrl.text}
        EMAIL:${emailCtrl.text}
        ORG:${orgCtrl.text}
        END:VCARD
        ''';
          break;

        case QRCategory.text:
          qrData = textCtrl.text;
          break;
      }
    });
  }

  // ---------------- QR PAINTER (CORE) ----------------
  Future<Uint8List> _generateQrPng({int size = 800}) async {
    const int padding = 32;

    final painter = QrPainter(
      data: qrData,
      version: QrVersions.auto,
      gapless: true,
      color: qrColor,
      emptyColor: bgColor,
      embeddedImageStyle: const QrEmbeddedImageStyle(
        size: Size(40,40),
      ),
    );

    final qrImage = await painter.toImage(size - padding * 2);

    final recorder = PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0,0, size.toDouble(), size.toDouble()));

    //final paint = Paint()..color = bgColor;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
      Paint()..color = bgColor,
    );

    canvas.drawImage(qrImage, Offset(padding.toDouble(), padding.toDouble()), Paint());

    final pciture = recorder.endRecording();
    final finalImage = await pciture.toImage(size, size);
    final byteData = await finalImage.toByteData(format: ImageByteFormat.png);

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
    } catch (e) {
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
              Center(
                child: Container(
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
                    embeddedImageStyle: const QrEmbeddedImageStyle(
                      size: Size(32, 32),
                    ),
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
        return Column(
          children: [
            _inputField(nameCtrl, "Full Name"),
            const SizedBox(height: 12),
            _inputField(phoneCtrl, "Phone Number"),
            const SizedBox(height: 12),
            _inputField(emailCtrl, "Email Address"),
            const SizedBox(height: 12),
            _inputField(orgCtrl, "Organization (optional)"),
          ],
        );

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
}