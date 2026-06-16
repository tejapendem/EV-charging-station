import 'dart:convert';
import 'dart:io';

import 'package:ev_connect_india/config/app_config.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  static const String _cachePrefix = 'ev_cache_';

  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  Future<void> cacheData({
    required String key,
    required dynamic data,
    Duration? duration,
  }) async {
    try {
      final cacheKey = '$_cachePrefix$key';
      final jsonString = jsonEncode(data);
      final file = await _cacheManager.putFile(
        cacheKey,
        utf8.encode(jsonString),
        key: cacheKey,
        maxAge: duration ?? AppConfig.cacheDuration,
        fileExtension: 'json',
      );
    } catch (e) {
      // Silently fail on cache write errors
    }
  }

  Future<dynamic> getCachedData(String key) async {
    try {
      final cacheKey = '$_cachePrefix$key';
      final fileInfo = await _cacheManager.getFileFromCache(cacheKey);

      if (fileInfo != null && fileInfo.file != null) {
        final file = fileInfo.file!;
        if (await file.exists()) {
          final content = await file.readAsString();
          return jsonDecode(content);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> hasCachedData(String key) async {
    final cacheKey = '$_cachePrefix$key';
    final fileInfo = await _cacheManager.getFileFromCache(cacheKey);
    return fileInfo != null && fileInfo.file != null;
  }

  Future<void> clearCache() async {
    await _cacheManager.emptyCache();
  }

  Future<void> clearCacheByKey(String key) async {
    final cacheKey = '$_cachePrefix$key';
    await _cacheManager.removeFile(cacheKey);
  }

  Future<void> clearAllAppCache() async {
    await _cacheManager.emptyCache();
  }

  Future<int> getCacheSize() async {
    try {
      final cacheInfo = await _cacheManager.getFileStream('');
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<void> evictIfNeeded() async {
    try {
      final size = await getCacheSize();
      if (size > AppConfig.maxCacheSize) {
        await clearCache();
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> cacheStationList({
    required List<Map<String, dynamic>> stations,
    required String queryKey,
  }) async {
    await cacheData(
      key: 'stations_$queryKey',
      data: stations,
      duration: const Duration(hours: 1),
    );
  }

  Future<List<Map<String, dynamic>>?> getCachedStationList(
    String queryKey,
  ) async {
    final data = await getCachedData('stations_$queryKey');
    if (data is List) {
      return data.cast<Map<String, dynamic>>();
    }
    return null;
  }

  Future<void> cacheUserProfile(Map<String, dynamic> userData) async {
    await cacheData(
      key: 'user_profile',
      data: userData,
      duration: const Duration(hours: 12),
    );
  }

  Future<Map<String, dynamic>?> getCachedUserProfile() async {
    final data = await getCachedData('user_profile');
    if (data is Map<String, dynamic>) {
      return data;
    }
    return null;
  }

  Future<void> cacheSearchHistory(List<String> queries) async {
    await cacheData(
      key: 'search_history',
      data: queries,
      duration: const Duration(days: 30),
    );
  }

  Future<List<String>?> getCachedSearchHistory() async {
    final data = await getCachedData('search_history');
    if (data is List) {
      return data.cast<String>();
    }
    return null;
  }

  void dispose() {
    _cacheManager.dispose();
  }
}
