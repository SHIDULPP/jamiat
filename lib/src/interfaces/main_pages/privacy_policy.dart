import 'package:flutter/material.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _email = 'jamiatconnect@gmail.com';
  static const _website = 'https://jamiatconnect.juhkerala.com';

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
                    child: Text('Privacy Policy', style: kSectionTitleSB),
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
                      'Privacy Policy for Jamiat Welfare Trust',
                      style: kBodyTitleSB,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Last updated: September 15, 2026',
                      style: kCaption12R.copyWith(color: kMutedText),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'This Privacy Policy describes Our policies and '
                      'procedures on the collection, use and disclosure of '
                      'Your information when You use the Service and tells '
                      'You about Your privacy rights and how the law '
                      'protects You.',
                      style: bodyStyle,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'We use Your Personal Data to provide and improve the '
                      'Service. We collect, use, and disclose Your '
                      'information as described in this Privacy Policy and, '
                      'where required by applicable law, only where We have '
                      'a valid legal basis to do so, including Your consent '
                      '(where consent is required). This Privacy Policy has '
                      'been created with the help of the Privacy Policy '
                      'Generator.',
                      style: bodyStyle,
                    ),
                    const SizedBox(height: 24),
                    _Section(
                      title: 'Interpretation and Definitions',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Interpretation', style: kBodyTitleM),
                          const SizedBox(height: 8),
                          Text(
                            'The words whose initial letters are capitalized '
                            'have meanings defined under the following '
                            'conditions. The following definitions shall '
                            'have the same meaning regardless of whether '
                            'they appear in singular or in plural.',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 16),
                          Text('Definitions', style: kBodyTitleM),
                          const SizedBox(height: 8),
                          Text(
                            'For the purposes of this Privacy Policy:',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 10),
                          _Definition(
                            term: 'Account',
                            text:
                                'means a unique account created for You to '
                                'access Our Service or parts of Our Service.',
                            style: bodyStyle,
                          ),
                          _Definition(
                            term: 'Affiliate',
                            text:
                                'means an entity that controls, is controlled '
                                'by, or is under common control with a party, '
                                'where "control" means ownership of 50% or '
                                'more of the shares, equity interest or other '
                                'securities entitled to vote for election of '
                                'directors or other managing authority.',
                            style: bodyStyle,
                          ),
                          _Definition(
                            term: 'Company',
                            text:
                                '(referred to as either "the Company", "We", '
                                '"Us" or "Our" in this Privacy Policy) refers '
                                'to Jamiat Welfare Trust, JAMIAT WELFARE '
                                'TRUST 16/701 A, EDATHALA NORTH, ALUVA '
                                'ERNAKULAM, KERALA - 683 564.',
                            style: bodyStyle,
                          ),
                          _Definition(
                            term: 'Cookies',
                            text:
                                'are small files that are placed on Your '
                                'computer, mobile device or any other device '
                                'by a website, containing the details of Your '
                                'browsing history on that website, among its '
                                'many uses.',
                            style: bodyStyle,
                          ),
                          _Definition(
                            term: 'Country/State',
                            text: 'refers to: Kerala, India.',
                            style: bodyStyle,
                          ),
                          _Definition(
                            term: 'Device',
                            text:
                                'means any device that can access the '
                                'Service, such as a computer, a cell phone or '
                                'a digital tablet.',
                            style: bodyStyle,
                          ),
                          _Definition(
                            term: 'Personal Data',
                            text:
                                '(or "Personal Information") is any '
                                'information that relates to an identified or '
                                'identifiable individual.\n\nWe use "Personal '
                                'Data" and "Personal Information" '
                                'interchangeably unless a law uses a specific '
                                'term.',
                            style: bodyStyle,
                          ),
                          _Definition(
                            term: 'Service',
                            text: 'refers to the Website.',
                            style: bodyStyle,
                          ),
                          _Definition(
                            term: 'Service Provider',
                            text:
                                'means any natural or legal person who '
                                'processes the data on behalf of the Company. '
                                'It refers to third-party companies or '
                                'individuals employed by the Company to '
                                'facilitate the Service, to provide the '
                                'Service on behalf of the Company, to perform '
                                'services related to the Service or to assist '
                                'the Company in analyzing how the Service is '
                                'used.',
                            style: bodyStyle,
                          ),
                          _Definition(
                            term: 'Usage Data',
                            text:
                                'refers to data collected automatically, '
                                'either generated by the use of the Service '
                                'or from the Service infrastructure itself '
                                '(for example, the duration of a page visit).',
                            style: bodyStyle,
                          ),
                          _Definition(
                            term: 'User',
                            text:
                                'means any individual who accesses or uses '
                                'the Service.',
                            style: bodyStyle,
                          ),
                          _Definition(
                            term: 'Website',
                            text:
                                'refers to Jamiat Welfare Trust, accessible '
                                'from $_website.',
                            style: bodyStyle,
                          ),
                          _Definition(
                            term: 'You',
                            text:
                                'means the individual accessing or using the '
                                'Service, or the company, or other legal '
                                'entity on behalf of which such individual is '
                                'accessing or using the Service, as '
                                'applicable.',
                            style: bodyStyle,
                          ),
                        ],
                      ),
                    ),
                    _Section(
                      title: 'Collecting and Using Your Personal Information',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Types of Data Collected', style: kBodyTitleM),
                          const SizedBox(height: 12),
                          Text('Personal Data', style: kBodyTitleM),
                          const SizedBox(height: 8),
                          Text(
                            'While using Our Service, We may ask You to '
                            'provide Us with certain personally identifiable '
                            'information that can be used to contact or '
                            'identify You. Personally identifiable '
                            'information may include, but is not limited to:',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 10),
                          _Bullet(
                            'First name and last name',
                            style: bulletStyle,
                          ),
                          _Bullet('Phone number', style: bulletStyle),
                          _Bullet('Usage Data', style: bulletStyle),
                          const SizedBox(height: 16),
                          Text('Usage Data', style: kBodyTitleM),
                          const SizedBox(height: 8),
                          Text(
                            'Usage Data is collected automatically when '
                            'using the Service.',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Usage Data may include information such as Your '
                            "Device's Internet Protocol address (e.g. IP "
                            'address), browser type, browser version, the '
                            'pages of Our Service that You visit, the time '
                            'and date of Your visit, the time spent on those '
                            'pages, unique device identifiers and other '
                            'diagnostic data.',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'When You access the Service by or through a '
                            'mobile device, We may collect certain '
                            'information automatically, including, but not '
                            'limited to, the type of mobile device You use, '
                            'Your mobile device\'s unique ID, the IP address '
                            'of Your mobile device, Your mobile operating '
                            'system, the type of mobile Internet browser You '
                            'use, unique device identifiers and other '
                            'diagnostic data.',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'We may also collect information that Your '
                            'browser sends whenever You visit Our Service or '
                            'when You access the Service by or through a '
                            'mobile device.',
                            style: bodyStyle,
                          ),
                        ],
                      ),
                    ),
                    _Section(
                      title: 'Tracking Technologies and Cookies',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'We use tracking technologies (such as cookies) '
                            'to track the activity and to improve Our '
                            'Service. The technologies We use may include:',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 10),
                          _Bullet(
                            'Cookies or Browser Cookies. A cookie is a '
                            'small file placed on Your Device. You can '
                            'instruct Your browser to refuse all Cookies or '
                            'to indicate when a Cookie is being sent. '
                            'However, if You do not accept Cookies, You may '
                            'not be able to use some parts of Our Service.',
                            style: bulletStyle,
                          ),
                          _Bullet(
                            'Web Beacons. Certain sections of Our Service '
                            'may contain small electronic files known as '
                            'web beacons (also referred to as clear gifs, '
                            'pixel tags, and single-pixel gifs) that permit '
                            'the Company, for example, to count users who '
                            'have visited those pages and for other related '
                            'website statistics (for example, recording the '
                            'popularity of a certain section and verifying '
                            'system and server integrity).',
                            style: bulletStyle,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Cookies can be "Persistent" or "Session" '
                            'Cookies. Persistent Cookies remain on Your '
                            'personal computer or mobile device when You go '
                            'offline, while Session Cookies are deleted as '
                            'soon as You close Your web browser.',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Where required by law, We use non-essential '
                            'cookies (that is, Cookies other than the '
                            'Necessary / Essential Cookies described below) '
                            'only with Your consent. You can withdraw or '
                            'change Your consent at any time using Our '
                            'cookie preferences tool (if available) or '
                            'through Your browser/device settings. '
                            'Withdrawing consent does not affect the '
                            'lawfulness of processing based on consent '
                            'before its withdrawal.',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'We use both Session and Persistent Cookies for '
                            'the purposes set out below:',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 16),
                          _CookieType(
                            title: 'Necessary / Essential Cookies',
                            type: 'Session Cookies',
                            administeredBy: 'Us',
                            purpose:
                                'These Cookies are essential to provide You '
                                'with services available through the Website '
                                'and to enable You to use some of its '
                                'features. They help to authenticate users '
                                'and prevent fraudulent use of user accounts. '
                                'Without these Cookies, the services that You '
                                'have asked for cannot be provided, and We '
                                'only use these Cookies to provide You with '
                                'those services.',
                            style: bodyStyle,
                          ),
                          _CookieType(
                            title:
                                'Cookies Policy / Notice Acceptance Cookies',
                            type: 'Persistent Cookies',
                            administeredBy: 'Us',
                            purpose:
                                'These Cookies identify whether users have '
                                'accepted the use of cookies on the Website '
                                'and record the consent choices You have '
                                'made, so that We can honor those choices on '
                                'future visits.',
                            style: bodyStyle,
                          ),
                          _CookieType(
                            title: 'Functionality Cookies',
                            type: 'Persistent Cookies',
                            administeredBy: 'Us',
                            purpose:
                                'These Cookies allow Us to remember choices '
                                'You make when You use the Website, such as '
                                'remembering Your Account login details or '
                                'language preference. The purpose of these '
                                'Cookies is to provide You with a more '
                                'personal experience and to avoid You having '
                                'to re-enter Your preferences every time You '
                                'use the Website.',
                            style: bodyStyle,
                          ),
                        ],
                      ),
                    ),
                    _Section(
                      title: 'Use of Your Personal Data',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'The Company may use Personal Data for the '
                            'following purposes:',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 10),
                          _Bullet(
                            'To provide and maintain Our Service, including '
                            'to monitor the usage of Our Service.',
                            style: bulletStyle,
                          ),
                          _Bullet(
                            'To manage Your Account: to manage Your '
                            'registration as a user of the Service. The '
                            'Personal Data You provide can give You access '
                            'to different functionalities of the Service '
                            'that are available to You as a registered user.',
                            style: bulletStyle,
                          ),
                          _Bullet(
                            'For the performance of a contract: the '
                            'development, compliance and undertaking of the '
                            'purchase contract for the products, items or '
                            'services You have purchased or of any other '
                            'contract with Us through the Service.',
                            style: bulletStyle,
                          ),
                          _Bullet(
                            'To contact You: To contact You by email, '
                            'telephone calls, SMS, or other equivalent forms '
                            'of electronic communication, such as a mobile '
                            "application's push notifications regarding "
                            'updates or informative communications related '
                            'to the functionalities, products or contracted '
                            'services, including the security updates, when '
                            'necessary or reasonable for their '
                            'implementation.',
                            style: bulletStyle,
                          ),
                          _Bullet(
                            'To provide You with news, special offers, and '
                            'general information about other goods, services '
                            'and events which We offer that are similar to '
                            'those that You have already purchased or '
                            'inquired about. We send such marketing '
                            'communications only where permitted by '
                            'applicable law: where prior consent is required '
                            '(for example, under the laws applicable in the '
                            'EEA and the UK), We will send them only with '
                            'Your consent; otherwise, We may send them until '
                            'You opt out. You may opt out or withdraw Your '
                            'consent at any time by using the unsubscribe '
                            'link in any marketing email We send or by '
                            'contacting Us.',
                            style: bulletStyle,
                          ),
                          _Bullet(
                            'To manage Your requests: To attend and manage '
                            'Your requests to Us.',
                            style: bulletStyle,
                          ),
                          _Bullet(
                            'For business transfers: We may use Your '
                            'Personal Data to evaluate or conduct a merger, '
                            'divestiture, restructuring, reorganization, '
                            'dissolution, or other sale or transfer of some '
                            'or all of Our assets, whether as a going '
                            'concern or as part of bankruptcy, liquidation, '
                            'or similar proceeding, in which Personal Data '
                            'held by Us about Our Service users is among the '
                            'assets transferred.',
                            style: bulletStyle,
                          ),
                          _Bullet(
                            'For other purposes: We may use Your information '
                            'for other purposes, such as data analysis, '
                            'identifying usage trends, determining the '
                            'effectiveness of Our promotional campaigns, and '
                            'evaluating and improving Our Service, products, '
                            'services, marketing and Your experience.',
                            style: bulletStyle,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'We may share Your Personal Data in the '
                            'following situations:',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 10),
                          _Bullet(
                            'With Service Providers: We may share Your '
                            'Personal Data with Service Providers to monitor '
                            'and analyze the use of Our Service, and to '
                            'contact You.',
                            style: bulletStyle,
                          ),
                          _Bullet(
                            'For business transfers: We may share or '
                            'transfer Your Personal Data in connection with, '
                            'or during negotiations of, any merger, sale of '
                            'Company assets, financing, or acquisition of '
                            'all or a portion of Our business to another '
                            'company.',
                            style: bulletStyle,
                          ),
                          _Bullet(
                            'With Affiliates: We may share Your Personal '
                            'Data with Our affiliates, in which case We will '
                            'require those affiliates to honor this Privacy '
                            'Policy. Affiliates include Our parent company '
                            'and any other subsidiaries, joint venture '
                            'partners or other companies that We control or '
                            'that are under common control with Us.',
                            style: bulletStyle,
                          ),
                          _Bullet(
                            'With other users: If Our Service offers public '
                            'areas, when You share Personal Data or '
                            'otherwise interact in the public areas with '
                            'other users, such information may be viewed by '
                            'all users and may be publicly distributed '
                            'outside the Service.',
                            style: bulletStyle,
                          ),
                          _Bullet(
                            'With Your consent: We may disclose Your '
                            'Personal Data for any other purpose with Your '
                            'consent.',
                            style: bulletStyle,
                          ),
                        ],
                      ),
                    ),
                    _Section(
                      title: 'Retention of Your Personal Data',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'The Company will retain Your Personal Data only '
                            'for as long as is necessary for the purposes '
                            'set out in this Privacy Policy. We will retain '
                            'and use Your Personal Data to the extent '
                            'necessary to comply with Our legal obligations '
                            '(for example, if We are required to retain Your '
                            'data to comply with applicable laws), resolve '
                            'disputes, and enforce Our legal agreements and '
                            'policies.',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Where possible, We apply shorter retention '
                            'periods and/or reduce identifiability by '
                            'deleting, aggregating, or anonymizing data. '
                            'Unless otherwise stated, the retention periods '
                            'below are maximum periods ("up to") and We may '
                            'delete or anonymize data sooner when it is no '
                            'longer needed for the relevant purpose. We '
                            'apply different retention periods to different '
                            'categories of Personal Data based on the '
                            'purpose of processing and legal obligations:',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 16),
                          Text('Account Information', style: kBodyTitleM),
                          const SizedBox(height: 8),
                          _Bullet(
                            'User Accounts: retained for the duration of '
                            'Your Account relationship plus up to 24 months '
                            'after account closure to handle any '
                            'post-termination issues or resolve disputes.',
                            style: bulletStyle,
                          ),
                          const SizedBox(height: 12),
                          Text('Usage Data', style: kBodyTitleM),
                          const SizedBox(height: 8),
                          _Bullet(
                            'Website analytics data (cookies, IP addresses, '
                            'device identifiers): up to 24 months from the '
                            'date of collection, which allows us to analyze '
                            'trends while respecting privacy principles.',
                            style: bulletStyle,
                          ),
                          _Bullet(
                            'Server logs (IP addresses, access times): up '
                            'to 24 months for security monitoring and '
                            'troubleshooting purposes.',
                            style: bulletStyle,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Usage Data is retained in accordance with the '
                            'retention periods described above, and may be '
                            'retained longer only where necessary for '
                            'security, fraud prevention, or legal compliance.',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'We may retain Personal Data beyond the periods '
                            'stated above for different reasons:',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 10),
                          _Bullet(
                            'Legal obligation: We are required by law to '
                            'retain specific data (e.g., financial records '
                            'for tax authorities).',
                            style: bulletStyle,
                          ),
                          _Bullet(
                            'Legal claims: Data is necessary to establish, '
                            'exercise, or defend legal claims.',
                            style: bulletStyle,
                          ),
                          _Bullet(
                            'Your explicit request: You ask Us to retain '
                            'specific information.',
                            style: bulletStyle,
                          ),
                          _Bullet(
                            'Technical limitations: Data exists in backup '
                            'systems that are scheduled for routine deletion.',
                            style: bulletStyle,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'You may request information about how long We '
                            'will retain Your Personal Data by contacting Us.',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'When retention periods expire, We securely '
                            'delete or anonymize Personal Data according to '
                            'the following procedures:',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 10),
                          _Bullet(
                            'Deletion: Personal Data is removed from Our '
                            'systems and no longer actively processed.',
                            style: bulletStyle,
                          ),
                          _Bullet(
                            'Backup retention: Residual copies may remain '
                            'in encrypted backups for a limited period '
                            'consistent with Our backup retention schedule '
                            'and are not restored except where necessary for '
                            'security, disaster recovery, or legal '
                            'compliance.',
                            style: bulletStyle,
                          ),
                          _Bullet(
                            'Anonymization: In some cases, We convert '
                            'Personal Data into anonymous statistical data '
                            'that cannot be linked back to You. This '
                            'anonymized data may be retained indefinitely '
                            'for research and analytics.',
                            style: bulletStyle,
                          ),
                        ],
                      ),
                    ),
                    _Section(
                      title: 'Transfer of Your Personal Data',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your information, including Personal Data, is "
                            "processed at the Company's operating offices "
                            'and in any other places where the parties '
                            'involved in the processing are located. This '
                            'means that this information may be transferred '
                            'to — and maintained on — computers located '
                            'outside of Your state, province, country or '
                            'other governmental jurisdiction where the data '
                            'protection laws may differ from those of Your '
                            'jurisdiction.',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Where required by applicable law, We will '
                            'ensure that international transfers of Your '
                            'Personal Data are subject to appropriate '
                            'safeguards and, where relevant, supplementary '
                            'measures. The Company will take all steps '
                            'reasonably necessary to ensure that Your data '
                            'is treated securely and in accordance with this '
                            'Privacy Policy and no transfer of Your Personal '
                            'Data will take place to an organization or a '
                            'country unless there are adequate controls in '
                            'place, including the security of Your data and '
                            'other personal information.',
                            style: bodyStyle,
                          ),
                        ],
                      ),
                    ),
                    _Section(
                      title: 'Delete Your Personal Data',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'You have the right to delete or request that We '
                            'assist in deleting the Personal Data that We '
                            'have collected about You.',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Our Service may give You the ability to delete '
                            'certain information about You from within the '
                            'Service.',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'You may update, amend, or delete Your '
                            'information at any time by signing in to Your '
                            'Account, if You have one, and visiting the '
                            'account settings section that allows You to '
                            'manage Your personal information. You may also '
                            'contact Us to request access to, correct, or '
                            'delete any Personal Data that You have provided '
                            'to Us.',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Please note, however, that We may need to '
                            'retain certain information when We have a legal '
                            'obligation or lawful basis to do so.',
                            style: bodyStyle,
                          ),
                        ],
                      ),
                    ),
                    _Section(
                      title: 'Disclosure of Your Personal Data',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Business Transactions', style: kBodyTitleM),
                          const SizedBox(height: 8),
                          Text(
                            'If the Company is involved in a merger, '
                            'acquisition or asset sale, Your Personal Data '
                            'may be transferred. We will provide notice '
                            'before Your Personal Data is transferred and '
                            'becomes subject to a different Privacy Policy.',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 16),
                          Text('Law Enforcement', style: kBodyTitleM),
                          const SizedBox(height: 8),
                          Text(
                            'Under certain circumstances, the Company may '
                            'disclose Your Personal Data if required to do '
                            'so by law or in response to valid requests by '
                            'public authorities (e.g. a court or a '
                            'government agency).',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 16),
                          Text('Other Legal Requirements', style: kBodyTitleM),
                          const SizedBox(height: 8),
                          Text(
                            'The Company may disclose Your Personal Data in '
                            'the good-faith belief that such action is '
                            'necessary to:',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 10),
                          _Bullet(
                            'Comply with a legal obligation',
                            style: bulletStyle,
                          ),
                          _Bullet(
                            'Protect and defend the rights or property of '
                            'the Company',
                            style: bulletStyle,
                          ),
                          _Bullet(
                            'Prevent or investigate possible wrongdoing in '
                            'connection with the Service',
                            style: bulletStyle,
                          ),
                          _Bullet(
                            'Protect the personal safety of Users of the '
                            'Service or the public',
                            style: bulletStyle,
                          ),
                          _Bullet(
                            'Protect against legal liability',
                            style: bulletStyle,
                          ),
                        ],
                      ),
                    ),
                    _Section(
                      title: 'Security of Your Personal Data',
                      child: Text(
                        'The security of Your Personal Data is important to '
                        'Us, but remember that no method of transmission '
                        'over the Internet, or method of electronic storage, '
                        'is 100% secure. While We strive to use commercially '
                        'reasonable means to protect Your Personal Data, We '
                        'cannot guarantee its absolute security.',
                        style: bodyStyle,
                      ),
                    ),
                    _Section(
                      title: "Children's and Minors' Privacy",
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'The Service is not directed to, and We do not '
                            'knowingly collect Personal Information from, '
                            'anyone under the age of 16.',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'If You are a parent or guardian and You believe '
                            'Your child has provided Us with Personal '
                            'Information, please contact Us. If We become '
                            'aware that We have collected Personal '
                            'Information from anyone under the age of 16, We '
                            'will take steps to remove that information from '
                            'Our servers as soon as reasonably possible.',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Some countries and states set a higher age at '
                            'which an individual can consent to the '
                            'processing of their own Personal Information. '
                            'Where We rely on consent as a legal basis and '
                            'the law applicable to a User sets an age higher '
                            'than 16, We may require the consent of that '
                            "User's parent or guardian before We collect and "
                            'use their Personal Information.',
                            style: bodyStyle,
                          ),
                        ],
                      ),
                    ),
                    _Section(
                      title: 'Links to Other Websites',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Our Service may contain links to other websites '
                            'that are not operated by Us. If You click on a '
                            "third-party link, You will be directed to that "
                            "third party's site. We strongly advise You to "
                            'review the Privacy Policy of every site You '
                            'visit.',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'We have no control over and assume no '
                            'responsibility for the content, privacy '
                            'policies or practices of any third-party sites '
                            'or services.',
                            style: bodyStyle,
                          ),
                        ],
                      ),
                    ),
                    _Section(
                      title: 'Changes to this Privacy Policy',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'We may update Our Privacy Policy from time to '
                            'time. We will notify You of any changes by '
                            'posting the new Privacy Policy on this page.',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'We will let You know via email and/or a '
                            'prominent notice on Our Service, prior to the '
                            'change becoming effective and update the "Last '
                            'updated" date at the top of this Privacy Policy.',
                            style: bodyStyle,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'You are advised to review this Privacy Policy '
                            'periodically for any changes. Changes to this '
                            'Privacy Policy are effective when they are '
                            'posted on this page.',
                            style: bodyStyle,
                          ),
                        ],
                      ),
                    ),
                    _Section(
                      title: 'Contact Us',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'If You have any questions about this Privacy '
                            'Policy, You can contact Us:',
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
                              'By email: $_email',
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

class _Definition extends StatelessWidget {
  const _Definition({
    required this.term,
    required this.text,
    required this.style,
  });

  final String term;
  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '$term ', style: kBodyTitleM.copyWith(height: 1.55)),
            TextSpan(text: text, style: style),
          ],
        ),
      ),
    );
  }
}

class _CookieType extends StatelessWidget {
  const _CookieType({
    required this.title,
    required this.type,
    required this.administeredBy,
    required this.purpose,
    required this.style,
  });

  final String title;
  final String type;
  final String administeredBy;
  final String purpose;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: kBodyTitleM),
          const SizedBox(height: 8),
          Text('Type: $type', style: style),
          const SizedBox(height: 4),
          Text('Administered by: $administeredBy', style: style),
          const SizedBox(height: 4),
          Text('Purpose: $purpose', style: style),
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
