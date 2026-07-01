import 'package:common_components/src/widgets/common_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Item model for MultiSelectDropdown
class MultiSelectItem<T> {
  const MultiSelectItem({required this.value, required this.label});

  final T value;
  final String label;
}

/// Decoration for the main input container
class MultiSelectDecoration {
  const MultiSelectDecoration({
    this.border,
    this.borderRadius,
    this.focusedBorder,
    this.fillColor,
    this.contentPadding,
    this.height,
  });

  final BorderSide? border;
  final BorderRadius? borderRadius;
  final BorderSide? focusedBorder;
  final Color? fillColor;
  final EdgeInsets? contentPadding;
  final double? height;
}

/// Decoration for chips
class MultiSelectChipDecoration {
  const MultiSelectChipDecoration({
    this.backgroundColor,
    this.deleteIconColor,
    this.labelStyle,
    this.borderRadius,
    this.padding,
    this.spacing,
    this.runSpacing,
  });

  final Color? backgroundColor;
  final Color? deleteIconColor;
  final TextStyle? labelStyle;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final double? spacing;
  final double? runSpacing;
}

/// Decoration for dropdown menu
class MultiSelectDropdownDecoration {
  const MultiSelectDropdownDecoration({
    this.elevation,
    this.borderRadius,
    this.backgroundColor,
    this.maxHeight,
  });

  final double? elevation;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final double? maxHeight;
}

class MultiSelectDropdown<T> extends StatefulWidget {
  const MultiSelectDropdown({
    super.key,
    required this.items,
    this.onSelectionChanged,
    required this.hint,
    required this.searchHint,
    required this.noItemsFoundText,
    this.width = 250,
    this.maxSelection,
    this.decoration,
    this.chipDecoration,
    this.dropdownDecoration,
    this.initialValues,
    this.maxVisibleChips = 3,
  });

  final List<MultiSelectItem<T>> items;
  final ValueChanged<List<T>>? onSelectionChanged;

  /// Placeholder text when no items selected
  final String hint;

  /// Placeholder text when items are selected (for search)
  final String searchHint;

  /// Text shown when search returns no results
  final String noItemsFoundText;
  final double width;
  final int? maxSelection;
  final MultiSelectDecoration? decoration;
  final MultiSelectChipDecoration? chipDecoration;
  final MultiSelectDropdownDecoration? dropdownDecoration;
  final List<T>? initialValues;

  /// Max visible chips before showing "+N more" (default 3)
  final int maxVisibleChips;

  @override
  State<MultiSelectDropdown<T>> createState() => _MultiSelectDropdownState<T>();
}

class _MultiSelectDropdownState<T> extends State<MultiSelectDropdown<T>> {
  final Set<T> _selectedValues = {};
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final Object _tapRegionGroupId = Object();
  final GlobalKey _anchorKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  String _searchQuery = '';
  bool _isOpen = false;

  List<MultiSelectItem<T>> get _filteredItems {
    if (_searchQuery.isEmpty) {
      return widget.items;
    }
    return widget.items
        .where(
          (item) =>
              item.label.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  bool get _canSelectMore {
    if (widget.maxSelection == null) return true;
    return _selectedValues.length < widget.maxSelection!;
  }

  String _getLabelForValue(T value) {
    final item = widget.items.cast<MultiSelectItem<T>?>().firstWhere(
          (item) => item!.value == value,
          orElse: () => null,
        );
    return item?.label ?? value.toString();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialValues != null) {
      _selectedValues.addAll(widget.initialValues!);
    }
  }

  @override
  void didUpdateWidget(covariant MultiSelectDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _selectedValues.removeWhere(
        (value) => !widget.items.any((item) => item.value == value),
      );
    }
    final oldInit = oldWidget.initialValues;
    final newInit = widget.initialValues;
    final changed = oldInit?.length != newInit?.length ||
        (newInit?.any((v) => !(oldInit?.contains(v) ?? false)) ?? false);
    if (changed) {
      _selectedValues.clear();
      if (newInit != null) {
        _selectedValues.addAll(newInit);
      }
    }
  }

  void _showOverlay() {
    if (_isOpen) return;
    _isOpen = true;
    _overlayEntry?.remove();

    final renderBox =
        _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    double? top, bottom;
    double availableHeight = widget.dropdownDecoration?.maxHeight ?? 200;

    double left = 0;
    if (renderBox != null) {
      final offset = renderBox.localToGlobal(Offset.zero);
      left = offset.dx;
      final screenHeight = MediaQuery.of(context).size.height;
      final widgetTop = offset.dy;
      final widgetBottom = offset.dy + renderBox.size.height;
      final spaceBelow = screenHeight - widgetBottom - 8;
      final spaceAbove = widgetTop - 8;
      const kSearchBarHeight = 60.0;

      if (spaceBelow >= (availableHeight + kSearchBarHeight) ||
          spaceBelow >= spaceAbove) {
        // open downward — clamp to available space
        top = widgetBottom + 4;
        availableHeight =
            (spaceBelow - kSearchBarHeight).clamp(80, availableHeight);
      } else {
        // open upward — clamp to available space
        bottom = screenHeight - widgetTop + 4;
        availableHeight =
            (spaceAbove - kSearchBarHeight).clamp(80, availableHeight);
      }
    }

    _overlayEntry = _createOverlayEntry(
      top: top,
      bottom: bottom,
      left: left,
      availableHeight: availableHeight,
    );
    Overlay.of(context).insert(_overlayEntry!);
    setState(() {});
  }

  void _hideOverlay() {
    if (!_isOpen) return;
    _isOpen = false;
    _searchController.clear();
    _searchQuery = '';
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {});
  }

  bool _updatePending = false;

  void _updateOverlay() {
    if (!_isOpen || _updatePending) return;
    _updatePending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updatePending = false;
      if (!mounted || !_isOpen) return;
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isOpen = false;
      _showOverlay();
    });
  }

  void _toggleItem(MultiSelectItem<T> item) {
    setState(() {
      if (_selectedValues.contains(item.value)) {
        _selectedValues.remove(item.value);
      } else if (_canSelectMore) {
        _selectedValues.add(item.value);
        _searchController.clear();
        _searchQuery = '';
      }
    });
    widget.onSelectionChanged?.call(_selectedValues.toList());
    if (widget.maxSelection == 1 && _selectedValues.isNotEmpty) {
      _hideOverlay();
    } else {
      _updateOverlay();
    }
  }

  void _removeValue(T value) {
    setState(() {
      _selectedValues.remove(value);
    });
    widget.onSelectionChanged?.call(_selectedValues.toList());
    _updateOverlay();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isOpen) _overlayEntry?.markNeedsBuild();
    });
  }

  BorderRadius get _borderRadius =>
      widget.decoration?.borderRadius ?? BorderRadius.circular(4);

  OverlayEntry _createOverlayEntry({
    double? top,
    double? bottom,
    double left = 0,
    required double availableHeight,
  }) {
    final dropdownDecor = widget.dropdownDecoration;
    return OverlayEntry(
      builder: (context) {
        final items = _filteredItems;
        return Positioned(
          top: top,
          bottom: bottom,
          left: left,
          width: widget.width,
          child: TapRegion(
            groupId: _tapRegionGroupId,
            child: Material(
              elevation: dropdownDecor?.elevation ?? 4,
              borderRadius: dropdownDecor?.borderRadius ?? _borderRadius,
              color: dropdownDecor?.backgroundColor,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommonTextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: widget.searchHint,
                      hintStyle: TextStyle(fontSize: 14.sp),
                      prefixIcon: Icon(Icons.search, size: 18.w),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.3),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: availableHeight),
                    child: items.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              widget.noItemsFoundText,
                              style: const TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            padding: EdgeInsets.zero,
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final isSelected =
                                  _selectedValues.contains(item.value);
                              final isDisabled = !isSelected && !_canSelectMore;
                              return InkWell(
                                onTap:
                                    isDisabled ? null : () => _toggleItem(item),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      if (widget.maxSelection != 1)
                                        Checkbox(
                                          value: isSelected,
                                          onChanged: isDisabled
                                              ? null
                                              : (_) => _toggleItem(item),
                                        ),
                                      Expanded(
                                        child: Text(
                                          item.label,
                                          style: TextStyle(
                                            color:
                                                isDisabled ? Colors.grey : null,
                                          ),
                                        ),
                                      ),
                                      if (widget.maxSelection == 1 && isSelected)
                                        Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _hideOverlay();
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final decor = widget.decoration;
    final chipDecor = widget.chipDecoration;
    final chipSpacing = chipDecor?.spacing ?? 6;
    final chipRunSpacing = chipDecor?.runSpacing ?? 6;
    final contentPadding = decor?.contentPadding ?? const EdgeInsets.all(6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TapRegion(
          groupId: _tapRegionGroupId,
          onTapOutside: (_) => _hideOverlay(),
          child: Container(
            key: _anchorKey,
              width: widget.width,
              decoration: BoxDecoration(
                border: Border.fromBorderSide(
                  decor?.border ?? const BorderSide(color: Colors.grey),
                ),
                borderRadius: _borderRadius,
                color: decor?.fillColor,
              ),
              constraints: BoxConstraints(
                minHeight: decor?.height ?? 41.h,
              ),
              padding: contentPadding,
              child: GestureDetector(
                onTap: () {
                  if (_isOpen) {
                    _hideOverlay();
                  } else {
                    _showOverlay();
                    _focusNode.requestFocus();
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Expanded(
                      child: _selectedValues.isEmpty
                          ? Text(
                              widget.hint,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey,
                              ),
                            )
                          : widget.maxSelection == 1
                              ? Text(
                                  _getLabelForValue(_selectedValues.first),
                                  style: TextStyle(fontSize: 14.sp),
                                  overflow: TextOverflow.ellipsis,
                                )
                              : Wrap(
                                  spacing: chipSpacing,
                                  runSpacing: chipRunSpacing,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    ..._selectedValues
                                        .take(widget.maxVisibleChips)
                                        .map((value) {
                                      return InputChip(
                                        label: Text(
                                          _getLabelForValue(value),
                                          style: chipDecor?.labelStyle ??
                                              TextStyle(fontSize: 12.sp),
                                        ),
                                        backgroundColor:
                                            chipDecor?.backgroundColor,
                                        deleteIconColor:
                                            chipDecor?.deleteIconColor,
                                        deleteIcon:
                                            Icon(Icons.close, size: 14.w),
                                        onDeleted: () => _removeValue(value),
                                        side: BorderSide(
                                            color: Colors.transparent),
                                        visualDensity: VisualDensity.compact,
                                        padding: chipDecor?.padding ??
                                            EdgeInsets.zero,
                                        labelPadding: const EdgeInsets.only(
                                          left: 6,
                                          right: 2,
                                        ),
                                        shape: chipDecor?.borderRadius != null
                                            ? RoundedRectangleBorder(
                                                borderRadius:
                                                    chipDecor!.borderRadius!,
                                              )
                                            : null,
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      );
                                    }),
                                    if (_selectedValues.length >
                                        widget.maxVisibleChips)
                                      GestureDetector(
                                        onTap: () {
                                          _showOverlay();
                                          _focusNode.requestFocus();
                                        },
                                        child: Chip(
                                          label: Text(
                                            '+${_selectedValues.length - widget.maxVisibleChips} more',
                                            style: chipDecor?.labelStyle ??
                                                TextStyle(fontSize: 12.sp),
                                          ),
                                          backgroundColor:
                                              chipDecor?.backgroundColor,
                                          side: BorderSide(
                                              color: Colors.transparent),
                                          visualDensity: VisualDensity.compact,
                                          padding: chipDecor?.padding ??
                                              EdgeInsets.zero,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                      ),
                                  ],
                                ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.maxSelection == 1 &&
                            _selectedValues.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedValues.clear();
                              });
                              widget.onSelectionChanged?.call([]);
                              _updateOverlay();
                            },
                            child: Icon(
                              Icons.close,
                              size: 18.w,
                              color: Colors.grey[600],
                            ),
                          )
                        else if (_selectedValues.length > 1)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedValues.clear();
                              });
                              widget.onSelectionChanged?.call([]);
                              _updateOverlay();
                            },
                            child: Text(
                              'Clear All',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        Icon(
                          _isOpen
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
