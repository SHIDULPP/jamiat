import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpAndSupportScreen extends StatelessWidget {
  const HelpAndSupportScreen({super.key});

  static const _email = 'jamiatconnect@gmail.com';
  static const _phone = '9633503777';

  Future<void> _launch(BuildContext context, Uri uri) async {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to open link',
            style: kCaption14M.copyWith(color: kWhite),
          ),
          backgroundColor: kRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bodyStyle = kBodyTitleR.copyWith(
      color: kBodyText,
      height: 1.55,
    );

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                kScreenPaddingH,
                8,
                kScreenPaddingH,
                16,
              ),
              child: Row(
                children: [
                  _HeaderCircleButton(
                    onTap: () {
                      HapticHelper.impact(HapticImpact.light);
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.arrow_back,
                      color: kTextColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Help & Support', style: kSectionTitleSB),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  kScreenPaddingH,
                  0,
                  kScreenPaddingH,
                  32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Need help? Reach out to us using the contact details '
                      'below. We\'re happy to assist you.',
                      style: bodyStyle,
                    ),
                    const SizedBox(height: 24),
                    Text('Contact Us', style: kBodyTitleSB),
                    const SizedBox(height: 16),
                    _ContactTile(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: _email,
                      onTap: () {
                        HapticHelper.impact(HapticImpact.light);
                        _launch(
                          context,
                          Uri(scheme: 'mailto', path: _email),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _ContactTile(
                      icon: Icons.phone_outlined,
                      label: 'Mobile No',
                      value: _phone,
                      onTap: () {
                        HapticHelper.impact(HapticImpact.light);
                        _launch(
                          context,
                          Uri(scheme: 'tel', path: _phone),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kScreenBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: kPrimaryColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: kCaption12R.copyWith(color: kMutedText),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: kBodyTitleM.copyWith(
                        color: kPrimaryColor,
                        decoration: TextDecoration.underline,
                        decorationColor: kPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: kMutedText,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kScreenBg,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(width: 40, height: 40, child: Center(child: child)),
      ),
    );
  }
}
