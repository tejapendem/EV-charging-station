import 'package:ev_connect_india/config/app_config.dart';
import 'package:ev_connect_india/config/routes.dart';
import 'package:ev_connect_india/features/map/map_bottom_sheet.dart';
import 'package:ev_connect_india/models/station.dart';
import 'package:ev_connect_india/providers/location_provider.dart';
import 'package:ev_connect_india/providers/station_provider.dart';
import 'package:ev_connect_india/services/station_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  Station? _selectedStation;
  Station? _focusedStation;
  List<Map<String, dynamic>> _externalChargers = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final extra = GoRouterState.of(context).extra;
      if (extra is Station) {
        setState(() {
          _focusedStation = extra;
          _selectedStation = extra;
        });
        _mapController.move(
          LatLng(extra.latitude, extra.longitude),
          16.0,
        );
      }
    });
    _loadExternalChargers();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadExternalChargers() async {
    final location = ref.read(locationProvider);
    if (location.status == LocationStatus.loaded) {
      final chargers = await StationService().getExternalChargers(
        latitude: location.latitude,
        longitude: location.longitude,
      );
      if (mounted) setState(() => _externalChargers = chargers);
    }
  }

  void _onStationMarkerTap(Station station) {
    debugPrint('MapScreen: marker tapped');
    setState(() => _selectedStation = station);
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    debugPrint('MapScreen: map tapped');
    setState(() => _selectedStation = null);
  }

  void _centerOnUserLocation() {
    debugPrint('MapScreen: center on user location');
    final location = ref.read(locationProvider);
    if (location.status == LocationStatus.loaded) {
      _mapController.move(
        LatLng(location.latitude, location.longitude),
        15.0,
      );
      _loadExternalChargers();
    } else {
      ref.read(locationProvider.notifier).getCurrentLocation().then((_) {
        final updated = ref.read(locationProvider);
        if (updated.status == LocationStatus.loaded) {
          _mapController.move(
            LatLng(updated.latitude, updated.longitude),
            15.0,
          );
          _loadExternalChargers();
        } else {
          _mapController.move(
            LatLng(AppConfig.defaultLatitude, AppConfig.defaultLongitude),
            5.0,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stationsState = ref.watch(stationListProvider);
    final stations = stationsState.stations;
    final locationState = ref.watch(locationProvider);

    return Scaffold(
      body: Stack(
        children: [
          if (stationsState.status == StationListStatus.loading && stations.isEmpty)
            const Center(child: CircularProgressIndicator())
          else if (stationsState.status == StationListStatus.error)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 64, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Failed to load map', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () => ref.read(stationListProvider.notifier).loadStations(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(
                  AppConfig.defaultLatitude,
                  AppConfig.defaultLongitude,
                ),
                initialZoom: 5.0,
                onTap: _onMapTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: AppConfig.packageName,
                ),
                MarkerLayer(
                  markers: [
                    if (locationState.status == LocationStatus.loaded)
                      Marker(
                        point: LatLng(locationState.latitude, locationState.longitude),
                        width: 30,
                        height: 30,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.withValues(alpha: 0.3),
                            border: Border.all(color: Colors.blue, width: 3),
                          ),
                          child: const Icon(Icons.my_location, color: Colors.blue, size: 16),
                        ),
                      ),
                    ..._externalChargers.map((charger) {
                      return Marker(
                        point: LatLng(
                          (charger['latitude'] as num).toDouble(),
                          (charger['longitude'] as num).toDouble(),
                        ),
                        width: 36,
                        height: 36,
                        child: Icon(
                          Icons.ev_station,
                          color: Colors.orange,
                          size: 28,
                        ),
                      );
                    }),
                    ...stations.map((station) {
                      return Marker(
                        point: LatLng(station.latitude, station.longitude),
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () => _onStationMarkerTap(station),
                          child: Icon(
                            _selectedStation?.id == station.id
                                ? Icons.ev_station
                                : Icons.ev_station_outlined,
                            color: _selectedStation?.id == station.id
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                            size: 32,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          if (stationsState.status != StationListStatus.loading &&
              stationsState.status != StationListStatus.error)
            ..._buildOverlayButtons(colorScheme),
          if (_selectedStation != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MapBottomSheet(
                station: _selectedStation!,
                onNavigate: () {},
                onViewDetails: () =>
                    context.push(Routes.stationDetails(_selectedStation!.id)),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildOverlayButtons(ColorScheme colorScheme) {
    return [
      Positioned(
        left: 16,
        top: MediaQuery.of(context).padding.top + 8,
        child: SafeArea(
          child: Column(
            children: [
              _MapOverlayButton(icon: Icons.search, onTap: () => context.push(Routes.search)),
              const SizedBox(height: 8),
              _MapOverlayButton(icon: Icons.filter_list, onTap: () {}),
            ],
          ),
        ),
      ),
      Positioned(
        right: 16,
        bottom: _selectedStation != null ? 320 : 120,
        child: Column(
          children: [
            _MapOverlayButton(icon: Icons.add, onTap: () {
            debugPrint('MapScreen: add station button tapped');
            context.push(Routes.addStation);
          }),
            const SizedBox(height: 8),
            _MapOverlayButton(icon: Icons.my_location, onTap: _centerOnUserLocation),
          ],
        ),
      ),
    ];
  }
}

class _MapOverlayButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapOverlayButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: colorScheme.onSurface),
      ),
    );
  }
}
