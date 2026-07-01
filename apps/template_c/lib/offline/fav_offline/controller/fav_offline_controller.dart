import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:template_c/core/constant/state_constant.dart';
import 'package:template_c/feat/listing/data/models/listing_model.dart';
import 'package:template_c/offline/core/box_constant.dart';
import 'package:template_c/offline/fav_offline/state/fav_offline_state.dart';
import 'package:preference_manager/hive_service.dart';

final favOfflineControllerProvider =
    NotifierProvider<FavOfflineController, FavOfflineState>(
      () => FavOfflineController(),
    );

class FavOfflineController extends Notifier<FavOfflineState> {
  static String get _boxName => BoxKey.templateC.name;
  static String get _favKey => BoxItemKeyConstant.favKey.name;
  static String get _unselectedFavKey => BoxItemKeyConstant.unselectedFavKey.name;

  @override
  FavOfflineState build() {
    return FavOfflineState([], [],StateConstant.loading);
  }

  Future<List<ListingModel>> _readList() async {
    final raw = await HiveService.instance.get<dynamic>(_boxName, _favKey);
    if (raw == null) return [];
    return (raw as List)
        .map((e) => ListingModel().fromJson(_deepCastMap(e as Map)))
        .toList();
  }

  Map<String, dynamic> _deepCastMap(Map map) {
    return map.map((key, value) {
      final castValue = switch (value) {
        Map() => _deepCastMap(value),
        List() => _deepCastList(value),
        _ => value,
      };
      return MapEntry(key.toString(), castValue);
    });
  }

  dynamic _deepCastList(List list) {
    return list.map((e) {
      if (e is Map) return _deepCastMap(e);
      if (e is List) return _deepCastList(e);
      return e;
    }).toList();
  }

  Future<void> _writeList(List<ListingModel> items) async {
    await HiveService.instance.put<dynamic>(
      _boxName,
      _favKey,
      items.map((e) => e.toJson()).toList(),
    );
  }

  Future<List<String>> _readUnselectedList() async {
    final raw = await HiveService.instance.get<dynamic>(_boxName, _unselectedFavKey);
    if (raw == null) return [];
    return (raw as List).cast<String>();
  }

  Future<void> _writeUnselectedList(List<String> ids) async {
    await HiveService.instance.put<dynamic>(_boxName, _unselectedFavKey, ids);
  }


  Future<void> addFavItem(ListingModel item) async {
    try {
      final items = await _readList();
      final exists = items.any((e) => e.id == item.id);
      if (!exists) {
        items.add(item);
        await _writeList(items);
        debugPrint('FavOffline: added → ${item.id}');
      }
    } catch (e) {
      debugPrint('FavOffline: addFavItem error → $e');
    }
  }


  Future<void> removeFavItem(String id) async {
    try {
      final items = await _readList();
      items.removeWhere((e) => e.id == id);
      await _writeList(items);
      final unselected = [...state.unselectedFavList, id];
      await _writeUnselectedList(unselected);
      state = state.copyWith(unselectedFavList: unselected, listingModelList: items);
      debugPrint('FavOffline: removed → $id');
    } catch (e) {
      debugPrint('FavOffline: removeFavItem error → $e');
    }
  }


  /// Returns all IDs that were unfavourited while offline.
  /// Reads from Hive to guarantee freshness even if state was not yet loaded.
  Future<List<String>> getUnselectedFavIds() async {
    try {
      return await _readUnselectedList();
    } catch (e) {
      debugPrint('FavOffline: getUnselectedFavIds error → $e');
      return [];
    }
  }

  /// Returns true if a listing with [id] is saved in the fav box.
  Future<bool> isFavorite(String id) async {
    try {
      final items = await _readList();
      return items.any((e) => e.id == id);
    } catch (e) {
      debugPrint('FavOffline: isFavorite error → $e');
      return false;
    }
  }

  
  Future<int> get favCount async {
    final items = await _readList();
    return items.length;
  }


  Future<void> clearAllFavItems() async {
    try {
      await _writeList([]);
      debugPrint('FavOffline: all fav items cleared');
    } catch (e) {
      debugPrint('FavOffline: clearAllFavItems error → $e');
    }
  }

  Future<void> getOfflineFavList() async {
    try {

      final offlineList = await _readList();
      final unselectedList = await _readUnselectedList();
      debugPrint('offline fav list length : ${offlineList.length}');
      debugPrint('unselected fav list length : ${unselectedList.length}');
      state = state.copyWith(
        listingModelList: offlineList,
        unselectedFavList: unselectedList,
        stateConstant: StateConstant.success
      );
    } catch (error) {
      debugPrint('getOfflineFavList exception: $error');
    }
  }

  /// Call this after successfully syncing [unselectedFavList] with the server
  /// to clear the persisted queue.
  Future<void> clearUnselectedFavList() async {
    await _writeUnselectedList([]);
    state = state.copyWith(unselectedFavList: []);
  }
}
