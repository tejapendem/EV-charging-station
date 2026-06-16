import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ev_connect_india/providers/station_provider.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  final Set<String> _selectedChargerTypes = {};
  final Set<String> _selectedSpeeds = {};
  final Set<String> _selectedAvailability = {};

  final _chargerTypes = ['CCS2', 'Type 2', 'CHAdeMO', 'Bharat DC-001', 'Bharat AC-001'];

  final _speeds = [
    {'label': 'Slow (<22kW)', 'value': 'slow'},
    {'label': 'Fast (22-100kW)', 'value': 'fast'},
    {'label': 'Ultra Fast (>100kW)', 'value': 'ultra'},
  ];

  final _availabilityOptions = [
    {'label': 'Available', 'value': 'available'},
    {'label': 'Occupied', 'value': 'occupied'},
    {'label': 'Offline', 'value': 'offline'},
  ];

  void _reset() {
    setState(() {
      _selectedChargerTypes.clear();
      _selectedSpeeds.clear();
      _selectedAvailability.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Filters', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              TextButton(onPressed: _reset, child: const Text('Reset')),
            ],
          ),
          const SizedBox(height: 24),
          Text('Charger Type', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _chargerTypes.map((type) {
              final selected = _selectedChargerTypes.contains(type);
              return FilterChip(
                label: Text(type),
                selected: selected,
                onSelected: (v) => setState(() => v ? _selectedChargerTypes.add(type) : _selectedChargerTypes.remove(type)),
                selectedColor: colorScheme.primaryContainer,
                checkmarkColor: colorScheme.onPrimaryContainer,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Charging Speed', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _speeds.map((speed) {
              final selected = _selectedSpeeds.contains(speed['value']);
              return FilterChip(
                label: Text(speed['label']!),
                selected: selected,
                onSelected: (v) => setState(() => v ? _selectedSpeeds.add(speed['value']!) : _selectedSpeeds.remove(speed['value']!)),
                selectedColor: colorScheme.primaryContainer,
                checkmarkColor: colorScheme.onPrimaryContainer,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Availability', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: _availabilityOptions.map((opt) {
              final selected = _selectedAvailability.contains(opt['value']);
              return FilterChip(
                label: Text(opt['label']!),
                selected: selected,
                onSelected: (v) => setState(() => v ? _selectedAvailability.add(opt['value']!) : _selectedAvailability.remove(opt['value']!)),
                selectedColor: colorScheme.primaryContainer,
                checkmarkColor: colorScheme.onPrimaryContainer,
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _reset,
                  style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    ref.read(stationFilterProvider.notifier).state = StationFilterState(
                      chargerType: _selectedChargerTypes.isNotEmpty ? _selectedChargerTypes.first : null,
                      speedCategory: _selectedSpeeds.isNotEmpty ? _selectedSpeeds.first : null,
                    );
                    ref.read(stationListProvider.notifier).setFilters(ref.read(stationFilterProvider));
                    Navigator.pop(context);
                  },
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
