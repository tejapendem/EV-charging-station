import 'package:ev_connect_india/providers/station_provider.dart';
import 'package:ev_connect_india/theme/color_schemes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SearchBarWidget extends ConsumerStatefulWidget {
  final bool autoFocus;
  final VoidCallback? onFilterTap;

  const SearchBarWidget({
    super.key,
    this.autoFocus = false,
    this.onFilterTap,
  });

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.autoFocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    ref.read(searchQueryProvider.notifier).state = query;
    ref.read(stationListProvider.notifier).setSearchQuery(query);
  }

  void _clearSearch() {
    _searchController.clear();
    _focusNode.unfocus();
    _onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filters = ref.watch(stationFilterProvider);
    final filterCount = filters.activeFilterCount;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              onChanged: _onSearch,
              onSubmitted: _onSearch,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search stations, locations...',
                prefixIcon: const Icon(Icons.search, size: 22),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: _clearSearch,
                        icon: const Icon(Icons.clear, size: 20),
                      )
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: theme.textTheme.bodyLarge,
            ),
          ),
          const SizedBox(width: 8),
          Stack(
            children: [
              IconButton(
                onPressed: widget.onFilterTap ??
                    () {
                      context.push('/search');
                    },
                icon: const Icon(Icons.tune, size: 24),
                style: IconButton.styleFrom(
                  backgroundColor: filterCount > 0
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceVariant.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (filterCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: EVColorSchemes.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$filterCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class SearchSuggestionTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const SearchSuggestionTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.location_on_outlined,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
      title: Text(title, style: theme.textTheme.bodyLarge),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      onTap: onTap,
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    );
  }
}

class RecentSearchTile extends StatelessWidget {
  final String query;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const RecentSearchTile({
    super.key,
    required this.query,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: const Icon(Icons.history, size: 20),
      title: Text(query, style: theme.textTheme.bodyMedium),
      onTap: onTap,
      trailing: IconButton(
        onPressed: onDelete,
        icon: const Icon(Icons.close, size: 18),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }
}
