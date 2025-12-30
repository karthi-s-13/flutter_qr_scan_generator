import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';


enum QRType { url, wifi, contact, text }

class ScanResultPage extends StatefulWidget {
  final String result;

  const ScanResultPage({super.key, required this.result});

  @override
  State<ScanResultPage> createState() => _ScanResultPageState();
}

class _ScanResultPageState extends State<ScanResultPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  // ---------------- QR TYPE DETECTION ----------------
  QRType get qrType {
    final data = widget.result;

    if (data.startsWith('WIFI:')) return QRType.wifi;
    if (data.startsWith('BEGIN:VCARD')) return QRType.contact;
    if (Uri.tryParse(data)?.hasAbsolutePath ?? false) {
      return QRType.url;
    }
    return QRType.text;
  }

  bool get isUrl => qrType == QRType.url;

  // ---------------- DOMAIN ----------------
  String get domain {
    if (!isUrl) return '';
    try {
      return Uri.parse(widget.result).host;
    } catch (_) {
      return '';
    }
  }

  // ---------------- WIFI PARSER ----------------
  Map<String, String> get wifiData {
    final Map<String, String> map = {};
    final content = widget.result.replaceFirst('WIFI:', '');
    final parts = content.split(';');

    for (final p in parts) {
      if (p.startsWith('S:')) map['ssid'] = p.substring(2);
      if (p.startsWith('P:')) map['password'] = p.substring(2);
      if (p.startsWith('T:')) map['type'] = p.substring(2);
    }
    return map;
  }

  //----------------vCARD PARSER ----------------
  Map<String, String> praseVCard(String data){
    final Map<String, String> contact = {};
    final lines = data.split('\n');

    for (final line in lines){
      if(line.startsWith('FN:')){
        contact['name'] = line.substring(3).trim();
      } else if (line.startsWith('TEL:')){
        contact['phone'] = line.split(':').last.trim();
      } else if (line.startsWith('EMAIL:')){
        contact['email'] = line.split(':').last.trim();
      }
      else if (line.startsWith('ORG:')){
        contact['org'] = line.substring(3).trim();
      }
    }

    return contact;
  }

  //----------------- addContactToDevice  ----------------
  Future<void> addContactToPhone(Map<String, String> contact) async {
    final Uri uri = Uri(
      scheme: 'content',
      host: 'com.android.contacts',
      path: 'contacts',
      queryParameters: {
        'name': contact['name'] ?? '',
        'phone': contact['phone'] ?? '',
        'email': contact['email'] ?? '',
      },
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to open contacts app"),
        ),
      );
    }
  }

  Future<void> _openWifiSettings() async {
  const intent = AndroidIntent(
    action: 'android.settings.WIFI_SETTINGS',
  );
  await intent.launch();
}


  Uri? _safeParseUrl(String raw) {
    final value = raw.trim();

  // Already valid URL
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return Uri.tryParse(value);
    }

  // Handle URLs like google.com / www.google.com
    if (value.contains('.') && !value.contains(' ')) {
      return Uri.tryParse('https://$value');
  }

    return null;
  }


  // ---------------- OPEN URL ----------------
  Future<void> _openBrowser() async {
    final uri = _safeParseUrl(widget.result);

    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid URL")),
      );
      return;
    }

    try {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open browser")),
      );
    }
  }


  // ---------------- INIT ----------------
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F14),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Scan Result"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// RESULT CARD
            ScaleTransition(
              scale: _scaleAnimation,
              child: _resultCard(),
            ),

            const SizedBox(height: 24),

            /// PRIMARY ACTION
            _primaryAction(),

            const SizedBox(height: 20),

            /// SECONDARY ACTIONS
            _secondaryActions(),
          ],
        ),
      ),
    );
  }

  // ---------------- RESULT CARD ----------------
  Widget _resultCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TYPE ROW
          Row(
            children: [
              Icon(
                qrType == QRType.url
                    ? Icons.link
                    : qrType == QRType.wifi
                        ? Icons.wifi
                        : qrType == QRType.contact
                            ? Icons.person
                            : Icons.text_snippet,
                color: qrType == QRType.url
                    ? Colors.greenAccent
                    : qrType == QRType.wifi
                        ? Colors.blueAccent
                        : Colors.white70,
              ),
              const SizedBox(width: 8),
              Text(
                qrType == QRType.url
                    ? "Web Link"
                    : qrType == QRType.wifi
                        ? "Wi-Fi Network"
                        : qrType == QRType.contact
                            ? "Contact"
                            : "Text",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// CONTENT
          if (qrType == QRType.wifi) ...[
            Text(
              "Wi-Fi Name: ${wifiData['ssid'] ?? '-'}",
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              "Password: ${wifiData['password'] ?? '-'}",
              style: const TextStyle(color: Colors.white70),
            ),
          ] else
            SelectableText(
              widget.result,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            ),

          if (domain.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              "Domain: $domain",
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------- PRIMARY ACTION ----------------
  Widget _primaryAction() {
    if (qrType == QRType.url) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.open_in_browser),
          label: const Text("Open in Browser"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.greenAccent.shade400,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: _openBrowser,
        ),
      );
    }

    if (qrType == QRType.wifi) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.wifi),
          label: const Text("Connect to Wi-Fi"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () async {
            Clipboard.setData(
              ClipboardData(text: wifiData['password'] ?? ''),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "Password copied. Open Wi-Fi settings to connect.",
                ),
              ),
            );
            await _openWifiSettings();
          },
        ),
      );
    }

    if (qrType == QRType.contact) {
      final contact = praseVCard(widget.result);
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.person_add),
          label: const Text("Add to Contacts"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purpleAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: () => addContactToPhone(contact),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // ---------------- SECONDARY ACTIONS ----------------
  Widget _secondaryActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _actionIcon(
          icon: Icons.copy,
          label: "Copy",
          color: Colors.greenAccent,
          onTap: () {
            Clipboard.setData(
              ClipboardData(text: widget.result),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Copied to clipboard")),
            );
          },
        ),
        _actionIcon(
          icon: Icons.share,
          label: "Share",
          color: Colors.white70,
          onTap: () => Share.share(widget.result),
        ),
        _actionIcon(
          icon: Icons.star_border,
          label: "Favorite",
          color: Colors.yellowAccent,
          onTap: () {
            // TODO: Save to favorites
          },
        ),
      ],
    );
  }

  Widget _actionIcon({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
