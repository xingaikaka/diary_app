import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/diary_entry.dart';
import '../theme/diary_theme.dart';
import 'diary_image.dart';
import 'emoji_text.dart';

class DiaryCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onTap;
  final VoidCallback onStarTap;

  const DiaryCard({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onStarTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = DiaryTheme.moodColor(entry.mood);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: DiaryTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: entry.isStarred
              ? Border.all(color: DiaryTheme.starColor, width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.imagePaths.isNotEmpty)
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: DiaryImage(
                  path: entry.imagePaths.first,
                  height: 140,
                  width: double.infinity,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _MoodBadge(mood: entry.mood, color: color),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.title.isEmpty ? '无题' : entry.title,
                          style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: DiaryTheme.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: onStarTap,
                        child: Icon(
                          entry.isStarred ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: entry.isStarred
                              ? DiaryTheme.starColor
                              : DiaryTheme.textSecondary,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    entry.excerpt,
                    style: GoogleFonts.nunito(
                      fontSize: 13,
                      color: DiaryTheme.textSecondary,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 12, color: DiaryTheme.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('yyyy年M月d日').format(entry.date),
                        style: GoogleFonts.nunito(
                            fontSize: 11, color: DiaryTheme.textSecondary),
                      ),
                      if (entry.tag != null) ...[
                        const SizedBox(width: 8),
                        _TagChip(tag: entry.tag!, color: color),
                      ],
                      const Spacer(),
                      if (entry.imagePaths.length > 1)
                        Row(
                          children: [
                            Icon(Icons.photo_library_outlined,
                                size: 12, color: DiaryTheme.textSecondary),
                            const SizedBox(width: 2),
                            Text('${entry.imagePaths.length}',
                                style: GoogleFonts.nunito(
                                    fontSize: 11,
                                    color: DiaryTheme.textSecondary)),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodBadge extends StatelessWidget {
  final String mood;
  final Color color;
  const _MoodBadge({required this.mood, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: EmojiText(mood, size: 14),
    );
  }
}

class _TagChip extends StatelessWidget {
  final String tag;
  final Color color;
  const _TagChip({required this.tag, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '# $tag',
        style: GoogleFonts.nunito(
            fontSize: 10, color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
