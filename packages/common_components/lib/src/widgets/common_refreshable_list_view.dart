import 'package:flutter/material.dart';

/// A generic, reusable refreshable list view with built-in support for:
/// - Pull-to-refresh
/// - Empty state (centered message)
/// - Error state (error icon + message)
/// - Pagination loading indicator
/// - Always-scrollable physics (enables pull-to-refresh even when content is short)
class CommonRefreshableListView<T> extends StatelessWidget {
  /// The list of items to display.
  final List<T> items;

  /// Whether there are more pages to load (shows pagination loader).
  final bool hasNextPage;

  /// Whether currently loading the next page.
  final bool isLoadingMore;

  /// Error message, if any. When non-null and items is empty, shows error state.
  final String? error;

  /// Message to display when items is empty and there is no error.
  final String emptyMessage;

  /// Optional message to display in the error state. Defaults to 'Error'.
  final String errorMessage;

  /// Builder for each item in the list.
  final Widget Function(BuildContext context, T item, int index) itemBuilder;

  /// Callback for pull-to-refresh.
  final Future<void> Function() onRefresh;

  /// Optional scroll controller (e.g. for pagination scroll listeners).
  final ScrollController? scrollController;

  /// Padding around the list. Defaults to `EdgeInsets.symmetric(horizontal: 16)`.
  final EdgeInsetsGeometry? padding;

  const CommonRefreshableListView({
    super.key,
    required this.items,
    required this.hasNextPage,
    this.isLoadingMore = false,
    this.error,
    required this.emptyMessage,
    this.errorMessage = 'Error',
    required this.itemBuilder,
    required this.onRefresh,
    this.scrollController,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: scrollController,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.isEmpty
            ? 1
            : items.length + (hasNextPage && isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Empty or Error state — single centered item at ~50% screen height
          if (items.isEmpty) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Center(
                child: error != null
                    ? _buildErrorState(context, theme)
                    : _buildEmptyState(theme),
              ),
            );
          }

          // Pagination loader at the end
          if (index == items.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              ),
            );
          }

          return itemBuilder(context, items[index], index);
        },
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Text(
      emptyMessage,
      style: theme.textTheme.titleMedium,
    );
  }

  Widget _buildErrorState(BuildContext context, ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
        const SizedBox(height: 16),
        Text(
          errorMessage,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
      ],
    );
  }
}
