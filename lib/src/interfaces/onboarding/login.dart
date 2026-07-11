import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';
import 'package:jamiat/src/interfaces/components/primarybutton.dart';

// ================= CUSTOM VECTOR ARTWORK ICONS =================

class SmartphoneIcon extends StatelessWidget {
  const SmartphoneIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Vibration waves on top-right
          Positioned(
            top: 16,
            right: 18,
            child: SizedBox(
              width: 14,
              height: 20,
              child: CustomPaint(
                painter: _VibrationLinesPainter(),
              ),
            ),
          ),
          // Smartphone shell
          Container(
            width: 38,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kTextColor, width: 2),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Top receiver speaker
                Positioned(
                  top: 5,
                  child: Container(
                    width: 10,
                    height: 2,
                    decoration: BoxDecoration(
                      color: kTextColor,
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
                // Bottom circular home key
                Positioned(
                  bottom: 3,
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: kTextColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VibrationLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kTextColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Outer larger arc
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width * 2, size.height),
      -0.9 * 3.1415,
      0.6 * 3.1415,
      false,
      paint,
    );
    // Inner smaller arc
    canvas.drawArc(
      Rect.fromLTWH(size.width * 0.3, size.height * 0.15, size.width * 1.4, size.height * 0.7),
      -0.9 * 3.1415,
      0.6 * 3.1415,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PasscodeIcon extends StatelessWidget {
  const PasscodeIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Keyboard ticks/rays indicator on top right
          Positioned(
            top: 22,
            right: 12,
            child: SizedBox(
              width: 12,
              height: 12,
              child: CustomPaint(
                painter: _PasscodeRaysPainter(),
              ),
            ),
          ),
          // Passcode block
          Container(
            width: 72,
            height: 26,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: kTextColor, width: 2),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('*', style: TextStyle(color: kTextColor, fontSize: 18, fontWeight: FontWeight.bold, height: 1.5)),
                Text('*', style: TextStyle(color: kTextColor, fontSize: 18, fontWeight: FontWeight.bold, height: 1.5)),
                Text('*', style: TextStyle(color: kTextColor, fontSize: 18, fontWeight: FontWeight.bold, height: 1.5)),
                Text('*', style: TextStyle(color: kTextColor, fontSize: 18, fontWeight: FontWeight.bold, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PasscodeRaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kTextColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw three ray vectors
    canvas.drawLine(const Offset(0, 8), const Offset(4, 4), paint);
    canvas.drawLine(const Offset(4, 10), const Offset(9, 7), paint);
    canvas.drawLine(const Offset(1, 11), const Offset(5, 13), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ================= MAIN LOGIN SCREEN =================

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _phoneController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _requestOtp() async {
    final digits = _phoneController.text.trim();
    if (digits.isEmpty || digits.length < 10) {
      _showMessage('Please enter a valid 10-digit mobile number');
      return;
    }

    setState(() => _isLoading = true);

    // Mock API Delay
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;
    setState(() => _isLoading = false);

    _showMessage('OTP Sent successfully to +91 $digits');

    // Transition to OTP screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPScreen(
          phoneNumber: digits,
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Circular Back Button
            Padding(
              padding: const EdgeInsets.only(left: 20, top: 16),
              child: GestureDetector(
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kWhite.withValues(alpha: 0.08),
                    border: Border.all(color: kBorder, width: 1.25),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: kTextColor,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Artwork Icon
            const Center(
              child: SmartphoneIcon(),
            ),
            const SizedBox(height: 16),

            // Heading & Subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter Phone Number',
                    style: kHeadTitleSB,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'We’ll send a OTP to verify your number',
                    style: kCaption13R.copyWith(color: kSecondaryTextColor),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Fields / Input Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mobile Number',
                      style: kLabel15M,
                    ),
                    const SizedBox(height: 8),

                    // Custom horizontal layout phone input container
                    Container(
                      height: 66,
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kBorder, width: 1.0),
                      ),
                      child: Row(
                        children: [
                          // Country selector (+91)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Row(
                              children: [
                                Text(
                                  '+91',
                                  style: kBodyTitleR.copyWith(color: kTextColor),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  color: kSecondaryTextColor,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                          // Vertical dividing border
                          Container(
                            width: 1.0,
                            height: 32,
                            color: kBorder,
                          ),
                          // Mobile Number Input Field
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              cursorColor: kBlack,
                              maxLength: 10,
                              style: kBodyTitleR.copyWith(color: kTextColor),
                              decoration: InputDecoration(
                                hintText: 'Enter mobile number',
                                hintStyle: kBodyTitleR.copyWith(color: kSecondaryTextColor),
                                border: InputBorder.none,
                                counterText: '',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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

            // Bottom CTA Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: primaryButton(
                label: 'Sent OTP',
                onPressed: _isLoading ? null : _requestOtp,
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= OTP SCREEN =================

class OTPScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OTPScreen({
    required this.phoneNumber,
    super.key,
  });

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  late TextEditingController _otpController;
  late FocusNode _hiddenFocusNode;
  bool _isLoading = false;
  Timer? _timer;
  int _start = 59;
  bool _isResendDisabled = true;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _hiddenFocusNode = FocusNode();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _hiddenFocusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isResendDisabled = true;
      _start = 59;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          _isResendDisabled = false;
        });
        timer.cancel();
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  void _resendOtp() async {
    _startTimer();
    setState(() => _isLoading = true);

    // Mock API Delay
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;
    setState(() => _isLoading = false);

    _showMessage('OTP resent successfully to +91 ${widget.phoneNumber}');
  }

  void _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      _showMessage('Please enter the 6-digit OTP');
      return;
    }

    setState(() => _isLoading = true);

    // Mock API Delay
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;
    setState(() => _isLoading = false);

    _showMessage('OTP verified successfully!');

    // Transition to main application screen (navBar)
    NavigationService().pushNamedAndRemoveUntil('navBar');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final otpLength = _otpController.text.length;

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Stack(
          children: [
            // Invisible input source to capture keyboard taps
            Positioned(
              top: -100,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 0.0,
                child: TextField(
                  focusNode: _hiddenFocusNode,
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  autofocus: true,
                  onChanged: (val) {
                    setState(() {});
                    if (val.length == 6) {
                      _hiddenFocusNode.unfocus();
                    }
                  },
                  decoration: const InputDecoration(
                    counterText: '',
                  ),
                ),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Circular Back Button
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 16),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kWhite.withValues(alpha: 0.08),
                        border: Border.all(color: kBorder, width: 1.25),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: kTextColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Passcode Vector Artwork Icon
                const Center(
                  child: PasscodeIcon(),
                ),
                const SizedBox(height: 16),

                // Heading & Subtitle (identical headings as Figma screenshots)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter Phone Number',
                        style: kHeadTitleSB,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'We’ll send a OTP to verify your number',
                        style: kCaption13R.copyWith(color: kSecondaryTextColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Fields / Input Section
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter OTP',
                          style: kLabel15M,
                        ),
                        const SizedBox(height: 8),

                        // Grid of 6 rounded boxes
                        GestureDetector(
                          onTap: () {
                            _hiddenFocusNode.requestFocus();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              final char = otpLength > index ? _otpController.text[index] : '';
                              final isFocusedCell = otpLength == index && _hiddenFocusNode.hasFocus;

                              return Container(
                                width: 52,
                                height: 58,
                                decoration: BoxDecoration(
                                  color: kWhite,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isFocusedCell
                                        ? kPrimaryColor
                                        : kBorder,
                                    width: isFocusedCell ? 2.0 : 1.0,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    char,
                                    style: kHeadTitleSB.copyWith(
                                      color: kTextColor,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Resend details
                        Center(
                          child: Column(
                            children: [
                              Text(
                                "Didn't get SMS?",
                                style: kCaption13R.copyWith(color: kSecondaryTextColor),
                              ),
                              const SizedBox(height: 6),
                              if (_isResendDisabled)
                                RichText(
                                  text: TextSpan(
                                    style: kCaption13R.copyWith(color: kSecondaryTextColor),
                                    children: [
                                      const TextSpan(text: 'Get a new OTP in '),
                                      TextSpan(
                                        text: '00:${_start.toString().padLeft(2, '0')}',
                                        style: kCaption13R.copyWith(
                                          color: kPrimaryColor,
                                          fontWeight: kSemiBold,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                GestureDetector(
                                  onTap: _resendOtp,
                                  child: Text(
                                    'Resend OTP',
                                    style: kLinkSB.copyWith(fontSize: 13),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Verify Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: primaryButton(
                    label: 'Verify OTP',
                    onPressed: _isLoading ? null : _verifyOtp,
                    isLoading: _isLoading,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
