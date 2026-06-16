enum ReportType {
  incorrectInfo('incorrect_info', 'Incorrect Information'),
  notAvailable('not_available', 'Station Not Available'),
  pricingWrong('pricing_wrong', 'Wrong Pricing'),
  chargerBroken('charger_broken', 'Charger Not Working'),
  locationWrong('location_wrong', 'Wrong Location'),
  safety('safety', 'Safety Concern'),
  other('other', 'Other');

  final String value;
  final String displayName;
  const ReportType(this.value, this.displayName);

  static ReportType fromString(String value) {
    return ReportType.values.firstWhere(
      (r) => r.value == value,
      orElse: () => ReportType.other,
    );
  }
}

class Report {
  final String id;
  final String stationId;
  final String userId;
  final ReportType reportType;
  final String description;
  final List<String> imageUrls;
  final ReportStatus status;
  final String? adminNote;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Report({
    required this.id,
    required this.stationId,
    required this.userId,
    required this.reportType,
    required this.description,
    this.imageUrls = const [],
    this.status = ReportStatus.pending,
    this.adminNote,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'] as String,
      stationId: json['station_id'] as String,
      userId: json['user_id'] as String,
      reportType: ReportType.fromString(json['report_type'] as String),
      description: json['description'] as String? ?? '',
      imageUrls: (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      status: ReportStatus.fromString(json['status'] as String? ?? 'pending'),
      adminNote: json['admin_note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'station_id': stationId,
      'user_id': userId,
      'report_type': reportType.value,
      'description': description,
      'image_urls': imageUrls,
      'status': status.value,
      'admin_note': adminNote,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Report copyWith({
    String? id,
    String? stationId,
    String? userId,
    ReportType? reportType,
    String? description,
    List<String>? imageUrls,
    ReportStatus? status,
    String? adminNote,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Report(
      id: id ?? this.id,
      stationId: stationId ?? this.stationId,
      userId: userId ?? this.userId,
      reportType: reportType ?? this.reportType,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      status: status ?? this.status,
      adminNote: adminNote ?? this.adminNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum ReportStatus {
  pending('pending'),
  reviewed('reviewed'),
  resolved('resolved'),
  dismissed('dismissed');

  final String value;
  const ReportStatus(this.value);

  static ReportStatus fromString(String value) {
    return ReportStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => ReportStatus.pending,
    );
  }
}
