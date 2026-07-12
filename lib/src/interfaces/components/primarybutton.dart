import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/interfaces/components/loading_indicator.dart';

/// Primary CTA matching Figma `Button/N` (Send OTP / Verify OTP).
///
/// Specs: height 66 · radius 8 · fill [kPrimaryColor] ·
/// Noto Sans SemiBold 15 white · horizontal padding 16.
Widget primaryButton({
  required String label,
  required VoidCallback? onPressed,
  Color labelColor = kWhite,
  double fontSize = kSize15,
  double buttonHeight = 66,
  bool isLoading = false,
  Color buttonColor = kPrimaryColor,
  Color sideColor = Colors.transparent,
  Widget? icon,
}) {
  final borderRadius = BorderRadius.circular(kCardRadiusSm);

  return SizedBox(
    height: buttonHeight,
    width: double.infinity,
    child: Material(
      color: Colors.transparent,
      child: _InteractiveButton(
        label: label,
        onPressed: onPressed,
        isLoading: isLoading,
        icon: icon,
        labelColor: labelColor,
        fontSize: fontSize,
        buttonColor: buttonColor,
        sideColor: sideColor,
        borderRadius: borderRadius,
      ),
    ),
  );
}

class _InteractiveButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final Color labelColor;
  final double fontSize;
  final Color buttonColor;
  final Color sideColor;
  final BorderRadius borderRadius;

  const _InteractiveButton({
    required this.label,
    required this.onPressed,
    required this.isLoading,
    required this.labelColor,
    required this.fontSize,
    required this.buttonColor,
    required this.sideColor,
    required this.borderRadius,
    this.icon,
  });

  @override
  State<_InteractiveButton> createState() => _InteractiveButtonState();
}

class _InteractiveButtonState extends State<_InteractiveButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    var backgroundColor = widget.buttonColor;
    if (_isPressed) {
      backgroundColor = widget.buttonColor.withValues(alpha: 0.85);
    } else if (_isHovered) {
      backgroundColor = widget.buttonColor.withValues(alpha: 0.95);
    }

    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: InkWell(
        borderRadius: widget.borderRadius,
        splashColor: kWhite.withValues(alpha: 0.15),
        highlightColor: Colors.transparent,
        onTap: isDisabled ? null : widget.onPressed,
        onTapDown: (_) {
          if (!isDisabled) {
            HapticHelper.impact(HapticImpact.medium);
            setState(() => _isPressed = true);
          }
        },
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onLongPress: isDisabled
            ? null
            : () => HapticHelper.impact(HapticImpact.medium),
        onHover: (value) => setState(() => _isHovered = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDisabled
                ? widget.buttonColor.withValues(alpha: 0.5)
                : backgroundColor,
            borderRadius: widget.borderRadius,
            border: Border.all(color: widget.sideColor),
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: LoadingAnimation(size: 22, loadingColor: kWhite),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        widget.icon!,
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Text(
                          widget.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: kButtonLabelSB.copyWith(
                            color: widget.labelColor,
                            fontSize: widget.fontSize,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
