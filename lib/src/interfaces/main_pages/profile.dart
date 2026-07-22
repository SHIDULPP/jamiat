import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jamiat/src/data/apis/auth_api.dart';
import 'package:jamiat/src/data/apis/upload_api.dart';
import 'package:jamiat/src/data/apis/user_api.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/models/user_model.dart';
import 'package:jamiat/src/data/providers/donation_provider.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';
import 'package:jamiat/src/data/services/profile_qr_share_service.dart';
import 'package:jamiat/src/data/services/secure_storage_service.dart';
import 'package:jamiat/src/data/utils/format_helpers.dart';
import 'package:jamiat/src/interfaces/components/async_content.dart';
import 'package:qr_flutter/qr_flutter.dart';

class _ProfileMenuItem {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.chevronColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color chevronColor;
  final VoidCallback onTap;
}

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isUploadingAvatar = false;
  bool _isSharingQr = false;
  final ProfileQrShareService _qrShareService = const ProfileQrShareService();

  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
          'You will need to verify your phone to sign in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    await ref.read(authApiProvider).logout();
    await ref.read(secureStorageServiceProvider).clearSession();
    NavigationService().pushNamedAndRemoveUntil('Login');
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

      final update = await ref.read(userApiProvider).updateProfile({
        'image': upload.data,
      });
      if (!mounted) return;
      if (!update.success) {
        _showMessage(update.message ?? 'Unable to update avatar.');
        return;
      }

      ref.invalidate(userProfileProvider);
      _showMessage('Avatar updated.');
    } catch (e) {
      if (mounted) {
        _showMessage(e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _shareProfileQr(UserModel user) async {
    if (_isSharingQr) return;
    HapticHelper.impact(HapticImpact.light);
    setState(() => _isSharingQr = true);

    try {
      final result = await _qrShareService.shareProfileQr(
        context: context,
        user: user,
      );
      if (!mounted) return;

      if (result.status == ProfileQrShareStatus.cancelled) return;
      if (!result.isSuccess) {
        _showMessage(result.message ?? 'Failed to share QR code');
      }
    } finally {
      if (mounted) setState(() => _isSharingQr = false);
    }
  }

  Uint8List? _decodeQrImage(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final payload = raw.contains(',') ? raw.split(',').last : raw;
      return base64Decode(payload);
    } catch (_) {
      return null;
    }
  }

  Widget _buildStatCard({required String title, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(kCardRadiusMd),
        border: Border.all(color: kBorder.withValues(alpha: 0.5), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: kCaption10SB.copyWith(
              color: kSecondaryTextColor,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: kHeadTitleB.copyWith(color: kPrimaryColor, fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(_ProfileMenuItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticHelper.impact(HapticImpact.light);
          item.onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Icon(item.icon, color: kPrimaryColor, size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item.title,
                  style: kBodyTitleM.copyWith(
                    color: kTextColor,
                    fontWeight: kMedium,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: item.chevronColor, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: kWhite,
      height: 1,
      thickness: 1.5,
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _avatar(UserModel user) {
    final image = user.image;
    if (image != null && image.startsWith('http')) {
      return CircleAvatar(
        radius: 45,
        backgroundColor: kScreenBg,
        backgroundImage: NetworkImage(image),
        onBackgroundImageError: (_, _) {},
      );
    }
    return Container(
      width: 90,
      height: 90,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: AssetImage('assets/pngs/profile_avatar.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _cameraButton() {
    return GestureDetector(
      onTap: _isUploadingAvatar
          ? null
          : () {
              HapticHelper.impact(HapticImpact.light);
              _pickAndUploadAvatar();
            },
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: kTextColor,
          shape: BoxShape.circle,
        ),
        child: _isUploadingAvatar
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: kWhite,
                ),
              )
            : const Icon(Icons.camera_alt, color: kWhite, size: 14),
      ),
    );
  }

  Widget _qrSection(UserModel user) {
    final qrBytes = _decodeQrImage(user.qrCode);

    return Container(
      width: 112,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: qrBytes != null
                ? Image.memory(qrBytes, fit: BoxFit.contain)
                : QrImageView(
                    data: user.id,
                    backgroundColor: kWhite,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: kTextColor,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: kTextColor,
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _isSharingQr
                ? null
                : () => _shareProfileQr(user),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Share',
                  style: kCaption12M.copyWith(
                    color: _isSharingQr ? kMutedText : kTextColor,
                  ),
                ),
                const SizedBox(width: 6),
                if (_isSharingQr)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  SvgPicture.asset(
                    'assets/svg/share.svg',
                    width: 14,
                    height: 14,
                    colorFilter: const ColorFilter.mode(
                      kTextColor,
                      BlendMode.srcIn,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _normalMemberHeader({
    required UserModel user,
    required String? donations,
    required String? totalDonated,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kScreenBg,
        borderRadius: BorderRadius.circular(kCardRadiusLg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    _avatar(user),
                    Positioned(bottom: 0, right: 0, child: _cameraButton()),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  user.displayName,
                  style: kBodyTitleB.copyWith(
                    color: kTextColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID : ${user.displayMemberId}',
                  style: kCaption12R.copyWith(color: kSecondaryTextColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Column(
              children: [
                _buildStatCard(
                  title: 'DONATIONS',
                  value: donations ?? '—',
                ),
                const SizedBox(height: 10),
                _buildStatCard(
                  title: 'TOTAL DONATED',
                  value: totalDonated ?? '—',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _jamiatMemberHeader({
    required UserModel user,
    required String? donations,
    required String? totalDonated,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kScreenBg,
        borderRadius: BorderRadius.circular(kCardRadiusLg),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        _avatar(user),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: _cameraButton(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.displayName,
                      style: kBodyTitleB.copyWith(
                        color: kTextColor,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Jamaith Member',
                          style: kCaption12R.copyWith(
                            color: kSecondaryTextColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (user.status == 'active')
                          const Icon(
                            Icons.verified,
                            color: kSecondaryColor,
                            size: 14,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ID : ${user.displayMemberId}',
                      style: kCaption12R.copyWith(color: kSecondaryTextColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _qrSection(user),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'DONATIONS',
                  value: donations ?? '—',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  title: 'TOTAL DONATED',
                  value: totalDonated ?? '—',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<_ProfileMenuItem> _menuItems({
    required bool isJamiatMember,
    required BuildContext context,
  }) {
    const mutedChevron = kSecondaryTextColor;
    const accentChevron = kPrimaryColor;

    return [
      _ProfileMenuItem(
        icon: Icons.volunteer_activism_outlined,
        title: 'Donation history',
        chevronColor: mutedChevron,
        onTap: () => NavigationService().pushNamed('DonationHistory'),
      ),
      if (isJamiatMember) ...[
        _ProfileMenuItem(
          icon: Icons.local_activity_outlined,
          title: 'Events',
          chevronColor: mutedChevron,
          onTap: () => NavigationService().pushNamed('Events'),
        ),
        _ProfileMenuItem(
          icon: Icons.inventory_2_outlined,
          title: 'Saved products',
          chevronColor: mutedChevron,
          onTap: () => NavigationService().pushNamed('SavedProducts'),
        ),
        _ProfileMenuItem(
          icon: Icons.chat_bubble_outline,
          title: 'Enquiries',
          chevronColor: mutedChevron,
          onTap: () => _showMessage('Enquiries coming soon'),
        ),
      ],
      _ProfileMenuItem(
        icon: Icons.autorenew_outlined,
        title: 'Autopay',
        chevronColor: mutedChevron,
        onTap: () => NavigationService().pushNamed('AutopayView'),
      ),
      _ProfileMenuItem(
        icon: Icons.person_outline,
        title: 'Edit Profile',
        chevronColor: mutedChevron,
        onTap: () => NavigationService().pushNamed(
          'Registration',
          arguments: {'editMode': true},
        ),
      ),
      _ProfileMenuItem(
        icon: Icons.headset_mic_outlined,
        title: 'Help & Support',
        chevronColor: accentChevron,
        onTap: () {},
      ),
      _ProfileMenuItem(
        icon: Icons.article_outlined,
        title: 'Terms and Conditions',
        chevronColor: accentChevron,
        onTap: () {},
      ),
      _ProfileMenuItem(
        icon: Icons.shield_outlined,
        title: 'Privacy Policy',
        chevronColor: accentChevron,
        onTap: () {},
      ),
    ];
  }

  Widget _menuCard({
    required List<_ProfileMenuItem> items,
    bool includeLogout = false,
    required BuildContext context,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kScreenBg,
        borderRadius: BorderRadius.circular(kCardRadiusLg),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) _buildDivider(),
            _buildMenuItem(items[i]),
          ],
          if (includeLogout) ...[
            _buildDivider(),
            _buildMenuItem(
              _ProfileMenuItem(
                icon: Icons.logout,
                title: 'Log out',
                chevronColor: kPrimaryColor,
                onTap: () => _logout(context),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final historyAsync = ref.watch(donationHistoryProvider);

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: AsyncContent(
          asyncValue: profileAsync,
          onRetry: () {
            ref.invalidate(userProfileProvider);
            ref.invalidate(donationHistoryProvider);
          },
          builder: (user) {
            final isJamiatMember = user.isJamiatMember;
            final donations = historyAsync.maybeWhen(
              data: (history) => history.summary.totalPayments.toString(),
              orElse: () => null,
            );
            final totalDonated = historyAsync.maybeWhen(
              data: (history) => formatRupeeCompact(history.summary.totalDonated),
              orElse: () => null,
            );
            final menuItems = _menuItems(
              isJamiatMember: isJamiatMember,
              context: context,
            );

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24,
                16,
                24,
                isJamiatMember ? 16 : 110,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                      const SizedBox(width: 16),
                      Text(
                        'My Profile',
                        style: kHeadTitleB.copyWith(
                          color: kTextColor,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (isJamiatMember)
                    _jamiatMemberHeader(
                      user: user,
                      donations: donations,
                      totalDonated: totalDonated,
                    )
                  else
                    _normalMemberHeader(
                      user: user,
                      donations: donations,
                      totalDonated: totalDonated,
                    ),
                  const SizedBox(height: 24),
                  if (isJamiatMember)
                    _menuCard(
                      items: menuItems,
                      includeLogout: true,
                      context: context,
                    )
                  else ...[
                    _menuCard(items: menuItems, context: context),
                    const SizedBox(height: 24),
                    _menuCard(
                      items: [
                        _ProfileMenuItem(
                          icon: Icons.logout,
                          title: 'Log out',
                          chevronColor: kPrimaryColor,
                          onTap: () => _logout(context),
                        ),
                      ],
                      context: context,
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
