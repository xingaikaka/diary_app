import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/diary_entry.dart';
import '../providers/diary_provider.dart';
import '../theme/diary_theme.dart';
import '../widgets/diary_image.dart';
import '../widgets/emoji_text.dart';
import 'diary_editor_screen.dart';

class DiaryDetailScreen extends StatelessWidget {
  final DiaryEntry entry;
  const DiaryDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final color = DiaryTheme.moodColor(entry.mood);
    final provider = context.read<DiaryProvider>();
    return Scaffold(
      backgroundColor: DiaryTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: entry.imagePaths.isNotEmpty ? 260 : 140,
            pinned: true,
            backgroundColor: DiaryTheme.background,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: Colors.white70, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: DiaryTheme.textPrimary),
              ),
            ),
            actions: [
              _ActionBtn(
                icon: entry.isStarred ? Icons.star_rounded : Icons.star_outline_rounded,
                color: entry.isStarred ? DiaryTheme.starColor : DiaryTheme.textSecondary,
                onTap: () => provider.toggleStar(entry.id),
              ),
              _ActionBtn(
                icon: Icons.edit_outlined,
                color: DiaryTheme.primary,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => DiaryEditorScreen(existing: entry)),
                ),
              ),
              _ActionBtn(
                icon: Icons.delete_outline_rounded,
                color: Colors.redAccent,
                onTap: () => _confirmDelete(context, provider),
              ),
              const SizedBox(width: 4),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: entry.imagePaths.isNotEmpty
                  ? _ImageBanner(paths: entry.imagePaths)
                  : _GradientBanner(color: color, mood: entry.mood),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            EmojiText(entry.mood, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              DiaryTheme.moodLabels[
                                  DiaryTheme.moods.indexOf(entry.mood)],
                              style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  color: color,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (entry.tag != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('# ${entry.tag}',
                              style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  color: color,
                                  fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    entry.title,
                    style: GoogleFonts.nunito(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: DiaryTheme.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('yyyy年M月d日 EEEE', 'zh_CN').format(entry.date),
                    style: GoogleFonts.nunito(
                        fontSize: 13, color: DiaryTheme.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  Container(height: 1, color: DiaryTheme.divider),
                  const SizedBox(height: 20),
                  Text(
                    entry.content,
                    style: GoogleFonts.nunito(
                        fontSize: 16,
                        color: DiaryTheme.textPrimary,
                        height: 1.9),
                  ),
                  if (entry.imagePaths.length > 1) ...[
                    const SizedBox(height: 24),
                    Text('那天的画面',
                        style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: DiaryTheme.textSecondary)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: entry.imagePaths.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 10),
                        itemBuilder: (_, i) => DiaryImage(
                          path: entry.imagePaths[i],
                          width: 120,
                          height: 120,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, DiaryProvider provider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('删除这段时光',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w800)),
        content: Text('确定要让这一天的故事消失吗？删除后将无法找回。',
            style: GoogleFonts.nunito()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('再想想')),
          TextButton(
            onPressed: () async {
              await provider.delete(entry.id);
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('删除', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
            color: Colors.white70, shape: BoxShape.circle),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

class _ImageBanner extends StatelessWidget {
  final List<String> paths;
  const _ImageBanner({required this.paths});
  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      itemCount: paths.length,
      itemBuilder: (_, i) => DiaryImage(
        path: paths[i],
        width: double.infinity,
        height: 260,
      ),
    );
  }
}

class _GradientBanner extends StatelessWidget {
  final Color color;
  final String mood;
  const _GradientBanner({required this.color, required this.mood});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withOpacity(0.3), DiaryTheme.background],
        ),
      ),
      child:                     Center(
        child: EmojiText(mood, size: 80, textAlign: TextAlign.center),
      ),
    );
  }
}
