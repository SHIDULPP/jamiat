import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/models/product_model.dart';
import 'package:jamiat/src/data/providers/product_provider.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';
import 'package:jamiat/src/data/utils/format_helpers.dart';
import 'package:jamiat/src/interfaces/components/async_content.dart';
import 'package:jamiat/src/interfaces/components/primarybutton.dart';
import 'package:jamiat/src/interfaces/market/market_product_card.dart';

class MyEnquiriesScreen extends ConsumerWidget {
  const MyEnquiriesScreen({super.key});

  Widget _headerCircleButton({
    required Widget child,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: kWhite,
          border: Border.all(color: kStrokeColor, width: 1.25),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/pngs/noenquiry.png',
              width: 88,
              height: 88,
            ),
            const SizedBox(height: 24),
            Text(
              'No Enquiries yet',
              style: kBodyTitleSB.copyWith(color: kTextColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "You haven't submitted any enquiries. Browse products and submit an enquiry.",
              style: kCaption12R.copyWith(
                color: kSecondaryTextColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 180,
              child: primaryButton(
                label: 'Explore Products',
                buttonHeight: 48,
                onPressed: () {
                  HapticHelper.impact(HapticImpact.light);
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    NavigationService().pushNamedAndRemoveUntil('navBar');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _enquiryCard(ProductEnquiryModel enquiry) {
    final product = enquiry.product;
    final enquiredOn = enquiry.createdAt != null
        ? formatDonationDateTime(enquiry.createdAt!.toLocal())
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(kCardRadiusMd),
        border: Border.all(color: kCardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(kCardRadiusSm),
            child: SizedBox(
              width: 72,
              height: 72,
              child: productCoverImage(product.image),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: kCaption12SB.copyWith(
                          color: kTextColor,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      product.formattedPrice,
                      style: kCaption12SB.copyWith(color: kTextColor),
                    ),
                  ],
                ),
                if (enquiredOn.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Enquired on: $enquiredOn',
                    style: kCaption10R.copyWith(
                      color: kSecondaryTextColor,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enquiriesAsync = ref.watch(myProductEnquiriesProvider);

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  _headerCircleButton(
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
                  Text('Enquiries', style: kSectionTitleSB),
                ],
              ),
            ),
            Expanded(
              child: AsyncContent(
                asyncValue: enquiriesAsync,
                onRetry: () => ref.invalidate(myProductEnquiriesProvider),
                builder: (page) {
                  final items = page.items;
                  if (items.isEmpty) return _emptyState(context);

                  return RefreshIndicator(
                    color: kPrimaryColor,
                    onRefresh: () async {
                      ref.invalidate(myProductEnquiriesProvider);
                      await ref.read(myProductEnquiriesProvider.future);
                    },
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(
                        kScreenPaddingH,
                        0,
                        kScreenPaddingH,
                        16,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final enquiry = items[index];
                        return GestureDetector(
                          onTap: () {
                            HapticHelper.impact(HapticImpact.light);
                            NavigationService().pushNamed(
                              'MarketProductDetail',
                              arguments: {'productId': enquiry.product.id},
                            );
                          },
                          child: _enquiryCard(enquiry),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
