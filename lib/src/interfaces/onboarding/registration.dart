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
import 'package:flutter_countries/flutter_countries.dart' as fc;
import 'package:jamiat/src/data/providers/location_provider.dart';
import 'package:jamiat/src/interfaces/components/loading_indicator.dart';
import 'package:jamiat/src/interfaces/components/modal_sheet.dart';
import 'package:jamiat/src/interfaces/components/primarybutton.dart';
import 'package:jamiat/src/interfaces/onboarding/role_selection.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key, this.isEditMode = false});

  final bool isEditMode;

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  static const double _figmaWidth = 402;
  static const double _fieldHeight = 66;
  static const double _fieldGap = 16;
  static const double _labelGap = 8;
  static const double _avatarSize = 120;
  static const double _cameraBadgeSize = 32;

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _whatsappController;
  late TextEditingController _emailController;
  late TextEditingController _dobController;
  late TextEditingController _addressController;
  late TextEditingController _areaController;
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
  String? _selectedCountryCode;
  String? _selectedCountryName;
  String? _selectedStateCode;
  String? _selectedStateName;
  String? _selectedDistrictCode;
  String? _selectedDistrictName;

  final List<String> _genders = ['Male', 'Female', 'Other'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _whatsappController = TextEditingController();
    _emailController = TextEditingController();
    _dobController = TextEditingController();
    _addressController = TextEditingController();
    _areaController = TextEditingController();
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
      _phoneController.text = _phoneDigits(phone);
    });
  }

  String _phoneDigits(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleaned.length > 10 && cleaned.startsWith('91')) {
      return cleaned.substring(cleaned.length - 10);
    }
    return cleaned;
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

    _nameController.text = user.name ?? '';
    _emailController.text = user.email ?? '';
    _addressController.text = user.address ?? '';
    _areaController.text = user.area ?? '';
    _pincodeController.text = user.pincode?.toString() ?? '';
    _dobController.text = _formatDob(user.dob);
    _imageUrl = user.image;
    _existingRole = user.role;

    final phone = user.phone.isNotEmpty ? user.phone : _verifiedPhone;
    _verifiedPhone = phone;
    _phoneController.text = _phoneDigits(phone);

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
    _selectedCountryName = user.country;
    _selectedStateName = user.state;
    _selectedDistrictName = user.district;

    if (user.role.isNotEmpty) {
      ref.read(selectedRoleProvider.notifier).setRole(user.role);
    }

    _resolveLocationCodesFromNames();
  }

  Future<void> _resolveLocationCodesFromNames() async {
    if ((_selectedCountryName == null || _selectedCountryName!.isEmpty) &&
        _selectedCountryCode == null) {
      return;
    }

    final countries = await fc.Countries.all;
    fc.Country? country;
    for (final item in countries) {
      final matchesCode = item.iso2 == _selectedCountryCode;
      final matchesName =
          item.name?.toLowerCase() == _selectedCountryName?.toLowerCase();
      if (matchesCode || matchesName) {
        country = item;
        break;
      }
    }
    if (country == null || !mounted) return;

    setState(() {
      _selectedCountryCode = country!.iso2;
      _selectedCountryName = country.name;
    });

    if ((_selectedStateName == null || _selectedStateName!.isEmpty) &&
        _selectedStateCode == null) {
      return;
    }

    final states = await fc.States.byCountryCode(country.iso2!);
    fc.State? state;
    for (final item in states) {
      final matchesCode = item.stateCode.toString() == _selectedStateCode;
      final matchesName =
          item.name?.toLowerCase() == _selectedStateName?.toLowerCase();
      if (matchesCode || matchesName) {
        state = item;
        break;
      }
    }
    if (state == null || !mounted) return;

    setState(() {
      _selectedStateCode = state!.stateCode.toString();
      _selectedStateName = state.name;
    });

    if ((_selectedDistrictName == null || _selectedDistrictName!.isEmpty) &&
        _selectedDistrictCode == null) {
      return;
    }

    final cities = await fc.Cities.byStateCode(state.stateCode.toString());
    fc.City? city;
    for (final item in cities) {
      final matchesCode = item.id.toString() == _selectedDistrictCode;
      final matchesName =
          item.name?.toLowerCase() == _selectedDistrictName?.toLowerCase();
      if (matchesCode || matchesName) {
        city = item;
        break;
      }
    }
    if (city == null || !mounted) return;

    setState(() {
      _selectedDistrictCode = city!.id.toString();
      _selectedDistrictName = city.name;
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
    _areaController.dispose();
    _pincodeController.dispose();
    _whatsappFocusNode.dispose();
    super.dispose();
  }

  OutlineInputBorder _fieldBorder({Color? color, double width = 1.0}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(kCardRadiusLg),
      borderSide: BorderSide(color: color ?? kBorder, width: width),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? suffixIcon,
    EdgeInsetsGeometry? contentPadding,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: kWhite,
      hintText: hintText,
      hintStyle: kBodyTitleR.copyWith(color: kSecondaryTextColor),
      contentPadding:
          contentPadding ??
          const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
      constraints: const BoxConstraints(minHeight: _fieldHeight),
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
      padding: const EdgeInsets.only(bottom: _labelGap),
      child: Text(text, style: kLabel15M.copyWith(height: 1.2)),
    );
  }

  Widget _buildIntlPhoneField({
    required TextEditingController controller,
    required String hintText,
    required bool enabled,
    FocusNode? focusNode,
    void Function(String completeNumber)? onChanged,
  }) {
    return IntlPhoneField(
      focusNode: focusNode,
      controller: controller,
      initialCountryCode: 'IN',
      disableLengthCheck: true,
      showCountryFlag: false,
      showDropdownIcon: true,
      enabled: enabled,
      cursorColor: kBlack,
      style: kBodyTitleR.copyWith(
        color: enabled ? kTextColor : kSecondaryTextColor,
      ),
      dropdownTextStyle: kBodyTitleR.copyWith(
        color: enabled ? kTextColor : kSecondaryTextColor,
      ),
      dropdownIcon: const Icon(
        Icons.keyboard_arrow_down,
        color: kSecondaryTextColor,
        size: 20,
      ),
      dropdownIconPosition: IconPosition.trailing,
      flagsButtonPadding: const EdgeInsets.only(left: 18, right: 8),
      decoration: _inputDecoration(hintText: hintText),
      onCountryChanged: (_) {},
      onChanged: (phone) {
        onChanged?.call(phone.completeNumber.replaceAll(' ', ''));
      },
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
        SizedBox(
          height: _fieldHeight,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            enabled: enabled,
            style: kBodyTitleR.copyWith(
              color: enabled ? kTextColor : kSecondaryTextColor,
            ),
            validator: validator,
            decoration: _inputDecoration(hintText: hintText),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectField({
    required String label,
    required String? value,
    required String hintText,
    required VoidCallback? onTap,
    bool isLoading = false,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        GestureDetector(
          onTap: onTap,
          child: SizedBox(
            height: _fieldHeight,
            child: InputDecorator(
              decoration: _inputDecoration(hintText: hintText).copyWith(
                errorText: errorText,
                suffixIcon: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: LoadingAnimation(size: 20),
                      )
                    : const Icon(
                        Icons.keyboard_arrow_down,
                        color: kSecondaryTextColor,
                        size: 20,
                      ),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  value ?? hintText,
                  style: kBodyTitleR.copyWith(
                    color: value == null ? kSecondaryTextColor : kTextColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderField() {
    return _buildSelectField(
      label: 'Gender',
      value: _selectedGender,
      hintText: 'Select',
      onTap: () {
        ModalSheet<String>(
          context: context,
          title: 'Select gender',
          searchHint: 'Search gender',
          items: _genders,
          itemLabel: (value) => value,
          onItemSelected: (value) {
            setState(() => _selectedGender = value);
          },
        ).show();
      },
    );
  }

  Widget _buildCountryField() {
    return Consumer(
      builder: (context, ref, _) {
        final countriesAsync = ref.watch(getAllCountriesProvider);
        return countriesAsync.when(
          data: (countries) {
            final countryMap = {
              for (final country in countries)
                if ((country.iso2 ?? '').isNotEmpty)
                  country.iso2!: country.name ?? '',
            };
            return _buildSelectField(
              label: 'Country',
              value: _selectedCountryName,
              hintText: 'Select',
              onTap: () {
                ModalSheet<String>(
                  context: context,
                  title: 'Select country',
                  searchHint: 'Search country',
                  items: countryMap.keys.toList(),
                  itemLabel: (code) => countryMap[code] ?? code,
                  searchFilter: (code, query) {
                    final name = countryMap[code] ?? '';
                    final q = query.toLowerCase();
                    return name.toLowerCase().contains(q) ||
                        code.toLowerCase().contains(q);
                  },
                  onItemSelected: (code) {
                    setState(() {
                      _selectedCountryCode = code;
                      _selectedCountryName = countryMap[code];
                      _selectedStateCode = null;
                      _selectedStateName = null;
                      _selectedDistrictCode = null;
                      _selectedDistrictName = null;
                    });
                  },
                ).show();
              },
            );
          },
          loading: () => _buildSelectField(
            label: 'Country',
            value: _selectedCountryName,
            hintText: 'Select',
            onTap: null,
            isLoading: true,
          ),
          error: (error, _) => _buildSelectField(
            label: 'Country',
            value: _selectedCountryName,
            hintText: 'Select',
            onTap: null,
            errorText: 'Unable to load countries',
          ),
        );
      },
    );
  }

  Widget _buildStateField() {
    return Consumer(
      builder: (context, ref, _) {
        if (_selectedCountryCode == null) {
          return _buildSelectField(
            label: 'State',
            value: null,
            hintText: 'Select',
            onTap: null,
          );
        }

        final statesAsync = ref.watch(
          getStatesByCountryProvider(_selectedCountryCode!),
        );
        return statesAsync.when(
          data: (states) {
            final stateMap = {
              for (final state in states)
                state.stateCode.toString(): state.name ?? '',
            };
            return _buildSelectField(
              label: 'State',
              value: _selectedStateName,
              hintText: 'Select',
              onTap: () {
                ModalSheet<String>(
                  context: context,
                  title: 'Select state',
                  searchHint: 'Search state',
                  items: stateMap.keys.toList(),
                  itemLabel: (code) => stateMap[code] ?? code,
                  searchFilter: (code, query) {
                    final name = stateMap[code] ?? '';
                    final q = query.toLowerCase();
                    return name.toLowerCase().contains(q) ||
                        code.toLowerCase().contains(q);
                  },
                  onItemSelected: (code) {
                    setState(() {
                      _selectedStateCode = code;
                      _selectedStateName = stateMap[code];
                      _selectedDistrictCode = null;
                      _selectedDistrictName = null;
                    });
                  },
                ).show();
              },
            );
          },
          loading: () => _buildSelectField(
            label: 'State',
            value: _selectedStateName,
            hintText: 'Select',
            onTap: null,
            isLoading: true,
          ),
          error: (error, _) => _buildSelectField(
            label: 'State',
            value: _selectedStateName,
            hintText: 'Select',
            onTap: null,
            errorText: 'Unable to load states',
          ),
        );
      },
    );
  }

  Widget _buildDistrictField() {
    return Consumer(
      builder: (context, ref, _) {
        if (_selectedCountryCode == null || _selectedStateCode == null) {
          return _buildSelectField(
            label: 'District',
            value: null,
            hintText: 'Select',
            onTap: null,
          );
        }

        final districtsAsync = ref.watch(
          getDistrictsByStateProvider((
            countryCode: _selectedCountryCode!,
            stateCode: _selectedStateCode!,
          )),
        );
        return districtsAsync.when(
          data: (districts) {
            final districtMap = {
              for (final district in districts)
                district.id.toString(): district.name ?? '',
            };
            return _buildSelectField(
              label: 'District',
              value: _selectedDistrictName,
              hintText: 'Select',
              onTap: () {
                ModalSheet<String>(
                  context: context,
                  title: 'Select district',
                  searchHint: 'Search district',
                  items: districtMap.keys.toList(),
                  itemLabel: (id) => districtMap[id] ?? id,
                  searchFilter: (id, query) {
                    final name = districtMap[id] ?? '';
                    return name.toLowerCase().contains(query.toLowerCase());
                  },
                  onItemSelected: (id) {
                    setState(() {
                      _selectedDistrictCode = id;
                      _selectedDistrictName = districtMap[id];
                    });
                  },
                ).show();
              },
            );
          },
          loading: () => _buildSelectField(
            label: 'District',
            value: _selectedDistrictName,
            hintText: 'Select',
            onTap: null,
            isLoading: true,
          ),
          error: (error, _) => _buildSelectField(
            label: 'District',
            value: _selectedDistrictName,
            hintText: 'Select',
            onTap: null,
            errorText: 'Unable to load districts',
          ),
        );
      },
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
        SizedBox(
          height: _fieldHeight,
          child: TextFormField(
            controller: controller,
            readOnly: true,
            style: kBodyTitleR.copyWith(color: kTextColor),
            decoration: _inputDecoration(hintText: 'dd/mm/yyyy'),
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
      _selectedCountryName,
      _selectedStateName,
      _selectedDistrictName,
      _areaController.text.trim(),
    ];
    if (requiredSelections.any((value) => value == null || value.isEmpty)) {
      _showMessage('Please complete all required fields.');
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
      'area': _areaController.text.trim(),
      'district': _selectedDistrictName!,
      'state': _selectedStateName!,
      'country': _selectedCountryName!,
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
        radius: _avatarSize / 2,
        backgroundColor: kGreyLight,
        backgroundImage: NetworkImage(image),
        onBackgroundImageError: (_, _) {},
      );
    }
    return Container(
      width: _avatarSize,
      height: _avatarSize,
      decoration: const BoxDecoration(
        color: kGreyLight,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildWhatsAppCheckbox() {
    return GestureDetector(
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
        padding: const EdgeInsets.only(bottom: _labelGap),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: _sameAsPhoneNumber ? kPrimaryColor : kBorder,
                  width: 1.5,
                ),
                color: _sameAsPhoneNumber ? kPrimaryColor : Colors.transparent,
              ),
              child: _sameAsPhoneNumber
                  ? const Icon(Icons.check, size: 16, color: kWhite)
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              'Same as phone number',
              style: kCaption12R.copyWith(color: kTextColor),
            ),
          ],
        ),
      ),
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

    final size = MediaQuery.sizeOf(context);
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final scale = (size.width / _figmaWidth).clamp(0.88, 1.12);
    final topPadding = (64 * scale - topInset).clamp(0.0, 64 * scale);
    final sideInset = 24 * scale;

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            sideInset,
            topPadding,
            sideInset,
            24 * scale + bottomInset,
          ),
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
                SizedBox(height: 32 * scale),
                Text(
                  widget.isEditMode ? 'Edit profile' : 'Profile setup',
                  style: kHeadTitleSB.copyWith(
                    color: kTextColor,
                    fontSize: kSize23,
                    height: 27 / kSize23,
                  ),
                ),
                Text(
                  widget.isEditMode
                      ? 'Update your details and keep your community profile current.'
                      : 'Complete your details to connect with the community and access your services.',
                  style: kCaption13R.copyWith(
                    color: kSecondaryTextColor,
                    height: 32 / kSize13,
                  ),
                ),
                SizedBox(height: 16 * scale),
                Center(
                  child: SizedBox(
                    width: _avatarSize,
                    height: _avatarSize,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _avatarWidget(),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: _isUploadingAvatar
                                ? null
                                : _pickAndUploadAvatar,
                            child: Container(
                              width: _cameraBadgeSize,
                              height: _cameraBadgeSize,
                              decoration: const BoxDecoration(
                                color: kBlack,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: _isUploadingAvatar
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: kWhite,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.camera_alt,
                                        color: kWhite,
                                        size: 16,
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16 * scale),
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
                const SizedBox(height: _fieldGap),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Phone Number'),
                    _buildIntlPhoneField(
                      controller: _phoneController,
                      hintText: '999587XXXX',
                      enabled: false,
                    ),
                  ],
                ),
                const SizedBox(height: _fieldGap),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('WhatsApp Number'),
                    _buildWhatsAppCheckbox(),
                    _buildIntlPhoneField(
                      focusNode: _whatsappFocusNode,
                      controller: _whatsappController,
                      hintText: 'Enter mobile number',
                      enabled: !_sameAsPhoneNumber,
                      onChanged: (value) => _whatsappFullNumber = value,
                    ),
                  ],
                ),
                const SizedBox(height: _fieldGap),
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
                const SizedBox(height: _fieldGap),
                _buildGenderField(),
                const SizedBox(height: _fieldGap),
                _buildDateField(
                  label: 'Date of Birth',
                  controller: _dobController,
                  context: context,
                ),
                const SizedBox(height: _fieldGap),
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
                const SizedBox(height: _fieldGap),
                _buildCountryField(),
                const SizedBox(height: _fieldGap),
                _buildStateField(),
                const SizedBox(height: _fieldGap),
                _buildDistrictField(),
                const SizedBox(height: _fieldGap),
                _buildTextField(
                  label: 'Area',
                  controller: _areaController,
                  hintText: 'Select',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Area is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: _fieldGap),
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
                const SizedBox(height: 24),
                primaryButton(
                  label: widget.isEditMode ? 'Save changes' : 'Continue',
                  onPressed: _isLoading ? null : _handleContinue,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
