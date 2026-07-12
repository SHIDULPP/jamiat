import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';
import 'package:jamiat/src/interfaces/components/primarybutton.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

// ================= MAIN LOGIN SCREEN =================

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _phoneController;
  late FocusNode _phoneFocusNode;
  bool _isLoading = false;
  bool _showPhoneError = false;
  String _fullPhoneNumber = '';
  String _dialCode = '91';

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    _phoneFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  Future<void> _requestOtp() async {
    setState(() => _showPhoneError = true);

    final digits = _phoneController.text.trim();
    if (digits.isEmpty || !RegExp(r'^[0-9]+$').hasMatch(digits)) {
      _showMessage('Please enter a valid mobile number');
      return;
    }
    if (digits.length < 10) {
      _showMessage('Please enter a valid 10-digit mobile number');
      return;
    }

    setState(() => _isLoading = true);

    // Mock API Delay
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;
    setState(() => _isLoading = false);

    final displayNumber = _fullPhoneNumber.isNotEmpty
        ? _fullPhoneNumber
        : '+$_dialCode $digits';
    _showMessage('OTP Sent successfully to $displayNumber');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPScreen(
          phoneNumber: digits,
          dialCode: _dialCode,
          fullPhoneNumber: displayNumber,
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  OutlineInputBorder _phoneBorder({Color? color, double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color ?? kBorder, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
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
              const SizedBox(height: 62),
              SvgPicture.asset(
                'assets/svg/phonelogo.svg',
                width: 42,
                height: 50,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
              ),
              const SizedBox(height: 16),
              Text('Enter Phone Number', style: kHeadTitleSB),
              const SizedBox(height: 6),
              Text(
                'We’ll send a OTP to verify your number',
                style: kCaption13R.copyWith(color: kSecondaryTextColor),
              ),
              const SizedBox(height: 32),
              Text('Mobile Number', style: kLabel15M),
              const SizedBox(height: 8),
              IntlPhoneField(
                focusNode: _phoneFocusNode,
                controller: _phoneController,
                initialCountryCode: 'IN',
                disableLengthCheck: true,
                showCountryFlag: false,
                showDropdownIcon: true,
                cursorColor: kBlack,
                style: kBodyTitleR.copyWith(color: kTextColor),
                dropdownTextStyle: kBodyTitleR.copyWith(color: kTextColor),
                dropdownIcon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: kSecondaryTextColor,
                  size: 18,
                ),
                dropdownIconPosition: IconPosition.trailing,
                flagsButtonPadding: const EdgeInsets.only(left: 18),
                validator: (phone) {
                  if (!_showPhoneError) return null;
                  if (phone == null || phone.number.isEmpty) {
                    return 'Mobile number is required';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(phone.number)) {
                    return 'Mobile number must contain only digits';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: kWhite,
                  hintText: 'Enter mobile number',
                  hintStyle: kBodyTitleR.copyWith(color: kSecondaryTextColor),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 16,
                  ),
                  border: _phoneBorder(),
                  enabledBorder: _phoneBorder(),
                  focusedBorder: _phoneBorder(color: kPrimaryColor, width: 1.5),
                  errorBorder: _phoneBorder(color: kRed, width: 1.5),
                  focusedErrorBorder: _phoneBorder(color: kRed, width: 2),
                ),
                onCountryChanged: (value) {
                  _dialCode = value.dialCode;
                },
                onChanged: (phone) {
                  _fullPhoneNumber = phone.completeNumber;
                  _dialCode = phone.countryCode.replaceAll('+', '');
                },
              ),
              const SizedBox(height: 24),
              primaryButton(
                label: 'Sent OTP',
                onPressed: _isLoading ? null : _requestOtp,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= OTP SCREEN =================

class OTPScreen extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String dialCode;
  final String fullPhoneNumber;

  const OTPScreen({
    required this.phoneNumber,
    this.dialCode = '91',
    this.fullPhoneNumber = '',
    super.key,
  });

  @override
  ConsumerState<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends ConsumerState<OTPScreen> {
  late TextEditingController _otpController;
  bool _isLoading = false;
  Timer? _timer;
  int _start = 59;
  bool _isResendDisabled = true;

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    // _otpController.dispose();
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
        setState(() => _isResendDisabled = false);
        timer.cancel();
      } else {
        setState(() => _start--);
      }
    });
  }

  Future<void> _resendOtp() async {
    _startTimer();
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;
    setState(() => _isLoading = false);

    final display = widget.fullPhoneNumber.isNotEmpty
        ? widget.fullPhoneNumber
        : '+${widget.dialCode} ${widget.phoneNumber}';
    _showMessage('OTP resent successfully to $display');
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      _showMessage('Please enter the 6-digit OTP');
      return;
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;
    setState(() => _isLoading = false);

    _showMessage('OTP verified successfully!');
    NavigationService().pushNamedAndRemoveUntil('RoleSelection');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
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
              const SizedBox(height: 62),
              SvgPicture.asset(
                'assets/svg/otplogo.svg',
                width: 72,
                height: 30,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
              ),
              const SizedBox(height: 16),
              Text('Enter Phone Number', style: kHeadTitleSB),
              const SizedBox(height: 6),
              Text(
                'We’ll send a OTP to verify your number',
                style: kCaption13R.copyWith(color: kSecondaryTextColor),
              ),
              const SizedBox(height: 32),
              Text('Enter OTP', style: kLabel15M),
              const SizedBox(height: 8),
              LayoutBuilder(
                builder: (context, constraints) {
                  const otpLength = 6;
                  const fieldGap = 8.0;
                  final fieldWidth =
                      ((constraints.maxWidth - fieldGap * (otpLength - 1)) /
                              otpLength)
                          .clamp(44.0, 56.0);

                  return PinCodeTextField(
                    appContext: context,
                    length: otpLength,
                    controller: _otpController,
                    obscureText: false,
                    autoFocus: true,
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.fade,
                    textStyle: kHeadTitleSB.copyWith(
                      color: kTextColor,
                      fontSize: 20,
                    ),
                    cursorColor: kPrimaryColor,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(16),
                      fieldHeight: 58,
                      fieldWidth: fieldWidth,
                      borderWidth: 1,
                      activeBorderWidth: 1,
                      selectedBorderWidth: 2,
                      inactiveBorderWidth: 1,
                      selectedColor: kPrimaryColor,
                      activeColor: kPrimaryColor.withValues(alpha: 0.5),
                      inactiveColor: kPrimaryColor.withValues(alpha: 0.5),
                      activeFillColor: kWhite,
                      selectedFillColor: kWhite,
                      inactiveFillColor: kWhite,
                    ),
                    animationDuration: const Duration(milliseconds: 200),
                    backgroundColor: Colors.transparent,
                    enableActiveFill: true,
                    onChanged: (_) {},
                    onCompleted: (_) => _verifyOtp(),
                  );
                },
              ),
              const SizedBox(height: 24),
              primaryButton(
                label: 'Verify OTP',
                onPressed: _isLoading ? null : _verifyOtp,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 24),
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
                          style: kCaption13R.copyWith(
                            color: kSecondaryTextColor,
                          ),
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
    );
  }
}
