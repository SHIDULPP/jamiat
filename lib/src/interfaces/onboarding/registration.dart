import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/interfaces/components/primarybutton.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Text Editing Controllers
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _whatsappController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  late TextEditingController _addressController;
  late TextEditingController _pincodeController;

  // Focus Nodes
  late FocusNode _phoneFocusNode;
  late FocusNode _whatsappFocusNode;

  // State Variables
  bool _sameAsPhoneNumber = false;
  bool _isLoading = false;

  // Dropdown Selections
  String? _selectedGender;
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedArea;

  // Mock Dropdown Lists
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _countries = ['India', 'Other'];
  final List<String> _states = ['Kerala', 'Karnataka', 'Tamil Nadu'];
  final List<String> _districts = ['Ernakulam', 'Calicut', 'Trivandrum'];
  final List<String> _areas = ['Area 1', 'Area 2', 'Area 3'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _whatsappController = TextEditingController();
    _emailController = TextEditingController();
    _dobController = TextEditingController();
    _addressController = TextEditingController();
    _pincodeController = TextEditingController();

    _phoneFocusNode = FocusNode();
    _whatsappFocusNode = FocusNode();

    // Listen to changes in phone number to automatically sync to WhatsApp if checkbox is enabled
    _phoneController.addListener(() {
      if (_sameAsPhoneNumber) {
        _whatsappController.text = _phoneController.text;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _pincodeController.dispose();

    _phoneFocusNode.dispose();
    _whatsappFocusNode.dispose();
    super.dispose();
  }

  OutlineInputBorder _fieldBorder({Color? color, double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color ?? kBorder, width: width),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: kWhite,
      hintText: hintText,
      hintStyle: kBodyTitleR.copyWith(color: kSecondaryTextColor),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 16,
      ),
      border: _fieldBorder(),
      enabledBorder: _fieldBorder(),
      focusedBorder: _fieldBorder(color: kPrimaryColor, width: 1.5),
      errorBorder: _fieldBorder(color: kRed, width: 1.5),
      focusedErrorBorder: _fieldBorder(color: kRed, width: 2),
      suffixIcon: suffixIcon,
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: kLabel15M.copyWith(color: kTextColor),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: kBodyTitleR.copyWith(color: kTextColor),
          validator: validator,
          decoration: _inputDecoration(hintText: hintText),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required String hintText,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        DropdownButtonFormField<String>(
          initialValue: value,
          hint: Text(
            hintText,
            style: kBodyTitleR.copyWith(color: kSecondaryTextColor),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: kSecondaryTextColor,
            size: 20,
          ),
          decoration: _inputDecoration(hintText: hintText),
          dropdownColor: kWhite,
          style: kBodyTitleR.copyWith(color: kTextColor),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: controller,
          readOnly: true,
          style: kBodyTitleR.copyWith(color: kTextColor),
          decoration: _inputDecoration(hintText: 'dd/mm/yyyy'),
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: kPrimaryColor,
                      onPrimary: kWhite,
                      onSurface: kTextColor,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              final day = picked.day.toString().padLeft(2, '0');
              final month = picked.month.toString().padLeft(2, '0');
              final year = picked.year.toString();
              setState(() {
                controller.text = '$day/$month/$year';
              });
            }
          },
        ),
      ],
    );
  }

  Future<void> _handleContinue() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      // Mock API delay for onboarding
      await Future.delayed(const Duration(milliseconds: 1000));
      if (!mounted) return;
      setState(() => _isLoading = false);

      // Navigate to next screen or complete onboarding
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile setup complete!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back Button
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
                      color: kWhite,
                      border: Border.all(color: kBorder, width: 1.25),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: kTextColor,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Screen Title & Subtitle
                Text(
                  'Profile setup',
                  style: kHeadTitleB.copyWith(color: kTextColor, fontSize: 24),
                ),
                const SizedBox(height: 6),
                Text(
                  'Complete your details to connect with the community and access your services.',
                  style: kCaption13R.copyWith(color: kSecondaryTextColor),
                ),
                const SizedBox(height: 32),

                // Centered Profile Image Avatar
                Center(
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD9D9D9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          size: 64,
                          color: Color(0xFF999999),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: kWhite,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: kTextColor,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Form Fields
                _buildTextField(
                  label: 'Name',
                  controller: _nameController,
                  hintText: 'Enter name',
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Phone Number field
                _buildLabel('Phone Number'),
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
                    if (phone == null || phone.number.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    return null;
                  },
                  decoration: _inputDecoration(hintText: '999587XXXX'),
                  onCountryChanged: (value) {},
                  onChanged: (phone) {
                    setState(() {
                      if (_sameAsPhoneNumber) {
                        _whatsappController.text = phone.number;
                      }
                    });
                  },
                ),
                const SizedBox(height: 20),

                // WhatsApp Number with "Same as phone number" checkbox
                _buildLabel('WhatsApp Number'),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _sameAsPhoneNumber = !_sameAsPhoneNumber;
                      if (_sameAsPhoneNumber) {
                        _whatsappController.text = _phoneController.text;
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: _sameAsPhoneNumber ? kPrimaryColor : kBorder,
                              width: 1.5,
                            ),
                            color: _sameAsPhoneNumber ? kPrimaryColor : Colors.transparent,
                          ),
                          child: _sameAsPhoneNumber
                              ? const Icon(
                                  Icons.check,
                                  size: 14,
                                  color: kWhite,
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Same as phone number',
                          style: kCaption12R.copyWith(
                            color: kTextColor,
                            fontWeight: kRegular,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IntlPhoneField(
                  focusNode: _whatsappFocusNode,
                  controller: _whatsappController,
                  initialCountryCode: 'IN',
                  disableLengthCheck: true,
                  showCountryFlag: false,
                  showDropdownIcon: true,
                  enabled: !_sameAsPhoneNumber,
                  cursorColor: kBlack,
                  style: kBodyTitleR.copyWith(
                    color: _sameAsPhoneNumber ? kSecondaryTextColor : kTextColor,
                  ),
                  dropdownTextStyle: kBodyTitleR.copyWith(
                    color: _sameAsPhoneNumber ? kSecondaryTextColor : kTextColor,
                  ),
                  dropdownIcon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: kSecondaryTextColor,
                    size: 18,
                  ),
                  dropdownIconPosition: IconPosition.trailing,
                  flagsButtonPadding: const EdgeInsets.only(left: 18),
                  decoration: _inputDecoration(hintText: 'Enter mobile number'),
                  onCountryChanged: (value) {},
                  onChanged: (phone) {},
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  label: 'Email',
                  controller: _emailController,
                  hintText: 'Enter email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildDropdownField(
                  label: 'Gender',
                  value: _selectedGender,
                  items: _genders,
                  hintText: 'Select',
                  onChanged: (val) {
                    setState(() {
                      _selectedGender = val;
                    });
                  },
                ),
                const SizedBox(height: 20),

                _buildDateField(
                  label: 'Date of Birth',
                  controller: _dobController,
                  context: context,
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  label: 'Address',
                  controller: _addressController,
                  hintText: 'Enter Address',
                ),
                const SizedBox(height: 20),

                _buildDropdownField(
                  label: 'Country',
                  value: _selectedCountry,
                  items: _countries,
                  hintText: 'Select',
                  onChanged: (val) {
                    setState(() {
                      _selectedCountry = val;
                    });
                  },
                ),
                const SizedBox(height: 20),

                _buildDropdownField(
                  label: 'State',
                  value: _selectedState,
                  items: _states,
                  hintText: 'Select',
                  onChanged: (val) {
                    setState(() {
                      _selectedState = val;
                    });
                  },
                ),
                const SizedBox(height: 20),

                _buildDropdownField(
                  label: 'District',
                  value: _selectedDistrict,
                  items: _districts,
                  hintText: 'Select',
                  onChanged: (val) {
                    setState(() {
                      _selectedDistrict = val;
                    });
                  },
                ),
                const SizedBox(height: 20),

                _buildDropdownField(
                  label: 'Area',
                  value: _selectedArea,
                  items: _areas,
                  hintText: 'Select',
                  onChanged: (val) {
                    setState(() {
                      _selectedArea = val;
                    });
                  },
                ),
                const SizedBox(height: 20),

                _buildTextField(
                  label: 'Pin code',
                  controller: _pincodeController,
                  hintText: 'Enter pin code',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),

                // Continue Button
                primaryButton(
                  label: 'Continue',
                  onPressed: _isLoading ? null : _handleContinue,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
