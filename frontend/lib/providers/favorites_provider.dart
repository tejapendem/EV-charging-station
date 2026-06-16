import 'package:ev_connect_india/models/station.dart';
import 'package:ev_connect_india/services/station_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FavoritesStatus { initial, loading, loaded, error }

class FavoritesState {
  final FavoritesStatus status;
  final List<Station> favorites;
  final String? error;
  final Set<String> favoriteIds;

  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.favorites = const [],
    this.error,
    this.favoriteIds = const {},
  });

  bool isFavorite(String stationId) => favoriteIds.contains(stationId);

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<Station>? favorites,
    String? error,
    Set<String>? favoriteIds,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
      error: error ?? this.error,
      favoriteIds: favoriteIds ?? this.favoriteIds,
    );
  }
}

class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final StationService _stationService;

  FavoritesNotifier(this._stationService) : super(const FavoritesState());

  Future<void> loadFavorites() async {
    state = state.copyWith(status: FavoritesStatus.loading, error: null);

    try {
      final favorites = await _stationService.getFavoriteStations();
      final ids = favorites.map((s) => s.id).toSet();

      state = state.copyWith(
        status: FavoritesStatus.loaded,
        favorites: favorites,
        favoriteIds: ids,
      );
    } catch (e) {
      state = state.copyWith(
        status: FavoritesStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> toggleFavorite(String stationId) async {
    try {
      await _stationService.toggleFavorite(stationId);

      if (state.isFavorite(stationId)) {
        state = state.copyWith(
          favorites: state.favorites.where((s) => s.id != stationId).toList(),
          favoriteIds: Set.from(state.favoriteIds)..remove(stationId),
        );
      } else {
        final station = await _stationService.getStationById(stationId);
        state = state.copyWith(
          favorites: [...state.favorites, station],
          favoriteIds: Set.from(state.favoriteIds)..add(stationId),
        );
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  bool isFavorite(String stationId) => state.isFavorite(stationId);

  Future<void> refresh() async {
    await loadFavorites();
  }
}

final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  return FavoritesNotifier(StationService());
});

final isFavoriteProvider =
    Provider.family<bool, String>((ref, stationId) {
  return ref.watch(favoritesProvider).isFavorite(stationId);
});

final favoritesCountProvider = Provider<int>((ref) {
  return ref.watch(favoritesProvider).favorites.length;
});
