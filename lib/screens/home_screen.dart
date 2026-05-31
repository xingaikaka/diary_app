import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/diary_provider.dart';
import '../theme/diary_theme.dart';
import '../widgets/diary_card.dart';
import 'diary_detail_screen.dart';
import 'diary_editor_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DiaryProvider>(
      builder: (context, provider, _) {
        final today = provider.todayEntry;
        final recent = provider.entries.skip(today != null ? 0 : 0).take(20).toList();

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header()),
            SliverToBoxAdapter(
              child: _TodaySection(
                entry: today,
                onWrite: () => _openEditor(context, null),
              ),
            ),
            if (recent.isNotEmpty) ...[
              SliverToBoxAdapter(
                child:             _SectionTitle(
                    icon: Icons.auto_stories_rounded, title: '近来的字句', count: recent.length),
              ),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => DiaryCard(
                      entry: recent[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                DiaryDetailScreen(entry: recent[i])),
                      ),
                      onStarTap: () =>
                          provider.toggleStar(recent[i].id),
                    ),
                    childCount: recent.length,
                  ),
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  void _openEditor(BuildContext context, DateTime? date) {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => DiaryEditorScreen(date: date ?? DateTime.now()),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DiaryTheme.greeting,
                      style: GoogleFonts.nunito(
                        fontSize: 15,
                        color: DiaryTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '拾光',
                      style: GoogleFonts.nunito(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: DiaryTheme.textPrimary,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '拾起日子里的微光',
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: DiaryTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 64,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(
                  color: DiaryTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('d').format(now),
                      style: GoogleFonts.nunito(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: DiaryTheme.primary),
                    ),
                    Text(
                      DateFormat('M月', 'zh_CN').format(now),
                      style: GoogleFonts.nunito(
                          fontSize: 11,
                          color: DiaryTheme.primary,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 装饰性彩条
          Row(
            children: [DiaryTheme.primary, DiaryTheme.secondary, DiaryTheme.accent]
                .asMap()
                .entries
                .map((e) => Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(right: e.key < 2 ? 4 : 0),
                        decoration: BoxDecoration(
                          color: e.value,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _TodaySection extends StatelessWidget {
  final dynamic entry;
  final VoidCallback onWrite;

  const _TodaySection({required this.entry, required this.onWrite});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(icon: Icons.wb_sunny_rounded, title: '今日', count: null),
          const SizedBox(height: 6),
          entry == null
              ? _WritePrompt(onTap: onWrite)
              : DiaryCard(
                  entry: entry,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => DiaryDetailScreen(entry: entry)),
                  ),
                  onStarTap: () =>
                      context.read<DiaryProvider>().toggleStar(entry.id),
                ),
        ],
      ),
    );
  }
}

class _WritePrompt extends StatelessWidget {
  final VoidCallback onTap;
  const _WritePrompt({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8BA888), Color(0xFFBACBB2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: DiaryTheme.primary.withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.edit_note_rounded, color: Colors.white, size: 42),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '今天，还是一页空白',
                    style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '轻触，写下此刻的心绪 →',
                    style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9)),
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

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final int? count;

  const _SectionTitle({required this.icon, required this.title, this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: DiaryTheme.primary),
          const SizedBox(width: 6),
          Text(
            title,
            style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: DiaryTheme.textPrimary),
          ),
          if (count != null) ...[
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: DiaryTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$count',
                style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: DiaryTheme.primary,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
