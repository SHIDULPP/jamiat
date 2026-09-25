import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

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
    final bulletStyle = bodyStyle;

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
                    child: Text('Terms & Conditions', style: kSectionTitleSB),
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
                      'Last Updated: 04 Sep 2026',
                      style: kCaption12R.copyWith(color: kMutedText),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome to Jamiat Charitable Trust. By using this app, '
                      'you agree to our terms below.',
                      style: bodyStyle,
                    ),
                    const SizedBox(height: 24),
                    _Section(
                      title: '1. Acceptance of Terms',
                      child: Text(
                        'By creating an account and using this app, you agree '
                        'to these Terms & Conditions.',
                        style: bodyStyle,
                      ),
                    ),
                    _Section(
                      title: '2. Who Can Use',
                      child: Text(
                        'You must be 18 years or older to use this app and '
                        'make donations.',
                        style: bodyStyle,
                      ),
                    ),
                    _Section(
                      title: '3. Donations',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Bullet(
                            'All donations are voluntary.',
                            style: bulletStyle,
                          ),
                          _Bullet(
                            'Donations are processed via secure payment gateway.',
                            style: bulletStyle,
                          ),
                          _Bullet(
                            'You will receive a receipt instantly after payment.',
                            style: bulletStyle,
                          ),
                        ],
                      ),
                    ),
                    _Section(
                      title: '4. Refund Policy',
                      child: Text(
                        'Donations are non-refundable once processed.',
                        style: bodyStyle,
                      ),
                    ),
                    _Section(
                      title: '5. Use of Funds',
                      child: Text(
                        'We ensure 100% transparency. We conduct regular audits.',
                        style: bodyStyle,
                      ),
                    ),
                    _Section(
                      title: '6. User Responsibility',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Bullet(
                            'Do not provide false information.',
                            style: bulletStyle,
                          ),
                          _Bullet(
                            'Keep your login OTP and password safe.',
                            style: bulletStyle,
                          ),
                          _Bullet(
                            'Do not misuse the app for any illegal activity.',
                            style: bulletStyle,
                          ),
                        ],
                      ),
                    ),
                    _Section(
                      title: '7. Privacy',
                      child: Text(
                        'We respect your privacy. We never share your personal '
                        'or payment details. Please read our Privacy Policy for '
                        'more details.',
                        style: bodyStyle,
                      ),
                    ),
                    _Section(
                      title: '8. Changes to Terms',
                      child: Text(
                        'We may update these terms from time to time. We will '
                        'notify you in the app if we do.',
                        style: bodyStyle,
                      ),
                    ),
                    _Section(
                      title: '9. Contact Us',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'If you have any questions, contact us:',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () {
                              HapticHelper.impact(HapticImpact.light);
                              _launch(
                                context,
                                Uri(scheme: 'mailto', path: _email),
                              );
                            },
                            child: Text(
                              _email,
                              style: kBodyTitleM.copyWith(
                                color: kPrimaryColor,
                                decoration: TextDecoration.underline,
                                decorationColor: kPrimaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () {
                              HapticHelper.impact(HapticImpact.light);
                              _launch(context, Uri(scheme: 'tel', path: _phone));
                            },
                            child: Text(
                              _phone,
                              style: kBodyTitleM.copyWith(
                                color: kPrimaryColor,
                                decoration: TextDecoration.underline,
                                decorationColor: kPrimaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
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

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: kBodyTitleSB),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: kBodyText,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: style)),
        ],
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
