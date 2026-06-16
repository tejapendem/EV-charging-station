import 'package:flutter/material.dart';
import 'package:ev_connect_india/models/station.dart';
import 'package:ev_connect_india/widgets/charger_type_chip.dart';
import 'package:ev_connect_india/widgets/rating_bar.dart';

class MapBottomSheet extends StatelessWidget {
  final Station station;
  final VoidCallback onNavigate;
  final VoidCallback onViewDetails;

  const MapBottomSheet({
    super.key,
    required this.station,
    required this.onNavigate,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, -4))],
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.35,
        minChildSize: 0.15,
        maxChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: colorScheme.primaryContainer),
                      child: Icon(Icons.ev_station, size: 32, color: colorScheme.onPrimaryContainer),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(station.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on, size: 14, color: colorScheme.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(station.address, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                          if (station.distanceKm != null) ...[
                            const SizedBox(height: 2),
                            Text('${station.distanceKm!.toStringAsFixed(1)} km away', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w600)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 10, height: 10,
                      decoration: BoxDecoration(color: _statusColor(station.status), shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(_statusLabel(station.status), style: TextStyle(color: _statusColor(station.status), fontWeight: FontWeight.w600, fontSize: 13)),
                    const Spacer(),
                    Text('${station.totalConnectors} connectors', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: station.connectors.map((c) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChargerTypeChip(connector: c),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    RatingBar(rating: station.rating),
                    const SizedBox(width: 8),
                    Text('${station.rating.toStringAsFixed(1)}', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Text(station.pricing.priceRange, style: theme.textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onNavigate,
                        icon: const Icon(Icons.navigation),
                        label: const Text('Navigate'),
                        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onViewDetails,
                        icon: const Icon(Icons.info_outline),
                        label: const Text('Details'),
                        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _statusColor(StationStatus status) {
    switch (status) {
      case StationStatus.available: return Colors.green;
      case StationStatus.busy: return Colors.orange;
      case StationStatus.closed: return Colors.red;
      case StationStatus.maintenance: return Colors.grey;
    }
  }

  String _statusLabel(StationStatus status) {
    switch (status) {
      case StationStatus.available: return 'Available';
      case StationStatus.busy: return 'Partially Available';
      case StationStatus.closed: return 'Closed';
      case StationStatus.maintenance: return 'Under Maintenance';
    }
  }
}
