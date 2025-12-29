import 'package:hive/hive.dart';

part 'scan_result_model.g.dart';

@HiveType(typeId: 0)
class ScanResultModel extends HiveObject {
  @HiveField(0)
  final String value;

  @HiveField(1)
  final DateTime scannedAt;

  ScanResultModel({
    required this.value,
    required this.scannedAt,
  });
}
