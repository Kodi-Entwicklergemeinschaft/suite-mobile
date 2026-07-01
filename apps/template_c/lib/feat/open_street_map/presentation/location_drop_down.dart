import 'dart:async';
import 'dart:math' as math;

import 'package:common_components/common_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:locale/locale.dart';
import 'package:template_c/core/utils/template_c_colors.dart';

class LocationDropDown<T extends Object> extends BaseStatefulWidget {
  final T? value;
  final List<T> items;
  final String hintText;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<T> onSelected;
  final TextEditingController controller;
  final FocusNode focusNode;
  final String Function(T) itemLabelBuilder;
  final IconData? prefixIcon;
  final Duration queryDebounce;
  final bool isLoading;
  final double? menuHeight;

  const LocationDropDown({
    super.key,
    required this.value,
    required this.items,
    required this.onQueryChanged,
    required this.onSelected,
    required this.controller,
    required this.focusNode,
    required this.itemLabelBuilder,
    required this.hintText,
    this.prefixIcon = Icons.location_on_outlined,
    this.queryDebounce = const Duration(milliseconds: 300),
    this.isLoading = false,
    this.menuHeight,
  });

  @override
  ConsumerState<LocationDropDown<T>> createState() =>
      _LocationDropDownState<T>();
}

class _LocationDropDownState<T extends Object>
    extends BaseStatefulWidgetState<LocationDropDown<T>> {
  bool _suppressTextListener = false;
  Timer? _debounce;
  String _lastQueriedText = '';
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _fieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChanged);
    widget.focusNode.addListener(_handleFocusChanged);
    _syncControllerFromValue();
  }

  @override
  void didUpdateWidget(covariant LocationDropDown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleTextChanged);
      widget.controller.addListener(_handleTextChanged);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocusChanged);
      widget.focusNode.addListener(_handleFocusChanged);
    }

    final needsSync =
        oldWidget.value != widget.value ||
        oldWidget.itemLabelBuilder != widget.itemLabelBuilder ||
        oldWidget.items != widget.items ||
        oldWidget.isLoading != widget.isLoading;

    if (needsSync) {
      _syncControllerFromValue();
      if (_overlayEntry != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _overlayEntry?.markNeedsBuild();
        });
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _removeOverlay();
    widget.controller.removeListener(_handleTextChanged);
    widget.focusNode.removeListener(_handleFocusChanged);
    super.dispose();
  }

  void _handleTextChanged() {
    if (_suppressTextListener) return;

    final currentText = widget.controller.text;
    if (currentText == _lastQueriedText) return;

    _debounce?.cancel();
    _debounce = Timer(widget.queryDebounce, () {
      if (!mounted) return;
      _lastQueriedText = widget.controller.text;
      widget.onQueryChanged(widget.controller.text);
      _overlayEntry?.markNeedsBuild();
    });
  }

  void _handleFocusChanged() {
    if (widget.focusNode.hasFocus) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _syncControllerFromValue() {
    final selected = widget.value;
    if (selected == null) return;

    final label = widget.itemLabelBuilder(selected);
    if (widget.controller.text == label) return;

    _suppressTextListener = true;
    widget.controller.value = TextEditingValue(
      text: label,
      selection: TextSelection.collapsed(offset: label.length),
    );
    _suppressTextListener = false;
  }

  void _selectItem(T item) {
    final label = widget.itemLabelBuilder(item);

    _suppressTextListener = true;
    widget.controller.value = TextEditingValue(
      text: label,
      selection: TextSelection.collapsed(offset: label.length),
    );
    _suppressTextListener = false;

    widget.focusNode.unfocus();
    _removeOverlay();
    widget.onSelected(item);
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    _overlayEntry = _buildOverlayEntry();
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _buildOverlayEntry() {
    return OverlayEntry(
      builder: (_) {
        final renderBox =
            _fieldKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox == null) return const SizedBox.shrink();

        final size = renderBox.size;
        final origin = renderBox.localToGlobal(Offset.zero);
        final mq = MediaQuery.of(context);

        final screenHeight = mq.size.height;

        // Use 25% of screen height - works for both with/without keyboard
        final maxHeight = math.max(
          100.0,
          widget.menuHeight ?? (screenHeight * 0.25),
        );
        final width = size.width;

        return Stack(
          children: [
            Positioned.fill(
              child: _OutsideTapDetector(
                fieldOrigin: origin,
                fieldSize: size,
                dropdownOrigin: Offset(origin.dx, origin.dy + size.height + 4),
                dropdownSize: Size(width, maxHeight),
                onTapOutside: widget.focusNode.unfocus,
              ),
            ),

            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 4),
              child: Align(
                alignment: Alignment.topLeft,
                child: Material(
                  color: Colors.transparent,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: width,
                      maxHeight: maxHeight,
                    ),
                    child: _DropdownPanel(
                      isLoading: widget.isLoading,
                      items: widget.items,
                      itemLabelBuilder: widget.itemLabelBuilder,
                      onSelected: _selectItem,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        key: _fieldKey,
        decoration: BoxDecoration(
          color: isLight
              ? const Color(0xFFF8F8F9)
              : TemplateCColors.darkModeBackground,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFEBEBEB)),
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          onTap: _showOverlay,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isLight ? const Color(0xFF151B23) : Colors.white,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: Icon(widget.prefixIcon, size: 20.r),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 12.h,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: widget.controller,
              builder: (_, value, __) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  icon: Icon(Icons.close_rounded, size: 18.r),
                  onPressed: () {
                    _lastQueriedText = '';
                    widget.controller.clear();
                    widget.onQueryChanged('');
                    widget.focusNode.requestFocus();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _OutsideTapDetector extends StatelessWidget {
  final Offset fieldOrigin;
  final Size fieldSize;
  final Offset dropdownOrigin;
  final Size dropdownSize;
  final VoidCallback onTapOutside;

  const _OutsideTapDetector({
    required this.fieldOrigin,
    required this.fieldSize,
    required this.dropdownOrigin,
    required this.dropdownSize,
    required this.onTapOutside,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        final pos = event.position;
        final fieldRect = fieldOrigin & fieldSize;
        final panelRect = dropdownOrigin & dropdownSize;

        // Expand rects slightly for finger-sized tolerance
        final toleratedFieldRect = fieldRect.inflate(8);
        final toleratedPanelRect = panelRect.inflate(8);

        // Only close if tap is outside BOTH the field and the dropdown panel
        if (!toleratedFieldRect.contains(pos) &&
            !toleratedPanelRect.contains(pos)) {
          onTapOutside();
        }
      },
    );
  }
}

class _DropdownPanel<T extends Object> extends StatelessWidget {
  final bool isLoading;
  final List<T> items;
  final String Function(T) itemLabelBuilder;
  final ValueChanged<T> onSelected;

  const _DropdownPanel({
    required this.isLoading,
    required this.items,
    required this.itemLabelBuilder,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final textColor = isLight ? const Color(0xFF151B23) : Colors.white;

    Widget child;

    if (isLoading && items.isEmpty) {
      child = const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    } else if (items.isEmpty) {
      child = Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'no_results_found'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey),
          ),
        ),
      );
    } else {
      child = ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: items.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: 12, endIndent: 12),
        itemBuilder: (_, index) {
          final item = items[index];
          final label = itemLabelBuilder(item);

          return InkWell(
            onTap: () => onSelected(item),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          );
        },
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15.r,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: const Color(0xFFEBEBEB)),
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(12.r), child: child),
    );
  }
}
