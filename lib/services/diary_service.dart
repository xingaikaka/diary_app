import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/diary_entry.dart';

class DiaryService {
  static const String _key = 'diary_entries_v3';
  static const String _initKey = 'sample_init_v3';
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
        title: '阳光晒过的午后',
        content: '风是软的，光是暖的。午后绕到公园走了一圈，花开得正好，连呼吸都带着草木的清香。和老朋友坐着喝茶，聊到日头偏西也没舍得走——原来幸福，不过是有人愿意陪你浪费一下午的时光。',
        mood: '😊',
        isStarred: true,
        imagePaths: ['https://picsum.photos/seed/diary1/400/300'],
        tag: '小确幸',
      ),
      DiaryEntry(
        id: _uuid.v4(),
        date: now.subtract(const Duration(days: 1)),
        title: '忙完之后的那碗热汤',
        content: '从清晨忙到星辰升起，手里的事终于落了地。身体是累的，心却是踏实的。回家给自己煮了一碗热汤，热气模糊了眼镜，也熨平了一天的疲惫。认真生活的人，连犒劳自己都格外温柔。',
        mood: '😴',
        tag: '日常',
      ),
      DiaryEntry(
        id: _uuid.v4(),
        date: now.subtract(const Duration(days: 3)),
        title: '把周末过得很慢',
        content: '睡到自然醒，慢悠悠地煎了蛋、磨了咖啡。午后看了一部一直惦记的老电影，窗外的云走得很慢。傍晚和家人视频，听他们絮絮叨叨，忽然觉得——所谓岁月静好，大抵就是这副模样。',
        mood: '😌',
        isStarred: true,
        imagePaths: [
          'https://picsum.photos/seed/diary3/400/300',
          'https://picsum.photos/seed/diary4/400/300',
        ],
        tag: '慢生活',
      ),
      DiaryEntry(
        id: _uuid.v4(),
        date: now.subtract(const Duration(days: 5)),
        title: '心里有片小小的乌云',
        content: '有件事没能处理得圆满，心里像压了一团说不清的雾。后来想想，人生本就是阴晴交替，没有谁能一直晴朗。把今天的失落写下来，明天，再做个迎着光的人。',
        mood: '🤔',
        tag: '心事',
      ),
      DiaryEntry(
        id: _uuid.v4(),
        date: now.subtract(const Duration(days: 7)),
        title: '遇见一个全新的世界',
        content: '报名的课程今天开讲，原以为枯燥，没想到一头扎进去就忘了时间。原来这个领域藏着这么多有趣的门道。心里那点久违的好奇又被点亮了——愿意一直做个对世界保持热爱的人。',
        mood: '😎',
        isStarred: true,
        imagePaths: ['https://picsum.photos/seed/diary5/400/300'],
        tag: '成长',
      ),
      DiaryEntry(
        id: _uuid.v4(),
        date: now.subtract(const Duration(days: 10)),
        title: '突如其来的好消息',
        content: '傍晚收到一条消息，惊喜来得猝不及防，开心得想原地转圈。买了一小块蛋糕给自己庆祝。生活总爱在不经意间，悄悄塞给你一颗糖。',
        mood: '🥳',
        isStarred: true,
        imagePaths: ['https://picsum.photos/seed/diary6/400/300'],
        tag: '惊喜',
      ),
      DiaryEntry(
        id: _uuid.v4(),
        date: now.subtract(const Duration(days: 14)),
        title: '听了一下午的雨',
        content: '雨从清晨落到黄昏，心也跟着安静下来。窝在沙发里，泡一壶热茶，听雨敲窗，看水痕在玻璃上蜿蜒。原来独处也可以这样温柔，不必热闹，也自有一番欢喜。',
        mood: '😢',
        tag: '雨天',
      ),
      DiaryEntry(
        id: _uuid.v4(),
        date: now.subtract(const Duration(days: 2)),
        title: '清晨的第一杯咖啡',
        content: '六点半醒来，城市还没完全苏醒。手冲一杯浅烘的豆子，看热气在晨光里打着旋。安静地坐了二十分钟，什么也没做，却觉得一整天都被温柔地接住了。',
        mood: '😌',
        tag: '清晨',
      ),
      DiaryEntry(
        id: _uuid.v4(),
        date: now.subtract(const Duration(days: 4)),
        title: '菜市场的烟火气',
        content: '拎着布袋逛了一圈菜市场，番茄红得发亮，香菜带着露水。摊主阿姨多塞了一把小葱，笑着说"拿去拿去"。这些细碎的善意，把平凡的日子点亮成了诗。',
        mood: '😊',
        isStarred: true,
        imagePaths: ['https://picsum.photos/seed/diary8/400/300'],
        tag: '生活',
      ),
      DiaryEntry(
        id: _uuid.v4(),
        date: now.subtract(const Duration(days: 6)),
        title: '夜跑时遇见的月亮',
        content: '沿着江边跑了五公里，风迎面而来，心跳和脚步渐渐合拍。抬头看见一轮很圆的月亮挂在桥头，忽然就停了下来。有些风景，是身体动起来才肯遇见的。',
        mood: '😎',
        tag: '运动',
      ),
      DiaryEntry(
        id: _uuid.v4(),
        date: now.subtract(const Duration(days: 8)),
        title: '想念远方的朋友',
        content: '整理旧照片时翻到了大学时的合影。那时一起熬夜、一起傻笑的人，如今散在天南海北。给她发了句"最近还好吗"，很快收到回复——原来惦念是双向的，真好。',
        mood: '😍',
        isStarred: true,
        tag: '念旧',
      ),
      DiaryEntry(
        id: _uuid.v4(),
        date: now.subtract(const Duration(days: 9)),
        title: '一本读到深夜的书',
        content: '本想睡前翻几页，结果一头扎进字里行间，直到窗外泛白。合上书的那一刻，心里又满又空。好的故事就是这样，借了别人的人生，照见了自己的影子。',
        mood: '🤔',
        imagePaths: ['https://picsum.photos/seed/diary9/400/300'],
        tag: '阅读',
      ),
      DiaryEntry(
        id: _uuid.v4(),
        date: now.subtract(const Duration(days: 12)),
        title: '阳台上的小番茄红了',
        content: '种了两个月的小番茄，今天终于红了第一颗。摘下来洗净放进嘴里，酸里带甜，是阳光和耐心的味道。养一株会结果的植物，像是和时间做了一场温柔的约定。',
        mood: '🥳',
        isStarred: true,
        imagePaths: ['https://picsum.photos/seed/diary10/400/300'],
        tag: '种植',
      ),
      DiaryEntry(
        id: _uuid.v4(),
        date: now.subtract(const Duration(days: 16)),
        title: '一个人的电影院',
        content: '挑了个工作日的下午场，偌大的影厅只坐了三两个人。没有人催促，没有人打扰，就这样安静地哭、安静地笑。偶尔的独处，是给自己充电的方式。',
        mood: '😌',
        tag: '独处',
      ),
      DiaryEntry(
        id: _uuid.v4(),
        date: now.subtract(const Duration(days: 18)),
        title: '被工作绊住的一天',
        content: '改了一遍又一遍的方案还是被打回，难免有些泄气。傍晚出门散步，看见晚霞把天烧成了橘红色，心忽然就松开了。事情总会过去的，而这片天，今天只为我亮一次。',
        mood: '😴',
        tag: '工作',
      ),
      DiaryEntry(
        id: _uuid.v4(),
        date: now.subtract(const Duration(days: 21)),
        title: '给自己写一封信',
        content: '提笔给一年后的自己写了封信，写着写着竟红了眼眶。原来心里藏了那么多没说出口的期待与温柔。把信封好，约定明年此时再拆——这是我和自己的小秘密。',
        mood: '😢',
        isStarred: true,
        tag: '心事',
      ),
      DiaryEntry(
        id: _uuid.v4(),
        date: now.subtract(const Duration(days: 24)),
        title: '老街区的旧时光',
        content: '路过一条快要拆迁的老街，斑驳的墙、晾衣的竹竿、门口打盹的猫。时间在这里走得格外慢。拍了好几张照片，想把这份不慌不忙，悄悄收藏进记忆里。',
        mood: '🤔',
        imagePaths: [
          'https://picsum.photos/seed/diary11/400/300',
          'https://picsum.photos/seed/diary12/400/300',
        ],
        tag: '散步',
      ),
      DiaryEntry(
        id: _uuid.v4(),
        date: now.subtract(const Duration(days: 28)),
        title: '雪后初晴的清晨',
        content: '一夜大雪，清晨推开窗，整个世界白得发亮。踩着咯吱作响的积雪去买早餐，呼出的白气和阳光撞个满怀。冬天再冷，也总有这样让人心头一暖的瞬间。',
        mood: '😊',
        isStarred: true,
        imagePaths: ['https://picsum.photos/seed/diary13/400/300'],
        tag: '冬日',
      ),
      DiaryEntry(
        id: _uuid.v4(),
        date: now.subtract(const Duration(days: 33)),
        title: '学会了一道新菜',
        content: '跟着视频做了一道糖醋排骨，第一次居然就成功了！色泽油亮，酸甜适口。一个人慢慢吃完，心里盈满小小的成就感。生活的乐趣，藏在这些亲手创造的滋味里。',
        mood: '😎',
        tag: '下厨',
      ),
    ];
    for (final e in samples) {
      await save(e);
    }
    await prefs.setBool(_initKey, true);
  }
}
