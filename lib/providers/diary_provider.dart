import 'package:flutter/foundation.dart';
import '../models/diary_entry.dart';
import '../services/diary_service.dart';

class DiaryProvider extends ChangeNotifier {
  final _svc = DiaryService();
  List<DiaryEntry> _entries = [];
  bool isLoading = false;

  List<DiaryEntry> get entries => _entries;
  List<DiaryEntry> get starred => _entries.where((e) => e.isStarred).toList();

  Future<void> init() async {
    await _svc.initSampleData();
    await load();
  }

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    _entries = await _svc.getAll();
    isLoading = false;
    notifyListeners();
  }

  Future<void> save(DiaryEntry entry) async {
    await _svc.save(entry);
    await load();
  }

  Future<void> delete(String id) async {
    await _svc.delete(id);
    await load();
  }

  Future<void> toggleStar(String id) async {
    await _svc.toggleStar(id);
    await load();
  }

  Future<String> copyImage(String src) => _svc.copyImageToLocal(src);

  String newId() => _svc.generateId();

  DiaryEntry? get todayEntry {
    final today = DateTime.now();
    try {
      return _entries.firstWhere((e) =>
          e.date.year == today.year &&
          e.date.month == today.month &&
          e.date.day == today.day);
    } catch (_) {
      return null;
    }
  }

  List<DiaryEntry> forDate(DateTime d) => _entries
      .where((e) =>
          e.date.year == d.year &&
          e.date.month == d.month &&
          e.date.day == d.day)
      .toList();

  List<DiaryEntry> forMonth(int y, int m) =>
      _entries.where((e) => e.date.year == y && e.date.month == m).toList();
}
