import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Thin scaffold wrapper for sub-screens inside shell branches.
/// The bottom bar is rendered by the StatefulShellRoute shell, so this
/// widget simply provides a Scaffold without duplicating the nav bar.
class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusBarStyle = isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: statusBarStyle,
      child: Scaffold(
        appBar: appBar,
        backgroundColor: backgroundColor,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: body,
      ),
    );
  }
}
