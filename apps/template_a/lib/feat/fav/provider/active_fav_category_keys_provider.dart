import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks the slugs of every currently-mounted [favCategoryScreenProvider]
/// instance (i.e. CategoryScreen opened with fromFavorites: true) so that
/// [FavouriteToggleService] can broadcast isFavourite changes to them.
final activeFavCategoryKeysProvider =
    NotifierProvider<ActiveFavCategoryKeysNotifier, Set<String>>(
  ActiveFavCategoryKeysNotifier.new,
);

class ActiveFavCategoryKeysNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void add(String slug) => state = {...state, slug};

  void remove(String slug) => state = state.difference({slug});
}
