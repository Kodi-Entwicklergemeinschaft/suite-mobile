import 'dart:async';

import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:locale/localizations.dart';
import 'package:template_c/feat/open_street_map/controller/map_with_radius_controller.dart';
import 'package:template_c/feat/open_street_map/params/map_with_radius_params.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:template_c/feat/open_street_map/presentation/custom_name_map_marker.dart';

class OpenStreetMapWithRadius extends BaseStatefulWidget {
  final MapWithRadiusParams mapWithRadiusParams;
  const OpenStreetMapWithRadius({super.key, required this.mapWithRadiusParams});

  @override
  ConsumerState<OpenStreetMapWithRadius> createState() =>
      _OpenStreetMapWithRadiusState();
}

class _OpenStreetMapWithRadiusState
    extends BaseStatefulWidgetState<OpenStreetMapWithRadius>
    with SingleTickerProviderStateMixin {
  MapController mapController = MapController();
  late AnimationController _zoomAnimController;
  late double _initialZoom;
  Timer? sliderDebounce;
  bool _isMapReady = false;


  static const List<int> _radiusSteps = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    20,
    30,
    40,
    50,
    75,
    100,
    150,
    200,
  ];

  static const List<Map<int, double>> _radiusStepsZoom = [
    {1: 12.0},
    {2: 12.0},
    {3: 11.3},
    {4: 11.0},
    {5: 10.8},
    {6: 10.9},
    {7: 10.0},
    {8: 10.0},
    {9: 10.0},
    {10: 10.2},
    {20: 9.5},
    {30: 9.0},
    {40: 8.5},
    {50: 8.0},
    {75: 7.5},
    {100: 7.0},
    {150: 6.5},
    {200: 6.0},
  ];

  @override
  void initState() {
    super.initState();
    _zoomAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _initialZoom = _zoomForRadiusKm(widget.mapWithRadiusParams.initialRadiusKm);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(mapWithRadiusProvider.notifier)
          .setRadiusKm(widget.mapWithRadiusParams.initialRadiusKm);
    });


  }

  @override
  void dispose() {
    sliderDebounce?.cancel();
    _zoomAnimController.dispose();
    super.dispose();
  }


  Animation<double>? _zoomAnimation;

  void _animateToZoom(double targetZoom) {
    if (!_isMapReady) return;
    
    _zoomAnimController.stop();
    final startZoom = mapController.camera.zoom;

    _zoomAnimation = Tween<double>(
      begin: startZoom,
      end: targetZoom,
    ).animate(CurvedAnimation(
      parent: _zoomAnimController,
      curve: Curves.easeInOut,
    ))..addListener(() {
      mapController.move(
        widget.mapWithRadiusParams.selectedLatLong,
        _zoomAnimation!.value,
      );
    });

    _zoomAnimController.reset();
    _zoomAnimController.forward();
  }

  @override
  void didUpdateWidget(covariant OpenStreetMapWithRadius oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldCenter = oldWidget.mapWithRadiusParams.selectedLatLong;
    final newCenter = widget.mapWithRadiusParams.selectedLatLong;
    if (oldCenter != newCenter && _isMapReady) {
      final state = ref.read(mapWithRadiusProvider);
      final zoom = _zoomForRadiusKm(state.radiusKm);
      mapController.move(newCenter, zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.read(mapWithRadiusProvider.notifier);
    final state = ref.watch(mapWithRadiusProvider);
    final borderRadius = 8.r;

    return Container(
      height: widget.mapWithRadiusParams.height,
      width: widget.mapWithRadiusParams.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          fit: StackFit.loose,
          children: [
            Positioned.fill(
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: widget.mapWithRadiusParams.selectedLatLong,
                  initialZoom: _initialZoom,
                  onMapReady: () {
                    setState(() {
                      _isMapReady = true;
                    });
                  },
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.drag | InteractiveFlag.flingAnimation,
                  ),
                ),
                children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.template_c',
                      // Keep tiles from previous zoom visible while new ones load
                      keepBuffer: 5,
                      panBuffer: 3,
                      // Light background while tiles load (instead of gray)
                      tileBuilder: (context, tileWidget, tile) {
                        if (!tile.readyToDisplay) {
                          return Container(
                            color: Colors.grey[200],
                          );
                        }
                        return tileWidget;
                      },
                      errorTileCallback: (tile, error, stackTrace) {
                        debugPrint('Tile error: $error');
                      },
                    ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        height: 60.h,
                        width: 51.w,
                        point: widget.mapWithRadiusParams.selectedLatLong,
                        child: CustomNameMapMarker(
                          name: widget.mapWithRadiusParams.userName?.substring(0,2).toUpperCase() ?? 'GU',
                          backgroundColor: Color.fromRGBO(42, 42, 42, 1),
                        ),
                      ),
                    ],
                  ),
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: widget.mapWithRadiusParams.selectedLatLong,
                        radius: state.radiusKm * 1000,
                        useRadiusInMeter: true,
                        borderColor: Colors.blueAccent,
                        color: Colors.blueAccent.withValues(alpha: 0.1),
                        borderStrokeWidth: 2.w,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- BOTTOM RADIUS CONTROL CARD ---
            Positioned(
              bottom: 12.h,
              left: 18.w,
              right: 18.w,
              child: Container(
                height: 93.h,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  color: Theme.of(context).scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Label Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CommonText(
                          titleText: 'perimeter'.tr,
                          textStyle: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            CommonText(
                              titleText: '${state.radiusKm.toInt()} km',
                              textStyle: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            CommonImage(imagePath: "assets/svg/location.svg",color: Theme.of(context).colorScheme.primary,),
                          ],
                        ),
                      ],
                    ),

                    // Slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4.h,
                        activeTrackColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.2),
                        inactiveTrackColor: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        thumbColor: Theme.of(context).colorScheme.primary,
                        thumbShape: RoundRectSliderThumbShape(
                          aspectRatio: 42.w / 24.h,
                          enabledThumbRadius: 10.h,
                        ),
                        overlayColor: Colors.transparent,
                      ),
                      child: Slider(
                        value: _radiusSteps
                            .indexOf(state.radiusKm.toInt())
                            .toDouble(),
                        padding: EdgeInsets.only(
                          top: 13.h,
                          left: 10.w,
                          right: 10.w,
                        ),
                        min: 0,
                        max: (_radiusSteps.length - 1).toDouble(),
                        divisions: null,
                        onChanged: (value) {
                          final index = value.round();
                          final km = _radiusSteps[index].toDouble();

                          // Update UI immediately
                          controller.setRadiusKm(km);
                          widget.mapWithRadiusParams.onRadiusChanged?.call(km);

                          // Debounce zoom animation
                          sliderDebounce?.cancel();
                          sliderDebounce = Timer(const Duration(milliseconds: 100), () {
                            _animateToZoom(_calculateZoom(index));
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateZoom(int index) {
    return _radiusStepsZoom[index][_radiusSteps[index]]!;
  }

  double _zoomForRadiusKm(double radiusKm) {
    final km = radiusKm.round();
    final index = _radiusSteps.indexOf(km);
    if (index >= 0) return _calculateZoom(index);

    // fallback: find nearest step
    var nearestIndex = 0;
    var nearestDiff = (km - _radiusSteps[0]).abs();
    for (var i = 1; i < _radiusSteps.length; i++) {
      final diff = (km - _radiusSteps[i]).abs();
      if (diff < nearestDiff) {
        nearestDiff = diff;
        nearestIndex = i;
      }
    }
    return _calculateZoom(nearestIndex);
  }
}

class RoundRectSliderThumbShape extends SliderComponentShape {
  final double enabledThumbRadius;
  final double aspectRatio;

  const RoundRectSliderThumbShape({
    this.enabledThumbRadius = 10.0,
    this.aspectRatio = 1.0,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(enabledThumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final paint = Paint()
      ..color = sliderTheme.thumbColor ?? Colors.blue
      ..style = PaintingStyle.fill;

    // This creates the rectangle with rounded corners
    final RRect rect = RRect.fromLTRBR(
      center.dx - (enabledThumbRadius * aspectRatio),
      center.dy - enabledThumbRadius,
      center.dx + (enabledThumbRadius * aspectRatio),
      center.dy + enabledThumbRadius,
      Radius.circular(enabledThumbRadius),
    );

    canvas.drawRRect(rect, paint);
  }
}
