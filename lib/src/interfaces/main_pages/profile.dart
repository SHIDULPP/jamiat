import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:jamiat/src/data/services/secure_storage_service.dart';
import 'package:jamiat/src/data/utils/format_helpers.dart';
import 'package:jamiat/src/interfaces/components/async_content.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isUploadingAvatar = false;

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Widget _buildStatCard({required String title, required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required Color chevronColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticHelper.impact(HapticImpact.light);
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              Icon(icon, color: kPrimaryColor, size: 20),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: kBodyTitleM.copyWith(
                    color: kTextColor,
                    fontWeight: kMedium,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: chevronColor, size: 22),
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

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final historyAsync = ref.watch(donationHistoryProvider);

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: AsyncContent(
          asyncValue: profileAsync,
          onRetry: () => ref.invalidate(userProfileProvider),
          builder: (user) {
            final isJamiatMember = user.role == 'jamiat_member';
            final donationCount =
                historyAsync.value?.summary.participatedCampaigns;
            final totalDonated = historyAsync.value?.summary.totalDonated;

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
                  Container(
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
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: _isUploadingAvatar
                                          ? null
                                          : () {
                                              HapticHelper.impact(
                                                HapticImpact.light,
                                              );
                                              _pickAndUploadAvatar();
                                            },
                                      child: Container(
                                        width: 32,
                                        height: 32,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: isJamiatMember
                                              ? kWhite
                                              : kTextColor,
                                          shape: BoxShape.circle,
                                          boxShadow: isJamiatMember
                                              ? const [
                                                  BoxShadow(
                                                    color: Colors.black12,
                                                    blurRadius: 4,
                                                    offset: Offset(0, 2),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: _isUploadingAvatar
                                            ? SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: isJamiatMember
                                                          ? kTextColor
                                                          : kWhite,
                                                    ),
                                              )
                                            : Icon(
                                                Icons.camera_alt,
                                                color: isJamiatMember
                                                    ? kTextColor
                                                    : kWhite,
                                                size: 14,
                                              ),
                                      ),
                                    ),
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
                              if (isJamiatMember) ...[
                                Row(
                                  children: [
                                    Text(
                                      user.role == 'normal_member'
                                          ? 'Jamiat Member'
                                          : user.role,
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
                                  user.phone.isNotEmpty
                                      ? user.phone
                                      : 'ID : ${user.id}',
                                  style: kCaption12R.copyWith(
                                    color: kSecondaryTextColor,
                                  ),
                                ),
                              ] else ...[
                                Text(
                                  'ID : ${user.id}',
                                  style: kCaption12R.copyWith(
                                    color: kSecondaryTextColor,
                                  ),
                                ),
                              ],
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
                                value: '${donationCount ?? '—'}',
                              ),
                              const SizedBox(height: 10),
                              _buildStatCard(
                                title: 'TOTAL DONATED',
                                value: totalDonated != null
                                    ? formatRupeeCompact(totalDonated)
                                    : '—',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (isJamiatMember)
                    Container(
                      decoration: BoxDecoration(
                        color: kScreenBg,
                        borderRadius: BorderRadius.circular(kCardRadiusLg),
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.volunteer_activism_outlined,
                            title: 'Donation history',
                            chevronColor: kSecondaryTextColor,
                            onTap: () => NavigationService().pushNamed(
                              'DonationHistory',
                            ),
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.local_activity_outlined,
                            title: 'Events',
                            chevronColor: kSecondaryTextColor,
                            onTap: () =>
                                NavigationService().pushNamed('Events'),
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.inventory_2_outlined,
                            title: 'Saved campaigns',
                            chevronColor: kSecondaryTextColor,
                            onTap: () =>
                                NavigationService().pushNamed('SavedDonations'),
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.autorenew_outlined,
                            title: 'Autopay',
                            chevronColor: kSecondaryTextColor,
                            onTap: () =>
                                NavigationService().pushNamed('AutopayView'),
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.person_outline,
                            title: 'Edit Profile',
                            chevronColor: kSecondaryTextColor,
                            onTap: () => NavigationService().pushNamed(
                              'Registration',
                              arguments: {'editMode': true},
                            ),
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.headset_mic_outlined,
                            title: 'Help & Support',
                            chevronColor: kPrimaryColor,
                            onTap: () {},
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.article_outlined,
                            title: 'Terms and Conditions',
                            chevronColor: kPrimaryColor,
                            onTap: () {},
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.shield_outlined,
                            title: 'Privacy Policy',
                            chevronColor: kPrimaryColor,
                            onTap: () {},
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.logout,
                            title: 'Log out',
                            chevronColor: kRed,
                            onTap: () => _logout(context),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    Container(
                      decoration: BoxDecoration(
                        color: kScreenBg,
                        borderRadius: BorderRadius.circular(kCardRadiusLg),
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.volunteer_activism_outlined,
                            title: 'Donation history',
                            chevronColor: kSecondaryTextColor,
                            onTap: () => NavigationService().pushNamed(
                              'DonationHistory',
                            ),
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.autorenew_outlined,
                            title: 'Autopay',
                            chevronColor: kSecondaryTextColor,
                            onTap: () =>
                                NavigationService().pushNamed('AutopayView'),
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.person_outline,
                            title: 'Edit Profile',
                            chevronColor: kSecondaryTextColor,
                            onTap: () => NavigationService().pushNamed(
                              'Registration',
                              arguments: {'editMode': true},
                            ),
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.headset_mic_outlined,
                            title: 'Help & Support',
                            chevronColor: kPrimaryColor,
                            onTap: () {},
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.article_outlined,
                            title: 'Terms and Conditions',
                            chevronColor: kPrimaryColor,
                            onTap: () {},
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            icon: Icons.shield_outlined,
                            title: 'Privacy Policy',
                            chevronColor: kPrimaryColor,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: kScreenBg,
                        borderRadius: BorderRadius.circular(kCardRadiusLg),
                      ),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.logout,
                            title: 'Log out',
                            chevronColor: kRed,
                            onTap: () => _logout(context),
                          ),
                        ],
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
