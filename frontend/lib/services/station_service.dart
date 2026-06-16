import 'package:ev_connect_india/models/review.dart';
import 'package:ev_connect_india/models/station.dart';
import 'package:ev_connect_india/services/api_service.dart';

class StationService {
  static final StationService _instance = StationService._internal();
  factory StationService() => _instance;
  StationService._internal();

  final ApiService _apiService = ApiService();

  Future<List<Station>> getStations({
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? query,
    String? chargerType,
    String? speedCategory,
    bool? isOpen,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (latitude != null) params['latitude'] = latitude.toStringAsFixed(6);
    if (longitude != null) params['longitude'] = longitude.toStringAsFixed(6);
    if (radiusKm != null) params['radius_km'] = radiusKm.toStringAsFixed(1);
    if (query != null && query.isNotEmpty) params['query'] = query;
    if (chargerType != null && chargerType.isNotEmpty) {
      params['charger_type'] = chargerType;
    }
    if (speedCategory != null && speedCategory.isNotEmpty) {
      params['speed_category'] = speedCategory;
    }
    if (isOpen != null) params['is_open'] = isOpen.toString();

    final response = await _apiService.get('/stations', queryParams: params);

    if (response.isSuccess && response.data != null) {
      final stationsJson = response.data!['stations'] as List<dynamic>? ?? [];
      final stations = stationsJson
          .map((s) => Station.fromJson(s as Map<String, dynamic>))
          .toList();
      return stations;
    }

    throw ApiException(
      message: response.error ?? 'Failed to load stations',
      statusCode: response.statusCode,
    );
  }

  Future<Station> getStationById(String stationId) async {
    final response = await _apiService.get('/stations/$stationId');

    if (response.isSuccess && response.data != null) {
      return Station.fromJson(response.data!);
    }

    throw ApiException(
      message: response.error ?? 'Failed to load station details',
      statusCode: response.statusCode,
    );
  }

  Future<List<Station>> searchStations({
    required String query,
    double? latitude,
    double? longitude,
    int limit = 10,
  }) async {
    final params = <String, String>{
      'query': query,
      'limit': limit.toString(),
    };

    if (latitude != null) params['latitude'] = latitude.toStringAsFixed(6);
    if (longitude != null) params['longitude'] = longitude.toStringAsFixed(6);

    final response = await _apiService.get('/stations/search', queryParams: params);

    if (response.isSuccess && response.data != null) {
      final stationsJson = response.data!['stations'] as List<dynamic>? ?? [];
      return stationsJson
          .map((s) => Station.fromJson(s as Map<String, dynamic>))
          .toList();
    }

    throw ApiException(
      message: response.error ?? 'Search failed',
      statusCode: response.statusCode,
    );
  }

  Future<List<Station>> getNearbyStations({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    int limit = 50,
  }) async {
    return getStations(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      limit: limit,
    );
  }

  Future<List<Review>> getStationReviews(String stationId, {int page = 1, int limit = 20}) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final response = await _apiService.get(
      '/stations/$stationId/reviews',
      queryParams: params,
    );

    if (response.isSuccess && response.data != null) {
      final reviewsJson = response.data!['reviews'] as List<dynamic>? ?? [];
      return reviewsJson
          .map((r) => Review.fromJson(r as Map<String, dynamic>))
          .toList();
    }

    throw ApiException(
      message: response.error ?? 'Failed to load reviews',
      statusCode: response.statusCode,
    );
  }

  Future<Review> addReview({
    required String stationId,
    required int rating,
    required String comment,
    List<String>? imageUrls,
  }) async {
    final response = await _apiService.post('/stations/$stationId/reviews', body: {
      'rating': rating,
      'comment': comment,
      'image_urls': imageUrls ?? [],
    });

    if (response.isSuccess && response.data != null) {
      return Review.fromJson(response.data!);
    }

    throw ApiException(
      message: response.error ?? 'Failed to add review',
      statusCode: response.statusCode,
    );
  }

  Future<void> toggleFavorite(String stationId) async {
    final response = await _apiService.post('/stations/$stationId/favorite');

    if (!response.isSuccess) {
      throw ApiException(
        message: response.error ?? 'Failed to toggle favorite',
        statusCode: response.statusCode,
      );
    }
  }

  Future<List<Station>> getFavoriteStations({int page = 1, int limit = 20}) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final response = await _apiService.get('/favorites', queryParams: params);

    if (response.isSuccess && response.data != null) {
      final stationsJson = response.data!['favorites'] as List<dynamic>? ?? [];
      return stationsJson
          .map((s) => Station.fromJson(s as Map<String, dynamic>))
          .toList();
    }

    throw ApiException(
      message: response.error ?? 'Failed to load favorites',
      statusCode: response.statusCode,
    );
  }

  Future<List<Map<String, dynamic>>> getExternalChargers({
    required double latitude,
    required double longitude,
    double distance = 10,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'lat': latitude.toStringAsFixed(6),
      'lon': longitude.toStringAsFixed(6),
      'distance': distance.toStringAsFixed(1),
      'limit': limit.toString(),
    };

    final response = await _apiService.get('/external-chargers', queryParams: params);

    if (response.isSuccess && response.data != null) {
      final chargers = response.data!['chargers'] as List<dynamic>? ?? [];
      return chargers.cast<Map<String, dynamic>>();
    }

    return [];
  }

  Future<Map<String, dynamic>> getStationAnalytics(String stationId) async {
    final response = await _apiService.get('/stations/$stationId/analytics');

    if (response.isSuccess && response.data != null) {
      return response.data!;
    }

    throw ApiException(
      message: response.error ?? 'Failed to load analytics',
      statusCode: response.statusCode,
    );
  }
}
