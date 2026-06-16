class Review {
  final String id;
  final String stationId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final int rating;
  final String comment;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likeCount;
  final bool isLikedByUser;
  final bool isVerifiedPurchase;

  const Review({
    required this.id,
    required this.stationId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.rating,
    required this.comment,
    this.imageUrls = const [],
    required this.createdAt,
    required this.updatedAt,
    this.likeCount = 0,
    this.isLikedByUser = false,
    this.isVerifiedPurchase = false,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      stationId: json['station_id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String? ?? 'Anonymous',
      userPhotoUrl: json['user_photo_url'] as String?,
      rating: json['rating'] as int,
      comment: json['comment'] as String? ?? '',
      imageUrls: (json['image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      likeCount: json['like_count'] as int? ?? 0,
      isLikedByUser: json['is_liked_by_user'] as bool? ?? false,
      isVerifiedPurchase: json['is_verified_purchase'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'station_id': stationId,
      'user_id': userId,
      'user_name': userName,
      'user_photo_url': userPhotoUrl,
      'rating': rating,
      'comment': comment,
      'image_urls': imageUrls,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'like_count': likeCount,
      'is_liked_by_user': isLikedByUser,
      'is_verified_purchase': isVerifiedPurchase,
    };
  }

  Review copyWith({
    String? id,
    String? stationId,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    int? rating,
    String? comment,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likeCount,
    bool? isLikedByUser,
    bool? isVerifiedPurchase,
  }) {
    return Review(
      id: id ?? this.id,
      stationId: stationId ?? this.stationId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likeCount: likeCount ?? this.likeCount,
      isLikedByUser: isLikedByUser ?? this.isLikedByUser,
      isVerifiedPurchase: isVerifiedPurchase ?? this.isVerifiedPurchase,
    );
  }
}
