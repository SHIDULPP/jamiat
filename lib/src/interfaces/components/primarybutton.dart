import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';

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
      borderRadius: borderRadius,
      child: InkWell(
        onTap: isLoading || onPressed == null ? null : onPressed,
        borderRadius: borderRadius,
        splashColor: kWhite.withValues(alpha: 0.15),
        highlightColor: Colors.transparent,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: (isLoading || onPressed == null)
                ? buttonColor.withValues(alpha: 0.5)
                : buttonColor,
            borderRadius: borderRadius,
            border: Border.all(color: sideColor),
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation<Color>(labelColor),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        icon,
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: kButtonLabelSB.copyWith(
                            color: labelColor,
                            fontSize: fontSize,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    ),
  );
}
