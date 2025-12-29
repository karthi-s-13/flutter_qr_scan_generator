import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
//import 'package:qr_scan_generator/features/result/presentation/scan_result_page.dart';

import '../controller/scanner_controller.dart';
import '../widgets/top_action_button.dart';
//import '../widgets/bottom_nav_bar.dart';
import 'scan_frame.dart';
import '../../../core/utils/haptics.dart';
//import '../../result/presentation/scan_result_page.dart';
import '../../../data/storage/scan_history_storage.dart';

import 'package:go_router/go_router.dart';


class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final ScannerController scannerController = ScannerController();

  bool scanSuccess = false;
  bool isProcessing = false;
  bool isFlashOn = false;

  @override
  void dispose() {
    scannerController.dispose();
    super.dispose();
  }

  // ---------------- SCAN SUCCESS ----------------
  void _showSuccess(String value) {
    scannerController.turnOffFlash(isFlashOn);
    isFlashOn = false;

    ScanHistoryStorage.add(value);

    Haptics.light();
    setState(() => scanSuccess = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      if(!mounted) return;

      context.push('/result', extra: value);

      setState(() {
        scanSuccess = false;
        isProcessing = false;
      });
      
    });
    

  }

  // ---------------- LIVE CAMERA SCAN ----------------
  void onDetect(BarcodeCapture capture) {
    if (isProcessing) return;

    final barcode = capture.barcodes.first;
    final String? value = barcode.rawValue;

    if (value == null) return;

    isProcessing = true;
    _showSuccess(value);
  }

  // ---------------- GALLERY SCAN ----------------
  Future<void> onGalleryScan() async {
    if (isProcessing) return;

    isProcessing = true;

    final barcode = await scannerController.scanFromGallery();

    if (barcode?.rawValue == null) {
      isProcessing = false;
      _showError();
      return;
    }

    _showSuccess(barcode!.rawValue!);
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("No QR code found in image"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      body: Stack(
        children: [
          /// CAMERA
          MobileScanner(
            controller: scannerController.cameraController,
            onDetect: onDetect,
            errorBuilder: (context, error, child) {
              if (error is MobileScannerException &&
                  error.errorCode ==
                      MobileScannerErrorCode.permissionDenied) {
                return const _CameraPermissionDenied();
              }

              return const Center(
                child: Text(
                  "Camera error occurred",
                  style: TextStyle(color: Colors.white70),
                ),
              );
            },
          ),

          /// DARK OVERLAY
          Container(
            color: const Color(0xFF0B0F14).withOpacity(0.65),
          ),

          /// TOP ACTIONS
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TopActionButton(
                    icon:
                        isFlashOn ? Icons.flash_on : Icons.flash_off,
                    onTap: () {
                      scannerController.toggleFlash();
                      setState(() => isFlashOn = !isFlashOn);
                      
                    },
                  ),
                  TopActionButton(
                    icon: Icons.photo_library_outlined,
                    onTap: onGalleryScan,
                  ),
                ],
              ),
            ),
          ),

          /// SCAN FRAME
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                ScanFrame(),
                SizedBox(height: 16),
                Text(
                  "Align QR inside frame",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          /// SUCCESS FADE (NON-BLOCKING)
          IgnorePointer(
            ignoring: true,
            child: AnimatedOpacity(
              opacity: scanSuccess ? 1 : 0,
              duration: const Duration(milliseconds: 400),
              child: Container(
                color:
                    const Color(0xFF4F8CFF).withOpacity(0.15),
              ),
            ),
          ),

        
           ],
      ),
    );
  }
}

// ---------------- PERMISSION DENIED UI ----------------
class _CameraPermissionDenied extends StatelessWidget {
  const _CameraPermissionDenied();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0B0F14),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(
            Icons.no_photography,
            size: 64,
            color: Colors.white70,
          ),
          SizedBox(height: 16),
          Text(
            "Camera Permission Required",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            "Please allow camera access to scan QR codes.",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
