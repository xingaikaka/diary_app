import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/diary_theme.dart';
import 'home_screen.dart';
import 'timeline_screen.dart';
import 'calendar_screen.dart';
import 'diary_editor_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    TimelineScreen(),
    CalendarScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DiaryTheme.background,
      body: IndexedStack(index: _index, children: _screens),
      floatingActionButton: FloatingActionButton(
        onPressed: _openEditor,
        backgroundColor: DiaryTheme.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 26),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomBar(
        index: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }

  void _openEditor() {
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const DiaryEditorScreen(),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _BottomBar({required this.index, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: DiaryTheme.surface,
      elevation: 8,
      notchMargin: 8,
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(child: _NavItem(iconData: Icons.home_rounded, label: '主页', selected: index == 0, onTap: () => onTap(0))),
          Expanded(child: _NavItem(iconData: Icons.calendar_month_rounded, label: '日历', selected: index == 2, onTap: () => onTap(2))),
          const SizedBox(width: 56), // FAB 占位
          Expanded(child: _NavItem(iconData: Icons.timeline_rounded, label: '时间线', selected: index == 1, onTap: () => onTap(1))),
          Expanded(child: _NavItem(iconData: Icons.star_rounded, label: '收藏', selected: false, onTap: () => onTap(1))),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData iconData;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.iconData,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? DiaryTheme.primary : DiaryTheme.textSecondary;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, size: selected ? 24 : 22, color: color),
            const SizedBox(height: 2),
            Text(label,
                style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight:
                        selected ? FontWeight.w800 : FontWeight.w600,
                    color: color)),
          ],
        ),
      ),
    );
  }
}
