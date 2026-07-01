import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:common_components/common_components.dart';
import 'package:locale/localizations.dart';
import '../../data/models/listing_model.dart';
import '../../../../core/utils/listing_utils.dart';

/// Event information widget for listing detail
class EventInfoWidget extends StatelessWidget {
  final ListingModel listing;

  const EventInfoWidget({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Check if there's any event info
    final hasEventInfo =
        (listing.eventStart != null && listing.eventStart!.isNotEmpty) ||
        (listing.eventEnd != null && listing.eventEnd!.isNotEmpty) ||
        (listing.address != null && listing.address!.isNotEmpty);

    if (!hasEventInfo) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        CommonText(
          titleText: 'eventInfo'.tr,
          isHeader: true,
          textStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),

        // Address
        if (listing.address != null && listing.address!.isNotEmpty) ...[
          _buildEventRow(
            context: context,
            icon: Icons.location_on,
            label: 'address'.tr,
            value: listing.address!,
          ),
          SizedBox(height: 12.h),
        ],

        // Start Date
        if (listing.eventStart != null && listing.eventStart!.isNotEmpty) ...[
          _buildEventRow(
            context: context,
            icon: Icons.event,
            label: 'startDate'.tr,
            value: formatDateTime(listing.eventStart!),
          ),
          SizedBox(height: 12.h),
        ],

        // End Date
        if (listing.eventEnd != null && listing.eventEnd!.isNotEmpty) ...[
          _buildEventRow(
            context: context,
            icon: Icons.event_available,
            label: 'endDate'.tr,
            value: formatDateTime(listing.eventEnd!),
          ),
          SizedBox(height: 12.h),
        ],
      ],
    );
  }

  Widget _buildEventRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        ExcludeSemantics(
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.1),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
        ),
        SizedBox(width: 12.w),

        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                titleText: label,
                textStyle: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 4.h),
              CommonText(
                titleText: value,
                textStyle: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
