import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:locale/localizations.dart';

class HomeSearchBar extends BaseStatefulWidget {
  final String tabSlug;
  const HomeSearchBar({super.key, required this.tabSlug});

  @override
  ConsumerState<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends BaseStatefulWidgetState<HomeSearchBar> {
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
    final fillColor = theme.colorScheme.surface;
    final contentColor = isDark ? Colors.black : Colors.white;
    final hintFontSize = theme.textTheme.bodyMedium?.fontSize ?? 14;
    return SearchBarWidget(
        controller: _controller,
        minHeight: 48,
        maxHeight: 48,
        hintText: 'find_next_experience'.tr,
        hintFontSize: hintFontSize,
        fillColor: fillColor,
        filled: true,
        borderRadius: 12,
        focusColor: Colors.white,
        hintTextColor: contentColor.withValues(alpha: 0.85),
        textColor: contentColor,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 10, right: 6),
          child: CommonIcon(
            icon: Icons.search,
            color: contentColor,
            size: 22,
          ),
        ),
        onDone: () {
          final query = _controller.text.trim();
          if (query.isNotEmpty) {
            _controller.clear();
            context.push('/shell/${widget.tabSlug}/search', extra: query);
          }
        },
    );
  }
}
