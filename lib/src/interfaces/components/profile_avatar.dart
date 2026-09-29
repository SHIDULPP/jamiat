import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';

/// Circular profile image with a common person-icon placeholder when missing.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.size = 48,
    this.backgroundColor,
    this.iconColor,
  });

  final String? imageUrl;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  String? get _resolvedUrl {
    var raw = imageUrl?.trim();
    if (raw == null || raw.isEmpty || raw == 'null') return null;
    if ((raw.startsWith('"') && raw.endsWith('"')) ||
        (raw.startsWith("'") && raw.endsWith("'"))) {
      raw = raw.substring(1, raw.length - 1).trim();
    }
    if (raw.startsWith('//')) raw = 'https:$raw';
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    return null;
  }

  Widget _placeholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? kGreyLight,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: iconColor ?? kMutedText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = _resolvedUrl;
    if (url == null) return _placeholder();

    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheSize = (size * dpr).round();

    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        filterQuality: FilterQuality.medium,
        cacheWidth: cacheSize,
        cacheHeight: cacheSize,
        errorBuilder: (context, error, stackTrace) {
          log(
            'ProfileAvatar failed to load: $url → $error',
            name: 'ProfileAvatar',
            stackTrace: stackTrace,
          );
          return _placeholder();
        },
      ),
    );
  }
}
