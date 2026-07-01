import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:common_components/common_components.dart';
import 'package:locale/localizations.dart';
import '../../data/models/listing_model.dart';
import '../../../../core/utils/listing_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Contact information widget for listing detail
class ContactInfoWidget extends BaseStatefulWidget {
  final ListingModel listing;

  const ContactInfoWidget({super.key, required this.listing});

  @override
  ConsumerState<ContactInfoWidget> createState() => _ContactInfoWidgetState();
}

class _ContactInfoWidgetState
    extends BaseStatefulWidgetState<ContactInfoWidget> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final effectiveWebsite = widget.listing.website?.isNotEmpty == true
        ? widget.listing.website
        : widget.listing.sourceUrl;

    // Check if there's any contact info
    final hasContactInfo =
        (widget.listing.contactPhone?.isNotEmpty == true) ||
        (widget.listing.contactEmail?.isNotEmpty == true) ||
        (effectiveWebsite?.isNotEmpty == true);

    if (!hasContactInfo) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        CommonText(
          titleText: 'contactInfo'.tr,
          isHeader: true,
          textStyle: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),

        // Phone
        if (widget.listing.contactPhone != null &&
            widget.listing.contactPhone!.isNotEmpty) ...[
          _buildContactRow(
            context: context,
            icon: Icons.phone,
            label: 'phone'.tr,
            value: widget.listing.contactPhone!,
            onTap: () => launchUrlUtil('tel:${widget.listing.contactPhone!}'),
          ),
          SizedBox(height: 12.h),
        ],

        // Email
        if (widget.listing.contactEmail != null &&
            widget.listing.contactEmail!.isNotEmpty) ...[
          _buildContactRow(
            context: context,
            icon: Icons.email,
            label: 'email'.tr,
            value: widget.listing.contactEmail!,
            onTap: () =>
                launchUrlUtil('mailto:${widget.listing.contactEmail!}'),
          ),
          SizedBox(height: 12.h),
        ],

        // Website
        if (effectiveWebsite != null && effectiveWebsite.isNotEmpty) ...[
          _buildContactRow(
            context: context,
            icon: Icons.language,
            label: 'website'.tr,
            value: effectiveWebsite,
            onTap: () => _openWebsite(context, effectiveWebsite),
          ),
          SizedBox(height: 12.h),
        ],
      ],
    );
  }

  void _openWebsite(BuildContext context, String url) {
    final webViewHandler = ref.read(webViewHandlerProvider);
    webViewHandler.executeAction(
      context,
      CommonWebViewWidgetParams(url: url, title: '', showAppBar: true),
    );
  }

  Widget _buildContactRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return Semantics(
      button: onTap != null,
      label: '$label, $value',
      child: GestureDetector(
        onTap: onTap,
        child: ExcludeSemantics(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                ),
                child: Icon(icon, color: theme.colorScheme.primary, size: 20),
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
                        color: onTap != null
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                      maxLines: 2,
                    ),
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
