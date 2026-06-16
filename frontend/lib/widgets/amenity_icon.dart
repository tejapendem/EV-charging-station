import 'package:flutter/material.dart';
import 'package:ev_connect_india/models/amenity.dart';

class AmenityIcon extends StatelessWidget {
  final Amenity amenity;
  final double size;

  const AmenityIcon({
    super.key,
    required this.amenity,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Icon(
      amenity.type.icon,
      size: size,
      color: amenity.isAvailable
          ? colorScheme.primary
          : colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
    );
  }
}
