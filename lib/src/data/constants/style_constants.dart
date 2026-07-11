import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';

// ================= FONT FAMILY =================
// Figma: Noto Sans (Regular / Medium / SemiBold)

const String kFontFamily = 'Noto Sans';

// ================= FONT WEIGHTS =================

const kRegular = FontWeight.w400;
const kMedium = FontWeight.w500;
const kSemiBold = FontWeight.w600;
const kBold = FontWeight.w700;

const kLight = FontWeight.w400;
const kUltraLight = FontWeight.w400;
const kExtraLight = FontWeight.w400;
const kExtraBold = FontWeight.w700;
const kBlackFont = FontWeight.w700;

// ================= LETTER SPACING =================

const double kShortClose = -1.2;
const double kShort = -0.3;

// ================= FONT SIZES (Figma type scale) =================
// Type@46 · Type@37 · Type@29 · Type@23 · Type@19 · Type@15 · Type@12 · Type@10 · Type@8

const double kDisplay = 46;
const double kExtraLarge = 37;
const double kLarge = 29;
const double kHeading = 23;
const double kSubHeading = 19;
const double kBody = 15;

const double kSize46 = 46;
const double kSize37 = 37;
const double kSize29 = 29;
const double kSize23 = 23;
const double kSize19 = 19;
const double kSize15 = 15;
const double kSize12 = 12;
const double kSize10 = 10;
const double kSize8 = 8;

const double kSize11 = 11;
const double kSize13 = 13;
const double kSize14 = 14;
const double kSize16 = 16;
const double kSize17 = 17;
const double kSize18 = 18;
const double kSize20 = 20;
const double kSize22 = 22;
const double kSize24 = 24;
const double kSize26 = 26;
const double kSize28 = 28;
const double kSize30 = 30;
const double kSize32 = 32;
const double kSize34 = 34;
const double kSize36 = 36;

// ── Layout tokens (Figma Mobile ~402pt frame) ─────────────────────────────────

const double kCardRadiusLg = 16;
const double kCardRadiusMd = 14;
const double kCardRadiusSm = 8;
const double kCardRadiusXs = 6;
const double kPillRadius = 128;
const double kScreenPaddingH = 16;

// ================= BASE STYLE =================
// Figma text styles use line-height 120%.

TextStyle kStyle(
  FontWeight weight,
  double size, {
  Color? color,
  double? letterSpacing,
  double? height,
}) {
  return TextStyle(
    fontFamily: kFontFamily,
    fontWeight: weight,
    color: color ?? kTextColor,
    fontSize: size,
    letterSpacing: letterSpacing,
    height: height ?? 1.2,
  );
}

// ================= DISPLAY (46) =================

final kDisplayTitleR = kStyle(kRegular, kDisplay);
final kDisplayTitleM = kStyle(kMedium, kDisplay);
final kDisplayTitleSB = kStyle(kSemiBold, kDisplay);
final kDisplayTitleB = kStyle(kBold, kDisplay);
final kDisplayTitleEB = kStyle(kExtraBold, kDisplay);

// ================= EXTRA LARGE (37) =================

final kExtraLargeTitleR = kStyle(kRegular, kExtraLarge);
final kExtraLargeTitleM = kStyle(kMedium, kExtraLarge);
final kExtraLargeTitleSB = kStyle(kSemiBold, kExtraLarge);
final kExtraLargeTitleB = kStyle(kBold, kExtraLarge);

// ================= LARGE (29) =================

final kLargeTitleR = kStyle(kRegular, kLarge);
final kLargeTitleM = kStyle(kMedium, kLarge);
final kLargeTitleSB = kStyle(kSemiBold, kLarge);
final kLargeTitleB = kStyle(kBold, kLarge);
final kLargeTitleEB = kStyle(kExtraBold, kLarge);

// ================= HEADING (23) =================

final kHeadTitleR = kStyle(kRegular, kHeading);
final kHeadTitleM = kStyle(kMedium, kHeading);
final kHeadTitleSB = kStyle(kSemiBold, kHeading);
final kHeadTitleB = kStyle(kBold, kHeading);
final kHeadTitleEB = kStyle(kExtraBold, kHeading);

// ================= SUBHEADING (19) =================

final kSubHeadingL = kStyle(kLight, kSubHeading);
final kSubHeadingR = kStyle(kRegular, kSubHeading);
final kSubHeadingM = kStyle(kMedium, kSubHeading);
final kSubHeadingSB = kStyle(kSemiBold, kSubHeading);
final kSubHeadingB = kStyle(kBold, kSubHeading);
final kSubHeadingEB = kStyle(kExtraBold, kSubHeading);

// ================= BODY (15) =================

final kBodyTitleL = kStyle(kLight, kBody);
final kBodyTitleR = kStyle(kRegular, kBody);
final kBodyTitleM = kStyle(kMedium, kBody);
final kBodyTitleSB = kStyle(kSemiBold, kBody);
final kBodyTitleB = kStyle(kBold, kBody);
final kBodyTitleEB = kStyle(kExtraBold, kBody);

// ================= CAPTION / COMPACT UI =================

final kCaption8R = kStyle(kRegular, kSize8);
final kCaption8M = kStyle(kMedium, kSize8);
final kCaption8SB = kStyle(kSemiBold, kSize8);

final kCaption10R = kStyle(kRegular, kSize10);
final kCaption10M = kStyle(kMedium, kSize10);
final kCaption10SB = kStyle(kSemiBold, kSize10);

final kCaption11R = kStyle(kRegular, kSize11);
final kCaption12R = kStyle(kRegular, kSize12, color: kSecondaryTextColor);
final kCaption12M = kStyle(kMedium, kSize12);
final kCaption12SB = kStyle(kSemiBold, kSize12);
final kCaption13R = kStyle(kRegular, kSize13, color: kSecondaryTextColor);
final kCaption13SB = kStyle(kSemiBold, kSize13, color: kTextColor);
final kCaption14R = kStyle(kRegular, kSize14);
final kCaption14M = kStyle(kMedium, kSize14);
final kCaption14B = kStyle(kSemiBold, kSize14, color: kTextColor);
final kCaption15M = kStyle(kMedium, kSize15, color: kMutedText);

final kLabel15M = kStyle(kMedium, kSize15, color: kTextColor, height: 1.25);
final kLabel15SB = kStyle(kSemiBold, kSize15, color: kTextColor);
final kLabel17B = kStyle(kSemiBold, kSize17, height: 1.1);
final kLabel19SB = kStyle(kSemiBold, kSize19, color: kTextColor, height: 1.1);
final kLabel22B = kStyle(kSemiBold, kSize22, color: kPrimaryColor, height: 1.1);
final kLabel22White = kStyle(kSemiBold, kSize22, color: kWhite, height: 1.15);

final kTabLabelR = kStyle(kRegular, kSize12, color: kTextColor);
final kTabLabelM = kStyle(kMedium, kSize12, color: kPrimaryColor);

final kNavLabelR = kStyle(kRegular, kSize12, color: kSecondaryTextColor);
final kNavLabelM = kStyle(kMedium, kSize12, color: kPrimaryColor);

final kLinkM = kStyle(kMedium, kSize15, color: kPrimaryColor);
final kLinkSB = kStyle(kSemiBold, kSize15, color: kPrimaryColor);

final kButtonLabelM = kStyle(kMedium, kSize15, color: kWhite, height: 1.2);
final kButtonLabelSB = kStyle(kSemiBold, kSize15, color: kWhite, height: 1.2);

final kSectionLabelR = kStyle(kRegular, kSize12, color: kSecondaryTextColor);
final kSectionTitleSB = kStyle(kSemiBold, kSize19, color: kTextColor);
final kEmptyStateM = kStyle(kMedium, kSize15, color: kMutedText);
final kVersionR = kStyle(kRegular, kSize12, color: kSecondaryTextColor);
