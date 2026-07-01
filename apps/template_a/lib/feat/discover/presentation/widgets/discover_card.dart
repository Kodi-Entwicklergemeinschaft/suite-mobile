import 'package:flutter/material.dart';
import 'package:locale/localizations.dart';
import 'package:template_a/core/widgets/app_image_card.dart';

/// Discover-screen preset of [AppImageCard].
///
/// Applies discover-specific defaults (bottom gradient, icon-capable tag,
/// title + subtitle, pronounced shadow). For the sub-service card, use
/// [AppImageCard] directly with its own overrides.
class DiscoverCard extends StatelessWidget {
  final String imageUrl;
  final double? height;
  final String? tagText;
  final Color? tagBgColor;
  final IconData? tagIcon;
  final String? tagIconUrl;
  final String? titleText;
  final Color? titleBgColor;
  final String? subtitleText;
  final double tagFontSize;
  final VoidCallback? onTap;

  const DiscoverCard({
    super.key,
    required this.imageUrl,
    this.height,
    this.tagText,
    this.tagBgColor,
    this.tagIcon,
    this.tagIconUrl,
    this.titleText,
    this.titleBgColor,
    this.subtitleText,
    this.tagFontSize = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardLabel = tagText ?? titleText ?? '';

    return Semantics(
      label: 'discover_item_label'.tr.replaceAll('{itemName}', cardLabel),
      button: true,
      child: AppImageCard(
        imageUrl: imageUrl,
        height: height,
        onTap: onTap,
        shadowOpacity: 0.15,
        shadowOffset: const Offset(0, 4),
        tagText: tagText,
        tagBgColor: tagBgColor,
        tagIcon: tagIcon,
        tagIconUrl: tagIconUrl,
        tagFontSize: tagFontSize,
        titleText: titleText,
        titleBgColor: titleBgColor,
        subtitleText: subtitleText,
      ),
    );
  }
}
