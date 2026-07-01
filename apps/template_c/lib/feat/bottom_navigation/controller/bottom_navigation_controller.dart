import 'dart:developer';

import 'package:common_components/common_components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locale/localizations.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_c/core/constant/action_constant.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/core/constant/storage_keys.dart';
import 'package:template_c/core/providers/auth_state_provider.dart';
import 'package:template_c/feat/bottom_navigation/data/model/request/bottom_navigation_request_model.dart';
import 'package:template_c/feat/bottom_navigation/data/model/response/bottom_navigation_response_model.dart';
import 'package:template_c/feat/bottom_navigation/domain/usecase/bottom_navigation_usecase.dart';
import 'package:template_c/feat/bottom_navigation/model/bottom_nav_item_model.dart';
import 'package:template_c/feat/bottom_navigation/presentation/auth_required_nav_screen.dart';
import 'package:template_c/feat/bottom_navigation/registry/template_c_registry.dart';
import 'package:template_c/feat/bottom_navigation/state/bottom_navigation_state.dart';
import 'package:template_c/feat/handler/template_c_handler.dart';
import 'package:template_c/feat/listing/data/models/listing_filter_model.dart';
import 'package:template_c/feat/home/widgets/listing/listing_family_key.dart';
import 'package:template_c/feat/listing/params/listing_screen_params.dart';
import 'package:template_c/feat/listing/ui/listing_screen.dart';
import 'package:template_c/feat/sub_service/presentation/sub_service_screen.dart';
import 'package:template_c/feat/linkhub_service/linkhub_service_model.dart';
import 'package:network/network.dart';
import 'package:template_c/feat/auth/domain/usecases/get_me_usecase.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:template_c/feat/bottom_navigation/sync/data/model/fav_sync_offline_request_model.dart';
import 'package:template_c/feat/bottom_navigation/sync/domain/usecase/sync_fav_offline_use_case.dart';
import 'package:template_c/feat/fav/constant/sort_by.dart';
import 'package:template_c/feat/fav/data/model/request_model/get_fav_request_model.dart';
import 'package:template_c/feat/fav/domain/usecase/get_fav_use_case.dart';
import 'package:template_c/feat/profile/controllers/profile_controller.dart';
import 'package:template_c/offline/core/box_constant.dart';
import 'package:template_c/offline/fav_offline/controller/fav_offline_controller.dart';
import 'package:preference_manager/hive_service.dart';
import 'package:template_c/core/feature_flags.dart';

final bottomNavigationControllerProvider =
    NotifierProvider.autoDispose<
      BottomNavigationController,
      BottomNavigationState
    >(() => BottomNavigationController());

class BottomNavigationController extends Notifier<BottomNavigationState> {
  /// Family keys of all active bottom-nav listing tabs, so
  /// FavouriteToggleService can broadcast fav changes to them.
  static final activeListingKeys = <String>{};
  BottomNavigationUsecase get bottomNavigationUseCase =>
      ref.read(bottomNavigationUseCaseProvider);

  late GetMeUseCase _getMeUseCase;
  FavOfflineController get _favOfflineController =>
      ref.read(favOfflineControllerProvider.notifier);

  SyncFavOfflineUseCase get _syncFavOfflineUseCase =>
      ref.read(syncFavOfflineUseCaseProvider);

  GetFavUseCase get _getFavUseCase => ref.read(getFavUseCaseProvider);

  @override
  BottomNavigationState build() {
    _getMeUseCase = ref.read(getMeUseCaseProvider);

    return BottomNavigationState(0, [], [], StateConstant.loading);
  }

  bool get _isLiveMode {
    final base = dotenv.maybeGet('BASE_URL') ?? '';
    return base.isNotEmpty && !base.startsWith('YOUR_');
  }

  Future<void> fetchMe() async {
    state = state.copyWith(stateConstant: StateConstant.loading);

    if (!_isLiveMode) {
      await getBottomConfig();
      state = state.copyWith(stateConstant: StateConstant.success);
      return;
    }

    try {
      final result = await _getMeUseCase.call(NoParams());
      result.fold((error) => debugPrint('fetchMe error: $error'), (
        response,
      ) async {
        final data = response.data;
        if (data == null) return;

        final pref = ref.read(preferenceManagerProvider);
        await Future.wait([
          pref.saveDouble(StorageKeys.lat, data.latitude ?? 0.0),
          pref.saveDouble(StorageKeys.long, data.longitude ?? 0.0),
          pref.saveDouble(StorageKeys.radius, data.radius ?? 0.0),
          pref.saveString(
            StorageKeys.selectedLocation,
            data.localityName ?? '',
          ),
        ]);
        await syncFavOfflineData();
        await storeFavInHive();
        await getBottomConfig();

        ref.read(profileControllerProvider.notifier).getProfile();
        state = state.copyWith(stateConstant: StateConstant.success);
      });
    } catch (e) {
      log("Error loading fetch me : $e");
      state = state.copyWith(stateConstant: StateConstant.error);
    }
  }

  getBottomConfig() async {
    try {
      BottomNavigationRequestModel params = BottomNavigationRequestModel();

      final result = await bottomNavigationUseCase.call(params);

      result.fold(
        (l) {
          debugPrint("fold exception while getting bottom config : $l");
          state = state.copyWith(stateConstant: StateConstant.error);
        },
        (r) {
          final res = r as BottomNavigationResponseModel;

          if (res.data != null) {
            _cachedNavData = res.data!;

            final navItems = res.data!.map((value) {
              return BottomNavItemModel(
                label: _getNavLabel(value),
                iconUrl: value.iconUrl,
              );
            }).toList();

            final screenList = List.generate(res.data!.length, (index) {
              final item = res.data![index];
              if (item.action?.type == ActionConstant.urlWebview.name &&
                  item.action?.config?.requireLogin != true) {
                _activeWebViewIndices.add(index);
              }
              return _generateUIObject(navigationData: item);
            });

            state = state.copyWith(
              listOfNavItems: navItems,
              screenList: screenList,
            );
            _cacheNavConfig(res.data!);
          } else {
            state = state.copyWith(listOfNavItems: [], screenList: []);
          }
        },
      );
    } catch (e) {
      debugPrint("exception while getting bottom config : $e");
      rethrow;
    }
  }

  Future<void> _cacheNavConfig(List<NavigationData> items) async {
    try {
      final serialized = items
          .map(
            (e) => {
              'slug': e.action?.target,
              'label': e.label,
              'iconUrl': e.iconUrl,
            },
          )
          .toList();
      await HiveService.instance.put<dynamic>(
        BoxKey.templateC.name,
        BoxItemKeyConstant.bottomNavConfigKey.name,
        serialized,
      );
      debugPrint('_cacheNavConfig: cached ${serialized.length} nav items');
    } catch (e) {
      debugPrint('_cacheNavConfig error: $e');
    }
  }

  updateSelectedIndex(int index) {
    state = state.copyWith(selectedIndex: index);
  }

  void onNavItemTap(BuildContext context, int index) {
    final data = state.screenList;
    if (index < 0 || index >= data.length) return;

    final navData = _navDataAt(index);
    if (navData == null) return;

    final actionType = navData.action?.type ?? '';

    if (actionType == ActionConstant.urlBrowser.name) {
      ref
          .read(templateCHandlerProvider)
          .executeAction(
            context,
            navData.action!,
            title: _getNavLabel(navData),
          );
      return;
    }

    if (actionType == ActionConstant.urlWebview.name) {
      final requireLogin = navData.action?.config?.requireLogin == true;
      final isLoggedIn = ref.read(authStateProvider);
      if (!requireLogin || isLoggedIn) {
        activateWebViewScreen(index);
      }
      updateSelectedIndex(index);
      return;
    }

    updateSelectedIndex(index);
  }

  NavigationData? _navDataAt(int index) {
    final data = _cachedNavData;
    if (data == null || index >= data.length) return null;
    return data[index];
  }

  List<NavigationData>? _cachedNavData;

  String? _getNavLabel(NavigationData item) {
    final nickname = item.nickname?.trim();
    if (nickname != null && nickname.isNotEmpty) {
      return nickname;
    }
    return item.label;
  }

  Widget _generateUIObject({required NavigationData navigationData}) {
    final slugName = navigationData.action?.target ?? '';
    final actionType = navigationData.action?.type ?? '';

    if (actionType == ActionConstant.urlBrowser.name) {
      return Container();
    }

    if (actionType == ActionConstant.urlWebview.name) {
      if (navigationData.action?.config?.requireLogin == true) {
        final isLoggedIn = ref.read(authStateProvider);
        if (!isLoggedIn) {
          return const AuthRequiredNavScreen();
        }
      }
      return _buildWebViewWidget(navigationData);
    }

    if (actionType == ActionConstant.category.name ||
        slugName == ActionConstant.category.name) {
      final config = navigationData.action?.config;
      final subcategorySlug = config?.subcategory;
      final categorySlug = config?.category ?? navigationData.slug ?? '';
      final familyKey = subcategorySlug ?? categorySlug;
      activeListingKeys.add(ListingFamilyKey.seeAll(familyKey));
      return ListingScreen(
        params: ListingScreenParams(
          familyKey: ListingFamilyKey.seeAll(familyKey),
          screenTitle: _getNavLabel(navigationData) ?? '',
          initialFilter: ListingFilterModel(
            categorySlug: subcategorySlug == null && categorySlug.isNotEmpty
                ? categorySlug
                : null,
            subcategorySlug: subcategorySlug?.isNotEmpty == true
                ? subcategorySlug
                : null,
            page: 1,
            limit: 20,
          ),
        ),
      );
    }

    if (actionType == ActionConstant.serviceHub.name) {
      return SubServiceScreen(
        params: SubServiceScreenParams(
          title: _getNavLabel(navigationData) ?? '',
          services: navigationData.action?.config?.children ?? [],
        ),
      );
    }

    if (actionType == ActionConstant.linkHub.name) {
      final action = navigationData.action;
      final service = LinkhubServiceModel.fromAction(
        id: navigationData.slug ?? '',
        title: _getNavLabel(navigationData) ?? '',
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

    if (templateCRegistry.containsKey(slugName)) {
      return templateCRegistry[slugName];
    }

    return Center(
      child: CommonText(
        titleText: 'comming_soon'.tr,
        textStyle: TextStyle(fontSize: 30.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildWebViewWidget(NavigationData navigationData) {
    return CommonWebViewWidget(
      params: CommonWebViewWidgetParams(
        url: navigationData.action?.config?.url ?? '',
        title: _getNavLabel(navigationData) ?? '',
        requiredShortCode: navigationData.action?.config?.requiredShortCode,
        onBackPressHandle: () => updateSelectedIndex(0),
      ),
    );
  }

  final Set<int> _activeWebViewIndices = {};

  void activateWebViewScreen(int index) {
    final data = _cachedNavData;
    if (data == null || index >= data.length) return;

    final navData = data[index];
    if (navData.action?.type != ActionConstant.urlWebview.name) return;

    // Skip if already a live webview to preserve scroll/history.
    if (index < state.screenList.length &&
        state.screenList[index] is CommonWebViewWidget) {
      _activeWebViewIndices.add(index);
      return;
    }

    _activeWebViewIndices.add(index);
    final updatedScreens = List<Widget>.from(state.screenList);
    updatedScreens[index] = _buildWebViewWidget(navData);
    state = state.copyWith(screenList: updatedScreens);
  }

  void deactivateWebViewScreens({bool clearActive = false}) {
    if (clearActive) _activeWebViewIndices.clear();
    final updatedScreens = List<Widget>.generate(state.screenList.length, (i) {
      final screen = state.screenList[i];
      if (screen is! CommonWebViewWidget) return screen;
      return Container();
    });
    state = state.copyWith(screenList: updatedScreens);
  }

  void clearWebViewScreens() {
    deactivateWebViewScreens(clearActive: false);
  }

  void restoreScreens() {
    final data = _cachedNavData;
    if (data == null) return;
    final screens = List.generate(
      data.length,
      (i) => _generateUIObject(navigationData: data[i]),
    );
    state = state.copyWith(screenList: screens);
    for (final index in _activeWebViewIndices) {
      activateWebViewScreen(index);
    }
  }

  syncFavOfflineData() async {
    try {
      final unselectedFavIds = await _favOfflineController
          .getUnselectedFavIds();

      await _favOfflineController.clearUnselectedFavList();
      await _favOfflineController.clearAllFavItems();
      if (unselectedFavIds.isEmpty) {
        debugPrint('syncFavOfflineData: nothing to sync');
      } else {
        final request = FavSyncOfflineRequestModel(
          removeFavorites: unselectedFavIds,
        );

        final result = await _syncFavOfflineUseCase.call(request);

        result.fold(
          (l) {
            debugPrint('syncFavOfflineData error: $l');
          },
          (r) async {
            debugPrint('syncFavOfflineData success: ${r.message}');
          },
        );
      }
    } catch (error) {
      debugPrint('syncFavOfflineData exception : $error');
    }
  }

  storeFavInHive() async {
    try {
      GetFavRequestModel getFavRequestModel = GetFavRequestModel(
        eventStartFrom: DateTime.now(),
        limit: 30,
      );
      final result = await _getFavUseCase.call(getFavRequestModel);

      result.fold(
        (l) {
          debugPrint('storeFavInHive fold error: $l');
        },
        (r) async {
          if (r.items != null && r.items!.isNotEmpty) {
            for (final item in r.items!) {
              await _favOfflineController.addFavItem(item);
            }
          }
        },
      );
    } catch (error) {
      debugPrint('storeFavInHive exception : $error');
    }
  }
}
