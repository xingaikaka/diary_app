import 'package:flutter/material.dart';

/// 使用 RichText 渲染 Emoji，完全绕过 DefaultTextStyle 的字体继承，
/// 确保系统 Emoji 字形可以正常显示。
class EmojiText extends StatelessWidget {
  final String emoji;
  final double size;
  final TextAlign textAlign;

  const EmojiText(
    this.emoji, {
    super.key,
    this.size = 20,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: textAlign,
      text: TextSpan(
        text: emoji,
        style: TextStyle(fontSize: size),
      ),
    );
  }
}
