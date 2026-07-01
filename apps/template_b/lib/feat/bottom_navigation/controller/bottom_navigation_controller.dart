import 'package:common_components/common_components.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/localizations.dart';
import 'package:template_b/core/constants/action_constant.dart';
import 'package:template_b/core/feature_flags.dart';
import 'package:template_b/feat/bottom_navigation/model/request_model/bottom_navigation_config_request_model.dart';
import 'package:template_b/feat/bottom_navigation/model/response_model/bottom_navigation_config_response_model.dart';
import 'package:template_b/feat/bottom_navigation/model/ui_model/bottom_nav_bar_model.dart';
import 'package:template_b/feat/bottom_navigation/presentation/auth_required_nav_screen.dart';
import 'package:template_b/feat/bottom_navigation/registry/template_b_registry.dart';
import 'package:template_b/feat/bottom_navigation/state/bottom_navigation_state.dart';
import 'package:template_b/feat/bottom_navigation/domain/usecase/bottom_navigation_usecase.dart';
import 'package:template_b/feat/linkhub_service/data/model/linkhub_service_model.dart';
import 'package:template_b/feat/sub_service/presentation/sub_service_screen.dart';
import 'package:template_b/feat/listing/presentation/screens/listing_screen.dart';

final bottomNavigationProvider =
    NotifierProvider<BottomNavigationController, BottomNavigationState>(
      () => BottomNavigationController(),
    );

class BottomNavigationController extends Notifier<BottomNavigationState> {
  BottomNavigationUsecase get _bottomNavigationUsecase =>
      ref.read(bottomNavigationUsecaseProvider);

  @override
  BottomNavigationState build() {
    return BottomNavigationState(true, 0, null, [], null);
  }

  Future<void> loadConfig() async {
    try {
      state = state.copyWith(isLoading: true);
      BottomNavigationConfigRequestModel requestModel =
          BottomNavigationConfigRequestModel();
      final res = await _bottomNavigationUsecase.call(requestModel);

      res.fold(
        (l) {
          debugPrint('bottom navigation config fold exception : $l');
        },
        (r) {
          final screens = List.generate(r.data?.length ?? 0, (index) {
            final item = r.data![index];
            if (item.action?.type == ActionConstant.urlWebview.name &&
                item.action?.config?.requireLogin != true) {
              _activeWebViewIndices.add(index);
            }
            return _generateUIObject(item: item);
          });

          final bottomNavBarModel = BottomNavBarModel(
            items: List.generate(r.data?.length ?? 0, (index) {
              final item = r.data![index];

              return NavItemModel(
                label: _getNavLabel(item),
                iconUrl: item.iconUrl ?? '',
              );
            }),
          );

          state = state.copyWith(
            bottomNavigationConfigResponseModel: r,
            bottomNavBarModel: bottomNavBarModel,
            screen: screens.cast<Widget>(),
            isLoading: false,
          );
        },
      );
    } catch (e) {
      debugPrint('bottom navigation config exception : $e');
      state = state.copyWith(isLoading: false);
    }
  }

  Widget _generateUIObject({required BottomNavItemModel item}) {
    final slugName = item.action?.target ?? '';
    final actionType = item.action?.type ?? '';

    if (actionType == ActionConstant.urlBrowser.name) {
      return Container();
    }

    if (actionType == ActionConstant.urlWebview.name) {
      if (item.action?.config?.requireLogin == true) {
        return const AuthRequiredNavScreen();
      }
      return CommonWebViewWidget(
        params: CommonWebViewWidgetParams(
          url: item.action?.config?.url ?? '',
          title: _getNavLabel(item) ?? '',
          requiredShortCode: item.action?.config?.requiredShortCode,
          onBackPressHandle: () {
            setSelectedIndex(0);
          },
        ),
      );
    }

    // When target is 'category', use the nav item's own slug as categorySlug
    // since BE does not include it in action.config
    if (slugName == ActionConstant.category.name) {
      return ListingScreen(
        params: ListingScreenParams(
          categorySlug: item.slug ?? '',
          title: _getNavLabel(item),
          showBackButton: false,
          isBottomBar: true,
        ),
      );
    }

    if (actionType == ActionConstant.serviceHub.name) {
      return SubServiceScreen(
        params: SubServiceScreenParams(
          title: _getNavLabel(item) ?? '',
          services: item.action?.config?.children ?? [],
        ),
      );
    }

    if (actionType == ActionConstant.linkHub.name) {
      final action = item.action;
      final service = LinkhubServiceModel.fromAction(
        id: item.slug ?? '',
        title: _getNavLabel(item) ?? '',
        image: action?.serviceImage,
        variant: action?.variant,
        config: action?.config,
      );
      return CommonLinkhubScreen(
        title: service.title,
        imageUrl: service.image,
        isAccordion: service.isAccordion,
        groups: service.groups,
        links: service.links,
      );
    }

    return templateBRegistry[slugName] ??
        Center(
          child: CommonText(
            titleText: 'comming_soon'.tr,
            textStyle: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold),
          ),
        );
  }

  void activateWebViewScreen(int index) {
    final data = state.bottomNavigationConfigResponseModel?.data;
    if (data == null || index >= data.length) return;

    final item = data[index];
    if (item.action?.type != ActionConstant.urlWebview.name) return;

    // Skip if the screen is already a live webview — avoids replacing it with a
    // fresh instance (which would lose scroll position and navigation history).
    if (index < state.screen.length &&
        state.screen[index] is CommonWebViewWidget) {
      _activeWebViewIndices.add(index);
      return;
    }

    _activeWebViewIndices.add(index);
    final updatedScreens = List<Widget>.from(state.screen);
    updatedScreens[index] = CommonWebViewWidget(
      params: CommonWebViewWidgetParams(
        url: item.action?.config?.url ?? '',
        title: _getNavLabel(item) ?? '',
        requiredShortCode: item.action?.config?.requiredShortCode,
        onBackPressHandle: () {
          setSelectedIndex(0);
        },
      ),
    );
    state = state.copyWith(screen: updatedScreens);
  }

  final Set<int> _activeWebViewIndices = {};

  void deactivateWebViewScreens({bool clearActive = false}) {
    if (clearActive) _activeWebViewIndices.clear();
    final data = state.bottomNavigationConfigResponseModel?.data;
    final updatedScreens = List<Widget>.generate(state.screen.length, (index) {
      final screen = state.screen[index];
      if (screen is! CommonWebViewWidget) return screen;
      return Container();
    });
    state = state.copyWith(screen: updatedScreens);
  }

  void setSelectedIndex(int index) {
    state = state.copyWith(selectedIndex: index);
  }

  /// Selects the tab whose action target slug matches [slug]. Falls back to
  /// the first tab if no match. Used after sign-in to land the user on a
  /// known tab so its native screen rebuilds with the new auth state.
  void setSelectedIndexBySlug(String slug) {
    final data = state.bottomNavigationConfigResponseModel?.data;
    if (data == null) return;
    final index = data.indexWhere((item) => item.action?.target == slug);
    state = state.copyWith(selectedIndex: index >= 0 ? index : 0);
  }

  void refreshIndexedStack() {
    state = state.copyWith(indexedStackKey: UniqueKey());
  }

  // Replace WebView screens with lightweight placeholders so native WKWebView objects
  // are released before the Flutter engine tears down (prevents crash in
  // WebKitLibraryPigeonInternalFinalizer during force-quit).
  void clearWebViewScreens() {
    deactivateWebViewScreens(clearActive: false);
  }

  // Rebuild screens from cached config without a network request.
  // Re-activates any WebView tabs that were active before the app was paused.
  void restoreScreens() {
    final data = state.bottomNavigationConfigResponseModel?.data;
    if (data == null) return;
    final screens = List.generate(
      data.length,
      (i) => _generateUIObject(item: data[i]),
    );
    state = state.copyWith(screen: screens.cast<Widget>());
    for (final index in _activeWebViewIndices) {
      activateWebViewScreen(index);
    }
  }

  String? _getNavLabel(BottomNavItemModel item) {
    final nickname = item.nickname?.trim();
    if (nickname != null && nickname.isNotEmpty) {
      return nickname;
    }

    return item.label;
  }
}
