import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/diary_entry.dart';
import '../providers/diary_provider.dart';
import '../theme/diary_theme.dart';
import '../widgets/diary_image.dart';
import '../widgets/emoji_text.dart';
import 'diary_detail_screen.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DiaryProvider>(
      builder: (context, provider, _) {
        final entries = provider.entries;
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _TimelineHeader(total: entries.length)),
            if (entries.isEmpty)
              const SliverFillRemaining(child: _EmptyState())
            else
              SliverPadding(
                padding:
                    const EdgeInsets.fromLTRB(20, 0, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _TimelineItem(
                      entry: entries[i],
                      isLast: i == entries.length - 1,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DiaryDetailScreen(entry: entries[i]),
                        ),
                      ),
                    ),
                    childCount: entries.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _TimelineHeader extends StatelessWidget {
  final int total;
  const _TimelineHeader({required this.total});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('时间线',
              style: GoogleFonts.nunito(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: DiaryTheme.textPrimary)),
          const SizedBox(height: 4),
          Text('共 $total 篇日记的故事',
              style: GoogleFonts.nunito(
                  fontSize: 14, color: DiaryTheme.textSecondary)),
          const SizedBox(height: 12),
          Row(
            children: [
              DiaryTheme.primary,
              DiaryTheme.secondary,
              DiaryTheme.accent,
              const Color(0xFFBA68C8),
            ]
                .map((c) => Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: c,
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

class _TimelineItem extends StatelessWidget {
  final DiaryEntry entry;
  final bool isLast;
  final VoidCallback onTap;

  const _TimelineItem({
    required this.entry,
    required this.isLast,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = DiaryTheme.moodColor(entry.mood);
    // 日期列宽52, 点列总宽40(左边距12+圆点16+右边距12), 圆点中心 = 52+12+8 = 72
    // 连接线宽2, 左边 = 72-1 = 71
    return Stack(
      children: [
        // 连接线（在内容之后渲染，不影响布局）
        if (!isLast)
          Positioned(
            left: 71,
            top: 32, // SizedBox(16) + 圆点(16) = 32
            bottom: 16, // 与卡片 margin.bottom 对齐
            child: Container(width: 2, color: DiaryTheme.divider),
          ),
        // 内容行（无 IntrinsicHeight，卡片自由伸展，彻底消除溢出）
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左侧日期列
            SizedBox(
              width: 52,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 14),
                  Text(
                    DateFormat('d').format(entry.date),
                    style: GoogleFonts.nunito(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: entry.isStarred
                            ? DiaryTheme.starColor
                            : DiaryTheme.textPrimary),
                  ),
                  Text(
                    DateFormat('MMM', 'zh_CN').format(entry.date),
                    style: GoogleFonts.nunito(
                        fontSize: 11,
                        color: DiaryTheme.textSecondary,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            // 中央圆点（不含延伸线，线由 Stack Positioned 绘制）
            SizedBox(
              width: 40,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, left: 12, right: 12),
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 6,
                          spreadRadius: 1)
                    ],
                  ),
                ),
              ),
            ),
            // 右侧卡片（mainAxisSize.min 确保高度完全由内容决定）
            Expanded(
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: DiaryTheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: entry.isStarred
                        ? Border.all(color: DiaryTheme.starColor, width: 1.5)
                        : Border.all(color: DiaryTheme.divider),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          EmojiText(entry.mood, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              entry.title,
                              style: GoogleFonts.nunito(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: DiaryTheme.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (entry.isStarred)
                            const Icon(Icons.star_rounded,
                                color: DiaryTheme.starColor, size: 16),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        entry.excerpt,
                        style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: DiaryTheme.textSecondary,
                            height: 1.5),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (entry.imagePaths.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 60,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: entry.imagePaths.length.clamp(0, 3),
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 6),
                            itemBuilder: (_, i) => DiaryImage(
                              path: entry.imagePaths[i],
                              width: 60,
                              height: 60,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                      if (entry.tag != null) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('# ${entry.tag}',
                              style: GoogleFonts.nunito(
                                  fontSize: 10,
                                  color: color,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories_outlined, size: 72, color: DiaryTheme.textSecondary.withOpacity(0.35)),
          const SizedBox(height: 16),
          Text('还没有日记记录',
              style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: DiaryTheme.textSecondary)),
          const SizedBox(height: 8),
          Text('开始写日记，时间线会显示在这里',
              style: GoogleFonts.nunito(
                  fontSize: 14, color: DiaryTheme.textSecondary)),
        ],
      ),
    );
  }
}
