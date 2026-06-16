import 'package:ev_connect_india/models/station.dart';
import 'package:ev_connect_india/services/cache_service.dart';
import 'package:ev_connect_india/services/station_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum StationListStatus { initial, loading, loaded, error, loadingMore }

class StationListState {
  final StationListStatus status;
  final List<Station> stations;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const StationListState({
    this.status = StationListStatus.initial,
    this.stations = const [],
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  StationListState copyWith({
    StationListStatus? status,
    List<Station>? stations,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return StationListState(
      status: status ?? this.status,
      stations: stations ?? this.stations,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class StationFilterState {
  final String? chargerType;
  final String? speedCategory;
  final bool? isOpenOnly;
  final double? radiusKm;
  final String? sortBy;
  final double? minRating;

  const StationFilterState({
    this.chargerType,
    this.speedCategory,
    this.isOpenOnly,
    this.radiusKm,
    this.sortBy,
    this.minRating,
  });

  StationFilterState copyWith({
    String? chargerType,
    String? speedCategory,
    bool? isOpenOnly,
    double? radiusKm,
    String? sortBy,
    double? minRating,
  }) {
    return StationFilterState(
      chargerType: chargerType ?? this.chargerType,
      speedCategory: speedCategory ?? this.speedCategory,
      isOpenOnly: isOpenOnly ?? this.isOpenOnly,
      radiusKm: radiusKm ?? this.radiusKm,
      sortBy: sortBy ?? this.sortBy,
      minRating: minRating ?? this.minRating,
    );
  }

  bool get hasActiveFilters =>
      chargerType != null ||
      speedCategory != null ||
      isOpenOnly == true ||
      radiusKm != null ||
      minRating != null;

  int get activeFilterCount {
    int count = 0;
    if (chargerType != null) count++;
    if (speedCategory != null) count++;
    if (isOpenOnly == true) count++;
    if (radiusKm != null) count++;
    if (minRating != null) count++;
    return count;
  }

  Map<String, String> toQueryParams() {
    final params = <String, String>{};
    if (chargerType != null) params['charger_type'] = chargerType!;
    if (speedCategory != null) params['speed_category'] = speedCategory!;
    if (isOpenOnly == true) params['is_open'] = 'true';
    if (radiusKm != null) params['radius_km'] = radiusKm.toString();
    if (sortBy != null) params['sort_by'] = sortBy!;
    if (minRating != null) params['min_rating'] = minRating.toString();
    return params;
  }
}

class StationListNotifier extends StateNotifier<StationListState> {
  final StationService _stationService;
  final CacheService _cacheService;
  StationFilterState _filters = const StationFilterState();
  String? _searchQuery;
  double? _latitude;
  double? _longitude;

  StationListNotifier(this._stationService, this._cacheService)
      : super(const StationListState());

  void setLocation(double latitude, double longitude) {
    _latitude = latitude;
    _longitude = longitude;
  }

  void setFilters(StationFilterState filters) {
    _filters = filters;
    loadStations();
  }

  void clearFilters() {
    _filters = const StationFilterState();
    loadStations();
  }

  StationFilterState get filters => _filters;

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadStations();
  }

  Future<void> loadStations() async {
    if (state.stations.isEmpty) {
      state = state.copyWith(status: StationListStatus.loading);
    }

    try {
      final stations = await _stationService.getStations(
        latitude: _latitude,
        longitude: _longitude,
        radiusKm: _filters.radiusKm,
        query: _searchQuery,
        chargerType: _filters.chargerType,
        speedCategory: _filters.speedCategory,
        isOpen: _filters.isOpenOnly,
        page: 1,
      );

      state = state.copyWith(
        status: StationListStatus.loaded,
        stations: stations,
        currentPage: 1,
        hasMore: stations.length >= 20,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: StationListStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.status == StationListStatus.loadingMore || !state.hasMore) return;

    state = state.copyWith(status: StationListStatus.loadingMore);

    try {
      final nextPage = state.currentPage + 1;
      final stations = await _stationService.getStations(
        latitude: _latitude,
        longitude: _longitude,
        radiusKm: _filters.radiusKm,
        query: _searchQuery,
        chargerType: _filters.chargerType,
        speedCategory: _filters.speedCategory,
        isOpen: _filters.isOpenOnly,
        page: nextPage,
      );

      state = state.copyWith(
        status: StationListStatus.loaded,
        stations: [...state.stations, ...stations],
        currentPage: nextPage,
        hasMore: stations.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(
        status: StationListStatus.loaded,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(status: StationListStatus.loading);
    await loadStations();
  }
}

class StationDetailState {
  final bool isLoading;
  final Station? station;
  final String? error;

  const StationDetailState({
    this.isLoading = false,
    this.station,
    this.error,
  });

  StationDetailState copyWith({
    bool? isLoading,
    Station? station,
    String? error,
  }) {
    return StationDetailState(
      isLoading: isLoading ?? this.isLoading,
      station: station ?? this.station,
      error: error ?? this.error,
    );
  }
}

class StationDetailNotifier extends StateNotifier<StationDetailState> {
  final StationService _stationService;

  StationDetailNotifier(this._stationService)
      : super(const StationDetailState());

  Future<void> loadStation(String stationId) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final station = await _stationService.getStationById(stationId);
      state = state.copyWith(
        isLoading: false,
        station: station,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> toggleFavorite() async {
    final station = state.station;
    if (station == null) return;

    try {
      await _stationService.toggleFavorite(station.id);
      state = state.copyWith(
        station: station.copyWith(isFavorite: !station.isFavorite),
      );
    } catch (e) {
      // Silently fail
    }
  }
}

final stationListProvider =
    StateNotifierProvider<StationListNotifier, StationListState>((ref) {
  return StationListNotifier(StationService(), CacheService());
});

final stationFilterProvider = StateProvider<StationFilterState>((ref) {
  return const StationFilterState();
});

final stationDetailProvider =
    StateNotifierProvider.family<StationDetailNotifier, StationDetailState, String>(
  (ref, stationId) {
    return StationDetailNotifier(StationService());
  },
);

final searchQueryProvider = StateProvider<String>((ref) => '');

final isLoadingStationsProvider = Provider<bool>((ref) {
  return ref.watch(stationListProvider).status == StationListStatus.loading;
});
