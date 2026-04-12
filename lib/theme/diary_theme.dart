import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DiaryTheme {
  static const Color background = Color(0xFFFFF8F0);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFFFF7B9C);
  static const Color primaryLight = Color(0xFFFFB3C6);
  static const Color secondary = Color(0xFFA8E6CF);
  static const Color accent = Color(0xFFFFD3B6);
  static const Color starColor = Color(0xFFFFCC02);
  static const Color textPrimary = Color(0xFF3D3340);
  static const Color textSecondary = Color(0xFFADA8B6);
  static const Color divider = Color(0xFFF0EBF4);

  static const List<String> moods = [
    '😊', '😢', '😡', '😴', '😍', '🤔', '😎', '🥳', '😌', '😰',
  ];
  static const List<String> moodLabels = [
    '开心', '难过', '生气', '困倦', '爱意', '思考', '酷', '庆祝', '平静', '焦虑',
  ];

  static Color moodColor(String mood) {
    switch (mood) {
      case '😊': return const Color(0xFFFF7B9C);
      case '😢': return const Color(0xFF64B5F6);
      case '😡': return const Color(0xFFFF7043);
      case '😴': return const Color(0xFFBA68C8);
      case '😍': return const Color(0xFFFF4081);
      case '🤔': return const Color(0xFF26C6DA);
      case '😎': return const Color(0xFFFFB300);
      case '🥳': return const Color(0xFF7C4DFF);
      case '😌': return const Color(0xFF66BB6A);
      case '😰': return const Color(0xFF78909C);
      default:   return const Color(0xFFFF7B9C);
    }
  }

  static String get greeting {
    final h = DateTime.now().hour;
    if (h < 6)  return '夜深了，还在记录 🌙';
    if (h < 12) return '早上好，新的一天开始了 ☀️';
    if (h < 14) return '午安，记录中午的心情吧 🌤️';
    if (h < 18) return '下午好，今天过得怎么样？🌈';
    if (h < 22) return '晚上好，来记录今天吧 🌙';
    return '夜深了，还在写日记 ⭐';
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
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      // 不全局覆盖 textTheme，避免 Nunito 字体遮盖系统 Emoji 字形
      useMaterial3: true,
    );
  }
}
