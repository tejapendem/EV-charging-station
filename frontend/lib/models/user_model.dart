class AppUser {
  final String id;
  final String? email;
  final String? phoneNumber;
  final String displayName;
  final String? photoUrl;
  final String? fcmToken;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final AuthProvider authProvider;
  final UserRole role;
  final VehicleInfo? vehicle;
  final Map<String, dynamic>? preferences;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const AppUser({
    required this.id,
    this.email,
    this.phoneNumber,
    required this.displayName,
    this.photoUrl,
    this.fcmToken,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.authProvider = AuthProvider.email,
    this.role = UserRole.user,
    this.vehicle,
    this.preferences,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String?,
      phoneNumber: json['phone_number'] as String?,
      displayName: json['display_name'] as String? ?? '',
      photoUrl: json['photo_url'] as String?,
      fcmToken: json['fcm_token'] as String?,
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      isPhoneVerified: json['is_phone_verified'] as bool? ?? false,
      authProvider: AuthProvider.fromString(
        json['auth_provider'] as String? ?? 'email',
      ),
      role: UserRole.fromString(json['role'] as String? ?? 'user'),
      vehicle: json['vehicle'] != null
          ? VehicleInfo.fromJson(json['vehicle'] as Map<String, dynamic>)
          : null,
      preferences: json['preferences'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone_number': phoneNumber,
      'display_name': displayName,
      'photo_url': photoUrl,
      'fcm_token': fcmToken,
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'auth_provider': authProvider.value,
      'role': role.value,
      'vehicle': vehicle?.toJson(),
      'preferences': preferences,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? displayName,
    String? photoUrl,
    String? fcmToken,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    AuthProvider? authProvider,
    UserRole? role,
    VehicleInfo? vehicle,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      authProvider: authProvider ?? this.authProvider,
      role: role ?? this.role,
      vehicle: vehicle ?? this.vehicle,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  bool get isAuthenticated => id.isNotEmpty;

  String get initials {
    if (displayName.isEmpty) return 'U';
    final parts = displayName.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return displayName[0].toUpperCase();
  }
}

class VehicleInfo {
  final String? make;
  final String? model;
  final int? year;
  final String? batteryCapacityKwh;
  final String? connectorType;

  const VehicleInfo({
    this.make,
    this.model,
    this.year,
    this.batteryCapacityKwh,
    this.connectorType,
  });

  factory VehicleInfo.fromJson(Map<String, dynamic> json) {
    return VehicleInfo(
      make: json['make'] as String?,
      model: json['model'] as String?,
      year: json['year'] as int?,
      batteryCapacityKwh: json['battery_capacity_kwh'] as String?,
      connectorType: json['connector_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'make': make,
      'model': model,
      'year': year,
      'battery_capacity_kwh': batteryCapacityKwh,
      'connector_type': connectorType,
    };
  }
}

enum AuthProvider {
  email('email'),
  google('google'),
  phone('phone'),
  apple('apple');

  final String value;
  const AuthProvider(this.value);

  static AuthProvider fromString(String value) {
    return AuthProvider.values.firstWhere(
      (p) => p.value == value,
      orElse: () => AuthProvider.email,
    );
  }
}

enum UserRole {
  user('user'),
  stationOwner('station_owner'),
  admin('admin');

  final String value;
  const UserRole(this.value);

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (r) => r.value == value,
      orElse: () => UserRole.user,
    );
  }
}
