import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/models/event_model.dart';
import 'package:jamiat/src/data/utils/format_helpers.dart';

Widget eventCoverImage(String? url, {BoxFit fit = BoxFit.cover}) {
  if (url != null && url.startsWith('http')) {
    return Image.network(
      url,
      fit: fit,
      errorBuilder: (_, _, _) => Container(
        color: kScreenBg,
        child: const Icon(Icons.image_outlined, color: kMutedText, size: 40),
      ),
    );
  }
  return Image.asset(
    url ?? 'assets/jpgs/campaign_education.jpg',
    fit: fit,
    errorBuilder: (_, _, _) => Container(
      color: kScreenBg,
      child: const Icon(Icons.image_outlined, color: kMutedText, size: 40),
    ),
  );
}

class EventListCard extends StatelessWidget {
  const EventListCard({
    super.key,
    required this.event,
    required this.onTap,
    required this.onBookmark,
    required this.onShare,
    this.isBookmarked,
    this.isBookmarkLoading = false,
    this.isShareLoading = false,
  });

  final EventModel event;
  final VoidCallback onTap;
  final VoidCallback onBookmark;
  final VoidCallback onShare;
  final bool? isBookmarked;
  final bool isBookmarkLoading;
  final bool isShareLoading;

  @override
  Widget build(BuildContext context) {
    final bookmarked = isBookmarked ?? event.isBookmarked;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: kWhite,
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
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 180,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    eventCoverImage(event.coverImage),
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
                          event.type,
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
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: kBodyTitleSB.copyWith(fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: kMutedText,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            formatEventDateTimeRange(
                              event.startDate,
                              event.endDate,
                            ),
                            style: kCaption12R.copyWith(
                              color: kSecondaryTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (event.venue != null && event.venue!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: kMutedText,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              event.venue!,
                              style: kCaption12R.copyWith(
                                color: kSecondaryTextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
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
                    width: 16,
                    height: 16,
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
