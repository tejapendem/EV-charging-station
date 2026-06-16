import 'package:flutter/material.dart';
import 'package:ev_connect_india/models/charger_type.dart';

class ChargerTypeChip extends StatelessWidget {
  final ChargerConnector connector;
  final bool showPower;

  const ChargerTypeChip({
    super.key,
    required this.connector,
    this.showPower = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: connector.isAvailable
            ? colorScheme.primaryContainer
            : colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, size: 14, color: colorScheme.onPrimaryContainer),
          const SizedBox(width: 4),
          Text(
            connector.type.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          if (showPower) ...[
            const SizedBox(width: 4),
            Text(
              '${connector.powerKw.toInt()}kW',
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
