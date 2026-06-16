import 'package:ev_connect_india/models/station.dart';

class Favorite {
  final String id;
  final String userId;
  final String stationId;
  final Station? station;
  final DateTime createdAt;

  const Favorite({
    required this.id,
    required this.userId,
    required this.stationId,
    this.station,
    required this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      stationId: json['station_id'] as String,
      station: json['station'] != null
          ? Station.fromJson(json['station'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'station_id': stationId,
      'station': station?.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Favorite copyWith({
    String? id,
    String? userId,
    String? stationId,
    Station? station,
    DateTime? createdAt,
  }) {
    return Favorite(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      stationId: stationId ?? this.stationId,
      station: station ?? this.station,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
