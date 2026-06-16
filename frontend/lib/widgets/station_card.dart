import 'package:flutter/material.dart';
import 'package:ev_connect_india/models/station.dart';
import 'package:ev_connect_india/widgets/rating_bar.dart';
import 'package:ev_connect_india/widgets/charger_type_chip.dart';

class StationCard extends StatelessWidget {
  final Station station;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const StationCard({
    super.key,
    required this.station,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.ev_station,
                      size: 40,
                      color: colorScheme.primary.withValues(alpha: 0.5),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.white,
                        size: 20,
                      ),
                      onPressed: onFavoriteTap,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black26,
                        padding: const EdgeInsets.all(6),
                        minimumSize: const Size(32, 32),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(station.status).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        station.status.value.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          station.address,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (station.distanceKm != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      '${station.distanceKm!.toStringAsFixed(1)} km',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      RatingBar(rating: station.rating, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${station.rating.toStringAsFixed(1)}',
                        style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Text(
                        station.pricing.priceRange,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 28,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: station.connectors.take(3).map((c) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChargerTypeChip(connector: c),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(StationStatus status) {
    switch (status) {
      case StationStatus.available:
        return Colors.green;
      case StationStatus.busy:
        return Colors.orange;
      case StationStatus.closed:
        return Colors.red;
      case StationStatus.maintenance:
        return Colors.grey;
    }
  }
}
