import 'package:flutter/material.dart';

enum AmenityType {
  restroom('Restroom', 'restroom', Icons.wc),
  cafeteria('Cafeteria', 'cafeteria', Icons.restaurant),
  waitingLounge('Waiting Lounge', 'waiting_lounge', Icons.airline_seat_recline_normal),
  wifi('Wi-Fi', 'wifi', Icons.wifi),
  cctv('CCTV', 'cctv', Icons.videocam),
  evg('EV Garage', 'ev_garage', Icons.build),
  tyreInflator('Tyre Inflator', 'tyre_inflator', Icons.air),
  drinkingWater('Drinking Water', 'drinking_water', Icons.local_drink),
  atm('ATM', 'atm', Icons.account_balance),
  shopping('Shopping', 'shopping', Icons.shopping_bag),
  hotel('Hotel', 'hotel', Icons.hotel),
  parking('Parking', 'parking', Icons.local_parking),
  mosque('Prayer Room', 'prayer_room', Icons.mosque),
  evShowroom('EV Showroom', 'ev_showroom', Icons.time_to_leave),
  solarRoof('Solar Roof', 'solar_roof', Icons.solar_power);

  final String displayName;
  final String apiValue;
  final IconData icon;

  const AmenityType(this.displayName, this.apiValue, this.icon);

  static AmenityType fromString(String value) {
    const backendMap = <String, AmenityType>{
      'RESTROOMS': AmenityType.restroom,
      'FOOD_COURT': AmenityType.cafeteria,
      'HOTEL': AmenityType.hotel,
      'WIFI': AmenityType.wifi,
      'PARKING': AmenityType.parking,
      'WAITING_LOUNGE': AmenityType.waitingLounge,
      'CCTV': AmenityType.cctv,
      'DRINKING_WATER': AmenityType.drinkingWater,
      'ATM': AmenityType.atm,
      'SHOPPING': AmenityType.shopping,
      'PRAYER_ROOM': AmenityType.mosque,
    };
    return backendMap[value] ??
        AmenityType.values.firstWhere(
          (a) =>
              a.apiValue.toLowerCase() == value.toLowerCase() ||
              a.name.toLowerCase() == value.toLowerCase() ||
              a.displayName.toLowerCase().replaceAll(' ', '_') ==
                  value.toLowerCase(),
          orElse: () => AmenityType.parking,
        );
  }
}

class Amenity {
  final String id;
  final AmenityType type;
  final bool isAvailable;
  final String? description;
  final bool isFree;

  const Amenity({
    required this.id,
    required this.type,
    this.isAvailable = true,
    this.description,
    this.isFree = true,
  });

  factory Amenity.fromJson(Map<String, dynamic> json) {
    return Amenity(
      id: json['id'] as String,
      type: AmenityType.fromString(json['type'] as String),
      isAvailable: json['is_available'] as bool? ?? true,
      description: json['description'] as String?,
      isFree: json['is_free'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.apiValue,
      'is_available': isAvailable,
      'description': description,
      'is_free': isFree,
    };
  }

  Amenity copyWith({
    String? id,
    AmenityType? type,
    bool? isAvailable,
    String? description,
    bool? isFree,
  }) {
    return Amenity(
      id: id ?? this.id,
      type: type ?? this.type,
      isAvailable: isAvailable ?? this.isAvailable,
      description: description ?? this.description,
      isFree: isFree ?? this.isFree,
    );
  }
}
