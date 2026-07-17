import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jamiat/src/data/constants/color_constants.dart';
import 'package:jamiat/src/data/constants/style_constants.dart';
import 'package:jamiat/src/data/router/nav_router.dart';
import 'package:jamiat/src/data/services/haptic_helper.dart';
import 'package:jamiat/src/data/services/get_fcm.dart';
import 'package:jamiat/src/interfaces/main_pages/donate.dart';
import 'package:jamiat/src/interfaces/main_pages/home.dart';
import 'package:jamiat/src/interfaces/main_pages/market.dart';
import 'package:jamiat/src/interfaces/main_pages/profile.dart';

class NavBar extends ConsumerStatefulWidget {
  const NavBar({super.key});

  @override
  ConsumerState<NavBar> createState() => _NavBarState();
}

class _NavBarState extends ConsumerState<NavBar> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getFcmToken(context, ref);
    });
  }

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    DonatePage(),
    MarketPage(),
    ProfilePage(),
  ];

  static const List<String> _icons = [
    'assets/svg/home_icon.svg',
    'assets/svg/donate.svg',
    'assets/svg/market_icon.svg',
    'assets/svg/profile_icon.svg',
  ];

  static const List<String> _labels = ['Home', 'Donate', 'Market', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    return PopScope(
      canPop: selectedIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        log('inside navbar popscope', name: 'NavBar');
        if (selectedIndex != 0) {
          ref.read(selectedIndexProvider.notifier).updateIndex(0);
        }
      },
      child: Scaffold(
        backgroundColor: kWhite,
        body: _pages.elementAt(selectedIndex),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: kWhite,
            boxShadow: [
              BoxShadow(
                color: kBlack.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 70,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: List.generate(_labels.length, (index) {
                    final isSelected = selectedIndex == index;
                    final color = isSelected ? kPrimaryColor : kIconMuted;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (selectedIndex == index) return;
                          HapticHelper.impact(HapticImpact.light);
                          ref
                              .read(selectedIndexProvider.notifier)
                              .updateIndex(index);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedScale(
                              duration: const Duration(milliseconds: 200),
                              scale: isSelected ? 1.15 : 1.0,
                              child: SvgPicture.asset(
                                _icons[index],
                                width: 24,
                                height: 24,
                                colorFilter: ColorFilter.mode(
                                  color,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _labels[index],
                              style: (isSelected ? kNavLabelM : kNavLabelR)
                                  .copyWith(color: color),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
