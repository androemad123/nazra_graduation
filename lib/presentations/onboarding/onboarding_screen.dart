import 'package:app/presentations/onboarding/widgets/build_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../app/provider/theme_provider.dart';
import '../../generated/l10n.dart';
import '../../routing/routes.dart';
import '../resources/color_manager.dart';
import '../resources/font_manager.dart';
import '../resources/styles_manager.dart';
import '../widgets/app_text_btn.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final controller = PageController();
  bool isLastPage = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: themeProvider.isDarkMode
                ? [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.secondary,
              Theme.of(context).colorScheme.surface,
            ]
                : [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- PageView ---
              Expanded(
                child: PageView(
                  controller: controller,
                  onPageChanged: (index) {
                    setState(() => isLastPage = index == 2);
                  },
                  children: [
                    BuildPage(
                      imageHeight: 351,
                      imageWidth: double.maxFinite,
                      imagePath: 'assets/images/onboarding1.png',
                      title: s.onboardTitle1,
                      subtitle: s.onboardSubtitle1,
                    ),
                    BuildPage(
                      imageHeight: 340,
                      imageWidth: 350,
                      imagePath: "assets/images/onboarding2.png",
                      title: s.onboardTitle2,
                      subtitle: s.onboardSubtitle2,
                    ),
                    BuildPage(
                      imageWidth: 360,
                      imageHeight: 340,
                      imagePath: "assets/images/onboarding3.png",
                      title: s.onboardTitle3,
                      subtitle: s.onboardSubtitle3,
                    ),
                  ],
                ),
              ),

              // --- Bottom Buttons ---
              Container(
                height: 200.h,
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SmoothPageIndicator(
                      controller: controller,
                      count: 3,
                      effect: ScaleEffect(
                        activeDotColor: Theme.of(context).primaryColor,
                        activeStrokeWidth: 0.1,
                        dotWidth: 7,
                        dotHeight: 7,
                        scale: 1.7,
                        dotColor: ColorManager.lightBrown,
                        spacing: 15,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    if (isLastPage) ...[
                      AppTextBtn(
                        buttonHeight: 56.h,
                        buttonWidth: 300.w,
                        buttonText: s.login,
                        textStyle: regularStyle(
                          fontSize: FontSize.s18,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.pushNamed(
                          context,
                          Routes.loginRoute,
                        ),
                        borderRadius: 10,
                      ),
                      SizedBox(height: 20.h),
                      AppTextBtn(
                        buttonHeight: 56.h,
                        buttonWidth: 300.w,
                        buttonText: s.signUp,
                        textStyle: regularStyle(
                          fontSize: FontSize.s18,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        onPressed: () {},
                        backGroundColor: Colors.transparent,
                        borderRadius: 10,
                      ),
                    ] else ...[
                      AppTextBtn(
                        buttonHeight: 56.h,
                        buttonWidth: 300.w,
                        buttonText: s.next,
                        onPressed: () => controller.nextPage(
                          curve: Curves.easeInOut,
                          duration: const Duration(milliseconds: 300),
                        ),
                        textStyle: regularStyle(
                          fontSize: FontSize.s18,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      AppTextBtn(
                        buttonHeight: 56.h,
                        buttonWidth: 300.w,
                        buttonText: s.skip,
                        textStyle: regularStyle(
                          fontSize: FontSize.s18,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        backGroundColor: Colors.transparent,
                        onPressed: () => controller.jumpToPage(2),
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
