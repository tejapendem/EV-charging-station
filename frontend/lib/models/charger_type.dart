enum ChargerType {
  ccs2('CCS2', 'CCS2', 350),
  chademo('CHAdeMO', 'CHAdeMO', 100),
  type2('Type 2', 'Type 2', 22),
  gbt('GB/T', 'GB/T', 250),
  bharatAC001('Bharat AC-001', 'Bharat AC-001', 15),
  bharatDC001('Bharat DC-001', 'Bharat DC-001', 30),
  tesla('Tesla Supercharger', 'Tesla', 250);

  final String displayName;
  final String apiValue;
  final double maxPowerKw;

  const ChargerType(this.displayName, this.apiValue, this.maxPowerKw);

  static ChargerType fromString(String value) {
    return ChargerType.values.firstWhere(
      (type) => type.apiValue == value || type.name == value,
      orElse: () => ChargerType.type2,
    );
  }

  String get iconAsset {
    switch (this) {
      case ChargerType.ccs2:
        return 'assets/images/charger_ccs2.svg';
      case ChargerType.chademo:
        return 'assets/images/charger_chademo.svg';
      case ChargerType.type2:
        return 'assets/images/charger_type2.svg';
      case ChargerType.gbt:
        return 'assets/images/charger_gbt.svg';
      case ChargerType.bharatAC001:
        return 'assets/images/charger_bharat_ac.svg';
      case ChargerType.bharatDC001:
        return 'assets/images/charger_bharat_dc.svg';
      case ChargerType.tesla:
        return 'assets/images/charger_tesla.svg';
    }
  }

  String get speedCategory {
    if (maxPowerKw < 22) return 'Slow';
    if (maxPowerKw <= 50) return 'Fast';
    if (maxPowerKw <= 150) return 'Rapid';
    return 'Ultra-Rapid';
  }

  double get estimatedChargeTimeMinutes {
    // Estimated time to charge 60 kWh battery from 20% to 80%
    switch (this) {
      case ChargerType.ccs2:
        return 25;
      case ChargerType.chademo:
        return 45;
      case ChargerType.type2:
        return 180;
      case ChargerType.gbt:
        return 35;
      case ChargerType.bharatAC001:
        return 240;
      case ChargerType.bharatDC001:
        return 120;
      case ChargerType.tesla:
        return 25;
    }
  }
}

class ChargerConnector {
  final String id;
  final ChargerType type;
  final double powerKw;
  final int totalConnectors;
  final int availableConnectors;
  final ConnectorStatus status;
  final double? pricePerKwh;

  const ChargerConnector({
    required this.id,
    required this.type,
    required this.powerKw,
    required this.totalConnectors,
    required this.availableConnectors,
    required this.status,
    this.pricePerKwh,
  });

  factory ChargerConnector.fromJson(Map<String, dynamic> json) {
    final rawType = json['type'] ?? json['charger_type'] as String? ?? 'Type2';
    final rawPower = json['power_kw'] ?? json['power_output'];
    final rawTotal = json['total_connectors'] ?? json['quantity'];
    final rawAvailable = json['available_connectors'];
    final rawStatus =
        json['status'] ?? json['connector_status'] as String? ?? 'available';
    final rawPrice = json['price_per_kwh'];

    final total = rawTotal != null ? (rawTotal is int ? rawTotal : int.parse(rawTotal.toString())) : 1;
    final available = rawAvailable != null
        ? (rawAvailable is int ? rawAvailable : int.parse(rawAvailable.toString()))
        : (rawStatus.toString().toUpperCase() == 'ACTIVE' ? total : 0);

    return ChargerConnector(
      id: json['id'] as String,
      type: ChargerType.fromString(rawType.toString()),
      powerKw: double.parse(rawPower.toString()),
      totalConnectors: total,
      availableConnectors: available,
      status: ConnectorStatus.fromString(rawStatus.toString()),
      pricePerKwh: rawPrice != null ? double.parse(rawPrice.toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.apiValue,
      'power_kw': powerKw,
      'total_connectors': totalConnectors,
      'available_connectors': availableConnectors,
      'status': status.value,
      'price_per_kwh': pricePerKwh,
    };
  }

  bool get isAvailable => status == ConnectorStatus.available;

  double get availabilityRatio =>
      totalConnectors > 0 ? availableConnectors / totalConnectors : 0.0;
}

enum ConnectorStatus {
  available('available'),
  occupied('occupied'),
  offline('offline'),
  maintenance('maintenance');

  final String value;
  const ConnectorStatus(this.value);

  static ConnectorStatus fromString(String value) {
    final normalized = value.toUpperCase();
    if (normalized == 'ACTIVE') return ConnectorStatus.available;
    if (normalized == 'INACTIVE' || normalized == 'OFFLINE') return ConnectorStatus.offline;
    if (normalized == 'OCCUPIED' || normalized == 'BUSY') return ConnectorStatus.occupied;
    if (normalized == 'MAINTENANCE') return ConnectorStatus.maintenance;
    return ConnectorStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => ConnectorStatus.offline,
    );
  }
}
