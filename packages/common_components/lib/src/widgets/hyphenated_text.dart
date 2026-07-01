import 'package:auto_hyphenating_text/auto_hyphenating_text.dart';
import 'package:flutter/material.dart';

export 'package:auto_hyphenating_text/auto_hyphenating_text.dart'
    show initHyphenation, DefaultResourceLoaderLanguage;

/// Drop-in hyphenating text widget backed by [AutoHyphenatingText].
///
/// Call [initHyphenation] once at app startup (and on locale change) before
/// using this widget:
/// ```dart
/// await initHyphenation(DefaultResourceLoaderLanguage.de1996); // German
/// ```
/// On locale change, re-init is handled automatically inside [ref.changeLocale]
/// from the locale package.
class HyphenatedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextScaler? textScaler;

  const HyphenatedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.textScaler,
  });

  @override
  Widget build(BuildContext context) {
    return AutoHyphenatingText(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.ellipsis,
      scaler: textScaler,
    );
  }
}
