import 'dart:async';

import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final String? address;
  final String? city;
  final String? state;
  final String? country;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.address,
    this.city,
    this.state,
    this.country,
  });
}

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  StreamSubscription<Position>? _positionStream;

  Future<bool> hasPermission() async {
    final status = await Geolocator.checkPermission();
    return status == LocationPermission.always ||
        status == LocationPermission.whileInUse;
  }

  Future<bool> requestPermission() async {
    final status = await Geolocator.requestPermission();
    return status == LocationPermission.always ||
        status == LocationPermission.whileInUse;
  }

  Future<bool> isLocationEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<LocationResult> getCurrentLocation({
    bool highAccuracy = true,
  }) async {
    final hasPerm = await hasPermission();
    if (!hasPerm) {
      final granted = await requestPermission();
      if (!granted) {
        throw LocationException(
          'Location permission denied. Please enable it in settings.',
        );
      }
    }

    final isEnabled = await isLocationEnabled();
    if (!isEnabled) {
      throw LocationException(
        'Location services are disabled. Please enable GPS.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: highAccuracy
          ? LocationAccuracy.high
          : LocationAccuracy.medium,
    );

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
    );
  }

  Future<LocationResult> getCurrentLocationWithAddress() async {
    final location = await getCurrentLocation();
    final address = await getAddressFromCoordinates(
      location.latitude,
      location.longitude,
    );

    return LocationResult(
      latitude: location.latitude,
      longitude: location.longitude,
      accuracy: location.accuracy,
      address: address.address,
      city: address.city,
      state: address.state,
      country: address.country,
    );
  }

  Future<LocationResult> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final addressParts = <String>[
          if (place.street != null) place.street!,
          if (place.locality != null) place.locality!,
          if (place.administrativeArea != null) place.administrativeArea!,
          if (place.postalCode != null) place.postalCode!,
          if (place.country != null) place.country!,
        ];

        return LocationResult(
          latitude: latitude,
          longitude: longitude,
          address: addressParts.where((p) => p.isNotEmpty).join(', '),
          city: place.locality,
          state: place.administrativeArea,
          country: place.country,
        );
      }

      return LocationResult(latitude: latitude, longitude: longitude);
    } catch (e) {
      return LocationResult(latitude: latitude, longitude: longitude);
    }
  }

  Future<List<LocationResult>> searchLocation(String query) async {
    try {
      final locations = await locationFromAddress(query);
      return locations.map((loc) {
        return LocationResult(
          latitude: loc.latitude,
          longitude: loc.longitude,
        );
      }).toList();
    } catch (e) {
      throw LocationException('Could not find location: $query');
    }
  }

  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  Stream<Position> watchPositionRaw({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilterMeters = 10,
  }) {
    _positionStream?.cancel();
    final stream = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilterMeters,
      ),
    );
    _positionStream = stream.listen((_) {});
    return stream;
  }

  void stopWatching() {
    _positionStream?.cancel();
    _positionStream = null;
  }

  void dispose() {
    stopWatching();
  }
}

class LocationException implements Exception {
  final String message;
  const LocationException(this.message);

  @override
  String toString() => 'LocationException: $message';
}
