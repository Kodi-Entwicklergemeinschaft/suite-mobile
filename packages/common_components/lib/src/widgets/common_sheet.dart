import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:theme/theme.dart';
import 'package:locale/localizations.dart';
import 'common_text.dart';

import 'package:go_router/go_router.dart';

enum SheetType { info, warning }

class CommonSheet extends StatelessWidget {
  final String? title;
  final String? content;
  final SheetType type;
  final Widget? child;
  final String? confirmButtonText;
  final String? cancelButtonText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool showButtons;
  final bool showIcon;

  const CommonSheet({
    super.key,
    this.title,
    this.content,
    this.type = SheetType.info,
    this.child,
    this.confirmButtonText,
    this.cancelButtonText,
    this.onConfirm,
    this.onCancel,
    this.showButtons = true,
    this.showIcon = false,
  });

  /// Show a simple sheet with title and content (no icon)
  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String content,
    String? confirmButtonText,
    String? cancelButtonText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showCupertinoSheet<bool>(
      context: context,
      builder: (context) => CommonSheet(
        title: title,
        content: content,
        confirmButtonText: confirmButtonText,
        cancelButtonText: cancelButtonText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        showIcon: false,
      ),
    );
  }

  /// Show a sheet with custom widget content (title only, no icon)
  static Future<T?> showWithChild<T>(
    BuildContext context, {
    String? title,
    required Widget child,
    String? confirmButtonText,
    String? cancelButtonText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool showButtons = true,
  }) {
    return showCupertinoSheet<T>(
      context: context,
      builder: (context) => CommonSheet(
        title: title,
        confirmButtonText: confirmButtonText,
        cancelButtonText: cancelButtonText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        showButtons: showButtons,
        showIcon: false,
        child: child,
      ),
    );
  }

  /// Show a confirmation sheet (warning style with icon and confirm/cancel)
  static Future<bool?> showConfirmation(
    BuildContext context, {
    required String title,
    required String content,
    String? confirmButtonText,
    String? cancelButtonText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return showCupertinoSheet<bool>(
      context: context,
      builder: (context) => CommonSheet(
        title: title,
        content: content,
        type: SheetType.warning,
        confirmButtonText: confirmButtonText,
        cancelButtonText: cancelButtonText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        showIcon: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorColors = AppErrorColors.of(context);

    return BottomSheet(
      shape: RoundedSuperellipseBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      onClosing: () {},
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon (only for confirmation)
          if (showIcon)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Icon(
                Icons.warning_rounded,
                color: errorColors.warning,
                size: 48,
              ),
            ),
          // Title
          if (title != null)
            Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: showIcon ? 12 : 20,
                bottom: 12,
              ),
              child: CommonText(
                titleText: title!,
                maxLines: 2,
                textStyle: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          // Content text
          if (content != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: CommonText(
                titleText: content!,
                maxLines: 3,
                overflow: TextOverflow.visible,
                textAlign: TextAlign.center,
                textStyle: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          // Custom child
          if (child != null) child!,
          const SizedBox(height: 16),
          // Buttons
          if (showButtons) ...[
            const Divider(height: 1),
            _buildActionButtons(context, theme, errorColors),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ThemeData theme,
    AppErrorColors errorColors,
  ) {
    final confirmText = confirmButtonText ?? 'ok'.tr;
    final hasCancelButton = cancelButtonText != null && cancelButtonText!.isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () {
              context.pop(true);
              onConfirm?.call();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                confirmText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: type == SheetType.warning
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
        if (hasCancelButton) ...[
          const SizedBox(height: 55, child: VerticalDivider()),
          Expanded(
            child: InkWell(
              onTap: () {
                onCancel?.call();
                context.pop(false);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  cancelButtonText!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
