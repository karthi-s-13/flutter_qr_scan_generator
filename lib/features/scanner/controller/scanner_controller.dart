import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerController {
  final MobileScannerController cameraController =
      MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        torchEnabled: false,
      );

  final ImagePicker _picker = ImagePicker();

  // 🔦 Toggle flash (SAFE for all 5.x versions)
  void toggleFlash() {
    cameraController.toggleTorch();
  }

  // 🔥 Force turn off flash (SAFE way)
  void turnOffFlash(bool isFlashOn) {
    if (isFlashOn) {
      cameraController.toggleTorch();
    }
  }

  // 🖼️ Scan from gallery
  Future<Barcode?> scanFromGallery() async {
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) return null;

    try {
      final BarcodeCapture? result =
          await cameraController.analyzeImage(image.path);

      if (result == null || result.barcodes.isEmpty) {
        return null;
      }

      return result.barcodes.first;
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    cameraController.dispose();
  }
}
