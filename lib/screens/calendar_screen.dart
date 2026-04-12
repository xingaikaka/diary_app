import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/diary_entry.dart';
import '../providers/diary_provider.dart';
import '../theme/diary_theme.dart';
import '../widgets/diary_card.dart';
import 'diary_detail_screen.dart';
import 'diary_editor_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  void _prevMonth() => setState(() {
        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
      });

  void _nextMonth() => setState(() {
        _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
      });

  @override
  Widget build(BuildContext context) {
    return Consumer<DiaryProvider>(builder: (context, provider, _) {
      final monthEntries =
          provider.forMonth(_focusedMonth.year, _focusedMonth.month);
      final dayEntries = provider.forDate(_selectedDay);

      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                _CalHeader(),
                _MonthNav(
                  month: _focusedMonth,
                  onPrev: _prevMonth,
                  onNext: _nextMonth,
                ),
                _CalendarGrid(
                  month: _focusedMonth,
                  entries: monthEntries,
                  selected: _selectedDay,
                  onSelect: (d) => setState(() => _selectedDay = d),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        DateFormat('M月d日').format(_selectedDay),
                        style: GoogleFonts.nunito(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: DiaryTheme.textPrimary),
                      ),
                      const Spacer(),
                      if (dayEntries.isEmpty)
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              fullscreenDialog: true,
                              builder: (_) =>
                                  DiaryEditorScreen(date: _selectedDay),
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: DiaryTheme.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.add, color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Text('写日记',
                                    style: GoogleFonts.nunito(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
          if (dayEntries.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.note_outlined, size: 56, color: DiaryTheme.textSecondary.withOpacity(0.4)),
                    const SizedBox(height: 12),
                    Text('这一天还没有日记',
                        style: GoogleFonts.nunito(
                            color: DiaryTheme.textSecondary, fontSize: 15)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => DiaryCard(
                    entry: dayEntries[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            DiaryDetailScreen(entry: dayEntries[i]),
                      ),
                    ),
                    onStarTap: () => provider.toggleStar(dayEntries[i].id),
                  ),
                  childCount: dayEntries.length,
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _CalHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 10),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('日历',
                  style: GoogleFonts.nunito(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: DiaryTheme.textPrimary)),
              Text('查看每天的日记记录',
                  style: GoogleFonts.nunito(
                      fontSize: 14, color: DiaryTheme.textSecondary)),
            ],
          ),
          const Spacer(),
          Icon(Icons.calendar_month_rounded, size: 36, color: DiaryTheme.primary),
        ],
      ),
    );
  }
}

class _MonthNav extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  const _MonthNav(
      {required this.month, required this.onPrev, required this.onNext});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left_rounded),
            color: DiaryTheme.primary,
          ),
          Expanded(
            child: Text(
              DateFormat('yyyy年 M月', 'zh_CN').format(month),
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: DiaryTheme.textPrimary),
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded),
            color: DiaryTheme.primary,
          ),
        ],
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  final DateTime month;
  final List<DiaryEntry> entries;
  final DateTime selected;
  final ValueChanged<DateTime> onSelect;

  const _CalendarGrid({
    required this.month,
    required this.entries,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // weekday: 1=Mon..7=Sun → offset so Sun=0
    int offset = firstDay.weekday % 7;

    final today = DateTime.now();
    final entryDays = entries.map((e) => e.date.day).toSet();

    const headers = ['日', '一', '二', '三', '四', '五', '六'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: DiaryTheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: DiaryTheme.primary.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: headers
                  .map((h) => Expanded(
                        child: Center(
                          child: FittedBox(
                            child: Text(h,
                              style: GoogleFonts.nunito(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: DiaryTheme.textSecondary)),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: offset + daysInMonth,
              itemBuilder: (_, idx) {
                if (idx < offset) return const SizedBox();
                final day = idx - offset + 1;
                final date = DateTime(month.year, month.month, day);
                final isToday = date.year == today.year &&
                    date.month == today.month &&
                    date.day == today.day;
                final isSelected = date.year == selected.year &&
                    date.month == selected.month &&
                    date.day == selected.day;
                final hasEntry = entryDays.contains(day);

                return GestureDetector(
                  onTap: () => onSelect(date),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? DiaryTheme.primary
                              : isToday
                                  ? DiaryTheme.primary.withOpacity(0.12)
                                  : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$day',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: isSelected || isToday
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : isToday
                                      ? DiaryTheme.primary
                                      : DiaryTheme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      if (hasEntry)
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : DiaryTheme.primary,
                            shape: BoxShape.circle,
                          ),
                        )
                      else
                        const SizedBox(height: 5),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
