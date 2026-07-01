import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:locale/localizations.dart';

import 'common_icon.dart';
import 'common_text.dart';

/// Theme-independent, platform-adaptive full-screen update overlay.
///
/// Renders a Cupertino-style card on iOS and a Material-style card on Android.
/// Uses [MediaQuery.platformBrightnessOf] (OS-level) and hardcoded system
/// colors so it renders correctly even before the app theme has loaded.
class AppUpdateOverlay extends StatelessWidget {
  const AppUpdateOverlay({super.key, required this.onUpdate});

  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final isDark =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;

    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Platform.isIOS
              ? _IosCard(isDark: isDark, onUpdate: onUpdate)
              : _AndroidCard(isDark: isDark, onUpdate: onUpdate),
        ),
      ),
    );
  }
}

// ── iOS card ────────────────────────────────────────────────────────────────

class _IosCard extends StatelessWidget {
  const _IosCard({required this.isDark, required this.onUpdate});

  final bool isDark;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final bodyColor =
        isDark ? const Color(0xFFAEAEB2) : const Color(0xFF3C3C43);
    const buttonColor = Color(0xFF007AFF);

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CommonIcon(
              icon: CupertinoIcons.cloud_download,
              size: 52,
              color: buttonColor,
            ),
            const SizedBox(height: 14),
            CommonText(
              titleText: 'app_update_required_title'.tr,
              textStyle: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: titleColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            CommonText(
              titleText: 'app_update_required_body'.tr,
              textStyle: TextStyle(fontSize: 13, color: bodyColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Divider(height: 1, color: bodyColor.withValues(alpha: 0.3)),
            CupertinoButton(
              onPressed: onUpdate,
              child: CommonText(
                titleText: 'app_update_now_button'.tr,
                textStyle: const TextStyle(
                  color: buttonColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Android card ─────────────────────────────────────────────────────────────

class _AndroidCard extends StatelessWidget {
  const _AndroidCard({required this.isDark, required this.onUpdate});

  final bool isDark;
  final VoidCallback onUpdate;

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);
    final titleColor = isDark ? Colors.white : const Color(0xFF1C1B1F);
    final bodyColor =
        isDark ? const Color(0xFFCAC4D0) : const Color(0xFF49454F);
    const accentColor = Color(0xFF2196F3);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(28),
      elevation: 6,
      shadowColor: Colors.black38,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: CommonIcon(
                icon: Icons.system_update_rounded,
                size: 36,
                color: accentColor,
              ),
            ),
            const SizedBox(height: 16),
            CommonText(
              titleText: 'app_update_required_title'.tr,
              textStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: titleColor,
                letterSpacing: 0.15,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            CommonText(
              titleText: 'app_update_required_body'.tr,
              textStyle: TextStyle(
                fontSize: 14,
                color: bodyColor,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onUpdate,
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                icon: CommonIcon(
                  icon: Icons.download_rounded,
                  size: 20,
                  color: Colors.white,
                ),
                label: CommonText(
                  titleText: 'app_update_now_button'.tr,
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
