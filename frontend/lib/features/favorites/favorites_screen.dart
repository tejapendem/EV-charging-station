import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ev_connect_india/providers/favorites_provider.dart';
import 'package:ev_connect_india/providers/station_provider.dart';
import 'package:ev_connect_india/config/routes.dart';
import 'package:ev_connect_india/widgets/station_card.dart';
import 'package:ev_connect_india/widgets/empty_state.dart';
import 'package:ev_connect_india/widgets/skeleton_loader.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  String? _selectedList;
  final _lists = <String>['All Favorites'];

  void _showCreateListDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New List'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'e.g., Hyderabad Chargers', border: OutlineInputBorder()),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _lists.add(controller.text.trim());
                  _selectedList = controller.text.trim();
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final favoritesState = ref.watch(favoritesProvider);
    final stationsState = ref.watch(stationListProvider);
    final stations = stationsState.stations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Stations'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _showCreateListDialog, tooltip: 'Create List'),
        ],
      ),
      body: Column(
        children: [
          if (_lists.length > 1)
            Container(
              height: 48,
              margin: const EdgeInsets.only(top: 4),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _lists.length,
                itemBuilder: (context, index) {
                  final list = _lists[index];
                  final selected = _selectedList == list || (_selectedList == null && index == 0);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(list),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedList = list),
                      selectedColor: colorScheme.primaryContainer,
                      checkmarkColor: colorScheme.onPrimaryContainer,
                    ),
                  );
                },
              ),
            ),
          Expanded(
            child: favoritesState.status == FavoritesStatus.loading && favoritesState.favorites.isEmpty
                ? const _FavoritesSkeleton()
                : favoritesState.status == FavoritesStatus.error
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error, size: 48, color: colorScheme.error),
                            const SizedBox(height: 16),
                            Text('Failed to load favorites'),
                            const SizedBox(height: 8),
                            FilledButton(onPressed: () => ref.read(favoritesProvider.notifier).loadFavorites(), child: const Text('Retry')),
                          ],
                        ),
                      )
                    : favoritesState.favorites.isEmpty
                        ? EmptyState(
                            icon: Icons.favorite_border,
                            title: 'No saved stations',
                            subtitle: 'Save stations you love for quick access',
                            actionLabel: 'Find Stations',
                            onAction: () => context.push(Routes.search),
                          )
                        : RefreshIndicator(
                            onRefresh: () => ref.read(favoritesProvider.notifier).refresh(),
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: favoritesState.favorites.length,
                              itemBuilder: (context, index) {
                                final station = favoritesState.favorites[index];
                                return Dismissible(
                                  key: Key(station.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(color: colorScheme.error, borderRadius: BorderRadius.circular(12)),
                                    child: Icon(Icons.delete_outline, color: colorScheme.onError),
                                  ),
                                  onDismissed: (_) {
                                    ref.read(favoritesProvider.notifier).toggleFavorite(station.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${station.name} removed'),
                                        action: SnackBarAction(
                                          label: 'Undo',
                                          onPressed: () => ref.read(favoritesProvider.notifier).toggleFavorite(station.id),
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: StationCard(
                                      station: station,
                                      isFavorite: true,
                                      onTap: () => context.push(Routes.stationDetails(station.id)),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}

class _FavoritesSkeleton extends StatelessWidget {
  const _FavoritesSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SkeletonLoader(width: double.infinity, height: 180),
      ),
    );
  }
}
