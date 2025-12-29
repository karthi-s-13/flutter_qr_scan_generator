import 'package:hive/hive.dart';
import '../models/scan_result_model.dart';

class ScanHistoryStorage {
  static const String boxName = 'scan_history';

  static Box<ScanResultModel> get _box =>
      Hive.box<ScanResultModel>(boxName);

  static Box<ScanResultModel> get box =>
    Hive.box<ScanResultModel>(boxName);


  static Future<void> add(String value) async {
    await _box.add(
      ScanResultModel(
        value: value,
        scannedAt: DateTime.now(),
      ),
    );
  }

  static Future<void> clearAll() async {
    await _box.clear();
  }

  static List<ScanResultModel> getAll() {
    return _box.values.toList().reversed.toList();
  }

  static Future<void> delete(int index) async {
    await _box.deleteAt(index);
  }
}
