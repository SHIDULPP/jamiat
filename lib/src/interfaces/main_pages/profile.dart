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
    // Figma: white · pad 16 · radius 8 · label 12/#6d6d6d · value 15 SB primary · gap 16
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(kCardRadiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: kCaption12SB.copyWith(color: kMutedText, height: 1.2),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: kBodyTitleSB.copyWith(color: kPrimaryColor, height: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(_ProfileMenuItem item) {
    // Figma menu row: icon 24 · gap 8 · label 12 Regular/#161616 · chevron 24
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticHelper.impact(HapticImpact.light);
          item.onTap();
        },
        child: Padding(
          padding: EdgeInsets.zero,
          child: Row(
            children: [
              Icon(item.icon, color: kPrimaryColor, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.title,
                  style: kCaption12R.copyWith(color: kBodyText, height: 1.2),
                ),
              ),
              Icon(Icons.chevron_right, color: item.chevronColor, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16),
      child: Divider(color: kLineGrey, height: 1, thickness: 1),
    );
  }

  Widget _avatar(UserModel user) {
    final image = user.image;
    if (image != null && image.startsWith('http')) {
      return CircleAvatar(
        radius: 40,
        backgroundColor: kScreenBg,
        backgroundImage: NetworkImage(image),
        onBackgroundImageError: (_, _) {},
      );
    }
    return Container(
      width: 80,
      height: 80,
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
      child: SizedBox(
        width: 21.3,
        height: 21.3,
        child: _isUploadingAvatar
            ? const CircularProgressIndicator(strokeWidth: 2, color: kPrimaryColor)
            : SvgPicture.asset(
                'assets/svg/figma/camera_badge.svg',
                width: 21.3,
                height: 21.3,
              ),
      ),
    );
  }

  Widget _qrSection(UserModel user) {
    final qrBytes = _decodeQrImage(user.qrCode);

    // Figma QR frame: stroke bg · pad 18 · radius 14 · QR 90 · Share 10 Regular
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kStrokeColor,
        borderRadius: BorderRadius.circular(kCardRadiusMd),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 90,
            height: 90,
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
          const SizedBox(height: 10),
          GestureDetector(
            onTap: _isSharingQr ? null : () => _shareProfileQr(user),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Share',
                  style: kCaption10R.copyWith(
                    color: _isSharingQr ? kMutedText : kTextColor,
                    height: 1.2,
                  ),
                ),
                const SizedBox(width: 4),
                if (_isSharingQr)
                  const SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  SvgPicture.asset(
                    'assets/svg/share.svg',
                    width: 13,
                    height: 12,
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
    // Figma 636:3461 — avatar+name left · stats right · gap 32 · radius 14
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kScreenBg,
        borderRadius: BorderRadius.circular(kCardRadiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    _avatar(user),
                    Positioned(
                      right: 0,
                      bottom: 2,
                      child: _cameraButton(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  user.displayName,
                  style: kCaption12SB.copyWith(color: kTextColor, height: 1.2),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: kScreenBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'ID : ${user.displayMemberId}',
                    style: kCaption12R.copyWith(
                      color: kSecondaryTextColor,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          Expanded(
            child: Column(
              children: [
                _buildStatCard(
                  title: 'DONATIONS',
                  value: donations ?? '—',
                ),
                const SizedBox(height: 12),
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
    // Figma 1187:6509 — avatar+meta | QR · then stats row
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kScreenBg,
        borderRadius: BorderRadius.circular(kCardRadiusMd),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _avatar(user),
                        Positioned(
                          right: 0,
                          bottom: 2,
                          child: _cameraButton(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      user.displayName,
                      style: kCaption12SB.copyWith(
                        color: kTextColor,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Jamaith Member',
                          style: kCaption10R.copyWith(
                            color: kTextColor,
                            height: 1.2,
                          ),
                        ),
                        if (user.status == 'active') ...[
                          const SizedBox(width: 4),
                          SvgPicture.asset(
                            'assets/svg/figma/check_circle.svg',
                            width: 12,
                            height: 12,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: kScreenBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'ID : ${user.displayMemberId}',
                        style: kCaption12R.copyWith(
                          color: kSecondaryTextColor,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _qrSection(user),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'DONATIONS',
                  value: donations ?? '—',
                ),
              ),
              const SizedBox(width: 12),
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
          onTap: () => NavigationService().pushNamed('Enquiries'),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kScreenBg,
        borderRadius: BorderRadius.circular(12),
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
                title: 'Logout',
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
              padding: const EdgeInsets.fromLTRB(
                kScreenPaddingH,
                8,
                kScreenPaddingH,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kWhite.withValues(alpha: 0.08),
                          border: Border.all(color: kGrey, width: 1.25),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: kTextColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'My Profile',
                        style: kBodyTitleSB.copyWith(
                          color: kTextColor,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
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
                  const SizedBox(height: 16),
                  if (isJamiatMember) ...[
                    _menuCard(
                      items: menuItems,
                      context: context,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kScreenBg,
                        borderRadius: BorderRadius.circular(kCardRadiusSm),
                      ),
                      child: _buildMenuItem(
                        _ProfileMenuItem(
                          icon: Icons.logout,
                          title: 'Logout',
                          chevronColor: kPrimaryColor,
                          onTap: () => _logout(context),
                        ),
                      ),
                    ),
                  ] else ...[
                    _menuCard(items: menuItems, context: context),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: kScreenBg,
                        borderRadius: BorderRadius.circular(kCardRadiusSm),
                      ),
                      child: _buildMenuItem(
                        _ProfileMenuItem(
                          icon: Icons.logout,
                          title: 'Logout',
                          chevronColor: kPrimaryColor,
                          onTap: () => _logout(context),
                        ),
                      ),
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
