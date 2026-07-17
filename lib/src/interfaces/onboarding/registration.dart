import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:jamiat/src/data/apis/upload_api.dart';
import 'package:jamiat/src/data/apis/user_api.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/models/user_model.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';
import 'package:jamiat/src/data/services/secure_storage_service.dart';
import 'package:jamiat/src/data/utils/auth_navigation.dart';
import 'package:jamiat/src/interfaces/components/primarybutton.dart';
import 'package:jamiat/src/interfaces/onboarding/role_selection.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key, this.isEditMode = false});

  final bool isEditMode;

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _whatsappController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  late TextEditingController _addressController;
  late TextEditingController _pincodeController;

  late FocusNode _whatsappFocusNode;

  bool _sameAsPhoneNumber = false;
  bool _isLoading = false;
  bool _isUploadingAvatar = false;
  bool _didPrefill = false;
  String _verifiedPhone = '';
  String _whatsappFullNumber = '';
  String? _imageUrl;
  String? _existingRole;

  String? _selectedGender;
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedDistrict;
  String? _selectedArea;

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

    _whatsappFocusNode = FocusNode();
    _loadVerifiedPhone();

    _phoneController.addListener(() {
      if (_sameAsPhoneNumber) {
        _whatsappController.text = _phoneController.text;
      }
    });
  }

  Future<void> _loadVerifiedPhone() async {
    final phone = await ref.read(secureStorageServiceProvider).getPhone();
    if (!mounted || phone == null) return;
    setState(() {
      _verifiedPhone = phone;
      _phoneController.text = phone;
    });
  }

  void _ensureInList(List<String> list, String? value) {
    if (value == null || value.isEmpty) return;
    if (!list.contains(value)) list.add(value);
  }

  String? _capitalizeGender(String? gender) {
    if (gender == null || gender.isEmpty) return null;
    return '${gender[0].toUpperCase()}${gender.substring(1).toLowerCase()}';
  }

  String _formatDob(DateTime? dob) {
    if (dob == null) return '';
    final day = dob.day.toString().padLeft(2, '0');
    final month = dob.month.toString().padLeft(2, '0');
    return '$day/$month/${dob.year}';
  }

  void _prefillFromUser(UserModel user) {
    if (_didPrefill) return;
    _didPrefill = true;

    final gender = _capitalizeGender(user.gender);
    _ensureInList(_genders, gender);
    _ensureInList(_countries, user.country);
    _ensureInList(_states, user.state);
    _ensureInList(_districts, user.district);
    _ensureInList(_areas, user.area);

    _nameController.text = user.name ?? '';
    _emailController.text = user.email ?? '';
    _addressController.text = user.address ?? '';
    _pincodeController.text = user.pincode?.toString() ?? '';
    _dobController.text = _formatDob(user.dob);
    _imageUrl = user.image;
    _existingRole = user.role;

    final phone = user.phone.isNotEmpty ? user.phone : _verifiedPhone;
    _verifiedPhone = phone;
    _phoneController.text = phone;

    final whatsapp = user.whatsappNo ?? '';
    final sameAsPhone = whatsapp.isEmpty || whatsapp == phone;
    _sameAsPhoneNumber = sameAsPhone;
    if (sameAsPhone) {
      _whatsappController.text = phone;
      _whatsappFullNumber = phone;
    } else {
      _whatsappController.text = whatsapp.replaceFirst(
        RegExp(r'^\+\d{1,3}'),
        '',
      );
      _whatsappFullNumber = whatsapp;
    }

    _selectedGender = gender;
    _selectedCountry = user.country;
    _selectedState = user.state;
    _selectedDistrict = user.district;
    _selectedArea = user.area;

    if (user.role.isNotEmpty) {
      ref.read(selectedRoleProvider.notifier).setRole(user.role);
    }
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
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
      child: Text(text, style: kLabel15M.copyWith(color: kTextColor)),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
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
          items: items
              .map((item) => DropdownMenuItem(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
          decoration: _inputDecoration(hintText: hintText),
          style: kBodyTitleR.copyWith(color: kTextColor),
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: kSecondaryTextColor,
          ),
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
          decoration: _inputDecoration(
            hintText: 'DD/MM/YYYY',
            suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Date of birth is required';
            }
            return null;
          },
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(now.year - 18),
              firstDate: DateTime(1920),
              lastDate: now,
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: kPrimaryColor,
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

  Future<void> _pickAndUploadAvatar() async {
    if (_isUploadingAvatar) return;

    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (file == null) return;

    setState(() => _isUploadingAvatar = true);
    try {
      final bytes = await file.readAsBytes();
      final filename = file.name.isNotEmpty ? file.name : 'avatar.jpg';
      final mimeType = filename.toLowerCase().endsWith('.png')
          ? 'image/png'
          : 'image/jpeg';

      final upload = await ref
          .read(uploadApiProvider)
          .uploadImage(
            bytes: Uint8List.fromList(bytes),
            filename: filename,
            mimeType: mimeType,
          );

      if (!mounted) return;
      if (!upload.success || upload.data == null) {
        _showMessage(upload.message ?? 'Unable to upload image.');
        return;
      }

      final imageUrl = upload.data!;
      if (widget.isEditMode) {
        final update = await ref.read(userApiProvider).updateProfile({
          'image': imageUrl,
        });
        if (!mounted) return;
        if (!update.success) {
          _showMessage(update.message ?? 'Unable to update avatar.');
          return;
        }
        ref.invalidate(userProfileProvider);
      }

      setState(() => _imageUrl = imageUrl);
      _showMessage('Avatar updated.');
    } catch (e) {
      if (mounted) {
        _showMessage(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _handleContinue() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();

    final role = ref.read(selectedRoleProvider) ?? _existingRole;
    if (role == null || role.isEmpty) {
      _showMessage('Please select your membership role.');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final requiredSelections = [
      _selectedGender,
      _selectedCountry,
      _selectedState,
      _selectedDistrict,
      _selectedArea,
    ];
    if (requiredSelections.any((value) => value == null || value.isEmpty)) {
      _showMessage('Please complete all dropdown fields.');
      return;
    }

    final whatsapp = _sameAsPhoneNumber ? _verifiedPhone : _whatsappFullNumber;
    if (whatsapp.isEmpty) {
      _showMessage('Please enter a valid WhatsApp number.');
      return;
    }

    final dobParts = _dobController.text.split('/');
    final pincode = int.tryParse(_pincodeController.text.trim());
    if (dobParts.length != 3 || pincode == null) {
      _showMessage('Please enter a valid date of birth and pin code.');
      return;
    }
    final dob = '${dobParts[2]}-${dobParts[1]}-${dobParts[0]}';

    setState(() => _isLoading = true);
    final payload = <String, dynamic>{
      'role': role,
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'gender': _selectedGender!.toLowerCase(),
      'whatsapp_no': whatsapp,
      'address': _addressController.text.trim(),
      'area': _selectedArea!,
      'district': _selectedDistrict!,
      'state': _selectedState!,
      'country': _selectedCountry!,
      'pincode': pincode,
      'dob': dob,
      if (_imageUrl != null && _imageUrl!.isNotEmpty) 'image': _imageUrl,
    };

    final response = await ref.read(userApiProvider).updateProfile(payload);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!response.success) {
      _showMessage(response.message ?? 'Unable to update your profile.');
      return;
    }

    final user = response.data;
    if (user == null) {
      _showMessage('The server returned an invalid profile response.');
      return;
    }

    ref.invalidate(userProfileProvider);
    _showMessage(response.message ?? 'Profile updated successfully.');

    if (widget.isEditMode) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      return;
    }

    NavigationService().pushNamedAndRemoveUntil(routeForUser(user));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Widget _avatarWidget() {
    final image = _imageUrl;
    if (image != null && image.startsWith('http')) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: const Color(0xFFD9D9D9),
        backgroundImage: NetworkImage(image),
        onBackgroundImageError: (_, _) {},
      );
    }
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        color: Color(0xFFD9D9D9),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, size: 64, color: Color(0xFF999999)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditMode) {
      ref.listen(userProfileProvider, (previous, next) {
        next.whenData(_prefillFromUser);
      });
      final profile = ref.watch(userProfileProvider).value;
      if (profile != null && !_didPrefill) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _prefillFromUser(profile));
        });
      }
    }

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
                Text(
                  widget.isEditMode ? 'Edit profile' : 'Profile setup',
                  style: kHeadTitleB.copyWith(color: kTextColor, fontSize: 24),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.isEditMode
                      ? 'Update your details and keep your community profile current.'
                      : 'Complete your details to connect with the community and access your services.',
                  style: kCaption13R.copyWith(color: kSecondaryTextColor),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Stack(
                    children: [
                      _avatarWidget(),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _isUploadingAvatar
                              ? null
                              : _pickAndUploadAvatar,
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
                                ),
                              ],
                            ),
                            child: _isUploadingAvatar
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.camera_alt,
                                    color: kTextColor,
                                    size: 18,
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
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
                _buildTextField(
                  label: 'Phone Number',
                  controller: _phoneController,
                  hintText: 'Verified phone number',
                  keyboardType: TextInputType.phone,
                  enabled: false,
                ),
                const SizedBox(height: 20),
                _buildLabel('WhatsApp Number'),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _sameAsPhoneNumber = !_sameAsPhoneNumber;
                      if (_sameAsPhoneNumber) {
                        _whatsappController.text = _phoneController.text;
                        _whatsappFullNumber = _verifiedPhone;
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
                              color: _sameAsPhoneNumber
                                  ? kPrimaryColor
                                  : kBorder,
                              width: 1.5,
                            ),
                            color: _sameAsPhoneNumber
                                ? kPrimaryColor
                                : Colors.transparent,
                          ),
                          child: _sameAsPhoneNumber
                              ? const Icon(Icons.check, size: 14, color: kWhite)
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
                    color: _sameAsPhoneNumber
                        ? kSecondaryTextColor
                        : kTextColor,
                  ),
                  dropdownTextStyle: kBodyTitleR.copyWith(
                    color: _sameAsPhoneNumber
                        ? kSecondaryTextColor
                        : kTextColor,
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
                  onChanged: (phone) {
                    _whatsappFullNumber = phone.completeNumber.replaceAll(
                      ' ',
                      '',
                    );
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  label: 'Email',
                  controller: _emailController,
                  hintText: 'Enter email',
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val != null &&
                        val.trim().isNotEmpty &&
                        !RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(val.trim())) {
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
                    setState(() => _selectedGender = val);
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Address is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildDropdownField(
                  label: 'Country',
                  value: _selectedCountry,
                  items: _countries,
                  hintText: 'Select',
                  onChanged: (val) {
                    setState(() => _selectedCountry = val);
                  },
                ),
                const SizedBox(height: 20),
                _buildDropdownField(
                  label: 'State',
                  value: _selectedState,
                  items: _states,
                  hintText: 'Select',
                  onChanged: (val) {
                    setState(() => _selectedState = val);
                  },
                ),
                const SizedBox(height: 20),
                _buildDropdownField(
                  label: 'District',
                  value: _selectedDistrict,
                  items: _districts,
                  hintText: 'Select',
                  onChanged: (val) {
                    setState(() => _selectedDistrict = val);
                  },
                ),
                const SizedBox(height: 20),
                _buildDropdownField(
                  label: 'Area',
                  value: _selectedArea,
                  items: _areas,
                  hintText: 'Select',
                  onChanged: (val) {
                    setState(() => _selectedArea = val);
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  label: 'Pin code',
                  controller: _pincodeController,
                  hintText: 'Enter pin code',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || int.tryParse(value.trim()) == null) {
                      return 'Enter a valid pin code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                primaryButton(
                  label: widget.isEditMode ? 'Save changes' : 'Continue',
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
