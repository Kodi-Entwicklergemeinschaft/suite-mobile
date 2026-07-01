import 'dart:async';

import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:locale/locale.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/core/constant/storage_keys.dart';
import 'package:template_c/core/utils/template_c_colors.dart';
import 'package:template_c/core/widgets/template_c_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/feat/location_onboarding/controller/location_onboarding_controller.dart';
import 'package:template_c/feat/location_onboarding/data/model/response_model/location_response_model.dart';
import 'package:template_c/feat/location_onboarding/presentation/location_onboarding_params.dart';
import 'package:template_c/feat/location_onboarding/state/location_onboarding_state.dart';
import 'package:template_c/feat/open_street_map/controller/map_with_radius_controller.dart';
import 'package:template_c/feat/open_street_map/params/map_with_radius_params.dart';
import 'package:template_c/feat/open_street_map/presentation/location_drop_down.dart';
import 'package:template_c/feat/open_street_map/presentation/map_with_radius.dart';
import 'package:go_router/go_router.dart';

class LocationOnboardingScreen extends BaseStatefulWidget {
  LocationOnboardingParams locationOnboardingParams;
  LocationOnboardingScreen({required this.locationOnboardingParams, super.key});

  @override
  ConsumerState<LocationOnboardingScreen> createState() =>
      _LocationOnboardingScreenState();
}

class _LocationOnboardingScreenState extends BaseStatefulWidgetState<LocationOnboardingScreen> {
  final TextEditingController locationController = TextEditingController();
  final FocusNode locationFocusNode = FocusNode();
  late AppPreferenceManager _preferences;
  Timer? _searchDebounce;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _preferences = ref.read(preferenceManagerProvider);
    locationController.text = _preferences.getStringOrEmpty(
      StorageKeys.selectedLocation,
    );
    locationController.addListener(_onSearchTextChanged);
    super.initState();
  }

  void _onSearchTextChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      final locationState = ref.read(locationOnboardingControllerProvider);
      final query = locationController.text.trim();
      final selectedLabel =
          locationState.selectedLocation?.displayName ??
          locationState.selectedLocation?.name ??
          '';
      if (query.isNotEmpty && query != selectedLabel) {
        ref
            .read(locationOnboardingControllerProvider.notifier)
            .searchLocations(query);
      }
    });
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    locationController.removeListener(_onSearchTextChanged);
    locationController.dispose();
    locationFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LocationOnboardingState>(locationOnboardingControllerProvider, (
      previous,
      next,
    ) {
      if (next.stateConstant == StateConstant.error) {
        AppSnackBar.showError(context, next.errorMessage ?? 'error'.tr);
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final locationState = ref.watch(locationOnboardingControllerProvider);
    final locationControllerNotifier = ref.read(
      locationOnboardingControllerProvider.notifier,
    );
    final selectedLatLng = _selectedLatLngOrDefault(
      locationState.selectedLocation,
    );
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Stack(
        children: [
          //1st layer
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: screenHeight,
            child: Container(
              decoration: BoxDecoration(
                gradient: context.templateColors.splashGradient,
              ),
            ),
          ),

          //2nd layer
          Positioned(
            top: 320.h,
            left: 0,
            right: 0,
            height: screenHeight,
            child: Container(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Theme.of(
                      context,
                    ).scaffoldBackgroundColor.withValues(alpha: 0.9)
                  : Theme.of(context).scaffoldBackgroundColor,
            ),
          ),

          Positioned(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: SafeArea(
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      CommonText(
                        titleText: "back".tr,
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          height: 1,
                          letterSpacing: 0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // SizedBox(height: 24.h),
          SafeArea(
            child: Container(
              padding: EdgeInsets.only(top: 60.h, bottom: 60),
              child: SingleChildScrollView(
                controller: _scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.manual,
                child: Column(
                  children: [
                    // Title
                    Center(
                      child: CommonText(
                        titleText: "select_location".tr,
                        textStyle: context
                            .templateColors
                            .secondaryTextTheme
                            ?.bodyMedium
                            ?.copyWith(
                              fontSize: 48.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                              height: 0.9,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // "Already have an account?" row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CommonText(
                          titleText: "location_onboarding_sub_text".tr,
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 12.sp,
                            height: 1.4,
                            letterSpacing: -0.01,
                          ),
                        ),
                        // GestureDetector(
                        //   onTap: () =>
                        //       context.pushReplacementNamed(RouteConstant.signin.name),
                        //   child: CommonText(
                        //     titleText: "auth_signup_signin".tr,
                        //     textStyle: TextStyle(
                        //       color: Colors.white,
                        //       fontWeight: FontWeight.w600,
                        //       fontSize: 12.sp,
                        //       height: 1.4,
                        //       letterSpacing: -0.01,
                        //       decoration: TextDecoration.underline,
                        //       decorationColor: Colors.white,
                        //       decorationThickness: 1.2,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),

                    SizedBox(height: 27.h),

                    // Form card
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.light
                                  ? const Color(0x14000000)
                                  : Colors.white.withValues(alpha: 0.05),
                              blurRadius: 54,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(
                            color: const Color(0x80EBEBEB),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            // _buildLocationSearchField(context, locationState),
                            SizedBox(
                              height: 48.h,
                              child: LocationDropDown<LocationItemModel>(
                                value: locationState.selectedLocation,
                                items: locationState.locations,
                                isLoading:
                                    locationState.stateConstant ==
                                    StateConstant.loading,
                                onQueryChanged: (query) {
                                  final q = query.trim();
                                  final selectedLabel =
                                      locationState.selectedLocation == null
                                      ? null
                                      : (locationState
                                                .selectedLocation!
                                                .displayName ??
                                            locationState
                                                .selectedLocation!
                                                .name ??
                                            '');
                                  if (selectedLabel != null &&
                                      selectedLabel.isNotEmpty &&
                                      q != selectedLabel) {
                                    locationControllerNotifier.selectLocation(
                                      null,
                                    );
                                  }
                                  locationControllerNotifier.searchLocations(
                                    query,
                                  );
                                },
                                onSelected: (selection) {
                                  locationControllerNotifier.selectLocation(
                                    selection,
                                  );
                                  locationFocusNode.unfocus();
                                },
                                controller: locationController,
                                focusNode: locationFocusNode,
                                itemLabelBuilder: (item) {
                                  return item.displayName ?? item.name ?? '';
                                },
                                hintText: 'choose_your_location'.tr,
                              ),
                            ),
                            12.verticalSpace,
                            OpenStreetMapWithRadius(
                              mapWithRadiusParams: MapWithRadiusParams(
                                userName:
                                    _preferences
                                        .getStringOrEmpty(StorageKeys.userName)
                                        .isNotEmpty
                                    ? _preferences.getStringOrEmpty(
                                        StorageKeys.userName,
                                      )
                                    : null,
                                height: 433.h,
                                width: double.infinity,
                                selectedLatLong: selectedLatLng,
                                initialRadiusKm:
                                    (_preferences.getDouble(
                                          StorageKeys.radius,
                                        ) >
                                        0)
                                    ? _preferences.getDouble(StorageKeys.radius)
                                    : 4,
                                onRadiusChanged: (km) {},
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          //button
          Align(
            alignment: AlignmentGeometry.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                24,
                12,
                24,
                12 + MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: const Border(top: BorderSide(color: Color(0xFFEBEBEB))),
              ),
              child: IgnorePointer(
                ignoring: locationState.isSubmitting,
                child: AppButton(
                   "confirm_location".tr,
                  borderRadius: 100.r,
                  onPressed: () async {
                    if (!locationState.isSubmitting) {
                      _onLocationConfirmed(context);
                    }
                  },
                 
                ),
              ),
            ),
          ),

          if (locationState.isSubmitting)
            Positioned.fill(
              child: AbsorbPointer(absorbing: true, child: TemplateCLoader()),
            ),
        ],
      ),
    );
  }

  void _onLocationConfirmed(BuildContext context) async {
    if (widget.locationOnboardingParams.isSearchFilter) {
      final locationState = ref.read(locationOnboardingControllerProvider);
      final selected = locationState.selectedLocation;
      final radiusKm = ref.read(mapWithRadiusProvider).radiusKm;

      final lat = double.tryParse(
        selected?.lat ?? _preferences.getDouble(StorageKeys.lat).toString(),
      );
      final lon = double.tryParse(
        selected?.lon ?? _preferences.getDouble(StorageKeys.long).toString(),
      );
      final name = selected?.displayName ??
          selected?.name ??
          _preferences.getStringOrEmpty(StorageKeys.selectedLocation);

      if (lat != null && lon != null && context.mounted) {
        context.pop((lat, lon, radiusKm, name));
      }
      return;
    }
    final locationControllerNotifier = ref.read(
      locationOnboardingControllerProvider.notifier,
    );
    final success = await locationControllerNotifier.updateLocationPreference(
      initialLocalityName: _preferences.getStringOrEmpty(
        StorageKeys.selectedLocation,
      ),
      initialLat: _preferences.getDouble(StorageKeys.lat),
      initialLon: _preferences.getDouble(StorageKeys.long),
    );
    if (success && context.mounted) {
      AppSnackBar.showSuccess(context, 'location_saved_successfully'.tr);
      widget.locationOnboardingParams.onConfirm(context);
    }
  }

  LatLng _selectedLatLngOrDefault(LocationItemModel? selected) {
    final lat = double.tryParse(
      selected?.lat ?? _preferences.getDouble(StorageKeys.lat).toString(),
    );
    final lon = double.tryParse(
      selected?.lon ?? _preferences.getDouble(StorageKeys.long).toString(),
    );
    if (lat != null && lon != null) return LatLng(lat, lon);
    return LatLng(49.7913, 9.9534);
  }
}
