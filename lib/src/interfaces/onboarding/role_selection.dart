import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';

final selectedRoleProvider = NotifierProvider<SelectedRoleNotifier, String?>(
  SelectedRoleNotifier.new,
);

class SelectedRoleNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setRole(String? role) {
    state = role;
  }
}

/// Figma frame: Role Selection (402 × 874) — node `239:340`
class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  static const double _figmaWidth = 402;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    // Scale layout to screen width from Figma's 402pt frame.
    final scale = (size.width / _figmaWidth).clamp(0.88, 1.12);

    // Content starts at y=64 in Figma (below status-bar area).
    final topPadding = (64 * scale - topInset).clamp(0.0, 64 * scale);

    // Outer x=16 + inner pad 8 ⇒ 24pt side inset on 402pt frame.
    final sideInset = 24 * scale;

    return Scaffold(
      backgroundColor: kWhite,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          sideInset,
          topPadding,
          sideInset,
          24 * scale + bottomInset,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo — Figma 140 × 64 (cropped lockup)
            Image.asset(
              'assets/pngs/role_selection_logo.png',
              width: 140 * scale,
              height: 64 * scale,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              filterQuality: FilterQuality.high,
            ),

            // Frame 2004 gap between logo and body
            SizedBox(height: 32 * scale),

            // Frame 35 — vertical gap 16
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Frame 2003 — illustration + titles, gap 16
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Illustration frame 80 × 80
                    SizedBox(
                      width: 80 * scale,
                      height: 80 * scale,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: SvgPicture.asset(
                          'assets/svg/rolechange.svg',
                          width: 71 * scale,
                          height: 51 * scale,
                          fit: BoxFit.contain,
                          alignment: Alignment.centerLeft,
                        ),
                      ),
                    ),
                    SizedBox(height: 16 * scale),

                    // Frame 47 — title + subtitle, gap 0
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Your Role',
                          style: kSubHeadingSB.copyWith(
                            color: kTextColor,
                            height: 1.4,
                          ),
                        ),
                        Text(
                          'Choose your role in Jamait',
                          style: kCaption12R.copyWith(
                            color: kSecondaryTextColor,
                            height: 1.36,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 16 * scale),

                // Frame 2005 — role cards, gap 16
                Column(
                  children: [
                    _RoleCard(
                      scale: scale,
                      iconAsset: 'assets/svg/normal_member.svg',
                      title: 'Normal Member',
                      description:
                          'Access the Charity module exclusively to view donation campaigns, track contributions, and read reports.',
                      onTap: () {
                        ref
                            .read(selectedRoleProvider.notifier)
                            .setRole('normal_member');
                        NavigationService().pushNamed('Registration');
                      },
                    ),
                    SizedBox(height: 16 * scale),
                    _RoleCard(
                      scale: scale,
                      iconAsset: 'assets/svg/jamiat_membership.svg',
                      title: 'Jamiat Member',
                      description:
                          'Gain full access to all community modules, features, updates, and specialized tools.',
                      onTap: () {
                        ref
                            .read(selectedRoleProvider.notifier)
                            .setRole('jamiat_member');
                        NavigationService().pushNamed('Registration');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.scale,
    required this.iconAsset,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final double scale;
  final String iconAsset;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pad = 16 * scale;
    final iconSize = 24 * scale;
    final radius = kCardRadiusMd * scale;

    return Material(
      color: kBackgroundColor,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Padding(
          padding: EdgeInsets.all(pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                iconAsset,
                width: iconSize,
                height: iconSize,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 12 * scale),
              Text(
                title,
                style: kBodyTitleSB.copyWith(color: kTextColor, height: 1.2),
              ),
              SizedBox(height: 4 * scale),
              Text(
                description,
                style: kCaption12R.copyWith(
                  color: kSecondaryTextColor,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
