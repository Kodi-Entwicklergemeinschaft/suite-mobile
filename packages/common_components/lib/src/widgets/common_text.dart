import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:theme/theme.dart';

class HighlightText extends StatelessWidget {
  const HighlightText({
    super.key,
    required this.source,
    required this.highlightColor,
    this.query,
    required this.style,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow,
  });

  final String source;
  final Color highlightColor;
  final String? query;
  final TextStyle style;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    if (query == null ||
        query!.isEmpty ||
        !source.toLowerCase().contains(query!.toLowerCase())) {
      return CommonText(
        titleText: source,
        textStyle: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final regex = RegExp(RegExp.escape(query!), caseSensitive: false);
    final matches = regex.allMatches(source);

    if (matches.isEmpty) {
      return CommonText(
        titleText: source,
        textStyle: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    final spans = <TextSpan>[];
    int last = 0;

    for (final m in matches) {
      if (m.start > last) {
        spans.add(TextSpan(text: source.substring(last, m.start), style: style));
      }
      spans.add(TextSpan(
        text: source.substring(m.start, m.end),
        style: style.copyWith(
          backgroundColor: highlightColor,
          fontWeight: FontWeight.bold,
        ),
      ));
      last = m.end;
    }

    if (last < source.length) {
      spans.add(TextSpan(text: source.substring(last), style: style));
    }

    return Text.rich(
      TextSpan(children: spans),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
    );
  }
}

class CommonText extends StatelessWidget {
  final String titleText;
  final TextStyle? textStyle;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final String? semanticsLabel;
  final bool? softWrap;
  final bool? isHeader;
  final bool? isLiveRegion;

  const CommonText({
    super.key,
    required this.titleText,
    this.textStyle,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.textScaler,
    this.semanticsLabel,
    this.softWrap,
    this.isHeader,
    this.isLiveRegion,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final defaultStyle = theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ) ??
        TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.normal,
        );

    final finalStyle = _resolveStyle(defaultStyle);

    return Semantics(
      label: semanticsLabel,
      header: isHeader ?? false,
      liveRegion: isLiveRegion ?? false,
      child: Text(
        titleText,
        style: finalStyle,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow ?? (maxLines != null ? TextOverflow.ellipsis : null),
        textScaler: textScaler,
        softWrap: softWrap,
      ),
    );
  }

  TextStyle _resolveStyle(TextStyle defaultStyle) {
    if (textStyle == null) return defaultStyle;

    // If fontWeight is explicitly set but fontFamily is not, we must resolve
    // the correct google_fonts variant family. Without this, the weight override
    // has no effect because DefaultTextStyle carries a single-weight variant
    // family (e.g. "Raleway_regular") that ignores all fontWeight overrides.
    if (textStyle!.fontFamily == null && textStyle!.fontWeight != null) {
      final variantFamily = defaultStyle.fontFamily;
      if (variantFamily != null) {
        final lastUnderscore = variantFamily.lastIndexOf('_');
        final baseName = lastUnderscore > 0
            ? variantFamily.substring(0, lastUnderscore)
            : variantFamily;
        final resolvedFamily = FontResolver.resolve(baseName, textStyle!.fontWeight!);
        if (resolvedFamily != null) {
          return defaultStyle.merge(textStyle).copyWith(fontFamily: resolvedFamily);
        }
      }
    }

    return defaultStyle.merge(textStyle);
  }
}
