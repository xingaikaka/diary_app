import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/diary_entry.dart';

class DiaryService {
  static const String _key = 'diary_entries_v1';
  static const String _initKey = 'sample_init_v1';
  static final DiaryService _i = DiaryService._();
  factory DiaryService() => _i;
  DiaryService._();

  final _uuid = const Uuid();

  String generateId() => _uuid.v4();

  Future<List<DiaryEntry>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    final entries = list
        .map((s) => DiaryEntry.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  Future<void> save(DiaryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getAll();
    final idx = entries.indexWhere((e) => e.id == entry.id);
    if (idx >= 0) {
      entries[idx] = entry;
    } else {
      entries.add(entry);
    }
    await prefs.setStringList(
        _key, entries.map((e) => jsonEncode(e.toJson())).toList());
  }

  Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getAll();
    entries.removeWhere((e) => e.id == id);
    await prefs.setStringList(
        _key, entries.map((e) => jsonEncode(e.toJson())).toList());
  }

  Future<void> toggleStar(String id) async {
    final entries = await getAll();
    final idx = entries.indexWhere((e) => e.id == id);
    if (idx >= 0) await save(entries[idx].copyWith(isStarred: !entries[idx].isStarred));
  }

  Future<String> copyImageToLocal(String sourcePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final imgDir = Directory('${dir.path}/diary_images');
    if (!await imgDir.exists()) await imgDir.create(recursive: true);
    final dest = '${imgDir.path}/${_uuid.v4()}.jpg';
    await File(sourcePath).copy(dest);
    return dest;
  }

  Future<void> initSampleData() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_initKey) == true) return;
    final now = DateTime.now();
    final samples = [
      DiaryEntry(
        id: _uuid.v4(),
        date: now,
        title: '美好的一天',
        content: '今天天气真好，阳光明媚，心情也跟着好了起来！早上去了公园，看到了很多盛开的花朵。下午和朋友一起喝了下午茶，聊了好久，感觉很充实很开心。',
        mood: '😊',
        isStarred: true,
        imagePaths: ['https://picsum.photos/seed/diary1/400/300'],
        tag: '开心',
      ),
      DiaryEntry(
        id: _uuid.v4(),
        date: now.subtract(const Duration(days: 1)),
        title: '有点累的一天',
        content: '今天工作量有点大，从早上一直忙到晚上，终于把项目赶完了。虽然很累，但是看到自己的成果还是挺满足的。晚上回家做了一顿好吃的犒劳自己。',
        mood: '😴',
        tag: '工作',
      ),
      DiaryEntry(
        id: _uuid.v4(),
        date: now.subtract(const Duration(days: 3)),
        title: '周末的悠闲时光',
        content: '终于等到周末了！今天睡到自然醒，悠悠哉哉地做了早餐。下午看了一部一直想看的电影，非常好看！晚上和家人视频聊天，感觉很温暖。',
        mood: '😌',
        isStarred: true,
        imagePaths: [
          'https://picsum.photos/seed/diary3/400/300',
          'https://picsum.photos/seed/diary4/400/300',
        ],
        tag: '生活',
      ),
      DiaryEntry(
        id: _uuid.v4(),
        date: now.subtract(const Duration(days: 5)),
        title: '有点小烦恼',
        content: '今天遇到了一些小麻烦，有件事情没处理好，心里有点不舒服。不过想想，人生中总会有这样的时刻，调整心态，明天继续加油！',
        mood: '🤔',
      ),
      DiaryEntry(
        id: _uuid.v4(),
        date: now.subtract(const Duration(days: 7)),
        title: '今天学到了新东西',
        content: '今天参加了一个线上课程，学到了很多有趣的知识。原来这个领域这么有意思！打算继续深入学习，感觉找到了新的兴趣爱好。',
        mood: '😎',
        isStarred: true,
        imagePaths: ['https://picsum.photos/seed/diary5/400/300'],
        tag: '学习',
      ),
      DiaryEntry(
        id: _uuid.v4(),
        date: now.subtract(const Duration(days: 10)),
        title: '今天很开心',
        content: '收到了一个意外的好消息，真的好开心！要好好庆祝一下，感谢生活中的每一个小确幸。',
        mood: '🥳',
        isStarred: true,
        imagePaths: ['https://picsum.photos/seed/diary6/400/300'],
        tag: '庆祝',
      ),
      DiaryEntry(
        id: _uuid.v4(),
        date: now.subtract(const Duration(days: 14)),
        title: '下雨天的心情',
        content: '今天下雨了，心情有点低落。窝在家里听音乐、喝热茶，也挺惬意的。有时候安静独处也是一种放松。',
        mood: '😢',
        tag: '心情',
      ),
    ];
    for (final e in samples) {
      await save(e);
    }
    await prefs.setBool(_initKey, true);
  }
}
