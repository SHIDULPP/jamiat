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

  bool get _hasNetworkImage =>
      imageUrl != null && imageUrl!.startsWith('http');

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
    if (!_hasNetworkImage) return _placeholder();

    return ClipOval(
      child: Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _placeholder(),
      ),
    );
  }
}
