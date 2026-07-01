import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/localizations.dart';
import 'package:template_a/core/constant/image.dart';
import 'package:template_a/router/router_provider.dart' show shellConfigProvider;

class TemplateSearchBar extends BaseStatefulWidget {
  final String hintText;
  final VoidCallback? onFilterTap;
  final bool showFilterButton;

  const TemplateSearchBar({
    super.key,
    required this.hintText,
    this.onFilterTap,
    this.showFilterButton = true,
  });

  @override
  ConsumerState<TemplateSearchBar> createState() => _TemplateSearchBarState();
}

class _TemplateSearchBarState extends BaseStatefulWidgetState<TemplateSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = theme.colorScheme.surface;
    final contentColor = isDark ? Colors.black : Colors.white;
    final hintFontSize = theme.textTheme.bodyMedium?.fontSize ?? 14;

    return Row(
      children: [
        Expanded(
          child: SearchBarWidget(
            controller: _controller,
            minHeight: 48,
            maxHeight: 48,
            hintText: widget.hintText,
            hintFontSize: hintFontSize,
            fillColor: bgColor,
            filled: true,
            borderRadius: 12,
            focusColor: Colors.white,
            hintTextColor: contentColor.withValues(alpha: 0.85),
            textColor: contentColor,
            onDone: () {
              final query = _controller.text.trim();
              if (query.isNotEmpty) {
                _controller.clear();
                final tabs = ref.read(shellConfigProvider) ?? [];
                final discoverTab = tabs.firstWhere(
                  (t) => t.action?.target == 'discover',
                  orElse: () => tabs.first,
                );
                final slug = discoverTab.slug ?? 'discover';
                context.go('/shell/$slug/search', extra: query);
              }
            },
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 12, right: 6),
              child: CommonIcon(
                icon: Icons.search,
                color: contentColor,
                size: 22,
              ),
            ),
          ),
        ),
        if (widget.showFilterButton) ...[
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: widget.onFilterTap,
            child: CommonImage(
              imagePath: Images.filterIcon,
              width: 48.w,
              height: 48.h,
              label: 'filter_icon_label'.tr,
            ),
          ),
        ],
      ],
    );
  }
}
