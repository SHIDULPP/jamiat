import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:jamiat/src/data/providers/screen_data_providers.dart';
import 'package:jamiat/src/data/services/navigation_services.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _entranceController;
  late AnimationController _shimmerController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _blurAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _scaleAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.5,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.1,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(_entranceController);

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _blurAnimation = Tween<double>(begin: 15.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
          ),
        );

    _entranceController.forward();

    Future.delayed(const Duration(seconds: 3), _navigateToNext);
  }

  Future<void> _navigateToNext() async {
    if (!mounted) return;
    NavigationService().pushNamedAndRemoveUntil('Login');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _entranceController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);

    // Figma: collage ~95.5% of frame width (≈8px inset on 375 design).
    final horizontalInset = screenSize.responsivePadding(8);

    // Logo asset includes transparent padding (~9.5% of asset width).
    // Figma visual logo ≈ 37.7% of width → asset width ≈ 41.5%.
    final logoWidth = screenSize.isTablet
        ? screenSize.responsiveSize(156)
        : screenSize.widthPercent(41.5).clamp(0.0, double.infinity);

    // Figma visual gap collage → logo ≈ 4.7% of frame height.
    // Subtract the logo asset's transparent top pad so the visible gap matches.
    const logoAssetHeight = 288.0;
    const logoAssetWidth = 632.0;
    const logoTrimTop = 48.0;
    final logoDisplayHeight = logoWidth * (logoAssetHeight / logoAssetWidth);
    final logoTopPad = logoDisplayHeight * (logoTrimTop / logoAssetHeight);
    final collageLogoGap =
        (screenSize.heightPercent(4.7) - logoTopPad).clamp(0.0, double.infinity);

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _entranceController,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: _blurAnimation.value,
                    sigmaY: _blurAnimation.value,
                  ),
                  child: SizedBox.expand(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalInset),
                      child: Column(
                        children: [
                          // Figma top ≈ 25%, bottom ≈ 26.6% — near-equal spacers.
                          const Spacer(flex: 25),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: screenSize.isTablet
                                  ? screenSize.responsiveSize(420)
                                  : double.infinity,
                            ),
                            child: Image.asset(
                              'assets/pngs/jamiat_splashimage.png',
                              width: double.infinity,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                          SizedBox(height: collageLogoGap),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: logoWidth,
                                child: Image.asset(
                                  'assets/pngs/jamiat_logo.png',
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                              if (_entranceController.value > 0.5)
                                Shimmer.fromColors(
                                  baseColor: Colors.transparent,
                                  highlightColor:
                                      Colors.white.withValues(alpha: 0.8),
                                  period: const Duration(milliseconds: 1500),
                                  direction: ShimmerDirection.ltr,
                                  child: SizedBox(
                                    width: logoWidth,
                                    child: Image.asset(
                                      'assets/pngs/jamiat_logo.png',
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.high,
                                      color: Colors.white
                                          .withValues(alpha: 200 / 255),
                                      colorBlendMode: BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const Spacer(flex: 27),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
