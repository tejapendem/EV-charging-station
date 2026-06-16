import 'package:ev_connect_india/models/amenity.dart';
import 'package:ev_connect_india/models/charger_type.dart';
import 'package:ev_connect_india/models/review.dart';

double _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.parse(value.toString());
}

class Station {
  final String id;
  final String name;
  final String address;
  final String? city;
  final String? state;
  final String? pincode;
  final String? landmark;
  final double latitude;
  final double longitude;
  final double? distanceKm;
  final List<ChargerConnector> connectors;
  final List<Amenity> amenities;
  final StationStatus status;
  final double rating;
  final int totalReviews;
  final List<Review>? reviews;
  final String? ownerId;
  final String? ownerName;
  final String? phoneNumber;
  final String? alternatePhone;
  final OperatingHours? operatingHours;
  final PricingInfo pricing;
  final List<String> imageUrls;
  final String? thumbnailUrl;
  final bool isVerified;
  final bool isFavorite;
  final bool isOpen24x7;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int totalBookings;

  const Station({
    required this.id,
    required this.name,
    required this.address,
    this.city,
    this.state,
    this.pincode,
    this.landmark,
    required this.latitude,
    required this.longitude,
    this.distanceKm,
    this.connectors = const [],
    this.amenities = const [],
    this.status = StationStatus.available,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.reviews,
    this.ownerId,
    this.ownerName,
    this.phoneNumber,
    this.alternatePhone,
    this.operatingHours,
    required this.pricing,
    this.imageUrls = const [],
    this.thumbnailUrl,
    this.isVerified = false,
    this.isFavorite = false,
    this.isOpen24x7 = false,
    required this.createdAt,
    required this.updatedAt,
    this.totalBookings = 0,
  });

  factory Station.fromJson(Map<String, dynamic> json) {
    final rawConnectors =
        json['connectors'] ?? json['chargers'] as List<dynamic>?;
    final connectorsList = rawConnectors == null
        ? <ChargerConnector>[]
        : (rawConnectors as List<dynamic>)
            .map((c) => ChargerConnector.fromJson(c as Map<String, dynamic>))
            .toList();

    final rawAmenities = json['amenities'] as List<dynamic>?;
    final amenityList = rawAmenities == null
        ? <Amenity>[]
        : rawAmenities.map((a) {
            if (a is Map<String, dynamic>) {
              return Amenity.fromJson(a);
            }
            return Amenity(
              id: a.toString(),
              type: AmenityType.fromString(a.toString()),
            );
          }).toList();

    final rating = json['rating'] ?? json['avg_rating'];
    final totalReviews = json['total_reviews'] ?? json['totalReviews'];

    final phone = json['phone_number'] ?? json['phone'];

    final rawImages = json['image_urls'] ?? json['images'] as List<dynamic>?;
    final imageList = rawImages == null
        ? <String>[]
        : (rawImages as List<dynamic>).map((e) {
            if (e is String) return e;
            if (e is Map<String, dynamic>) return e['url'] as String? ?? '';
            return e.toString();
          }).where((s) => s.isNotEmpty).toList();
    if (json['image_url'] != null && imageList.isEmpty) {
      imageList.add(json['image_url'] as String);
    }

    return Station(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
      landmark: json['landmark'] as String?,
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      distanceKm: json['distance_km'] != null
          ? _toDouble(json['distance_km'])
          : null,
      connectors: connectorsList,
      amenities: amenityList,
      status:
          StationStatus.fromString(json['status'] as String? ?? 'available'),
      rating: rating != null ? _toDouble(rating) : 0.0,
      totalReviews: totalReviews as int? ?? 0,
      reviews: (json['reviews'] as List<dynamic>?)
          ?.map((r) => Review.fromJson(r as Map<String, dynamic>))
          .toList(),
      ownerId: json['owner_id'] as String?,
      ownerName: json['owner_name'] as String?,
      phoneNumber: phone as String?,
      alternatePhone: json['alternate_phone'] as String?,
      operatingHours: json['operating_hours'] is Map
          ? OperatingHours.fromJson(
              json['operating_hours'] as Map<String, dynamic>,
            )
          : null,
      pricing: json['pricing'] is Map
          ? PricingInfo.fromJson(
              json['pricing'] as Map<String, dynamic>,
            )
          : const PricingInfo(),
      imageUrls: imageList,
      thumbnailUrl: json['thumbnail_url'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      isFavorite: json['is_favorite'] as bool? ?? false,
      isOpen24x7: json['is_open_24x7'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      totalBookings: json['total_bookings'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'landmark': landmark,
      'latitude': latitude,
      'longitude': longitude,
      'distance_km': distanceKm,
      'connectors': connectors.map((c) => c.toJson()).toList(),
      'amenities': amenities.map((a) => a.toJson()).toList(),
      'status': status.value,
      'rating': rating,
      'total_reviews': totalReviews,
      'reviews': reviews?.map((r) => r.toJson()).toList(),
      'owner_id': ownerId,
      'owner_name': ownerName,
      'phone_number': phoneNumber,
      'alternate_phone': alternatePhone,
      'operating_hours': operatingHours?.toJson(),
      'pricing': pricing.toJson(),
      'image_urls': imageUrls,
      'thumbnail_url': thumbnailUrl,
      'is_verified': isVerified,
      'is_favorite': isFavorite,
      'is_open_24x7': isOpen24x7,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'total_bookings': totalBookings,
    };
  }

  Station copyWith({
    String? id,
    String? name,
    String? address,
    String? city,
    String? state,
    String? pincode,
    String? landmark,
    double? latitude,
    double? longitude,
    double? distanceKm,
    List<ChargerConnector>? connectors,
    List<Amenity>? amenities,
    StationStatus? status,
    double? rating,
    int? totalReviews,
    List<Review>? reviews,
    String? ownerId,
    String? ownerName,
    String? phoneNumber,
    String? alternatePhone,
    OperatingHours? operatingHours,
    PricingInfo? pricing,
    List<String>? imageUrls,
    String? thumbnailUrl,
    bool? isVerified,
    bool? isFavorite,
    bool? isOpen24x7,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalBookings,
  }) {
    return Station(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      landmark: landmark ?? this.landmark,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceKm: distanceKm ?? this.distanceKm,
      connectors: connectors ?? this.connectors,
      amenities: amenities ?? this.amenities,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      reviews: reviews ?? this.reviews,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      alternatePhone: alternatePhone ?? this.alternatePhone,
      operatingHours: operatingHours ?? this.operatingHours,
      pricing: pricing ?? this.pricing,
      imageUrls: imageUrls ?? this.imageUrls,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isVerified: isVerified ?? this.isVerified,
      isFavorite: isFavorite ?? this.isFavorite,
      isOpen24x7: isOpen24x7 ?? this.isOpen24x7,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalBookings: totalBookings ?? this.totalBookings,
    );
  }

  int get totalConnectors => connectors.length;
  int get availableConnectors =>
      connectors.where((c) => c.isAvailable).length;

  bool get hasAvailableChargers => availableConnectors > 0;

  List<ChargerConnector> get availableConnectorsList =>
      connectors.where((c) => c.isAvailable).toList();

  List<String> get chargerTypeNames =>
      connectors.map((c) => c.type.displayName).toSet().toList();

  String get connectorSummary {
    final counts = <String, int>{};
    for (final c in connectors) {
      counts[c.type.displayName] =
          (counts[c.type.displayName] ?? 0) + c.totalConnectors;
    }
    return counts.entries
        .map((e) => '${e.value}x ${e.key}')
        .join(', ');
  }

  double get minPricePerKwh {
    final prices = connectors
        .where((c) => c.pricePerKwh != null)
        .map((c) => c.pricePerKwh!)
        .toList();
    if (prices.isEmpty) return 0.0;
    return prices.reduce((a, b) => a < b ? a : b);
  }

  double get maxPricePerKwh {
    final prices = connectors
        .where((c) => c.pricePerKwh != null)
        .map((c) => c.pricePerKwh!)
        .toList();
    if (prices.isEmpty) return 0.0;
    return prices.reduce((a, b) => a > b ? a : b);
  }
}

enum StationStatus {
  available('available'),
  busy('busy'),
  closed('closed'),
  maintenance('maintenance');

  final String value;
  const StationStatus(this.value);

  static StationStatus fromString(String value) {
    return StationStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => StationStatus.available,
    );
  }
}

class OperatingHours {
  final TimeRange monday;
  final TimeRange tuesday;
  final TimeRange wednesday;
  final TimeRange thursday;
  final TimeRange friday;
  final TimeRange saturday;
  final TimeRange sunday;

  const OperatingHours({
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });

  factory OperatingHours.fromJson(Map<String, dynamic> json) {
    return OperatingHours(
      monday: TimeRange.fromJson(json['monday'] as Map<String, dynamic>? ?? {}),
      tuesday: TimeRange.fromJson(json['tuesday'] as Map<String, dynamic>? ?? {}),
      wednesday:
          TimeRange.fromJson(json['wednesday'] as Map<String, dynamic>? ?? {}),
      thursday:
          TimeRange.fromJson(json['thursday'] as Map<String, dynamic>? ?? {}),
      friday: TimeRange.fromJson(json['friday'] as Map<String, dynamic>? ?? {}),
      saturday:
          TimeRange.fromJson(json['saturday'] as Map<String, dynamic>? ?? {}),
      sunday: TimeRange.fromJson(json['sunday'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monday': monday.toJson(),
      'tuesday': tuesday.toJson(),
      'wednesday': wednesday.toJson(),
      'thursday': thursday.toJson(),
      'friday': friday.toJson(),
      'saturday': saturday.toJson(),
      'sunday': sunday.toJson(),
    };
  }

  bool isOpenNow() {
    final now = DateTime.now();
    final dayOfWeek = now.weekday;
    final timeRange = _getTimeRange(dayOfWeek);
    if (timeRange == null || !timeRange.isOpen) return false;
    final currentMinutes = now.hour * 60 + now.minute;
    return currentMinutes >= timeRange.openMinutes &&
        currentMinutes <= timeRange.closeMinutes;
  }

  TimeRange? _getTimeRange(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return monday;
      case DateTime.tuesday:
        return tuesday;
      case DateTime.wednesday:
        return wednesday;
      case DateTime.thursday:
        return thursday;
      case DateTime.friday:
        return friday;
      case DateTime.saturday:
        return saturday;
      case DateTime.sunday:
        return sunday;
      default:
        return null;
    }
  }
}

class TimeRange {
  final int openMinutes;
  final int closeMinutes;
  final bool isOpen;

  const TimeRange({
    this.openMinutes = 0,
    this.closeMinutes = 0,
    this.isOpen = false,
  });

  factory TimeRange.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return const TimeRange();
    }
    return TimeRange(
      openMinutes: json['open_minutes'] as int? ?? 0,
      closeMinutes: json['close_minutes'] as int? ?? 0,
      isOpen: json['is_open'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'open_minutes': openMinutes,
      'close_minutes': closeMinutes,
      'is_open': isOpen,
    };
  }

  String get openTime {
    final h = openMinutes ~/ 60;
    final m = openMinutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  String get closeTime {
    final h = closeMinutes ~/ 60;
    final m = closeMinutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}

class PricingInfo {
  final double? acPricePerKwh;
  final double? dcFastPricePerKwh;
  final double? dcUltraFastPricePerKwh;
  final double? parkingFeePerHour;
  final double? minChargeFee;
  final double? serviceFee;
  final bool isGstIncluded;
  final double? gstPercentage;

  const PricingInfo({
    this.acPricePerKwh,
    this.dcFastPricePerKwh,
    this.dcUltraFastPricePerKwh,
    this.parkingFeePerHour,
    this.minChargeFee,
    this.serviceFee,
    this.isGstIncluded = true,
    this.gstPercentage = 18.0,
  });

  factory PricingInfo.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) {
      return const PricingInfo();
    }
    return PricingInfo(
      acPricePerKwh: json['ac_price_per_kwh'] != null
          ? _toDouble(json['ac_price_per_kwh'])
          : null,
      dcFastPricePerKwh: json['dc_fast_price_per_kwh'] != null
          ? _toDouble(json['dc_fast_price_per_kwh'])
          : null,
      dcUltraFastPricePerKwh: json['dc_ultra_fast_price_per_kwh'] != null
          ? _toDouble(json['dc_ultra_fast_price_per_kwh'])
          : null,
      parkingFeePerHour: json['parking_fee_per_hour'] != null
          ? _toDouble(json['parking_fee_per_hour'])
          : null,
      minChargeFee: json['min_charge_fee'] != null
          ? _toDouble(json['min_charge_fee'])
          : null,
      serviceFee: json['service_fee'] != null
          ? _toDouble(json['service_fee'])
          : null,
      gstPercentage: json['gst_percentage'] != null
          ? _toDouble(json['gst_percentage'])
          : 18.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ac_price_per_kwh': acPricePerKwh,
      'dc_fast_price_per_kwh': dcFastPricePerKwh,
      'dc_ultra_fast_price_per_kwh': dcUltraFastPricePerKwh,
      'parking_fee_per_hour': parkingFeePerHour,
      'min_charge_fee': minChargeFee,
      'service_fee': serviceFee,
      'is_gst_included': isGstIncluded,
      'gst_percentage': gstPercentage,
    };
  }

  String get priceRange {
    final prices = <double>[
      if (acPricePerKwh != null) acPricePerKwh!,
      if (dcFastPricePerKwh != null) dcFastPricePerKwh!,
      if (dcUltraFastPricePerKwh != null) dcUltraFastPricePerKwh!,
    ];
    if (prices.isEmpty) return 'N/A';
    prices.sort();
    if (prices.first == prices.last) {
      return '₹${prices.first.toStringAsFixed(2)}/kWh';
    }
    return '₹${prices.first.toStringAsFixed(2)} - ₹${prices.last.toStringAsFixed(2)}/kWh';
  }
}
