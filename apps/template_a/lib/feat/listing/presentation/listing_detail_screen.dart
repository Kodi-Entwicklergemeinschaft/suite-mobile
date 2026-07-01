import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:locale/localizations.dart';
import 'package:preference_manager/shared_pref.dart';
import 'package:template_a/core/constant/storage_keys.dart';
import 'package:template_a/core/widgets/register_dialog.dart';
import 'package:template_a/feat/fav/controller/favourite_toggle_service.dart';
import 'package:template_a/feat/listing/controller/listing_detail_controller.dart';
import 'package:template_a/router/route_constant.dart';
import '../../../core/utils/listing_utils.dart';
import '../data/models/listing_model.dart';

class ListingDetailScreen extends BaseStatefulWidget {
  final ListingModel listing;
  final String? searchedText;
  final String? categorySlug;

  const ListingDetailScreen({super.key, required this.listing, this.searchedText, this.categorySlug});

  @override
  String get screenName => RouteConstant.listingDetail.name;

  @override
  ConsumerState<ListingDetailScreen> createState() =>
      _ListingDetailScreenState();
}

class _ListingDetailScreenState extends BaseStatefulWidgetState<ListingDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(listingDetailProvider.notifier).initListing(widget.listing);
        final id = widget.listing.id;
        if (id != null && id.isNotEmpty) {
          ref.read(listingDetailProvider.notifier).fetchListing(
            id,
            categorySlug: widget.categorySlug,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(listingDetailProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: CommonIcon(
            icon: Icons.arrow_back_ios_rounded,
            label: 'back_button_label'.tr,
            size: 28,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        elevation: 0,
        title: const CommonText(titleText: ''),
      ),
      body: state.isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: theme.colorScheme.secondary,
              ),
            )
          : _buildDetail(
              context,
              theme,
              state.listing ?? widget.listing,
              widget.searchedText ?? '',
            ),
    );
  }

  Widget _buildDetail(
      BuildContext context, ThemeData theme, ListingModel listing, String searchedText) {
    final seen = <String>{};
    final imageUrls = <String>[];

    // Primary: heroImageUrl, else fall back to categoryFallbackImage
    final primary = (listing.heroImageUrl?.isNotEmpty == true)
        ? listing.heroImageUrl!
        : (listing.categoryFallbackImage?.isNotEmpty == true)
            ? listing.categoryFallbackImage!
            : null;
    if (primary != null && seen.add(primary)) imageUrls.add(primary);

    // Additional media images
    if (listing.media != null) {
      for (final m in listing.media!) {
        if (m.url != null && m.url!.isNotEmpty && seen.add(m.url!)) {
          imageUrls.add(m.url!);
        }
      }
    }

    final images = imageUrls;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (images.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _ImageSection(
                imageUrls: images,
                categoryFallbackImage: listing.categoryFallbackImage,
              ),
            ),
            SizedBox(height: 12.h),
          ],

          // Distance badge
          if (listing.distance != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: _parseTagColor(listing.categoryTitleBackgroundColor) ?? theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: CommonText(
                  titleText: '${(listing.distance! / 1000).toStringAsFixed(2)} km',
                  textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (listing.distance != null) SizedBox(height: 12.h),

          // Title + favourite icon
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: HighlightText(
                    source: listing.title ?? '',
                    query: searchedText,
                    highlightColor: theme.colorScheme.primary.withValues(alpha: 0.4),
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: listing.isFavourite
                      ? 'remove_from_favourites'.tr
                      : 'add_to_favourites'.tr,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _onFavTap(context, listing),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(10.w, 8.h, 8.w, 8.h),
                      child: ExcludeSemantics(
                        child: Icon(
                          listing.isFavourite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 26.sp,
                          color: listing.isFavourite ? Colors.red : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // Address
          if (listing.address != null && listing.address!.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Semantics(
                button: true,
                label: '${'address'.tr}: ${listing.address}',
                hint: 'open_maps'.tr,
                child: GestureDetector(
                  onTap: () => openMapUtil(listing.geoLat!, listing.geoLng!),
                  child: ExcludeSemantics(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on,
                            size: 18.sp, color: theme.colorScheme.onSurface),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: CommonText(
                            titleText: listing.address!,
                            overflow: TextOverflow.visible,
                            textStyle: TextStyle(
                              fontSize: 14.sp,
                              decoration: TextDecoration.underline,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          if (listing.address != null && listing.address!.isNotEmpty)
            SizedBox(height: 12.h),

          // Event date/time — tap to add to device calendar
          if (listing.eventStart != null && listing.eventStart!.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Semantics(
                button: true,
                label: 'add_to_calendar'.tr,
                child: GestureDetector(
                  onTap: () => addEventToDeviceCalendarFromStrings(
                    context: context,
                    eventId: listing.id ?? '',
                    title: listing.title ?? '',
                    eventStart: listing.eventStart,
                    eventEnd: listing.eventEnd,
                    location: listing.address,
                  ),
                  behavior: HitTestBehavior.opaque,
                  child: ExcludeSemantics(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.access_time_filled,
                            size: 18.sp,
                            color: theme.colorScheme.onSurface),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: CommonText(
                            titleText: _formatDateRange(
                                listing.eventStart, listing.eventEnd),
                            overflow: TextOverflow.visible,
                            textStyle: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: _parseTagColor(listing.categoryTitleBackgroundColor) ?? theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        Icon(Icons.calendar_today_outlined,
                            size: 20.sp,
                            color: _parseTagColor(listing.categoryTitleBackgroundColor) ?? theme.colorScheme.primary),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          if (listing.eventStart != null && listing.eventStart!.isNotEmpty)
            SizedBox(height: 12.h),

          // Opening hours
          if (listing.timeIntervals != null &&
              listing.timeIntervals!.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: _OpeningHoursPopup(
                        timeIntervals: listing.timeIntervals!,
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time_filled,
                      size: 18.sp,
                      color: theme.colorScheme.onSurface,
                    ),
                    SizedBox(width: 8.w),
                    CommonText(
                      titleText: _getTodayOpeningHours(
                        context,
                        listing.timeIntervals!,
                      ),
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                        color: _parseTagColor(
                              listing.categoryTitleBackgroundColor,
                            ) ??
                            theme.colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14.sp,
                      color: _parseTagColor(
                            listing.categoryTitleBackgroundColor,
                          ) ??
                          theme.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),

          if (listing.timeIntervals != null &&
              listing.timeIntervals!.isNotEmpty)
            SizedBox(height: 12.h),

          // Tag chips
          if (listing.tags != null && listing.tags!.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: listing.tags!.map((tag) {
                  return _ChipLabel(
                    text: tag.name ?? tag.slug ?? '',
                    color: _parseTagColor(tag.color) ??
                        _parseTagColor(listing.categoryTitleBackgroundColor) ??
                        theme.colorScheme.surfaceContainerHighest,
                    textColor: Colors.white,
                  );
                }).toList(),
              ),
            ),

          if (listing.tags != null && listing.tags!.isNotEmpty)
            SizedBox(height: 12.h),

          // Summary
          if (listing.summary != null && listing.summary!.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _HighlightText(
                text: listing.summary!,
                query: searchedText,
                style: TextStyle(
                  fontSize: 17.sp,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                  color: theme.textTheme.bodySmall?.color,
                ),
                highlightColor: theme.colorScheme.primary.withValues(alpha: 0.4),
              ),
            ),

          if (listing.summary != null && listing.summary!.isNotEmpty)
            SizedBox(height: 8.h),

          // HTML content
          if (listing.content != null && listing.content!.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: HtmlContentWidget(
                htmlContent: listing.content!,
                enableExpand: false,
                fontSize: 17.sp,
                searchQuery: searchedText,
                highlightColor: theme.colorScheme.primary.withValues(alpha: 0.4),
              ),
            ),

          if (listing.content != null && listing.content!.isNotEmpty)
            SizedBox(height: 16.h),

          // Contact details
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              children: [
                if (listing.website != null && listing.website!.isNotEmpty)
                  _ContactItem(
                    icon: Icons.home_rounded,
                    text: listing.website!,
                    onTap: () => launchUrlUtil(listing.website!),
                  ),
                if (listing.sourceUrl != null &&
                    listing.sourceUrl!.isNotEmpty &&
                    (listing.website == null || listing.website!.isEmpty))
                  _ContactItem(
                    icon: Icons.home_rounded,
                    text: listing.sourceUrl!,
                    onTap: () => launchUrlUtil(listing.sourceUrl!),
                  ),
                if (listing.contactEmail != null &&
                    listing.contactEmail!.isNotEmpty)
                  _ContactItem(
                    icon: Icons.email,
                    text: listing.contactEmail!,
                    onTap: () =>
                        launchUrlUtil('mailto:${listing.contactEmail!}'),
                  ),
                if (listing.contactPhone != null &&
                    listing.contactPhone!.isNotEmpty)
                  _ContactItem(
                    icon: Icons.phone,
                    text: listing.contactPhone!,
                    onTap: () => launchUrlUtil('tel:${listing.contactPhone!}'),
                  ),
              ],
            ),
          ),

          SizedBox(height: 5.h),

          // Start navigation
          if (listing.geoLat != null && listing.geoLng != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Semantics(
                button: true,
                label: 'navigation_start'.tr,
                child: GestureDetector(
                  onTap: () => openMapUtil(listing.geoLat!, listing.geoLng!),
                  child: ExcludeSemantics(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on,
                            size: 32.sp, color: theme.colorScheme.onSurface),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: CommonText(
                            titleText: 'navigation_start'.tr,
                            overflow: TextOverflow.visible,
                            textStyle: TextStyle(
                              fontSize: 15.sp,
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  void _onFavTap(BuildContext context, ListingModel listing) {
    final id = listing.id ?? '';
    if (id.isEmpty) return;
    final prefs = ref.read(preferenceManagerProvider);
    final isLoggedIn = prefs.getBool(StorageKeys.authIsLoggedIn);
    final isGuest = prefs.getBool(StorageKeys.authIsGuest);
    final isFullyLoggedIn = isLoggedIn && !isGuest;

    if (!isFullyLoggedIn) {
      showRegisterDialog(context, ref);
    } else {
      ref.read(favouriteToggleServiceProvider).toggleFav(
            id: id,
            newValue: !listing.isFavourite,
          );
    }
  }

  String _getTodayOpeningHours(
      BuildContext context, List<ListingTimeInterval> intervals) {
    final now = DateTime.now();
    final todayWeekday = DateFormat('EEEE', 'en_US').format(now);

    for (final interval in intervals) {
      if (interval.start == null || interval.end == null) continue;

      final freq = (interval.freq ?? '').toLowerCase();

      if (freq == 'none') {
        final start = DateTime.parse(interval.start!).toUtc();
        final end = DateTime.parse(interval.end!).toUtc();
        if (!now.isBefore(start) && !now.isAfter(end)) {
          return 'open_hours'.tr
              .replaceAll('{start}', DateFormat('HH:mm').format(start))
              .replaceAll('{end}', DateFormat('HH:mm').format(end));
        }
      } else {
        if (interval.weekdays?.any((d) => d.toUpperCase() == todayWeekday.toUpperCase()) ?? false) {
          final start = DateTime.parse(interval.start!).toUtc();
          final end = DateTime.parse(interval.end!).toUtc();
          return 'open_hours'.tr
              .replaceAll('{start}', DateFormat('HH:mm').format(start))
              .replaceAll('{end}', DateFormat('HH:mm').format(end));
        }
      }
    }
    return 'closed'.tr;
  }

  String _formatDateRange(String? start, String? end) {
    if (start == null || start.isEmpty) return '';
    try {
      final s = DateTime.parse(start).toLocal();
      final startDate =
          '${s.day.toString().padLeft(2, '0')}.${s.month.toString().padLeft(2, '0')}.${s.year}';
      final startTime =
          '${s.hour.toString().padLeft(2, '0')}:${s.minute.toString().padLeft(2, '0')}';
      if (end == null || end.isEmpty) return '$startDate · $startTime';
      final e = DateTime.parse(end).toLocal();
      final endTime =
          '${e.hour.toString().padLeft(2, '0')}:${e.minute.toString().padLeft(2, '0')}';
      final sameDay = s.year == e.year && s.month == e.month && s.day == e.day;
      if (sameDay) return '$startDate · $startTime – $endTime';
      final endDate =
          '${e.day.toString().padLeft(2, '0')}.${e.month.toString().padLeft(2, '0')}.${e.year}';
      return '$startDate · $startTime To $endDate · $endTime';
    } catch (_) {
      return '';
    }
  }

  Color? _parseTagColor(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (_) {
      return null;
    }
  }
}

// ─── Private widgets (unchanged) ─────────────────────────────────────────────

class _ChipLabel extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;

  const _ChipLabel({required this.text, required this.color, this.textColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: CommonText(
        titleText: text,
        textStyle: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 13.sp,
        ),
      ),
    );
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _ContactItem({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isDark ? Colors.black : Colors.white;
    final avatarBg = isDark ? Colors.white : theme.colorScheme.primary;
    return Semantics(
      button: true,
      label: text,
      child: Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: ExcludeSemantics(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: avatarBg,
                child: Icon(icon, size: 22.sp, color: iconColor),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: CommonText(
                  titleText: text,
                  overflow: TextOverflow.visible,
                  textStyle: TextStyle(
                    fontSize: 15.sp,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _ImageSection extends StatefulWidget {
  final List<String> imageUrls;
  final String? categoryFallbackImage;

  const _ImageSection({required this.imageUrls, this.categoryFallbackImage});

  @override
  State<_ImageSection> createState() => _ImageSectionState();
}

class _ImageSectionState extends State<_ImageSection> {
  final PageController _controller = PageController();
  int _currentIndex = 0;
  late List<String> _images;

  @override
  void initState() {
    super.initState();
    _images = widget.imageUrls.isEmpty ? [''] : widget.imageUrls;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 240.h,
          width: double.infinity,
          child: PageView.builder(
            controller: _controller,
            itemCount: _images.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: CommonImage(
                  imagePath: _images[index],
                  fit: BoxFit.cover,
                  height: 240.h,
                  width: double.infinity,
                  loadingWidget: CommonShimmer(
                    child: Container(
                      height: 240.h,
                      width: double.infinity,
                      color: theme.colorScheme.surface,
                    ),
                  ),
                  errorWidget: (index == 0 &&
                          widget.categoryFallbackImage?.isNotEmpty == true &&
                          _images[0] != widget.categoryFallbackImage)
                      ? (context, error, stack) => CommonImage(
                            imagePath: widget.categoryFallbackImage!,
                            fit: BoxFit.cover,
                            height: 240.h,
                            width: double.infinity,
                          )
                      : null,
                ),
              );
            },
          ),
        ),
        if (_images.length > 1)
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ArrowButton(
                      icon: Icons.arrow_back_ios_rounded,
                      onTap: _currentIndex > 0
                          ? () => _controller.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              )
                          : null,
                      theme: theme,
                    ),
                    _ArrowButton(
                      icon: Icons.arrow_forward_ios_rounded,
                      onTap: _currentIndex < _images.length - 1
                          ? () => _controller.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              )
                          : null,
                      theme: theme,
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (_images.length > 1)
          Positioned(
            bottom: 10.h,
            child: ExcludeSemantics(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _images.length,
                (i) => Container(
                  height: 8.h,
                  width: _currentIndex == i ? 20.w : 8.w,
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    color: _currentIndex == i
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            ),
          ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final ThemeData theme;

  const _ArrowButton(
      {required this.icon, required this.onTap, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isPrev = icon == Icons.arrow_back_ios_rounded;
    return Semantics(
      button: onTap != null,
      label: isPrev ? 'previous_image'.tr : 'next_image'.tr,
      enabled: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: ExcludeSemantics(
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.35),
            ),
            child: Icon(icon, color: Colors.white, size: 18.sp),
          ),
        ),
      ),
    );
  }
}

// ─── Opening Hours Popup ──────────────────────────────────────────────────────

class _OpeningHoursPopup extends StatefulWidget {
  final List<ListingTimeInterval> timeIntervals;

  const _OpeningHoursPopup({required this.timeIntervals});

  @override
  State<_OpeningHoursPopup> createState() => _OpeningHoursPopupState();
}

class _OpeningHoursPopupState extends State<_OpeningHoursPopup> {
  DateTime _weekStart = _startOfWeek(DateTime.now());

  static DateTime _startOfWeek(DateTime date) =>
      date.subtract(Duration(days: date.weekday - 1));

  Map<String, String?> _buildSchedule(DateTime weekStart) {
    final weekEnd = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day + 6,
      23,
      59,
      59,
    );

    final schedule = <String, String?>{
      'Monday': null,
      'Tuesday': null,
      'Wednesday': null,
      'Thursday': null,
      'Friday': null,
      'Saturday': null,
      'Sunday': null,
    };

    for (final interval in widget.timeIntervals) {
      if (interval.start == null || interval.end == null) continue;

      final freq = (interval.freq ?? '').toLowerCase();
      final start = DateTime.parse(interval.start!).toLocal();
      final end = DateTime.parse(interval.end!).toLocal();

      if (freq == 'none') {
        // one-time: show on the day(s) that fall within this week
        if (!start.isAfter(weekEnd) && !end.isBefore(weekStart)) {
          var cursor = start.isAfter(weekStart) ? start : weekStart;
          final rangeEnd = end.isBefore(weekEnd) ? end : weekEnd;
          while (!cursor.isAfter(rangeEnd)) {
            final dayName = DateFormat('EEEE').format(cursor);
            schedule[dayName] =
                '${DateFormat('HH:mm').format(start)} - ${DateFormat('HH:mm').format(end)}';
            cursor = cursor.add(const Duration(days: 1));
          }
        }
      } else {
        // weekly recurring
        final repeatUntil = interval.repeatUntil != null
            ? DateTime.parse(interval.repeatUntil!).toLocal()
            : null;

        for (final weekday in (interval.weekdays ?? [])) {
          final idx = _weekdayIndex(weekday);
          final targetDate = weekStart.add(Duration(days: idx));
          if (repeatUntil != null && targetDate.isAfter(repeatUntil)) continue;

          final s = DateTime(
              targetDate.year, targetDate.month, targetDate.day, start.hour, start.minute);
          final e = DateTime(
              targetDate.year, targetDate.month, targetDate.day, end.hour, end.minute);
          schedule[weekday] =
              '${DateFormat('HH:mm').format(s)} - ${DateFormat('HH:mm').format(e)}';
        }
      }
    }

    return schedule;
  }

  int _weekdayIndex(String day) {
    switch (day.toLowerCase()) {
      case 'monday': return 0;
      case 'tuesday': return 1;
      case 'wednesday': return 2;
      case 'thursday': return 3;
      case 'friday': return 4;
      case 'saturday': return 5;
      case 'sunday': return 6;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final schedule = _buildSchedule(_weekStart);
    final weekEnd = _weekStart.add(const Duration(days: 6));

    return Container(
      padding: EdgeInsets.all(16.r),
      color: theme.scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Week navigator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _NavButton(
                icon: Icons.arrow_back,
                onTap: () => setState(() {
                  _weekStart = _weekStart.subtract(const Duration(days: 7));
                }),
                theme: theme,
              ),
              Flexible(
                child: CommonText(
                  titleText:
                      '${DateFormat('dd.MM.yyyy').format(_weekStart)} - '
                      '${DateFormat('dd.MM.yyyy').format(weekEnd)}',
                  textStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _NavButton(
                icon: Icons.arrow_forward,
                onTap: () => setState(() {
                  _weekStart = _weekStart.add(const Duration(days: 7));
                }),
                theme: theme,
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Header row
          Row(
            children: [
              Expanded(
                child: CommonText(
                  titleText: 'weekday'.tr,
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              Expanded(
                child: CommonText(
                  titleText: 'time'.tr,
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // Day rows
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: schedule.length,
              itemBuilder: (context, index) {
                final day = schedule.keys.toList()[index];
                final time = schedule[day];
                final isClosed = time == null;

                return Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: CommonText(
                          titleText: day.toLowerCase().tr,
                          textStyle: TextStyle(fontSize: 15.sp),
                        ),
                      ),
                      Expanded(
                        child: CommonText(
                          titleText: isClosed ? 'closed'.tr : time,
                          textStyle: TextStyle(
                            fontSize: 15.sp,
                            color: isClosed ? Colors.red : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final ThemeData theme;

  const _NavButton(
      {required this.icon, required this.onTap, required this.theme});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.focusColor,
        ),
        child: Icon(icon, size: 20.sp),
      ),
    );
  }
}

class _HighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle? style;
  final Color highlightColor;

  const _HighlightText({
    required this.text,
    required this.query,
    this.style,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(text, style: style, overflow: TextOverflow.visible);
    }
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;
    int index = lowerText.indexOf(lowerQuery);
    while (index != -1) {
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: TextStyle(backgroundColor: highlightColor),
      ));
      start = index + query.length;
      index = lowerText.indexOf(lowerQuery, start);
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }
    return RichText(
      text: TextSpan(style: style, children: spans),
      overflow: TextOverflow.visible,
    );
  }
}
