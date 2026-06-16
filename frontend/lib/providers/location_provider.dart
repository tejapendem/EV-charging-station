import 'package:ev_connect_india/config/app_config.dart';
import 'package:ev_connect_india/services/location_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LocationStatus { initial, loading, loaded, denied, disabled, error }

class LocationState {
  final LocationStatus status;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final String? address;
  final String? city;
  final String? error;

  const LocationState({
    this.status = LocationStatus.initial,
    this.latitude = AppConfig.defaultLatitude,
    this.longitude = AppConfig.defaultLongitude,
    this.accuracy,
    this.address,
    this.city,
    this.error,
  });

  LocationState copyWith({
    LocationStatus? status,
    double? latitude,
    double? longitude,
    double? accuracy,
    String? address,
    String? city,
    String? error,
  }) {
    return LocationState(
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      address: address ?? this.address,
      city: city ?? this.city,
      error: error ?? this.error,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  final LocationService _locationService;

  LocationNotifier(this._locationService) : super(const LocationState());

  Future<void> getCurrentLocation() async {
    state = state.copyWith(status: LocationStatus.loading, error: null);

    try {
      final hasPermission = await _locationService.hasPermission();
      if (!hasPermission) {
        final granted = await _locationService.requestPermission();
        if (!granted) {
          state = state.copyWith(
            status: LocationStatus.denied,
            error: 'Location permission denied',
          );
          return;
        }
      }

      final isEnabled = await _locationService.isLocationEnabled();
      if (!isEnabled) {
        state = state.copyWith(
          status: LocationStatus.disabled,
          error: 'Location services disabled',
        );
        return;
      }

      final location = await _locationService.getCurrentLocationWithAddress();

      state = state.copyWith(
        status: LocationStatus.loaded,
        latitude: location.latitude,
        longitude: location.longitude,
        accuracy: location.accuracy,
        address: location.address,
        city: location.city,
      );
    } catch (e) {
      debugPrint('LocationProvider error: $e');
      state = state.copyWith(
        status: LocationStatus.error,
        error: e.toString(),
      );
    }
  }

  Future<void> refreshLocation() async {
    await getCurrentLocation();
  }

  void updateLocation({
    required double latitude,
    required double longitude,
    String? address,
  }) {
    state = state.copyWith(
      status: LocationStatus.loaded,
      latitude: latitude,
      longitude: longitude,
      address: address,
    );
  }

  Future<List<LocationResult>> searchLocation(String query) async {
    return _locationService.searchLocation(query);
  }

  double calculateDistanceTo(double lat, double lng) {
    return _locationService.calculateDistance(
      state.latitude,
      state.longitude,
      lat,
      lng,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final locationProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier(LocationService());
});

final currentLatLngProvider = Provider<({double lat, double lng})>((ref) {
  final location = ref.watch(locationProvider);
  return (lat: location.latitude, lng: location.longitude);
});
