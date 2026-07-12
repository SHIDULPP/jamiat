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

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Figma: frame 402pt · content x=16 + inner pad 8 ⇒ 24pt side inset · top=64
    final topInset = MediaQuery.paddingOf(context).top;
    final topPadding = (64 - topInset).clamp(0.0, 64.0);

    return Scaffold(
      backgroundColor: kWhite,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(24, topPadding, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo — Figma 140 × 64
            Image.asset(
              'assets/pngs/jamiat_logo.png',
              width: 140,
              height: 64,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
            ),
            const SizedBox(height: 32),

            // Illustration — Figma 80 × 80
            SvgPicture.asset(
              'assets/svg/rolechange.svg',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
            ),
            const SizedBox(height: 16),

            // Title — Noto Sans SemiBold 19 / line-height 1.4
            Text(
              'Select Your Role',
              style: kSubHeadingSB.copyWith(color: kTextColor, height: 1.4),
            ),
            // Subtitle flush under title — Regular 12 / #AAAAAA / line-height 1.36
            Text(
              'Choose your role in Jamait',
              style: kCaption12R.copyWith(
                color: kSecondaryTextColor,
                height: 1.36,
              ),
            ),
            const SizedBox(height: 16),

            _RoleCard(
              iconAsset: 'assets/svg/normal_member.svg',
              title: 'Normal Member',
              description:
                  'Access the Charity module exclusively to view donation campaigns, track contributions, and read reports.',
              onTap: () {
                ref.read(selectedRoleProvider.notifier).setRole('normal');
                NavigationService().pushNamedAndRemoveUntil('navBar');
              },
            ),
            const SizedBox(height: 16),
            _RoleCard(
              iconAsset: 'assets/svg/jamiat_membership.svg',
              title: 'Jamiat Member',
              description:
                  'Gain full access to all community modules, features, updates, and specialized tools.',
              onTap: () {
                ref.read(selectedRoleProvider.notifier).setRole('member');
                NavigationService().pushNamedAndRemoveUntil('navBar');
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Figma role card: bg #F4F4F4 · radius 14 · pad 16 · icon 24 · gap 12 / 4
class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.iconAsset,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final String iconAsset;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kBackgroundColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(iconAsset, width: 24, height: 24),
            const SizedBox(height: 12),
            Text(
              title,
              style: kBodyTitleSB.copyWith(color: kTextColor, height: 1.2),
            ),
            const SizedBox(height: 4),
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
    );
  }
}
