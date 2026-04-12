import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/diary_theme.dart';
import 'emoji_text.dart';

class MoodSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const MoodSelector({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: DiaryTheme.moods.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final mood = DiaryTheme.moods[i];
          final isSelected = mood == selected;
          return GestureDetector(
            onTap: () => onChanged(mood),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 60,
              decoration: BoxDecoration(
                color: isSelected
                    ? DiaryTheme.moodColor(mood).withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? DiaryTheme.moodColor(mood)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    EmojiText(mood, size: 26),
                  const SizedBox(height: 2),
                  Text(
                    DiaryTheme.moodLabels[i],
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      color: isSelected
                          ? DiaryTheme.moodColor(mood)
                          : DiaryTheme.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
