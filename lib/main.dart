import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
//import 'package:go_router/go_router.dart';

import 'routes/app_routes.dart';
import 'data/models/scan_result_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(ScanResultModelAdapter());
  await Hive.openBox<ScanResultModel>('scan_history');

  runApp(const QRScanGeneratorApp());
}

class QRScanGeneratorApp extends StatelessWidget {
  const QRScanGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData.dark(useMaterial3: true),
    );
  }
}
