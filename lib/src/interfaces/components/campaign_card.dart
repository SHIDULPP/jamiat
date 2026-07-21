import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/models/campaign_model.dart';
import 'package:jamiat/src/data/utils/category_mapper.dart';
import 'package:jamiat/src/data/utils/format_helpers.dart';
import 'package:jamiat/src/interfaces/components/primarybutton.dart';

Widget campaignCoverImage(String? url, {BoxFit fit = BoxFit.cover}) {
  if (url != null && url.startsWith('http')) {
    return Image.network(
      url,
      fit: fit,
      errorBuilder: (_, _, _) => Container(
        color: kScreenBg,
        child: const Icon(Icons.image_outlined, color: kMutedText),
      ),
    );
  }
  return Image.asset(
    url ?? 'assets/jpgs/campaign_education.jpg',
    fit: fit,
    errorBuilder: (_, _, _) => Container(
      color: kScreenBg,
      child: const Icon(Icons.image_outlined, color: kMutedText),
    ),
  );
}

class CampaignListCard extends StatelessWidget {
  const CampaignListCard({
    super.key,
    required this.campaign,
    required this.onDonate,
    required this.onBookmark,
    required this.onShare,
    this.isBookmarked,
    this.isBookmarkLoading = false,
    this.isShareLoading = false,
  });

  final CampaignModel campaign;
  final VoidCallback onDonate;
  final VoidCallback onBookmark;
  final VoidCallback onShare;
  final bool? isBookmarked;
  final bool isBookmarkLoading;
  final bool isShareLoading;

  @override
  Widget build(BuildContext context) {
    final bookmarked = isBookmarked ?? campaign.isBookmarked;
    final progress = campaign.targetAmount <= 0
        ? 0.0
        : (campaign.collectedAmount / campaign.targetAmount).clamp(0.0, 1.0);
    final percent = campaign.progressPercent > 0
        ? campaign.progressPercent
        : (progress * 100).round();
    final daysLeft = campaign.remainingDays ?? 0;
    final categoryLabel = CategoryMapper.toUi(campaign.category);
    final daysColor = daysLeft <= 7 ? kDaysLeftWarning : kMutedText;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: kCardBg,
        borderRadius: BorderRadius.circular(kCardRadiusLg),
        border: Border.all(color: kCardBorder),
        boxShadow: [
          BoxShadow(
            color: kBlack.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onDonate,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 180,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    campaignCoverImage(campaign.coverImage),
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
                          borderRadius: BorderRadius.circular(kPillRadius),
                        ),
                        child: Text(
                          categoryLabel,
                          style: kCaption10M.copyWith(color: kWhite),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Row(
                        children: [
                          _OverlayIconButton(
                            asset: 'assets/svg/share.svg',
                            onTap: isShareLoading ? null : onShare,
                            loading: isShareLoading,
                          ),
                          const SizedBox(width: 8),
                          _OverlayIconButton(
                            asset: 'assets/svg/bookmark.svg',
                            onTap: isBookmarkLoading ? null : onBookmark,
                            filled: bookmarked,
                            loading: isBookmarkLoading,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      campaign.title,
                      style: kBodyTitleSB.copyWith(fontSize: kSize16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      campaign.description,
                      style: kCaption12R.copyWith(
                        color: kMutedText,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(kPillRadius),
                      child: LinearProgressIndicator(
                        value: progress.toDouble(),
                        minHeight: 8,
                        backgroundColor: kGreyLight,
                        color: kSecondaryColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formatRupee(campaign.collectedAmount),
                                style: kBodyTitleSB,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'of ${formatRupee(campaign.targetAmount)}',
                                style: kCaption12R.copyWith(
                                  color: kSecondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('$percent%', style: kBodyTitleSB),
                            const SizedBox(height: 2),
                            Text(
                              '$daysLeft days left',
                              style: kCaption12M.copyWith(color: daysColor),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    primaryButton(
                      label: 'Donate Now',
                      onPressed: onDonate,
                      buttonHeight: 48,
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

class _OverlayIconButton extends StatelessWidget {
  const _OverlayIconButton({
    required this.asset,
    required this.onTap,
    this.filled = false,
    this.loading = false,
  });

  final String asset;
  final VoidCallback? onTap;
  final bool filled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kBlack.withValues(alpha: 0.35),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: kWhite,
                    ),
                  )
                : SvgPicture.asset(
                    asset,
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(
                      filled ? kPrimaryColor : kWhite,
                      BlendMode.srcIn,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
