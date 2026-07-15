import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/interfaces/components/donation_sheet.dart';

class WelfareDetailsScreen extends StatelessWidget {
  final String serviceKey;

  const WelfareDetailsScreen({super.key, required this.serviceKey});

  // Fetch detailed data map
  Map<String, dynamic> _getServiceData() {
    switch (serviceKey) {
      case 'maktab':
        return {
          'title': 'Maktab',
          'image': 'assets/jpgs/campaign_education.jpg',
          'description':
              'Providing foundational Islamic and moral education to millions of children through a statewide network of local Maktabs.',
          'blocks': [
            {
              'title': 'Goal',
              'content':
                  'To establish a Maktab in every locality to teach reading of the Quran, Islamic basics, and moral values to children.',
            },
            {
              'title': 'Vision',
              'content':
                  'Eliminating religious ignorance among children and raising a morally upright generation.',
            },
          ],
          'stats': [
            {'label': 'Active Maktabs', 'val': '12,000+'},
            {'label': 'Students enrolled', 'val': '15 Lakh+'},
            {'label': 'Teachers active', 'val': '24,000+'},
          ],
          'campaignTitle': 'Maktab support fund 2026',
          'icon': Icons.menu_book,
          'iconBgColor': const Color(0xFFFFFBEB),
          'iconColor': const Color(0xFFD97706),
        };

      case 'ulama':
        return {
          'title': 'Ulama',
          'image': 'assets/jpgs/campaign_education.jpg',
          'description':
              'Empowering young Islamic scholars with modern, social, and economic skills to uplift and serve the community.',
          'blocks': [
            {
              'title': 'Vision',
              'content':
                  'Jamiat Launched countrywide programs with a vision to employ 50 thousands trained young ulama to work in their respective areas.',
            },
          ],
          'stats': [
            {'label': 'Workshops', 'val': '589'},
            {'label': 'Ulama Trained', 'val': '20,000+'},
          ],
          'targetText': 'To train 35,000+ Ulama',
          'campaignTitle': 'Ulama support fund 2026',
          'icon': Icons.people,
          'iconBgColor': const Color(0xFFFFF1F2),
          'iconColor': const Color(0xFFE11D48),
        };

      case 'youth_club':
        return {
          'title': 'Youth Club',
          'image': 'assets/jpgs/campaign_welfare.jpg',
          'description':
              'Inculcating humanitarian spirit and leadership skills in youth under the world-renowned "Bharat Scouts & Guides" umbrella.\n\nWorks under the umbrella of the world renowned autonomous body "Bharat Scouts & Guides"',
          'blocks': [
            {
              'title': 'Mission',
              'content':
                  'To inculcate the true humanitarian spirit and positive change amongst the youth of the country.',
            },
            {
              'title': 'Motto',
              'content': 'To Nurture the Youth for the service of Mankind',
            },
          ],
          'stats': [
            {'label': 'Branches in', 'val': '37\ndistricts\n12\nstates'},
            {'label': 'First Stage', 'val': '755\ncampus\n29,514\nTrained'},
            {'label': 'Advances Stage', 'val': '195\ncampus\n3,565\ntrained'},
          ],
          'targetText': 'To train 52000+ youth',
          'campaignTitle': 'Youth Club support fund 2026',
          'icon': Icons.explore,
          'iconBgColor': const Color(0xFFF0FDF4),
          'iconColor': const Color(0xFF16A34A),
        };

      case 'study_center':
        return {
          'title': 'Study Center',
          'image': 'assets/jpgs/campaign_education.jpg',
          'description':
              'Providing secondary education coaching and NIOS certifications to modernize learning for madrasa students.',
          'blocks': [
            {
              'title': 'Objective',
              'content':
                  'To modernize Islamic scholars, addressing current challenges, and preparing them to serve as effective religious leaders in today\'s evolving societal landscape.',
            },
            {
              'title': 'Goal',
              'content':
                  'To fulfill the most essential needs of society by preparing trained professionals in the following fields: Law, Social Services, Education (Teaching), Mass Communication, Institutional Management.',
            },
          ],
          'stats': [
            {'label': 'Under Study', 'val': '11,000+'},
            {'label': 'Cleared Exams', 'val': '7,500+'},
            {'label': 'As. Madrasas', 'val': '482'},
            {'label': 'Trained Teachers', 'val': '490'},
            {'label': 'Projectors Installed', 'val': '230'},
          ],
          'targetText': 'To train 50,000 students',
          'campaignTitle': 'Maktab support fund 2026',
          'icon': Icons.computer,
          'iconBgColor': const Color(0xFFFDF4FF),
          'iconColor': const Color(0xFFD946EF),
        };

      case 'model_village':
        return {
          'title': 'Model Village',
          'image': 'assets/jpgs/campaign_housing.jpg',
          'description':
              'Developing sustainable model villages and emergency housing infrastructure for rehabilitation and community growth.',
          'blocks': [
            {
              'title': 'Mission',
              'content':
                  'To catalyse the transformation of numerous villages across India into self-sufficient and self-reliant villages.',
            },
            {
              'title': 'Spectrum',
              'content':
                  '• Support in implementing government schemes and development projects.\n• Execution of projects and initiatives launched by JUH.\n• Support for documentation.',
            },
          ],
          'stats': [
            {'label': 'Active Village\nChampions', 'val': '350+'},
            {'label': 'Villages', 'val': '100'},
            {'label': 'Beneficiaries', 'val': '100,000+'},
          ],
          'targetText': '1,000 Villages | 11 Lakh Beneficiaries',
          'campaignTitle': 'Donate for Model village',
          'icon': Icons.home,
          'iconBgColor': const Color(0xFFEFF6FF),
          'iconColor': const Color(0xFF2563EB),
        };

      case 'jem':
      default:
        return {
          'title': 'JEM',
          'image': 'assets/jpgs/campaign_welfare.jpg',
          'description':
              'Justice and Empowerment of Minorities (JEM). Safeguarding human rights and protecting constitutional liberties by documenting hate crimes and providing essential legal aid.',
          'blocks': [
            {
              'title': 'Goal',
              'content':
                  'Envisioned to uphold, protect and enforce the human rights of Minorities in India for a just society. Safeguarding Human Rights.',
            },
            {'title': 'Vision', 'content': 'Safeguarding Human Rights'},
            {'title': 'Mission', 'content': 'To promote the rule of Law.'},
            {
              'title': 'Activities',
              'content':
                  'As a forum to collate, research and document the increasing cases of \'Hate Crimes\' occurring on a daily basis in the country.',
            },
          ],
          'stats': [
            {'label': 'Letters sent\nauthorities', 'val': '350+'},
            {'label': 'Trainees', 'val': '862'},
            {'label': 'Workshops', 'val': '15'},
          ],
          'campaignTitle': 'Donate for JEM',
          'icon': Icons.gavel,
          'iconBgColor': const Color(0xFFF5EBE6),
          'iconColor': const Color(0xFF9A3412),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _getServiceData();
    final blocks = data['blocks'] as List<Map<String, String>>;
    final stats = data['stats'] as List<Map<String, String>>;
    final hasTarget = data['targetText'] != null;

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticHelper.impact(HapticImpact.light);
                      Navigator.pop(context);
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
                    data['title'] as String,
                    style: kHeadTitleB.copyWith(
                      color: kTextColor,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        data['image'] as String,
                        height: 190,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 190,
                            color: kScreenBg,
                            child: const Icon(
                              Icons.image_outlined,
                              color: kMutedText,
                              size: 40,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Short Description
                    Text(
                      data['description'] as String,
                      style: kBodyTitleB.copyWith(
                        color: kTextColor,
                        fontSize: 14.5,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Objectives / Mission blocks
                    ...blocks.map((block) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              block['title']!,
                              style: kSectionTitleSB.copyWith(
                                color: kTextColor,
                                fontSize: 16,
                                fontWeight: kBold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              block['content']!,
                              style: kCaption12R.copyWith(
                                color: kSecondaryTextColor,
                                height: 1.45,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    // Journey so far header
                    Text(
                      'Journey so far',
                      style: kSectionTitleSB.copyWith(
                        color: kTextColor,
                        fontSize: 16,
                        fontWeight: kBold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Stats Grid using LayoutBuilder + Wrap for pixel-perfect card scaling
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cardWidth = (constraints.maxWidth - 24) / 3;

                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: stats.map((stat) {
                            return Container(
                              width: cardWidth,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB), // Soft cream
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFFEF3C7),
                                  width: 1.25,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    stat['label']!,
                                    style: kCaption12M.copyWith(
                                      color: const Color(0xFF92400E),
                                      fontSize: 11.5,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    stat['val']!,
                                    style: kHeadTitleB.copyWith(
                                      color: const Color(0xFFD97706),
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Blue target box (if present)
                    if (hasTarget) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF), // Soft light blue
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.track_changes,
                              color: Color(0xFF2563EB),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Target for 3 Years',
                                    style: kBodyTitleB.copyWith(
                                      color: const Color(0xFF1E3A8A),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    data['targetText'] as String,
                                    style: kCaption12R.copyWith(
                                      color: const Color(0xFF2563EB),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Donate Section
                    Text(
                      'Donate for ${data['title']}',
                      style: kSectionTitleSB.copyWith(
                        color: kTextColor,
                        fontSize: 16,
                        fontWeight: kBold,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Active Campaign donation card
                    Container(
                      margin: const EdgeInsets.only(bottom: 32),
                      decoration: BoxDecoration(
                        color: kWhite,
                        borderRadius: BorderRadius.circular(kCardRadiusLg),
                        border: Border.all(color: kBorder),
                        boxShadow: [
                          BoxShadow(
                            color: kBlack.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Campaign cover image
                          SizedBox(
                            height: 160,
                            width: double.infinity,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  'assets/jpgs/campaign_education.jpg',
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: kBlack.withValues(alpha: 0.45),
                                      borderRadius: BorderRadius.circular(
                                        kPillRadius,
                                      ),
                                    ),
                                    child: Text(
                                      'Education',
                                      style: kCaption10M.copyWith(
                                        color: kWhite,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: kBlack.withValues(alpha: 0.4),
                                        ),
                                        child: const Icon(
                                          Icons.share_outlined,
                                          color: kWhite,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: kBlack.withValues(alpha: 0.4),
                                        ),
                                        child: const Icon(
                                          Icons.bookmark_border,
                                          color: kWhite,
                                          size: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Text & Progress details
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['campaignTitle'] as String,
                                  style: kBodyTitleB.copyWith(
                                    fontSize: 16,
                                    color: kTextColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Providing resources and infrastructure for Islamic education centers in rural areas',
                                  style: kCaption12R.copyWith(
                                    color: kSecondaryTextColor,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Progress bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: const LinearProgressIndicator(
                                    value: 0.68,
                                    minHeight: 5,
                                    backgroundColor: kBorder,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      kSecondaryColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Goal/Raised Info row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '₹ 68,000',
                                          style: kBodyTitleB.copyWith(
                                            color: kTextColor,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'of ₹ 1,000,000',
                                          style: kCaption12R.copyWith(
                                            color: kMutedText,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '68%',
                                          style: kBodyTitleB.copyWith(
                                            color: kSecondaryColor,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '2 days left',
                                          style: kCaption12R.copyWith(
                                            color: const Color(0xFFEF4444),
                                            fontSize: 11,
                                            fontWeight: kBold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Donate Now Action button
                                SizedBox(
                                  width: double.infinity,
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      HapticHelper.impact(HapticImpact.light);
                                      DonationSheet.show(
                                        context: context,
                                        categoryTitle:
                                            data['campaignTitle'] as String,
                                        icon: data['icon'] as IconData,
                                        iconBgColor:
                                            data['iconBgColor'] as Color,
                                        iconColor: data['iconColor'] as Color,
                                        isAutopay: false,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: kPrimaryColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Donate Now',
                                      style: kButtonLabelSB.copyWith(
                                        color: kWhite,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
