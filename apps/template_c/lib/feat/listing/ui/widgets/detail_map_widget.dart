import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:locale/localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:latlong2/latlong.dart';
import 'package:template_c/feat/open_street_map/presentation/custom_name_map_marker.dart';

class DetailMapWidget extends StatefulWidget {
  final double lat;
  final double lng;
  final String address;

  const DetailMapWidget({
    super.key,
    required this.lat,
    required this.lng,
    required this.address,
  });

  @override
  State<DetailMapWidget> createState() => _DetailMapWidgetState();
}

class _DetailMapWidgetState extends State<DetailMapWidget> {
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final point = LatLng(widget.lat, widget.lng);
    final markerName = widget.address.isNotEmpty ? widget.address : 'Event';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CommonText(
            titleText: 'listing_detail_map_title'.tr,
            textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.sp),
          ),
          if (widget.address.isNotEmpty) ...[
            SizedBox(height: 8.h),
            CommonText(
              titleText: widget.address,
              maxLines: 2,
              textStyle: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                height: 1.71,
              ),
            ),
          ],
          SizedBox(height: 16.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: SizedBox(
              height: 400.h,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: point,
                  initialZoom: 15.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.template_c',
                    keepBuffer: 5,
                    panBuffer: 3,
                    tileBuilder: (context, tileWidget, tile) => AnimatedOpacity(
                      opacity: tile.readyToDisplay ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: tileWidget,
                    ),
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        height: 60.h,
                        width: 51.w,
                        point: point,
                        child: CustomNameMapMarker(
                          name: markerName,
                          backgroundColor: const Color(0xFF2A2A2A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
