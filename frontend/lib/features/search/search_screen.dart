import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ev_connect_india/providers/station_provider.dart';
import 'package:ev_connect_india/config/routes.dart';
import 'package:ev_connect_india/models/station.dart';
import 'package:ev_connect_india/widgets/station_card.dart';
import 'package:ev_connect_india/widgets/empty_state.dart';
import 'package:ev_connect_india/widgets/skeleton_loader.dart';
import 'package:ev_connect_india/widgets/error_state.dart';
import 'package:ev_connect_india/features/search/filter_bottom_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  final List<String> _recentSearches = ['Hyderabad', 'Mumbai-Pune Highway', 'CCS2 Charger', '500034'];

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(stationListProvider.notifier).setSearchQuery(query);
    });
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const FilterBottomSheet(),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(stationListProvider.notifier).setSearchQuery('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final stationsState = ref.watch(stationListProvider);
    final stations = stationsState.stations;
    final isLoading = stationsState.status == StationListStatus.loading;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      onChanged: _onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Search stations, city, pincode...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(icon: const Icon(Icons.clear), onPressed: _clearSearch)
                            : null,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: _showFilters,
                    style: IconButton.styleFrom(backgroundColor: colorScheme.secondaryContainer),
                  ),
                ],
              ),
            ),
            if (_searchController.text.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recent Searches', style: theme.textTheme.titleSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                        TextButton(onPressed: () {}, child: const Text('Clear All')),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _recentSearches.map((search) {
                        return ActionChip(
                          avatar: const Icon(Icons.history, size: 16),
                          label: Text(search),
                          onPressed: () {
                            _searchController.text = search;
                            _onSearchChanged(search);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text('Search by', style: theme.textTheme.titleSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: [
                        _SearchHintChip(icon: Icons.ev_station, label: 'Station Name', onTap: () { _searchController.text = 'Tata Power '; _onSearchChanged(_searchController.text); }),
                        _SearchHintChip(icon: Icons.location_city, label: 'City', onTap: () { _searchController.text = 'Hyderabad '; _onSearchChanged(_searchController.text); }),
                        _SearchHintChip(icon: Icons.route, label: 'Highway', onTap: () { _searchController.text = 'NH-44 '; _onSearchChanged(_searchController.text); }),
                        _SearchHintChip(icon: Icons.pin_drop, label: 'Pincode', onTap: () { _searchController.text = '5000'; _onSearchChanged(_searchController.text); }),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 8),
            Expanded(
              child: isLoading && stations.isEmpty
                  ? const _SearchSkeleton()
                  : stationsState.status == StationListStatus.error
                      ? ErrorState(message: stationsState.error ?? 'Error', onRetry: () => ref.read(stationListProvider.notifier).loadStations())
                      : stations.isEmpty
                          ? const EmptyState(icon: Icons.search_off, title: 'No stations found', subtitle: 'Try a different search term')
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: stations.length,
                              itemBuilder: (context, index) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: StationCard(
                                  station: stations[index],
                                  onTap: () => context.push(Routes.stationDetails(stations[index].id)),
                                ),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchHintChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SearchHintChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(avatar: Icon(icon, size: 16), label: Text(label), onPressed: onTap);
  }
}

class _SearchSkeleton extends StatelessWidget {
  const _SearchSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SkeletonLoader(width: double.infinity, height: 180),
      ),
    );
  }
}
