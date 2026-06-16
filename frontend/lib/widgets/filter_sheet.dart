import 'package:ev_connect_india/config/app_config.dart';
import 'package:ev_connect_india/models/charger_type.dart';
import 'package:ev_connect_india/providers/station_provider.dart';
import 'package:ev_connect_india/theme/color_schemes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key});

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late String? _selectedChargerType;
  late String? _selectedSpeed;
  late bool _isOpenOnly;
  late double _radiusKm;
  late double _minRating;

  @override
  void initState() {
    super.initState();
    final filters = ref.read(stationFilterProvider);
    _selectedChargerType = filters.chargerType;
    _selectedSpeed = filters.speedCategory;
    _isOpenOnly = filters.isOpenOnly ?? false;
    _radiusKm = filters.radiusKm ?? AppConfig.defaultRadiusKm;
    _minRating = filters.minRating ?? 0;
  }

  void _apply() {
    ref.read(stationFilterProvider.notifier).state =
        const StationFilterState().copyWith(
      chargerType: _selectedChargerType,
      speedCategory: _selectedSpeed,
      isOpenOnly: _isOpenOnly,
      radiusKm: _radiusKm,
      minRating: _minRating > 0 ? _minRating : null,
    );

    ref.read(stationListProvider.notifier).setFilters(
          ref.read(stationFilterProvider),
        );

    Navigator.pop(context);
  }

  void _reset() {
    setState(() {
      _selectedChargerType = null;
      _selectedSpeed = null;
      _isOpenOnly = false;
      _radiusKm = AppConfig.defaultRadiusKm;
      _minRating = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 24),
              _buildChargerTypeSection(theme),
              const SizedBox(height: 24),
              _buildSpeedSection(theme),
              const SizedBox(height: 24),
              _buildRadiusSection(theme),
              const SizedBox(height: 24),
              _buildRatingSection(theme),
              const SizedBox(height: 24),
              _buildOpenNowToggle(theme),
              const SizedBox(height: 32),
              _buildActions(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Filters',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        TextButton(
          onPressed: _reset,
          child: const Text('Reset All'),
        ),
      ],
    );
  }

  Widget _buildChargerTypeSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Charger Type',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConfig.availableChargerTypes.map((type) {
            final selected = _selectedChargerType == type;
            return ChoiceChip(
              label: Text(type),
              selected: selected,
              onSelected: (isSelected) {
                setState(() {
                  _selectedChargerType = isSelected ? type : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSpeedSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Charging Speed',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppConfig.chargingSpeeds.map((speed) {
            final selected = _selectedSpeed == speed;
            return ChoiceChip(
              label: Text(speed),
              selected: selected,
              onSelected: (isSelected) {
                setState(() {
                  _selectedSpeed = isSelected ? speed : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRadiusSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Search Radius',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_radiusKm.round()} km',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: EVColorSchemes.primaryGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: EVColorSchemes.primaryGreen,
            thumbColor: EVColorSchemes.primaryGreen,
            inactiveTrackColor: theme.colorScheme.surfaceVariant,
            overlayColor: EVColorSchemes.primaryGreen.withValues(alpha: 0.12),
          ),
          child: Slider(
            value: _radiusKm,
            min: 1,
            max: AppConfig.maxRadiusKm,
            divisions: 99,
            label: '${_radiusKm.round()} km',
            onChanged: (value) {
              setState(() {
                _radiusKm = value;
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('1 km', style: theme.textTheme.labelSmall),
            Text('${AppConfig.maxRadiusKm.round()} km',
                style: theme.textTheme.labelSmall),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Minimum Rating',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (_minRating > 0)
              Text(
                '${_minRating.toStringAsFixed(1)}+',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: EVColorSchemes.tertiaryAmber,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [0, 3.0, 3.5, 4.0, 4.5].map((rating) {
            final selected = _minRating == rating;
            return ChoiceChip(
              label: Text(
                rating == 0 ? 'Any' : '$rating+',
              ),
              selected: selected,
              onSelected: (_) {
                setState(() {
                  _minRating = rating;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOpenNowToggle(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Open Now',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Switch(
          value: _isOpenOnly,
          onChanged: (value) {
            setState(() {
              _isOpenOnly = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _apply,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Apply Filters'),
          ),
        ),
      ],
    );
  }
}

void showFilterSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => const FilterSheet(),
  );
}
