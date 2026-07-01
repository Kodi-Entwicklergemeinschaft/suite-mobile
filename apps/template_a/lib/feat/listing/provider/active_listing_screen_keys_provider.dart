import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks the family keys of every currently-mounted [listingScreenControllerProvider]
/// instance so that [FavouriteToggleService] can broadcast isFavourite changes
/// to all active category/listing screens, not just those derived from home config.
final activeListingScreenKeysProvider =
    NotifierProvider<ActiveListingScreenKeysNotifier, Set<String>>(
  ActiveListingScreenKeysNotifier.new,
);

class ActiveListingScreenKeysNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void add(String key) => state = {...state, key};

  void remove(String key) => state = state.difference({key});
}
