import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/diary_entry.dart';
import '../providers/diary_provider.dart';
import '../theme/diary_theme.dart';
import '../widgets/mood_selector.dart';
import '../widgets/diary_image.dart';

class DiaryEditorScreen extends StatefulWidget {
  final DiaryEntry? existing;
  final DateTime? date;

  const DiaryEditorScreen({super.key, this.existing, this.date});

  @override
  State<DiaryEditorScreen> createState() => _DiaryEditorScreenState();
}

class _DiaryEditorScreenState extends State<DiaryEditorScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _tagCtrl = TextEditingController();
  String _mood = '😊';
  List<String> _images = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final e = widget.existing!;
      _titleCtrl.text = e.title;
      _contentCtrl.text = e.content;
      _tagCtrl.text = e.tag ?? '';
      _mood = e.mood;
      _images = List.from(e.imagePaths);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _tagCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(imageQuality: 80);
    if (files.isEmpty) return;
    final provider = context.read<DiaryProvider>();
    final paths = <String>[];
    for (final f in files) {
      final p = await provider.copyImage(f.path);
      paths.add(p);
    }
    setState(() => _images.addAll(paths));
  }

  Future<void> _save() async {
    final content = _contentCtrl.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请先写点什么吧 ✍️')));
      return;
    }
    setState(() => _saving = true);
    final provider = context.read<DiaryProvider>();
    final tag = _tagCtrl.text.trim();
    final entry = DiaryEntry(
      id: widget.existing?.id ?? provider.newId(),
      date: widget.existing?.date ?? widget.date ?? DateTime.now(),
      title: _titleCtrl.text.trim().isEmpty ? '无题' : _titleCtrl.text.trim(),
      content: content,
      mood: _mood,
      isStarred: widget.existing?.isStarred ?? false,
      imagePaths: _images,
      tag: tag.isEmpty ? null : tag,
      createdAt: widget.existing?.createdAt,
    );
    await provider.save(entry);
    if (mounted) Navigator.pop(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.existing?.date ?? widget.date ?? DateTime.now();
    return Scaffold(
      backgroundColor: DiaryTheme.background,
      appBar: AppBar(
        backgroundColor: DiaryTheme.background,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('取消',
              style: GoogleFonts.nunito(color: DiaryTheme.textSecondary)),
        ),
        leadingWidth: 64,
        title: Text(
          DateFormat('M月d日').format(date),
          style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: DiaryTheme.textPrimary),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: DiaryTheme.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                    ),
                    child: Text('保存',
                        style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionLabel('今天的心情'),
            MoodSelector(
                selected: _mood, onChanged: (m) => setState(() => _mood = m)),
            const SizedBox(height: 16),
            _SectionLabel('标题'),
            _InputBox(
              controller: _titleCtrl,
              hint: '给今天起个名字吧…',
              maxLines: 1,
              style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: DiaryTheme.textPrimary),
            ),
            const SizedBox(height: 16),
            _SectionLabel('日记内容'),
            _InputBox(
              controller: _contentCtrl,
              hint: '写下今天的故事…',
              maxLines: 12,
              style: GoogleFonts.nunito(
                  fontSize: 15,
                  color: DiaryTheme.textPrimary,
                  height: 1.7),
            ),
            const SizedBox(height: 16),
            _SectionLabel('标签（可选）'),
            _InputBox(
              controller: _tagCtrl,
              hint: '例如：开心、工作、旅行…',
              maxLines: 1,
              style: GoogleFonts.nunito(
                  fontSize: 14, color: DiaryTheme.textPrimary),
            ),
            const SizedBox(height: 20),
            _SectionLabel('添加图片'),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _AddImageButton(onTap: _pickImage),
                  ..._images.map((p) => _ImageThumb(
                        path: p,
                        onRemove: () =>
                            setState(() => _images.remove(p)),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: DiaryTheme.textSecondary,
              letterSpacing: 0.5)),
    );
  }
}

class _InputBox extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextStyle style;

  const _InputBox({
    required this.controller,
    required this.hint,
    required this.maxLines,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DiaryTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: DiaryTheme.primary.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 2))
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: style,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.nunito(
              color: DiaryTheme.textSecondary, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

class _AddImageButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddImageButton({required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 90,
        margin: const EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: DiaryTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border:
              Border.all(color: DiaryTheme.primary.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_outlined,
                color: DiaryTheme.primary, size: 28),
            const SizedBox(height: 4),
            Text('添加图片',
                style: GoogleFonts.nunito(
                    fontSize: 10, color: DiaryTheme.primary)),
          ],
        ),
      ),
    );
  }
}

class _ImageThumb extends StatelessWidget {
  final String path;
  final VoidCallback onRemove;
  const _ImageThumb({required this.path, required this.onRemove});
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 90,
          height: 90,
          margin: const EdgeInsets.only(right: 10),
          child: DiaryImage(
            path: path,
            width: 90,
            height: 90,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        Positioned(
          top: 4,
          right: 14,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                  color: Colors.black54, shape: BoxShape.circle),
              child:
                  const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}
