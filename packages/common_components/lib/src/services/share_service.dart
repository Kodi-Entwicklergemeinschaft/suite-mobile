import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

/// Shares a pre-formatted event text via the native share sheet.
///
/// Pass [context] so that on iOS the share sheet can be anchored to the
/// calling widget's position. A screen-center fallback is used when the
/// context is unavailable or the widget has no layout size yet.
Future<void> shareEvent({
  required String title,
  String? dateLine,
  String? address,
  String? websiteUrl,
  BuildContext? context,
}) async {
  final parts = <String>[
    title,
    if (websiteUrl != null && websiteUrl.isNotEmpty) websiteUrl,
  ];

  Rect origin = _screenCenterRect();

  if (context != null) {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize && box.size != Size.zero) {
      origin = box.localToGlobal(Offset.zero) & box.size;
    }
  }

  await Share.share(parts.join('\n\n'), sharePositionOrigin: origin);
}

Rect _screenCenterRect() {
  final view =
      WidgetsBinding.instance.platformDispatcher.views.firstOrNull;
  if (view == null) return const Rect.fromLTWH(100, 100, 200, 200);
  final size = view.physicalSize / view.devicePixelRatio;
  return Rect.fromCenter(
    center: Offset(size.width / 2, size.height / 2),
    width: 1,
    height: 1,
  );
}
