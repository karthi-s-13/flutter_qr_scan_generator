import 'package:flutter/material.dart';
import '../../../data/models/scan_result_model.dart';
import '../../../data/storage/scan_history_storage.dart';
//import '../../result/presentation/scan_result_page.dart';
//import 'package:go_router/go_router.dart';

enum HistoryTab { scanned, generated }

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  HistoryTab currentTab = HistoryTab.scanned;
  String query = '';

  @override
  Widget build(BuildContext context) {
    final box = ScanHistoryStorage.box;

    final List<MapEntry<dynamic, ScanResultModel>> allItems =
        box.toMap().entries.toList().reversed.toList();

    final filtered = allItems.where((e) {
      return e.value.value
          .toLowerCase()
          .contains(query.toLowerCase());
    }).toList();

    final groups = _groupByTime(filtered);

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F14),
        elevation: 0,
        title: _searchBar(),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _tabs(),
          Expanded(
            child: groups.isEmpty
                ? const Center(
                    child: Text(
                      "No history found",
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    children: groups.entries.map((entry) {
                      return _section(entry.key, entry.value);
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  // ---------------- SEARCH ----------------
  Widget _searchBar() {
    return TextField(
      onChanged: (v) => setState(() => query = v),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Search history",
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        prefixIcon:
            const Icon(Icons.search, color: Colors.white54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ---------------- TABS ----------------
  Widget _tabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: HistoryTab.values.map((tab) {
          final bool active = currentTab == tab;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => currentTab = tab),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFF4F8CFF).withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tab == HistoryTab.scanned
                      ? "Scanned"
                      : "Generated",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: active
                        ? const Color(0xFF4F8CFF)
                        : Colors.white60,
                    fontWeight:
                        active ? FontWeight.w600 : null,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ---------------- SECTION ----------------
  Widget _section(
      String title, List<MapEntry<dynamic, ScanResultModel>> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((e) => _historyItem(e)).toList(),
      ],
    );
  }

  // ---------------- ITEM ----------------
  Widget _historyItem(MapEntry<dynamic, ScanResultModel> entry) {
    final item = entry.value;

    return Dismissible(
      key: ValueKey(entry.key),
      background: _favoriteBg(),
      secondaryBackground: _deleteBg(),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Favorite
          setState(() {});
          return false;
        } else {
          return await _confirmDelete(context);
        }
      },
      onDismissed: (_) async {
        await ScanHistoryStorage.box.delete(entry.key);
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              _iconFor(item.value),
              color: Colors.white70,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(item.scannedAt),
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.star_border,
                color: Colors.white54),
          ],
        ),
      ),
    );
  }

  // ---------------- HELPERS ----------------
  IconData _iconFor(String value) {
    return value.startsWith("http")
        ? Icons.link
        : Icons.qr_code;
  }

  String _formatTime(DateTime t) {
    return "${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}";
  }

  Map<String, List<MapEntry<dynamic, ScanResultModel>>> _groupByTime(
      List<MapEntry<dynamic, ScanResultModel>> list) {
    final now = DateTime.now();

    final Map<String, List<MapEntry<dynamic, ScanResultModel>>> map =
        {
      "Today": [],
      "Yesterday": [],
      "Older": [],
    };

    for (final item in list) {
      final diff = now.difference(item.value.scannedAt).inDays;
      if (diff == 0) {
        map["Today"]!.add(item);
      } else if (diff == 1) {
        map["Yesterday"]!.add(item);
      } else {
        map["Older"]!.add(item);
      }
    }

    map.removeWhere((k, v) => v.isEmpty);
    return map;
  }

  // ---------------- DIALOGS & BG ----------------
  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: const Color(0xFF0B0F14),
            title: const Text("Delete?",
                style: TextStyle(color: Colors.white)),
            content: const Text(
              "This item will be permanently removed.",
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pop(context, true),
                style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent),
                child: const Text("Delete"),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _favoriteBg() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 20),
      color: Colors.amber,
      child: const Icon(Icons.star, color: Colors.white),
    );
  }

  Widget _deleteBg() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      color: Colors.redAccent,
      child: const Icon(Icons.delete, color: Colors.white),
    );
  }
}
