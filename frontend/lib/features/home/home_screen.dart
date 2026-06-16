import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ev_connect_india/providers/station_provider.dart';
import 'package:ev_connect_india/providers/location_provider.dart';
import 'package:ev_connect_india/providers/favorites_provider.dart';
import 'package:ev_connect_india/config/routes.dart';
import 'package:ev_connect_india/models/station.dart';
import 'package:ev_connect_india/widgets/skeleton_loader.dart';
import 'package:ev_connect_india/widgets/station_card.dart';
import 'package:ev_connect_india/widgets/empty_state.dart';
import 'package:ev_connect_india/widgets/error_state.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _selectedFilter = ValueNotifier<String>('nearby');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final location = ref.read(locationProvider);
      ref.read(stationListProvider.notifier).loadStations();
    });
  }

  @override
  void dispose() {
    _selectedFilter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stationsState = ref.watch(stationListProvider);
    final location = ref.watch(locationProvider);
    final favoritesState = ref.watch(favoritesProvider);
    final stations = stationsState.stations;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.read(stationListProvider.notifier).refresh(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: false,
              snap: true,
              backgroundColor: colorScheme.surface,
              surfaceTintColor: colorScheme.surfaceTint,
              title: GestureDetector(
                onTap: () => context.push(Routes.search),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 20, color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Text('Search stations...', style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: const Icon(Icons.route),
                    onPressed: () => context.push(Routes.routePlanner),
                    tooltip: 'Route Planner',
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: colorScheme.primaryContainer,
                    child: IconButton(
                      icon: Icon(Icons.person, size: 18, color: colorScheme.onPrimaryContainer),
                      onPressed: () => context.push(Routes.profile),
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: colorScheme.primary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            location.address ?? 'Fetching location...',
                            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Welcome back!', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 40,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _FilterChip(label: 'Nearby', icon: Icons.near_me, selected: _selectedFilter.value == 'nearby', onTap: () => _selectedFilter.value = 'nearby'),
                          _FilterChip(label: 'Fast Chargers', icon: Icons.bolt, selected: _selectedFilter.value == 'fast', onTap: () => _selectedFilter.value = 'fast'),
                          _FilterChip(label: 'Open Now', icon: Icons.schedule, selected: _selectedFilter.value == 'open', onTap: () => _selectedFilter.value = 'open'),
                          _FilterChip(label: 'Favorites', icon: Icons.favorite, selected: _selectedFilter.value == 'favorites', onTap: () => _selectedFilter.value = 'favorites'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (stationsState.status == StationListStatus.loading && stations.isEmpty)
              const SliverFillRemaining(child: _HomeSkeleton())
            else if (stationsState.status == StationListStatus.error)
              SliverFillRemaining(
                child: ErrorState(message: stationsState.error ?? 'Failed to load stations', onRetry: () => ref.read(stationListProvider.notifier).loadStations()),
              )
            else if (stations.isEmpty)
              const SliverFillRemaining(
                child: EmptyState(icon: Icons.ev_station, title: 'No stations found', subtitle: 'Try adjusting your search filters'),
              )
            else
              SliverToBoxAdapter(
                child: ListenableBuilder(
                  listenable: _selectedFilter,
                  builder: (context, _) {
                    final filter = _selectedFilter.value;
                    final fastStations = stations.where((s) => s.connectors.any((c) => c.powerKw >= 50)).toList();
                    final favoriteStations = stations.where((s) => favoritesState.isFavorite(s.id)).toList();

                    if (filter == 'fast') {
                      return _buildStationSection(title: 'Fast Chargers', stationList: fastStations, favState: favoritesState);
                    }
                    if (filter == 'favorites') {
                      return _buildStationSection(title: 'Favorites', stationList: favoriteStations, favState: favoritesState);
                    }
                    if (filter == 'open') {
                      return _buildStationSection(title: 'Open Now', stationList: stations, favState: favoritesState);
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionHeader(title: 'Nearby Stations', onSeeAll: () => context.push(Routes.search, extra: {'filter': 'nearby'})),
                        _buildStationRow(stations: stations.take(5).toList(), favState: favoritesState),
                        _SectionHeader(title: 'Fast Chargers', onSeeAll: () => context.push(Routes.search, extra: {'filter': 'fast'})),
                        _buildStationRow(stations: fastStations.take(5).toList(), favState: favoritesState),
                        _SectionHeader(title: 'Recently Viewed', onSeeAll: null),
                        _buildStationRow(stations: stations.take(5).toList(), favState: favoritesState),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationSection({required String title, required List<Station> stationList, required FavoritesState favState}) {
    if (stationList.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: title, onSeeAll: null),
        _buildStationRow(stations: stationList.take(5).toList(), favState: favState),
      ],
    );
  }

  Widget _buildStationRow({required List<Station> stations, required FavoritesState favState}) {
    if (stations.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16, right: 8, bottom: 16),
        itemCount: stations.length,
        itemBuilder: (context, index) {
          final s = stations[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SizedBox(
              width: 280,
              child: StationCard(
                station: s,
                isFavorite: favState.isFavorite(s.id),
                onTap: () => context.push(Routes.map, extra: s),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        selectedColor: colorScheme.primaryContainer,
        checkmarkColor: colorScheme.onPrimaryContainer,
        side: BorderSide(color: selected ? colorScheme.primaryContainer : colorScheme.outline),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;

  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          if (onSeeAll != null) TextButton(onPressed: onSeeAll, child: const Text('See All')),
        ],
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SkeletonLoader(width: 200, height: 20),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SkeletonLoader(width: double.infinity, height: 44),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SkeletonLoader(width: 140, height: 20),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16, right: 8),
              itemCount: 3,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(width: 280, child: SkeletonLoader(width: 280, height: 240)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
