import 'dart:convert';
import 'dart:math';

import 'package:ev_connect_india/models/station.dart';
import 'package:ev_connect_india/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class PlaceSuggestion {
  final String displayName;
  final double latitude;
  final double longitude;
  final String placeId;

  const PlaceSuggestion({
    required this.displayName,
    required this.latitude,
    required this.longitude,
    required this.placeId,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaceSuggestion(
      displayName: json['display_name'] as String? ?? json['name'] as String? ?? '',
      latitude: double.parse(json['lat'] as String),
      longitude: double.parse(json['lon'] as String),
      placeId: json['place_id']?.toString() ?? '',
    );
  }
}

class RouteInfo {
  final List<LatLng> geometry;
  final double distanceKm;
  final double durationMinutes;

  const RouteInfo({
    required this.geometry,
    required this.distanceKm,
    required this.durationMinutes,
  });
}

class ChargingStop {
  final Station station;
  final double distanceFromStartKm;
  final double detourKm;

  const ChargingStop({
    required this.station,
    required this.distanceFromStartKm,
    required this.detourKm,
  });
}

class RouteResult {
  final RouteInfo route;
  final List<ChargingStop> chargingStops;
  final double batteryUsedPercent;

  const RouteResult({
    required this.route,
    required this.chargingStops,
    required this.batteryUsedPercent,
  });
}

class RouteService {
  static final RouteService _instance = RouteService._internal();
  factory RouteService() => _instance;
  RouteService._internal();

  final http.Client _client = http.Client();

  static const String _nominatimBase = 'https://nominatim.openstreetmap.org';
  static const String _osrmBase = 'https://router.project-osrm.org';
  static const String _userAgent = 'EVConnectIndia/1.0';

  Future<List<PlaceSuggestion>> searchLocations(String query) async {
    if (query.length < 2) return [];

    try {
      final response = await _client.get(
        Uri.parse(
          '$_nominatimBase/search?q=${Uri.encodeComponent(query)}&format=json&limit=7&countrycodes=in&dedupe=1',
        ),
        headers: {'User-Agent': _userAgent},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        return data
            .map((j) => PlaceSuggestion.fromJson(j as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    final stationSuggestions = await _searchStations(query);
    return stationSuggestions;
  }

  Future<List<PlaceSuggestion>> _searchStations(String query) async {
    try {
      final api = ApiService();
      final response = await api.get('/stations/search', queryParams: {
        'q': query,
        'limit': '5',
      });

      if (response.isSuccess && response.data != null) {
        final stationsJson = response.data!['stations'] as List<dynamic>? ?? [];
        return stationsJson.map((s) {
          final station = s as Map<String, dynamic>;
          return PlaceSuggestion(
            displayName:
                '${station['name']} — ${station['address']}, ${station['city'] ?? ''}',
            latitude: double.parse(station['latitude'].toString()),
            longitude: double.parse(station['longitude'].toString()),
            placeId: station['id'] as String,
          );
        }).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<RouteInfo?> getRoute(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) async {
    try {
      final response = await _client.get(
        Uri.parse(
          '$_osrmBase/route/v1/driving/$startLng,$startLat;$endLng,$endLat?geometries=geojson&overview=full&steps=false',
        ),
        headers: {'User-Agent': _userAgent},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['code'] == 'Ok') {
          final routes = data['routes'] as List<dynamic>;
          if (routes.isNotEmpty) {
            final route = routes[0] as Map<String, dynamic>;
            final geometry = route['geometry'] as Map<String, dynamic>;
            final coords = geometry['coordinates'] as List<dynamic>;
            final points = coords
                .map((c) {
                  final coord = c as List<dynamic>;
                  return LatLng(
                    (coord[1] as num).toDouble(),
                    (coord[0] as num).toDouble(),
                  );
                })
                .toList();

            final dist = (route['distance'] as num).toDouble() / 1000;
            final dur = (route['duration'] as num).toDouble() / 60;
            return RouteInfo(
              geometry: points,
              distanceKm: dist,
              durationMinutes: dur,
            );
          }
        }
      }
    } catch (_) {}
    return null;
  }

  Future<RouteResult?> findRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    List<Station>? availableStations,
  }) async {
    final route = await getRoute(startLat, startLng, endLat, endLng);
    if (route == null) return null;

    final batteryUsedPercent = _estimateBatteryUsage(route.distanceKm);

    final stops = <ChargingStop>[];
    if (availableStations != null && availableStations.isNotEmpty) {
      final stationsWithPositions = availableStations.map((s) {
        final dist = _haversineDistance(
          startLat, startLng,
          s.latitude, s.longitude,
        );
        return (station: s, distanceFromStart: dist);
      }).toList();

      stationsWithPositions.sort((a, b) => a.distanceFromStart.compareTo(b.distanceFromStart));

      Set<String> added = {};
      for (final item in stationsWithPositions) {
        if (added.length >= 5) break;
        if (added.contains(item.station.id)) continue;

        final distFromStart = item.distanceFromStart;
        final detour = _calculateDetour(
          startLat, startLng, endLat, endLng,
          item.station.latitude, item.station.longitude,
        );

        if (detour < route.distanceKm * 0.3) {
          stops.add(ChargingStop(
            station: item.station,
            distanceFromStartKm: distFromStart,
            detourKm: detour,
          ));
          added.add(item.station.id);
        }
      }
    }

    return RouteResult(
      route: route,
      chargingStops: stops,
      batteryUsedPercent: batteryUsedPercent,
    );
  }

  double _estimateBatteryUsage(double distanceKm) {
    const avgConsumptionKwhPerKm = 0.18;
    const batteryCapacityKwh = 40.0;
    final energyNeeded = distanceKm * avgConsumptionKwhPerKm;
    return (energyNeeded / batteryCapacityKwh * 100).clamp(0, 100);
  }

  double _haversineDistance(
    double lat1, double lng1,
    double lat2, double lng2,
  ) {
    const r = 6371.0;
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRad(lat1)) * cos(_toRad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    return r * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  double _toRad(double deg) => deg * pi / 180;

  double _calculateDetour(
    double startLat, double startLng,
    double endLat, double endLng,
    double pointLat, double pointLng,
  ) {
    final directDist =
        _haversineDistance(startLat, startLng, endLat, endLng);
    final viaDist = _haversineDistance(startLat, startLng, pointLat, pointLng) +
        _haversineDistance(pointLat, pointLng, endLat, endLng);
    return viaDist - directDist;
  }

  void dispose() {
    _client.close();
  }
}
