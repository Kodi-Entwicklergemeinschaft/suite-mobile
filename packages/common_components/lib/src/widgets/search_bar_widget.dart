import 'package:flutter/material.dart';
import 'common_text_field.dart';
import 'package:locale/locale.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SearchBarWidget extends StatefulWidget {
  final String? label;
  final TextEditingController? controller;
  final VoidCallback? onClear;
  final VoidCallback? onDone;
  final VoidCallback? onTap;
  final Widget? permanentSuffixIcon;
  final Color? fillColor;
  final bool filled;
  final bool showBorder;
  final Color? borderColor;
  final double borderRadius;
  final Color? focusColor;
  final void Function(String)? onChanged;
  final bool readOnly;
  final FocusNode? focusNode;
  final EdgeInsets? contentPadding;
  final double? minHeight;
  final double? maxHeight;
  final String? hintText;
  final Widget? prefixIcon;
  final Color? hintTextColor;
  final Color? textColor;
  final double? hintFontSize;
  final Color? cursorColor;

  const SearchBarWidget(
      {super.key,
      this.label,
      this.controller,
      this.onClear,
      this.onDone,
      this.onTap,
      this.permanentSuffixIcon,
      this.fillColor,
      this.filled = true,
      this.showBorder = false,
      this.borderColor,
      this.borderRadius = 8.0,
      this.focusColor,
      this.onChanged,
      this.readOnly = false,
      this.focusNode,
      this.contentPadding,
      this.minHeight,
      this.maxHeight,
      this.hintText,
      this.prefixIcon,
      this.hintTextColor,
      this.textColor,
      this.hintFontSize,
      this.cursorColor,
      });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_updateClearButton);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _updateClearButton() {
    setState(() {
      _hasText = _controller.text.isNotEmpty;
    });
  }

  void _clear() {
    _controller.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final height = widget.minHeight ?? widget.maxHeight ?? 48.h;

    return SizedBox(
      height: height,
      child: CommonTextField(
        fillColor: widget.fillColor,
        filled: widget.filled,
        showBorder: widget.showBorder,
        borderColor: widget.borderColor,
        borderRadius: widget.borderRadius,
        focusColor: widget.focusColor,
        label: widget.label,
        hintText: widget.hintText ?? 'search'.tr,
        hintTextColor: widget.hintTextColor,
        hintFontSize: widget.hintFontSize,
        textColor: widget.textColor,
        cursorColor: widget.cursorColor,
        controller: _controller,
        focusNode: widget.focusNode,
        textInputAction: TextInputAction.done,
        onChanged: widget.onChanged,
        onSubmitted: (_) => widget.onDone?.call(),
        onTap: widget.onTap,
        readOnly: widget.readOnly,
        isDense: true,
        contentPadding: widget.contentPadding ?? EdgeInsets.symmetric(horizontal: 12.w),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.permanentSuffixIcon,
      ),
    );
  }
}
