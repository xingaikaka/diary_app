import 'dart:io';
import 'package:flutter/material.dart';

/// 同时支持本地路径和网络 URL 的图片组件
class DiaryImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const DiaryImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  bool get _isNetwork => path.startsWith('http');

  @override
  Widget build(BuildContext context) {
    Widget img;
    if (_isNetwork) {
      img = Image.network(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _loading(),
      );
    } else {
      final f = File(path);
      img = f.existsSync()
          ? Image.file(f, width: width, height: height, fit: fit)
          : _placeholder();
    }
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: img);
    }
    return img;
  }

  Widget _placeholder() => Container(
        width: width,
        height: height,
        color: const Color(0xFFF5F0F8),
        child: const Icon(Icons.image_outlined, color: Color(0xFFCDC8D6)),
      );

  Widget _loading() => Container(
        width: width,
        height: height,
        color: const Color(0xFFF5F0F8),
        child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFF7B9C))),
      );
}
