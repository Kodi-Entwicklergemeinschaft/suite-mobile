import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:template_a/core/model/action_response_model.dart';
import 'package:template_a/feat/handler/template_a_handler.dart';
import 'package:template_a/feat/home/data/models/home_config.dart';
import 'package:template_a/feat/home/data/models/tile_item.dart';
import 'package:template_a/feat/home/widgets/common_image_text_card.dart';

class ContentSliderV6 extends BaseStatelessWidget {
  final ContentSliderConfig config;

  const ContentSliderV6({super.key, required this.config});

  Color _parseColor(String? hex, Color fallback) {
    if (hex == null || hex.isEmpty) return fallback;
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xff')));
    } catch (_) {
      return fallback;
    }
  }

  void _onItemTap(BuildContext context, WidgetRef ref, TileItem item) {
    final actionJson = <String, dynamic>{
      'type': item.actionType,
      'target': item.actionTarget,
      'config': {
        'url': item.actionUrl,
        'requireLogin': item.requireLogin,
        'requireShortCode': item.requireShortCode,
      },
    };
    final actionModel = ActionResponseModel().fromJson(actionJson);
    ref.read(templateAHandlerProvider).executeAction(context, actionModel, title: item.label);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = config.items ?? [];
    if (items.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (config.label != null && config.label!.isNotEmpty) ...[
            CommonText(
              titleText: config.label!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textStyle: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 10.h),
          ],
          SizedBox(
            height: 160.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (_, index) {
                final item = items[index];
                return CommonImageTextCard(
                  title: item.label ?? '',
                  imageUrl: item.image ?? '',
                  titleColor: _parseColor(item.titleBackgroundColor, theme.colorScheme.secondary),
                  onTap: item.actionType == null ? null : () => _onItemTap(context, ref, item),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
