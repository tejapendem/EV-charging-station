import 'dart:async';
import 'dart:math' show log, ln2;

import 'package:ev_connect_india/models/station.dart';
import 'package:ev_connect_india/providers/location_provider.dart';
import 'package:ev_connect_india/providers/station_provider.dart';
import 'package:ev_connect_india/services/route_service.dart';
import 'package:ev_connect_india/widgets/skeleton_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class RoutePlannerScreen extends ConsumerStatefulWidget {
  const RoutePlannerScreen({super.key});

  @override
  ConsumerState<RoutePlannerScreen> createState() =>
      _RoutePlannerScreenState();
}

class _RoutePlannerScreenState extends ConsumerState<RoutePlannerScreen> {
  final _sourceController = TextEditingController();
  final _destinationController = TextEditingController();
  final _sourceFocusNode = FocusNode();
  final _destinationFocusNode = FocusNode();
  final _routeService = RouteService();

  bool _isSearching = false;
  bool _routeFound = false;
  bool _isLoadingSuggestions = false;
  bool _showSourceSuggestions = false;
  bool _showDestSuggestions = false;

  PlaceSuggestion? _selectedSource;
  PlaceSuggestion? _selectedDest;
  RouteResult? _routeResult;
  List<PlaceSuggestion> _sourceSuggestions = [];
  List<PlaceSuggestion> _destSuggestions = [];

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _sourceController.addListener(() => _onTextChanged(true));
    _destinationController.addListener(() => _onTextChanged(false));
    _sourceFocusNode.addListener(() {
      if (!_sourceFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) setState(() => _showSourceSuggestions = false);
        });
      }
    });
    _destinationFocusNode.addListener(() {
      if (!_destinationFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted) setState(() => _showDestSuggestions = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _destinationController.dispose();
    _sourceFocusNode.dispose();
    _destinationFocusNode.dispose();
    _debounce?.cancel();
    _routeService.dispose();
    super.dispose();
  }

  void _onTextChanged(bool isSource) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _fetchSuggestions(isSource);
    });
  }

  Future<void> _fetchSuggestions(bool isSource) async {
    final query = isSource ? _sourceController.text : _destinationController.text;
    if (query.length < 2) {
      setState(() {
        if (isSource) {
          _showSourceSuggestions = false;
          _sourceSuggestions = [];
        } else {
          _showDestSuggestions = false;
          _destSuggestions = [];
        }
      });
      return;
    }

    setState(() => _isLoadingSuggestions = true);

    final suggestions = await _routeService.searchLocations(query);

    if (mounted) {
      setState(() {
        _isLoadingSuggestions = false;
        if (isSource) {
          _sourceSuggestions = suggestions;
          _showSourceSuggestions = suggestions.isNotEmpty;
        } else {
          _destSuggestions = suggestions;
          _showDestSuggestions = suggestions.isNotEmpty;
        }
      });
    }
  }

  void _selectSuggestion(bool isSource, PlaceSuggestion suggestion) {
    setState(() {
      if (isSource) {
        _sourceController.text = suggestion.displayName;
        _sourceController.selection = TextSelection.fromPosition(
          TextPosition(offset: suggestion.displayName.length),
        );
        _selectedSource = suggestion;
        _showSourceSuggestions = false;
      } else {
        _destinationController.text = suggestion.displayName;
        _destinationController.selection = TextSelection.fromPosition(
          TextPosition(offset: suggestion.displayName.length),
        );
        _selectedDest = suggestion;
        _showDestSuggestions = false;
      }
    });
  }

  Future<void> _findRoute() async {
    if (_sourceController.text.isEmpty || _destinationController.text.isEmpty) {
      return;
    }

    setState(() => _isSearching = true);

    final location = ref.read(locationProvider);

    double startLat = _selectedSource?.latitude ?? location.latitude ?? 19.076;
    double startLng = _selectedSource?.longitude ?? location.longitude ?? 72.8777;
    double endLat = _selectedDest?.latitude ?? 12.9716;
    double endLng = _selectedDest?.longitude ?? 77.5946;

    if (_selectedSource == null) {
      final results = await _routeService.searchLocations(_sourceController.text);
      if (results.isNotEmpty) {
        startLat = results.first.latitude;
        startLng = results.first.longitude;
        if (mounted) {
          setState(() => _selectedSource = results.first);
        }
      }
    }

    if (_selectedDest == null) {
      final results =
          await _routeService.searchLocations(_destinationController.text);
      if (results.isNotEmpty) {
        endLat = results.first.latitude;
        endLng = results.first.longitude;
        if (mounted) {
          setState(() => _selectedDest = results.first);
        }
      }
    }

    final stationsState = ref.read(stationListProvider);
    final result = await _routeService.findRoute(
      startLat: startLat,
      startLng: startLng,
      endLat: endLat,
      endLng: endLng,
      availableStations: stationsState.stations,
    );

    if (mounted) {
      setState(() {
        _isSearching = false;
        _routeFound = result != null;
        _routeResult = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stationsState = ref.watch(stationListProvider);
    final stations = stationsState.stations;

    return Scaffold(
      appBar: AppBar(title: const Text('Route Planner')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBox(theme, colorScheme),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _isSearching ? null : _findRoute,
                icon: _isSearching
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.route),
                label: Text(_isSearching ? 'Finding Route...' : 'Find Route'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            if (_routeResult != null) ...[
              const SizedBox(height: 24),
              _buildRouteMap(colorScheme),
              const SizedBox(height: 24),
              _buildRouteInfoCards(colorScheme),
              const SizedBox(height: 24),
              Text(
                'Charging Stops Along Route',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                'Recommended stops to keep your EV charged',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              if (_routeResult!.chargingStops.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'No charging stations found along this route. Try expanding your search area.',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ..._routeResult!.chargingStops.asMap().entries.map((entry) {
                  final stop = entry.value;
                  final stopNumber = entry.key + 1;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ChargingStopCard(
                      station: stop.station,
                      stopNumber: stopNumber,
                      distanceKm: stop.distanceFromStartKm,
                      detourKm: stop.detourKm,
                      colorScheme: colorScheme,
                      theme: theme,
                    ),
                  );
                }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBox(ThemeData theme, ColorScheme colorScheme) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 24,
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.4),
                        ),
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        TextField(
                          controller: _sourceController,
                          focusNode: _sourceFocusNode,
                          decoration: const InputDecoration(
                            hintText: 'Starting point',
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 14),
                          ),
                          onChanged: (_) {
                            setState(() {
                              _selectedSource = null;
                              _routeFound = false;
                              _routeResult = null;
                            });
                          },
                        ),
                        Divider(
                          height: 1,
                          color: colorScheme.outlineVariant,
                        ),
                        TextField(
                          controller: _destinationController,
                          focusNode: _destinationFocusNode,
                          decoration: const InputDecoration(
                            hintText: 'Destination',
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 14),
                          ),
                          onChanged: (_) {
                            setState(() {
                              _selectedDest = null;
                              _routeFound = false;
                              _routeResult = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.swap_vert),
                    onPressed: () {
                      final tempText = _sourceController.text;
                      _sourceController.text = _destinationController.text;
                      _destinationController.text = tempText;
                      final tempSel = _selectedSource;
                      _selectedSource = _selectedDest;
                      _selectedDest = tempSel;
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        if (_showSourceSuggestions)
          Positioned(
            top: 56,
            left: 0,
            right: 0,
            child: _buildSuggestionsOverlay(
              suggestions: _sourceSuggestions,
              isSource: true,
              colorScheme: colorScheme,
            ),
          ),
        if (_showDestSuggestions)
          Positioned(
            top: 104,
            left: 0,
            right: 0,
            child: _buildSuggestionsOverlay(
              suggestions: _destSuggestions,
              isSource: false,
              colorScheme: colorScheme,
            ),
          ),
      ],
    );
  }

  Widget _buildSuggestionsOverlay({
    required List<PlaceSuggestion> suggestions,
    required bool isSource,
    required ColorScheme colorScheme,
  }) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      color: colorScheme.surface,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 240),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: suggestions.length,
          separatorBuilder: (_, __) =>
              Divider(height: 1, color: colorScheme.outlineVariant),
          itemBuilder: (context, index) {
            final suggestion = suggestions[index];
            return ListTile(
              dense: true,
              leading: Icon(
                Icons.location_on,
                size: 18,
                color: colorScheme.primary,
              ),
              title: Text(
                suggestion.displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
              onTap: () => _selectSuggestion(isSource, suggestion),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRouteMap(ColorScheme colorScheme) {
    if (_routeResult == null) return const SizedBox.shrink();

    final route = _routeResult!.route;
    final bounds = _calculateBounds(route.geometry);

    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: bounds.center,
          initialZoom: _calculateZoom(bounds),
          interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.evconnect.india',
          ),
          PolylineLayer(
            polylines: [
              Polyline(
                points: route.geometry,
                color: colorScheme.primary,
                strokeWidth: 4,
              ),
            ],
          ),
          MarkerLayer(
            markers: [
              if (route.geometry.isNotEmpty) ...[
                Marker(
                  point: route.geometry.first,
                  width: 32,
                  height: 32,
                  child: const Icon(Icons.trip_origin, color: Colors.green, size: 32),
                ),
                Marker(
                  point: route.geometry.last,
                  width: 32,
                  height: 32,
                  child: const Icon(Icons.location_on, color: Colors.red, size: 32),
                ),
              ],
              ..._routeResult!.chargingStops.map((stop) => Marker(
                    point: LatLng(stop.station.latitude, stop.station.longitude),
                    width: 28,
                    height: 28,
                    child: const Icon(Icons.ev_station, color: Colors.orange, size: 28),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  _Bounds _calculateBounds(List<LatLng> points) {
    double minLat = double.infinity, maxLat = double.negativeInfinity;
    double minLng = double.infinity, maxLng = double.negativeInfinity;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    final center = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
    return _Bounds(center: center, latSpan: maxLat - minLat, lngSpan: maxLng - minLng);
  }

  double _calculateZoom(_Bounds bounds) {
    final latZoom = bounds.latSpan > 0 ? log(180 / bounds.latSpan) / ln2 : 10.0;
    final lngZoom = bounds.lngSpan > 0 ? log(360 / bounds.lngSpan) / ln2 : 10.0;
    return (latZoom < lngZoom ? latZoom : lngZoom).clamp(5.0, 14.0);
  }

  Widget _buildRouteInfoCards(ColorScheme colorScheme) {
    if (_routeResult == null) return const SizedBox.shrink();
    final route = _routeResult!.route;

    final hours = route.durationMinutes ~/ 60;
    final mins = route.durationMinutes % 60;
    final timeStr =
        hours > 0 ? '${hours}h ${mins.toInt()}m' : '${mins.toInt()}m';

    return Row(
      children: [
        _RouteInfoCard(
          icon: Icons.straighten,
          label: 'Distance',
          value: '${route.distanceKm.toStringAsFixed(1)} km',
          colorScheme: colorScheme,
        ),
        const SizedBox(width: 12),
        _RouteInfoCard(
          icon: Icons.timer,
          label: 'Travel Time',
          value: timeStr,
          colorScheme: colorScheme,
        ),
        const SizedBox(width: 12),
        _RouteInfoCard(
          icon: Icons.battery_charging_full,
          label: 'Battery Used',
          value: '${_routeResult!.batteryUsedPercent.toStringAsFixed(0)}%',
          colorScheme: colorScheme,
        ),
      ],
    );
  }
}

class _Bounds {
  final LatLng center;
  final double latSpan;
  final double lngSpan;
  const _Bounds({
    required this.center,
    required this.latSpan,
    required this.lngSpan,
  });
}

class _RouteInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme colorScheme;

  const _RouteInfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChargingStopCard extends StatelessWidget {
  final Station station;
  final int stopNumber;
  final double distanceKm;
  final double detourKm;
  final ColorScheme colorScheme;
  final ThemeData theme;

  const _ChargingStopCard({
    required this.station,
    required this.stopNumber,
    required this.distanceKm,
    required this.detourKm,
    required this.colorScheme,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$stopNumber',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station.name,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  station.address,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.ev_station, size: 14, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      '${station.connectors.length} connectors',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.bolt, size: 14, color: colorScheme.primary),
                    const SizedBox(width: 4),
                    Text(
                      station.connectors.isNotEmpty
                          ? '${station.connectors.first.powerKw.toInt()}kW'
                          : '',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    if (detourKm > 0) ...[
                      const SizedBox(width: 12),
                      Icon(Icons.sync_alt, size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        '${detourKm.toStringAsFixed(1)} km detour',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: Colors.orange),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
