import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DiaryTheme {
  // 清新自然 · 日系极简 —— 米白 + 抹茶绿 + 原木色
  static const Color background = Color(0xFFF6F4EC);
  static const Color surface = Color(0xFFFFFEFB);
  static const Color primary = Color(0xFF8BA888);
  static const Color primaryLight = Color(0xFFBACBB2);
  static const Color secondary = Color(0xFFDCC9A6);
  static const Color accent = Color(0xFFD7A98C);
  static const Color starColor = Color(0xFFD8B45A);
  static const Color textPrimary = Color(0xFF4A463E);
  static const Color textSecondary = Color(0xFFA59E8E);
  static const Color divider = Color(0xFFEAE6DA);

  static const List<String> moods = [
    '😊', '😢', '😡', '😴', '😍', '🤔', '😎', '🥳', '😌', '😰',
  ];
  static const List<String> moodLabels = [
    '欢喜', '微凉', '恼意', '倦怠', '心动', '沉思', '从容', '雀跃', '安然', '忐忑',
  ];

  static Color moodColor(String mood) {
    switch (mood) {
      case '😊': return const Color(0xFF8BA888); // 抹茶绿
      case '😢': return const Color(0xFF8FA9B8); // 雾蓝
      case '😡': return const Color(0xFFC97B63); // 陶土红
      case '😴': return const Color(0xFFA194B0); // 藕紫
      case '😍': return const Color(0xFFD99A9A); // 浅粉陶
      case '🤔': return const Color(0xFF7FA6A0); // 青灰绿
      case '😎': return const Color(0xFFC2A35A); // 橄榄黄
      case '🥳': return const Color(0xFFD7A98C); // 暖陶橘
      case '😌': return const Color(0xFF9CB496); // 浅抹茶
      case '😰': return const Color(0xFF94A0A6); // 灰蓝
      default:   return const Color(0xFF8BA888);
    }
  }

  static String get greeting {
    final h = DateTime.now().hour;
    if (h < 6)  return '夜色温柔，把心事轻轻写下 🌙';
    if (h < 12) return '晨光熹微，记下醒来的第一缕心情 ☀️';
    if (h < 14) return '日光正好，为此刻留一行字 🍃';
    if (h < 18) return '午后微风，慢慢把今天收藏起来 🌿';
    if (h < 22) return '暮色四合，与今天好好道一声晚安 🌙';
    return '夜已深，留几行字给安静的自己 ✨';
  }

  static ThemeData get theme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        surface: surface,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      // 不全局覆盖 textTheme，避免 Nunito 字体遮盖系统 Emoji 字形
      useMaterial3: true,
    );
  }
}
