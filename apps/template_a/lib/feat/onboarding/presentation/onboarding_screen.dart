import 'package:common_components/common_components.dart';
import 'package:common_components/src/animations/move_up_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:template_a/core/constant/common_enums.dart';
import 'package:theme/theme.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constant/image.dart';
import '../../../core/utils/template_a_colors.dart';
import '../../../router/route_constant.dart';
import '../../../router/router_provider.dart' show shellConfigProvider;
import '../controller/onboarding_controller.dart';
import '../widget/common_widget.dart';
import '../widget/page_count_dotted_ui.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../auth/presentation/auth_page.dart';
import '../../auth/presentation/user_selection_page.dart';
import '../../../core/widgets/user_type_card.dart';
import 'pages/welcome_page.dart';

class OnboardingScreen extends BaseStatefulWidget {
  const OnboardingScreen({super.key, this.initialPage = 0});

  final int initialPage;

  @override
  String get screenName => RouteConstant.onboarding.name;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends BaseStatefulWidgetState<OnboardingScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialPage != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(onboardingControllerProvider.notifier).onPageChanged(widget.initialPage);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingControllerProvider);
    final appTheme = ref.watch(appThemeProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: TemplateAColors.darkModeBackground,
        appBar: _buildAppBar(context, state, appTheme),
        body: Stack(
          children: [
            const _BackgroundLayer(),
            _ScrollableContent(state: state),
            onboardingBottomInfo(),
            if (state.state == StateEnum.loading)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    dynamic state,
    dynamic appTheme,
  ) {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      toolbarHeight: 120.h,
      leadingWidth: 44.w,
      leading: state.selectedPage > 0
          ? Padding(
              padding: EdgeInsets.only(left: 32.w),
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  if (state.isResetPasswordActive) {
                    ref.read(onboardingControllerProvider.notifier).exitResetPassword();
                    return;
                  }
                  if (state.selectedPage >= 2) {
                    ref.read(authControllerProvider.notifier).clearGuestSession().then((_) {
                      ref.read(authControllerProvider.notifier).setUserType(UserTypeEnum.resident);
                      ref.read(onboardingControllerProvider.notifier).onPageChanged(1);
                    });
                  } else {
                    ref.read(onboardingControllerProvider.notifier).onPageChanged(state.selectedPage - 1);
                  }
                },
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
            )
          : null,
      titleSpacing: 4,
      centerTitle: false,
      title: CommonImage(
        imagePath: appTheme.assets?.logoUrl ?? "",
        height: 120.h,
      ),
      backgroundColor: Colors.transparent,
    );
  }
}

class _ScrollableContent extends BaseStatefulWidget {
  final dynamic state;

  const _ScrollableContent({required this.state});

  @override
  ConsumerState<_ScrollableContent> createState() => _ScrollableContentState();
}

class _ScrollableContentState extends BaseStatefulWidgetState<_ScrollableContent>  with TickerProviderStateMixin{

  int _loginPageKey = 0;

  List<Widget> get _pages => [
    const WelcomePage(),
    const UserSelectionPage(),
    const AuthPage(key: ValueKey(AuthMode.register), initialMode: AuthMode.register),
    AuthPage(key: ValueKey(_loginPageKey), initialMode: AuthMode.login),
  ];

  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnimation = Tween<Offset>(
      begin:  Offset(0,1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _slideController.forward();
  }

  @override
  void didUpdateWidget(covariant _ScrollableContent oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Re-trigger animation when page changes
    if (oldWidget.state.selectedPage != widget.state.selectedPage && widget.state.selectedPage == 1) {
      _slideController.reset();
      _slideController.forward();
    }

    // Reset password exit → force login page remount so _authMode resets to login
    if (oldWidget.state.isResetPasswordActive == true && widget.state.isResetPasswordActive == false) {
      setState(() => _loginPageKey++);
    }
  }

  @override
  void dispose() {
    _slideController.dispose();  // Always dispose!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildBirdIcon(widget.state),
            SizedBox(height: 10.h),
            if (widget.state.selectedPage != 0)
              ...[
                SizedBox(height: 10.h),
                SlideTransition(
                  position: _slideAnimation,
                  child: onboardingAppLogo()),
              ],
            if (widget.state.selectedPage != 0) SizedBox(height: 32.h),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: widget.state.selectedPage >= 2 ? 0 : 16.w,
              ),
              child: _pages[widget.state.selectedPage],
            ),
            if(widget.state.selectedPage == 0)
              _buildActionButton(context, widget.state),
            SizedBox(height: 16.h),
            PageCountDottedUI(
              currentPage: widget.state.selectedPage == 3 ? 2 : widget.state.selectedPage,
              totalPage: 6,
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildBirdIcon(dynamic state) {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 60.w),
        child: state.selectedPage == 0
            ? CommonImage(imagePath: Images.birdForwardIcon)
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, dynamic state) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: AppButton(
        _getButtonText(state.selectedPage),
        type: ButtonType.normal,
        size: ButtonSize.large,
        onPressed: () => _handleButtonPressed(state),
        bgColor: Theme.of(context).colorScheme.secondary,
        fontSize: 20.sp,
      ),
    );
  }

  String _getButtonText(int pageIndex) {
    switch (pageIndex) {
      case 0:
        return 'welcome_button'.tr;
      case 1:
        return 'next'.tr;
      case 2:
        return 'finish'.tr;
      default:
        return 'welcome_button'.tr;
    }
  }

  void _handleButtonPressed(dynamic state) {
    final controller = ProviderScope.containerOf(context).read(onboardingControllerProvider.notifier);

    switch (state.selectedPage) {
      case 0:
        ProviderScope.containerOf(context).read(authControllerProvider.notifier).clearUserType();
        controller.onPageChanged(state.selectedPage + 1);
        break;
      case 1:
        controller.onPageChanged(state.selectedPage + 1);
        break;
      case 2:
        ///handled in auth page no need to handle we can skip
        _completeOnboarding();
        break;
    }
  }

  void _completeOnboarding() {
    final path = ProviderScope.containerOf(context)
        .read(shellConfigProvider.notifier)
        .firstTabPath;
    context.go(path);
  }
}

class _BackgroundLayer extends BaseStatefulWidget {
  const _BackgroundLayer();

  @override
  ConsumerState<_BackgroundLayer> createState() => _BackgroundLayerState();
}

class _BackgroundLayerState extends BaseStatefulWidgetState<_BackgroundLayer> {
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _animate = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(
      onboardingControllerProvider.select((s) => s.selectedPage),
      (_, __) {
        setState(() => _animate = false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _animate = true);
        });
      },
    );

    ref.listen<bool>(
      onboardingControllerProvider.select((s) => s.isResetPasswordActive),
      (_, __) {
        setState(() => _animate = false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _animate = true);
        });
      },
    );

    final onboardingState = ref.watch(onboardingControllerProvider);
    final selectedPage = onboardingState.selectedPage;
    // Reset password behaves like signup (page 2 = even) for wave direction
    final isEvenPage = onboardingState.isResetPasswordActive ? true : selectedPage % 2 == 0;
    final waveUpPath = isEvenPage ? Images.wave5Svg : Images.wave6Svg;
    final waveDownPath = isEvenPage ? Images.wave6Svg : Images.wave5Svg;

    return Stack(
      children: [
        buildWave(animate: _animate, imagePath: waveUpPath, heightFraction: 0.33),
        buildWave(animate: _animate, imagePath: waveDownPath, reverse: true, heightFraction: 0.33),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: onboardingBuildings(
            animate: _animate,
            initialStart: 0.07,
            finalStart: 0.45,
            slideForward: !isEvenPage,
          ),
        ),
      ],
    );
  }
}
